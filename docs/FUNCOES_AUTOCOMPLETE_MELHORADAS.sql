-- Funções SQL melhoradas para autocomplete mais flexível
-- Execute este script no Supabase SQL Editor

-- 1. Criar tabelas se não existirem
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

-- 2. Função para normalizar texto (remove acentos, converte para minúsculo)
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
$$ LANGUAGE plpgsql;

-- 3. Função para calcular similaridade entre strings
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
$$ LANGUAGE plpgsql;

-- 4. Função melhorada para buscar cidades
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

-- 5. Função melhorada para buscar setores
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

-- 6. Função para inserir/atualizar cidade
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

-- 7. Função para inserir/atualizar setor
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

-- 8. Inserir municípios de Goiás (exemplos principais)
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

-- 9. Inserir setores comuns em Goiânia
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

-- 10. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_cities_name_normalized ON cities (normalize_text(name));
CREATE INDEX IF NOT EXISTS idx_sectors_name_normalized ON sectors (normalize_text(name));
CREATE INDEX IF NOT EXISTS idx_users_city_normalized ON users (normalize_text(city));
CREATE INDEX IF NOT EXISTS idx_users_sector_normalized ON users (normalize_text(sector));

-- 11. Habilitar RLS
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE sectors ENABLE ROW LEVEL SECURITY;

-- 12. Criar políticas RLS
CREATE POLICY "Allow all to read cities" ON cities FOR SELECT USING (true);
CREATE POLICY "Allow all to insert cities" ON cities FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all to read sectors" ON sectors FOR SELECT USING (true);
CREATE POLICY "Allow all to insert sectors" ON sectors FOR INSERT WITH CHECK (true);

-- 13. Criar triggers para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cities_updated_at BEFORE UPDATE ON cities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sectors_updated_at BEFORE UPDATE ON sectors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
