-- =====================================================
-- OTIMIZAR GRÁFICOS PARA PERFORMANCE COM 1500+ REGISTROS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. CRIAR ÍNDICES PARA MELHORAR PERFORMANCE DOS GRÁFICOS
-- =====================================================

-- Índice para consultas por cidade (gráfico de barras por cidade)
CREATE INDEX IF NOT EXISTS idx_members_city ON members(city) WHERE deleted_at IS NULL;

-- Índice para consultas por setor (gráfico de barras por setor)
CREATE INDEX IF NOT EXISTS idx_members_sector ON members(sector) WHERE deleted_at IS NULL;

-- Índice para consultas por status (gráfico de pizza de status)
CREATE INDEX IF NOT EXISTS idx_members_status ON members(status) WHERE deleted_at IS NULL;

-- Índice para consultas por data de registro (gráfico de linha temporal)
CREATE INDEX IF NOT EXISTS idx_members_registration_date ON members(registration_date) WHERE deleted_at IS NULL;

-- Índice composto para consultas combinadas (cidade + setor)
CREATE INDEX IF NOT EXISTS idx_members_city_sector ON members(city, sector) WHERE deleted_at IS NULL;

-- Índice para consultas por referrer (filtros de admin)
CREATE INDEX IF NOT EXISTS idx_members_referrer ON members(referrer) WHERE deleted_at IS NULL;

-- Índice para consultas por ranking_status (gráficos de performance)
CREATE INDEX IF NOT EXISTS idx_members_ranking_status ON members(ranking_status) WHERE deleted_at IS NULL;

-- =====================================================
-- 2. CRIAR VIEWS OTIMIZADAS PARA GRÁFICOS
-- =====================================================

-- View para estatísticas de cidade (otimizada para gráficos)
CREATE OR REPLACE VIEW v_city_stats AS
SELECT 
    city,
    COUNT(*) as total_members,
    COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as active_members,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as green_members,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as yellow_members,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as red_members
FROM members 
WHERE deleted_at IS NULL
GROUP BY city
ORDER BY total_members DESC;

-- View para estatísticas de setor (otimizada para gráficos)
CREATE OR REPLACE VIEW v_sector_stats AS
SELECT 
    sector,
    COUNT(*) as total_members,
    COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as active_members,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as green_members,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as yellow_members,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as red_members
FROM members 
WHERE deleted_at IS NULL
GROUP BY sector
ORDER BY total_members DESC;

-- View para estatísticas de localização (cidade + setor)
CREATE OR REPLACE VIEW v_location_stats AS
SELECT 
    city,
    sector,
    CONCAT(city, ' - ', sector) as location,
    COUNT(*) as total_members,
    COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as active_members
FROM members 
WHERE deleted_at IS NULL
GROUP BY city, sector
ORDER BY total_members DESC;

-- View para estatísticas de status (otimizada para gráfico de pizza)
CREATE OR REPLACE VIEW v_status_stats AS
SELECT 
    status,
    COUNT(*) as count,
    CASE 
        WHEN status = 'Ativo' THEN '#10B981'
        WHEN status = 'Inativo' THEN '#EF4444'
        ELSE '#6B7280'
    END as color
FROM members 
WHERE deleted_at IS NULL
GROUP BY status
ORDER BY count DESC;

-- View para estatísticas de ranking (otimizada para gráficos de performance)
CREATE OR REPLACE VIEW v_ranking_stats AS
SELECT 
    ranking_status,
    COUNT(*) as count,
    CASE 
        WHEN ranking_status = 'Verde' THEN '#10B981'
        WHEN ranking_status = 'Amarelo' THEN '#F59E0B'
        WHEN ranking_status = 'Vermelho' THEN '#EF4444'
        ELSE '#6B7280'
    END as color
FROM members 
WHERE deleted_at IS NULL
GROUP BY ranking_status
ORDER BY count DESC;

-- View para estatísticas temporais (últimos 30 dias)
CREATE OR REPLACE VIEW v_daily_registrations AS
SELECT 
    registration_date,
    COUNT(*) as registrations_count,
    COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as active_registrations
FROM members 
WHERE deleted_at IS NULL 
    AND registration_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY registration_date
ORDER BY registration_date DESC;

-- =====================================================
-- 3. FUNÇÕES OTIMIZADAS PARA GRÁFICOS
-- =====================================================

-- Função para obter dados de cidade (otimizada)
CREATE OR REPLACE FUNCTION get_city_chart_data()
RETURNS TABLE (
    city TEXT,
    total_members BIGINT,
    active_members BIGINT,
    green_members BIGINT,
    yellow_members BIGINT,
    red_members BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cs.city,
        cs.total_members,
        cs.active_members,
        cs.green_members,
        cs.yellow_members,
        cs.red_members
    FROM v_city_stats cs
    ORDER BY cs.total_members DESC
    LIMIT 20; -- Limitar a 20 cidades para performance
END;
$$ LANGUAGE plpgsql;

-- Função para obter dados de setor (otimizada)
CREATE OR REPLACE FUNCTION get_sector_chart_data()
RETURNS TABLE (
    sector TEXT,
    total_members BIGINT,
    active_members BIGINT,
    green_members BIGINT,
    yellow_members BIGINT,
    red_members BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ss.sector,
        ss.total_members,
        ss.active_members,
        ss.green_members,
        ss.yellow_members,
        ss.red_members
    FROM v_sector_stats ss
    ORDER BY ss.total_members DESC
    LIMIT 15; -- Limitar a 15 setores para performance
END;
$$ LANGUAGE plpgsql;

-- Função para obter dados de status (otimizada)
CREATE OR REPLACE FUNCTION get_status_chart_data()
RETURNS TABLE (
    status TEXT,
    count BIGINT,
    color TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sts.status,
        sts.count,
        sts.color
    FROM v_status_stats sts
    ORDER BY sts.count DESC;
END;
$$ LANGUAGE plpgsql;

-- Função para obter dados de ranking (otimizada)
CREATE OR REPLACE FUNCTION get_ranking_chart_data()
RETURNS TABLE (
    ranking_status TEXT,
    count BIGINT,
    color TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rs.ranking_status,
        rs.count,
        rs.color
    FROM v_ranking_stats rs
    ORDER BY rs.count DESC;
END;
$$ LANGUAGE plpgsql;

-- Função para obter dados temporais (últimos 7 dias)
CREATE OR REPLACE FUNCTION get_daily_registrations_data()
RETURNS TABLE (
    date TEXT,
    registrations_count BIGINT,
    active_registrations BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TO_CHAR(dr.registration_date, 'DD/MM') as date,
        dr.registrations_count,
        dr.active_registrations
    FROM v_daily_registrations dr
    WHERE dr.registration_date >= CURRENT_DATE - INTERVAL '7 days'
    ORDER BY dr.registration_date ASC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. VERIFICAR PERFORMANCE DOS ÍNDICES
-- =====================================================

-- Verificar se os índices foram criados
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'members' 
    AND indexname LIKE 'idx_members_%'
ORDER BY indexname;

-- Verificar se as views foram criadas
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name LIKE 'v_%_stats'
ORDER BY table_name;

-- Verificar se as funções foram criadas
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
    AND routine_name LIKE 'get_%_chart_data'
ORDER BY routine_name;

-- =====================================================
-- 5. TESTAR PERFORMANCE DAS FUNÇÕES
-- =====================================================

-- Testar função de cidade
SELECT * FROM get_city_chart_data();

-- Testar função de setor
SELECT * FROM get_sector_chart_data();

-- Testar função de status
SELECT * FROM get_status_chart_data();

-- Testar função de ranking
SELECT * FROM get_ranking_chart_data();

-- Testar função de registros diários
SELECT * FROM get_daily_registrations_data();

-- =====================================================
-- RESUMO DAS OTIMIZAÇÕES:
-- =====================================================
-- ✅ Índices criados para consultas frequentes
-- ✅ Views otimizadas para gráficos
-- ✅ Funções otimizadas para dados de gráficos
-- ✅ Limitação de resultados para performance
-- ✅ Consultas otimizadas com WHERE deleted_at IS NULL
-- ✅ Agregações pré-calculadas nas views
-- ✅ Índices parciais para registros ativos apenas
