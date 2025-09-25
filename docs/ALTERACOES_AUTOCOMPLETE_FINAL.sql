-- ALTERAÇÕES PARA MELHORAR O AUTOCOMPLETE (VERSÃO FINAL)
-- Execute apenas estas alterações no Supabase SQL Editor

-- 1. Remover funções antigas primeiro (se existirem)
DROP FUNCTION IF EXISTS search_cities(text);
DROP FUNCTION IF EXISTS search_sectors(text, text);
DROP FUNCTION IF EXISTS upsert_city(text);
DROP FUNCTION IF EXISTS upsert_sector(text, text);
DROP FUNCTION IF EXISTS normalize_text(text);
DROP FUNCTION IF EXISTS calculate_similarity(text, text);

-- 2. Criar tabelas se não existirem (caso não tenham sido criadas ainda)
CREATE TABLE IF NOT EXISTS cities (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  state VARCHAR(2) DEFAULT 'GO',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sectors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  city_id INTEGER REFERENCES cities(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(name, city_id)
);

-- 3. Função para normalizar texto (marcada como IMMUTABLE)
CREATE OR REPLACE FUNCTION normalize_text(input_text TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN LOWER(
    TRANSLATE(
      input_text,
      'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ',
      'AAAAAAACEEEEIIIIDNOOOOOOUUUUYBSaaaaaaaceeeeiiiidnoooooouuuuyby'
    )
  );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 4. Função para calcular similaridade entre strings (marcada como IMMUTABLE)
CREATE OR REPLACE FUNCTION calculate_similarity(str1 TEXT, str2 TEXT)
RETURNS FLOAT AS $$
DECLARE
  normalized1 TEXT;
  normalized2 TEXT;
  similarity FLOAT;
BEGIN
  normalized1 := normalize_text(str1);
  normalized2 := normalize_text(str2);
  
  -- Se são exatamente iguais após normalização
  IF normalized1 = normalized2 THEN
    RETURN 1.0;
  END IF;
  
  -- Se uma contém a outra
  IF normalized1 LIKE '%' || normalized2 || '%' OR normalized2 LIKE '%' || normalized1 || '%' THEN
    RETURN 0.8;
  END IF;
  
  -- Calcular similaridade usando algoritmo simples
  similarity := (
    LENGTH(normalized1) + LENGTH(normalized2) - 
    LENGTH(REPLACE(normalized1, normalized2, '')) - 
    LENGTH(REPLACE(normalized2, normalized1, ''))
  ) / GREATEST(LENGTH(normalized1), LENGTH(normalized2));
  
  RETURN GREATEST(0, similarity);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 5. Função melhorada para buscar cidades
CREATE OR REPLACE FUNCTION search_cities(search_term TEXT)
RETURNS TABLE(
  id INTEGER,
  name VARCHAR(255),
  usage_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    COALESCE(COUNT(u.id), 0) as usage_count
  FROM cities c
  LEFT JOIN users u ON normalize_text(u.city) = normalize_text(c.name)
  WHERE 
    c.state = 'GO' AND (
      -- Busca exata
      normalize_text(c.name) = normalize_text(search_term) OR
      -- Busca que contém o termo
      normalize_text(c.name) LIKE '%' || normalize_text(search_term) || '%' OR
      -- Busca que o termo contém
      normalize_text(search_term) LIKE '%' || normalize_text(c.name) || '%' OR
      -- Busca por similaridade (mínimo 60%)
      calculate_similarity(c.name, search_term) > 0.6
    )
  GROUP BY c.id, c.name
  ORDER BY 
    -- Priorizar correspondências exatas
    CASE WHEN normalize_text(c.name) = normalize_text(search_term) THEN 1 ELSE 2 END,
    -- Depois por similaridade
    calculate_similarity(c.name, search_term) DESC,
    -- Por último por uso
    usage_count DESC,
    c.name
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- 6. Função melhorada para buscar setores
CREATE OR REPLACE FUNCTION search_sectors(search_term TEXT, city_name TEXT)
RETURNS TABLE(
  id INTEGER,
  name VARCHAR(255),
  usage_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    COALESCE(COUNT(u.id), 0) as usage_count
  FROM sectors s
  JOIN cities c ON s.city_id = c.id
  LEFT JOIN users u ON normalize_text(u.sector) = normalize_text(s.name) 
    AND normalize_text(u.city) = normalize_text(city_name)
  WHERE 
    normalize_text(c.name) = normalize_text(city_name) AND (
      -- Busca exata
      normalize_text(s.name) = normalize_text(search_term) OR
      -- Busca que contém o termo
      normalize_text(s.name) LIKE '%' || normalize_text(search_term) || '%' OR
      -- Busca que o termo contém
      normalize_text(search_term) LIKE '%' || normalize_text(s.name) || '%' OR
      -- Busca por similaridade (mínimo 60%)
      calculate_similarity(s.name, search_term) > 0.6
    )
  GROUP BY s.id, s.name
  ORDER BY 
    -- Priorizar correspondências exatas
    CASE WHEN normalize_text(s.name) = normalize_text(search_term) THEN 1 ELSE 2 END,
    -- Depois por similaridade
    calculate_similarity(s.name, search_term) DESC,
    -- Por último por uso
    usage_count DESC,
    s.name
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- 7. Função para inserir/atualizar cidade
CREATE OR REPLACE FUNCTION upsert_city(city_name TEXT)
RETURNS INTEGER AS $$
DECLARE
  city_id INTEGER;
BEGIN
  INSERT INTO cities (name, state) 
  VALUES (city_name, 'GO')
  ON CONFLICT (name) DO UPDATE SET
    updated_at = NOW()
  RETURNING id INTO city_id;
  
  RETURN city_id;
END;
$$ LANGUAGE plpgsql;

-- 8. Função para inserir/atualizar setor
CREATE OR REPLACE FUNCTION upsert_sector(sector_name TEXT, city_name TEXT)
RETURNS INTEGER AS $$
DECLARE
  sector_id INTEGER;
  city_id INTEGER;
BEGIN
  -- Primeiro, garantir que a cidade existe
  SELECT upsert_city(city_name) INTO city_id;
  
  -- Depois, inserir/atualizar o setor
  INSERT INTO sectors (name, city_id) 
  VALUES (sector_name, city_id)
  ON CONFLICT (name, city_id) DO UPDATE SET
    updated_at = NOW()
  RETURNING id INTO sector_id;
  
  RETURN sector_id;
END;
$$ LANGUAGE plpgsql;

-- 9. Inserir municípios principais de Goiás (apenas se não existirem)
INSERT INTO cities (name, state) VALUES 
('Goiânia', 'GO'),
('Aparecida de Goiânia', 'GO'),
('Anápolis', 'GO'),
('Rio Verde', 'GO'),
('Luziânia', 'GO'),
('Valparaíso de Goiás', 'GO'),
('Trindade', 'GO'),
('Formosa', 'GO'),
('Novo Gama', 'GO'),
('Planaltina', 'GO'),
('Santo Antônio do Descoberto', 'GO'),
('Senador Canedo', 'GO'),
('Itumbiara', 'GO'),
('Catalão', 'GO'),
('Jataí', 'GO'),
('Caldas Novas', 'GO'),
('Mineiros', 'GO'),
('Ceres', 'GO'),
('Iporá', 'GO'),
('Pirenópolis', 'GO')
ON CONFLICT (name) DO NOTHING;

-- 10. Inserir setores comuns em Goiânia (apenas se não existirem)
INSERT INTO sectors (name, city_id) VALUES 
('Setor Central', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Oeste', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Leste', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Sul', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Norte', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Bueno', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Marista', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Campinas', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Jardim América', (SELECT id FROM cities WHERE name = 'Goiânia')),
('Setor Vila Nova', (SELECT id FROM cities WHERE name = 'Goiânia'))
ON CONFLICT (name, city_id) DO NOTHING;

-- 11. Criar índices simples (sem funções para evitar problemas)
CREATE INDEX IF NOT EXISTS idx_cities_name ON cities (name);
CREATE INDEX IF NOT EXISTS idx_cities_state ON cities (state);
CREATE INDEX IF NOT EXISTS idx_sectors_name ON sectors (name);
CREATE INDEX IF NOT EXISTS idx_sectors_city_id ON sectors (city_id);

-- 12. Habilitar RLS se não estiver habilitado
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE sectors ENABLE ROW LEVEL SECURITY;

-- 13. Criar políticas RLS se não existirem
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'cities' AND policyname = 'Allow all to read cities') THEN
    CREATE POLICY "Allow all to read cities" ON cities FOR SELECT USING (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'cities' AND policyname = 'Allow all to insert cities') THEN
    CREATE POLICY "Allow all to insert cities" ON cities FOR INSERT WITH CHECK (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'sectors' AND policyname = 'Allow all to read sectors') THEN
    CREATE POLICY "Allow all to read sectors" ON sectors FOR SELECT USING (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'sectors' AND policyname = 'Allow all to insert sectors') THEN
    CREATE POLICY "Allow all to insert sectors" ON sectors FOR INSERT WITH CHECK (true);
  END IF;
END $$;
