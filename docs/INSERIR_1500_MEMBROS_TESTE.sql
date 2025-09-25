-- =====================================================
-- SCRIPT COMPLETO: 1500 MEMBROS + RELACIONAMENTOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. LIMPEZA DOS DADOS ANTIGOS (OPCIONAL)
-- =====================================================

-- Limpar dados de teste anteriores (manter apenas dados reais)
DELETE FROM user_links WHERE user_id != (SELECT id FROM auth_users WHERE username = 'admin');
DELETE FROM friends WHERE referrer != 'Admin';
DELETE FROM members WHERE name != 'Admin';
DELETE FROM auth_users WHERE username != 'admin';

-- =====================================================
-- 2. FUNÇÕES PARA GERAR DADOS REALISTAS
-- =====================================================

-- Função para gerar nomes brasileiros realistas
CREATE OR REPLACE FUNCTION generate_brazilian_name() RETURNS TEXT AS $$
DECLARE
    first_names TEXT[] := ARRAY[
        'João', 'Maria', 'José', 'Ana', 'Carlos', 'Mariana', 'Pedro', 'Julia', 'Lucas', 'Fernanda',
        'Rafael', 'Camila', 'Diego', 'Beatriz', 'Gabriel', 'Larissa', 'Felipe', 'Amanda', 'Bruno', 'Natália',
        'Rodrigo', 'Carolina', 'Thiago', 'Isabela', 'Marcos', 'Priscila', 'André', 'Renata', 'Leandro', 'Vanessa',
        'Alexandre', 'Patrícia', 'Ricardo', 'Monica', 'Eduardo', 'Cristina', 'Paulo', 'Sandra', 'Roberto', 'Márcia',
        'Antonio', 'Lucia', 'Francisco', 'Rosa', 'Manuel', 'Teresa', 'Joaquim', 'Cecilia', 'Sebastião', 'Helena',
        'Miguel', 'Inês', 'Afonso', 'Margarida', 'Henrique', 'Isabel', 'Duarte', 'Beatriz', 'Nuno', 'Leonor',
        'Gonçalo', 'Catarina', 'Diogo', 'Joana', 'Tomás', 'Filipa', 'Simão', 'Bárbara', 'Vasco', 'Mafalda',
        'Lourenço', 'Constança', 'Martim', 'Branca', 'Gil', 'Urraca', 'Álvaro', 'Sancha', 'Fernão', 'Dulce'
    ];
    last_names TEXT[] := ARRAY[
        'Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes',
        'Costa', 'Ribeiro', 'Martins', 'Carvalho', 'Almeida', 'Lopes', 'Soares', 'Fernandes', 'Vieira', 'Barbosa',
        'Rocha', 'Dias', 'Monteiro', 'Cardoso', 'Reis', 'Ramos', 'Pinto', 'Cunha', 'Moreira', 'Mendes',
        'Nunes', 'Faria', 'Machado', 'Araújo', 'Freitas', 'Melo', 'Coelho', 'Teixeira', 'Correia', 'Miranda',
        'Cavalcanti', 'Nascimento', 'Moura', 'Bezerra', 'Campos', 'Vasconcelos', 'Andrade', 'Brito', 'Siqueira', 'Castro',
        'Nogueira', 'Lima', 'Azevedo', 'Magalhães', 'Tavares', 'Bastos', 'Guimarães', 'Macedo', 'Medeiros', 'Duarte',
        'Morais', 'Cordeiro', 'Dantas', 'Coutinho', 'Leite', 'Borges', 'Antunes', 'Torres', 'Caldeira', 'Pacheco',
        'Aguiar', 'Bandeira', 'Vargas', 'Figueiredo', 'Xavier', 'Peixoto', 'Lacerda', 'Barros', 'Sales', 'Paiva',
        'Guedes', 'Mota', 'Cabral', 'Viana', 'Franco', 'Brito', 'Sampaio', 'Teles', 'Queiroz', 'Porto',
        'Vasques', 'Pinheiro', 'Fonseca', 'Menezes', 'Sá', 'Couto', 'Bento', 'Garcia', 'Marques', 'Henriques'
    ];
    first_name TEXT;
    last_name TEXT;
BEGIN
    first_name := first_names[1 + floor(random() * array_length(first_names, 1))];
    last_name := last_names[1 + floor(random() * array_length(last_names, 1))];
    RETURN first_name || ' ' || last_name;
END;
$$ LANGUAGE plpgsql;

-- Função para gerar nomes de casais
CREATE OR REPLACE FUNCTION generate_couple_name() RETURNS TEXT AS $$
DECLARE
    couple_names TEXT[] := ARRAY[
        'Maria', 'Ana', 'Julia', 'Mariana', 'Camila', 'Beatriz', 'Larissa', 'Amanda', 'Natália', 'Carolina',
        'Isabela', 'Priscila', 'Renata', 'Vanessa', 'Patrícia', 'Monica', 'Cristina', 'Sandra', 'Márcia', 'Lucia',
        'Rosa', 'Teresa', 'Cecilia', 'Helena', 'Inês', 'Margarida', 'Isabel', 'Leonor', 'Catarina', 'Joana',
        'Filipa', 'Bárbara', 'Mafalda', 'Constança', 'Branca', 'Urraca', 'Sancha', 'Dulce'
    ];
    couple_name TEXT;
BEGIN
    couple_name := couple_names[1 + floor(random() * array_length(couple_names, 1))];
    RETURN couple_name;
END;
$$ LANGUAGE plpgsql;

-- Função para gerar telefones brasileiros
CREATE OR REPLACE FUNCTION generate_brazilian_phone() RETURNS TEXT AS $$
DECLARE
    ddd TEXT[] := ARRAY['11', '21', '31', '41', '51', '61', '71', '81', '85', '62'];
    phone_digits TEXT;
    ddd_code TEXT;
BEGIN
    ddd_code := ddd[1 + floor(random() * array_length(ddd, 1))];
    phone_digits := lpad(floor(random() * 100000000)::TEXT, 8, '0');
    RETURN '(' || ddd_code || ') ' || substring(phone_digits, 1, 4) || '-' || substring(phone_digits, 5, 4);
END;
$$ LANGUAGE plpgsql;

-- Função para gerar Instagram realista
CREATE OR REPLACE FUNCTION generate_instagram() RETURNS TEXT AS $$
DECLARE
    prefixes TEXT[] := ARRAY['joao', 'maria', 'jose', 'ana', 'carlos', 'mariana', 'pedro', 'julia', 'lucas', 'fernanda'];
    suffixes TEXT[] := ARRAY['silva', 'santos', 'oliveira', 'souza', 'rodrigues', 'ferreira', 'alves', 'pereira', 'lima', 'gomes'];
    prefix TEXT;
    suffix TEXT;
    number_part TEXT;
BEGIN
    prefix := prefixes[1 + floor(random() * array_length(prefixes, 1))];
    suffix := suffixes[1 + floor(random() * array_length(suffixes, 1))];
    number_part := floor(random() * 999)::TEXT;
    RETURN '@' || prefix || suffix || number_part;
END;
$$ LANGUAGE plpgsql;

-- Função para gerar cidades brasileiras
CREATE OR REPLACE FUNCTION generate_brazilian_city() RETURNS TEXT AS $$
DECLARE
    cities TEXT[] := ARRAY[
        'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Brasília', 'Fortaleza', 'Salvador', 'Manaus', 'Curitiba', 'Recife', 'Porto Alegre',
        'Goiânia', 'Belém', 'Guarulhos', 'Campinas', 'São Luís', 'São Gonçalo', 'Maceió', 'Duque de Caxias', 'Natal', 'Teresina',
        'Campo Grande', 'Nova Iguaçu', 'São Bernardo do Campo', 'João Pessoa', 'Santo André', 'Osasco', 'Jaboatão dos Guararapes', 'São José dos Campos', 'Ribeirão Preto', 'Uberlândia',
        'Sorocaba', 'Contagem', 'Aracaju', 'Feira de Santana', 'Cuiabá', 'Joinville', 'Aparecida de Goiânia', 'Londrina', 'Niterói', 'Ananindeua',
        'Porto Velho', 'Serra', 'Caxias do Sul', 'Macapá', 'Vila Velha', 'Florianópolis', 'Mauá', 'São João de Meriti', 'Diadema', 'Carapicuíba',
        'Mogi das Cruzes', 'Campina Grande', 'Jundiaí', 'Maringá', 'Montes Claros', 'Piracicaba', 'Caruaru', 'Bauru', 'Itaquaquecetuba', 'São Vicente',
        'Franca', 'Blumenau', 'Guarujá', 'Ribeirão das Neves', 'Petrolina', 'Uberaba', 'Paulista', 'Cascavel', 'Praia Grande', 'Taubaté',
        'Limeira', 'Petrópolis', 'Camaçari', 'Palmas', 'Suzano', 'Cabo Frio', 'Foz do Iguaçu', 'Volta Redonda', 'Santa Maria', 'Novo Hamburgo',
        'Caucaia', 'Barueri', 'Várzea Grande', 'Brasiléia', 'São José de Ribamar', 'Guarulhos', 'Embu das Artes', 'Magé', 'Viamão', 'Santarém',
        'Taboão da Serra', 'Sumaré', 'Marília', 'Divinópolis', 'São Caetano do Sul', 'Americana', 'Araraquara', 'São Leopoldo', 'Jacareí', 'Rondonópolis'
    ];
BEGIN
    RETURN cities[1 + floor(random() * array_length(cities, 1))];
END;
$$ LANGUAGE plpgsql;

-- Função para gerar setores
CREATE OR REPLACE FUNCTION generate_sector() RETURNS TEXT AS $$
DECLARE
    sectors TEXT[] := ARRAY[
        'Centro', 'Zona Norte', 'Zona Sul', 'Zona Leste', 'Zona Oeste', 'Setor Central', 'Setor Norte', 'Setor Sul', 'Setor Leste', 'Setor Oeste',
        'Centro Histórico', 'Comercial', 'Residencial', 'Industrial', 'Rural', 'Subúrbio', 'Periferia', 'Bairro Alto', 'Bairro Baixo', 'Vila Nova',
        'Jardim', 'Parque', 'Conjunto', 'Condomínio', 'Loteamento', 'Fazenda', 'Sítio', 'Chácara', 'Distrito', 'Região',
        'Área', 'Quadra', 'Quadrilátero', 'Setor A', 'Setor B', 'Setor C', 'Setor D', 'Setor E', 'Setor F', 'Setor G',
        'Setor H', 'Setor I', 'Setor J', 'Setor K', 'Setor L', 'Setor M', 'Setor N', 'Setor O', 'Setor P', 'Setor Q',
        'Setor R', 'Setor S', 'Setor T', 'Setor U', 'Setor V', 'Setor W', 'Setor X', 'Setor Y', 'Setor Z', 'Setor 1',
        'Setor 2', 'Setor 3', 'Setor 4', 'Setor 5', 'Setor 6', 'Setor 7', 'Setor 8', 'Setor 9', 'Setor 10', 'Setor 11',
        'Setor 12', 'Setor 13', 'Setor 14', 'Setor 15', 'Setor 16', 'Setor 17', 'Setor 18', 'Setor 19', 'Setor 20', 'Setor 21',
        'Setor 22', 'Setor 23', 'Setor 24', 'Setor 25', 'Setor 26', 'Setor 27', 'Setor 28', 'Setor 29', 'Setor 30', 'Setor 31',
        'Setor 32', 'Setor 33', 'Setor 34', 'Setor 35', 'Setor 36', 'Setor 37', 'Setor 38', 'Setor 39', 'Setor 40', 'Setor 41'
    ];
BEGIN
    RETURN sectors[1 + floor(random() * array_length(sectors, 1))];
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. INSERIR MEMBROS COM DIFERENTES TIPOS DE CONTRATOS
-- =====================================================

DO $$
DECLARE
    i INTEGER;
    member_name TEXT;
    couple_name TEXT;
    member_phone TEXT;
    couple_phone TEXT;
    member_instagram TEXT;
    couple_instagram TEXT;
    city TEXT;
    sector TEXT;
    couple_city TEXT;
    couple_sector TEXT;
    contracts_completed INTEGER;
    ranking_status TEXT;
    ranking_position INTEGER;
    is_top_1500 BOOLEAN;
    can_be_replaced BOOLEAN;
    member_id UUID;
    auth_user_id UUID;
    link_id TEXT;
    referrer_name TEXT;
    friends_count INTEGER;
    j INTEGER;
    friend_name TEXT;
    friend_couple_name TEXT;
    friend_phone TEXT;
    friend_couple_phone TEXT;
    friend_instagram TEXT;
    friend_couple_instagram TEXT;
    friend_city TEXT;
    friend_sector TEXT;
    friend_couple_city TEXT;
    friend_couple_sector TEXT;
    friend_id UUID;
    friend_auth_user_id UUID;
BEGIN
    RAISE NOTICE '🚀 Iniciando inserção de 1500 membros com relacionamentos completos...';
    
    FOR i IN 1..1500 LOOP
        -- Gerar dados do membro
        member_name := generate_brazilian_name();
        couple_name := generate_couple_name() || ' ' || split_part(member_name, ' ', 2);
        member_phone := generate_brazilian_phone();
        couple_phone := generate_brazilian_phone();
        member_instagram := generate_instagram();
        couple_instagram := generate_instagram();
        city := generate_brazilian_city();
        sector := generate_sector();
        couple_city := city; -- Mesma cidade do membro
        couple_sector := generate_sector(); -- Setor diferente
        
        -- Definir tipo de contrato baseado no índice
        -- Todos os membros terão exatamente 15 contratos (consistente com 15 amigos)
        contracts_completed := 15;
        ranking_status := 'Verde';
        ranking_position := i;
        is_top_1500 := true;
        can_be_replaced := false;
        
        -- Definir referrer
        IF i = 1 THEN
            referrer_name := 'Admin';
        ELSE
            referrer_name := 'Membro ' || (i - 1);
        END IF;
        
        -- Inserir membro
        INSERT INTO members (
            name, phone, instagram, city, sector, referrer, registration_date, status,
            couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
            contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced,
            created_at, updated_at
        ) VALUES (
            member_name, member_phone, member_instagram, city, sector, referrer_name, 
            CURRENT_DATE - (random() * 365)::INTEGER, 'Ativo',
            couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
            contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced,
            NOW() - (random() * 365 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second',
            NOW() - (random() * 30 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second'
        ) RETURNING id INTO member_id;
        
        -- Inserir auth_user para o membro
        auth_user_id := gen_random_uuid();
        INSERT INTO auth_users (
            id, username, password, name, role, full_name, instagram, phone, is_active,
            created_at, updated_at
        ) VALUES (
            auth_user_id, 
            lower(replace(member_name, ' ', '')) || '_membro_' || i, 
            'membro123', 
            member_name, 
            'Membro', 
            member_name || ' - Membro',
            member_instagram,
            member_phone,
            true,
            NOW() - (random() * 365 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second',
            NOW() - (random() * 30 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second'
        );
        
        -- Gerar link_id único
        link_id := 'link_' || i || '_' || substring(member_id::TEXT, 1, 8);
        
        -- Inserir user_link para o membro
        INSERT INTO user_links (
            link_id, user_id, link_type, referrer_name, is_active, created_at, updated_at
        ) VALUES (
            link_id, auth_user_id, 'members', referrer_name, true,
            NOW() - (random() * 365 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second',
            NOW() - (random() * 30 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second'
        );
        
        -- Inserir amigos baseado no número de contratos
        -- Garantir que cada membro tenha exatamente 15 amigos para totalizar 22.500
        friends_count := 15;
        FOR j IN 1..friends_count LOOP
            -- Gerar dados do amigo
            friend_name := generate_brazilian_name();
            friend_couple_name := generate_couple_name() || ' ' || split_part(friend_name, ' ', 2);
            friend_phone := generate_brazilian_phone();
            friend_couple_phone := generate_brazilian_phone();
            friend_instagram := generate_instagram();
            friend_couple_instagram := generate_instagram();
            friend_city := generate_brazilian_city();
            friend_sector := generate_sector();
            friend_couple_city := friend_city;
            friend_couple_sector := generate_sector();
            
            -- Inserir amigo
            INSERT INTO friends (
                member_id, name, phone, instagram, city, sector, referrer, registration_date, status,
                couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
                contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced,
                created_at, updated_at
            ) VALUES (
                member_id, friend_name, friend_phone, friend_instagram, friend_city, friend_sector, member_name,
                CURRENT_DATE - (random() * 365)::INTEGER, 'Ativo',
                friend_couple_name, friend_couple_phone, friend_couple_instagram, friend_couple_city, friend_couple_sector,
                0, 0, 'Vermelho', false, true,
                NOW() - (random() * 365 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second',
                NOW() - (random() * 30 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second'
            ) RETURNING id INTO friend_id;
            
            -- Inserir auth_user para o amigo
            friend_auth_user_id := gen_random_uuid();
            INSERT INTO auth_users (
                id, username, password, name, role, full_name, instagram, phone, is_active,
                created_at, updated_at
            ) VALUES (
                friend_auth_user_id, 
                lower(replace(friend_name, ' ', '')) || '_amigo_' || i || '_' || j, 
                'amigo123', 
                friend_name, 
                'Amigo', 
                friend_name || ' - Amigo',
                friend_instagram,
                friend_phone,
                true,
                NOW() - (random() * 365 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second',
                NOW() - (random() * 30 * 24 * 60 * 60)::INTEGER * INTERVAL '1 second'
            );
        END LOOP;
        
        -- Log de progresso
        IF i % 100 = 0 THEN
            RAISE NOTICE '✅ Inseridos % membros...', i;
        END IF;
    END LOOP;
    
    RAISE NOTICE '🎉 Inserção de 1500 membros com relacionamentos completos concluída!';
END $$;

-- =====================================================
-- 4. VERIFICAÇÃO FINAL
-- =====================================================

-- Contar membros inseridos
SELECT 
    'MEMBROS INSERIDOS' as tipo,
    COUNT(*) as total_membros,
    COUNT(CASE WHEN contracts_completed = 0 THEN 1 END) as membros_0_contratos,
    COUNT(CASE WHEN contracts_completed BETWEEN 1 AND 14 THEN 1 END) as membros_1_14_contratos,
    COUNT(CASE WHEN contracts_completed = 15 THEN 1 END) as membros_15_contratos,
    COUNT(CASE WHEN contracts_completed > 15 THEN 1 END) as membros_mais_15_contratos
FROM members;

-- Contar amigos inseridos
SELECT 
    'AMIGOS INSERIDOS' as tipo,
    COUNT(*) as total_amigos,
    COUNT(DISTINCT member_id) as membros_com_amigos
FROM friends;

-- Contar auth_users inseridos
SELECT 
    'AUTH_USERS INSERIDOS' as tipo,
    COUNT(*) as total_auth_users,
    COUNT(CASE WHEN role = 'Membro' THEN 1 END) as membros_auth,
    COUNT(CASE WHEN role = 'Amigo' THEN 1 END) as amigos_auth
FROM auth_users;

-- Contar user_links inseridos
SELECT 
    'USER_LINKS INSERIDOS' as tipo,
    COUNT(*) as total_user_links,
    COUNT(CASE WHEN link_type = 'members' THEN 1 END) as links_members,
    COUNT(CASE WHEN link_type = 'friends' THEN 1 END) as links_friends
FROM user_links;

-- Verificar top performers
SELECT 
    'TOP PERFORMERS' as tipo,
    name,
    contracts_completed,
    ranking_position,
    ranking_status,
    is_top_1500
FROM members 
WHERE contracts_completed > 15
ORDER BY contracts_completed DESC
LIMIT 10;

-- Verificar membros com mais amigos
SELECT 
    'MEMBROS COM MAIS AMIGOS' as tipo,
    m.name,
    m.contracts_completed,
    COUNT(f.id) as amigos_cadastrados
FROM members m
LEFT JOIN friends f ON m.id = f.member_id
GROUP BY m.id, m.name, m.contracts_completed
ORDER BY amigos_cadastrados DESC
LIMIT 10;

-- =====================================================
-- 5. LIMPEZA DAS FUNÇÕES TEMPORÁRIAS
-- =====================================================

DROP FUNCTION IF EXISTS generate_brazilian_name();
DROP FUNCTION IF EXISTS generate_couple_name();
DROP FUNCTION IF EXISTS generate_brazilian_phone();
DROP FUNCTION IF EXISTS generate_instagram();
DROP FUNCTION IF EXISTS generate_brazilian_city();
DROP FUNCTION IF EXISTS generate_sector();

-- =====================================================
-- RESUMO DO SCRIPT
-- =====================================================
/*
ESTE SCRIPT INSERE:

1. MEMBROS (1500):
   - Todos com exatamente 15 contratos (Verde, Top 1500)
   - Status consistente para relatórios

2. AMIGOS (22.500):
   - Cada membro tem exatamente 15 amigos
   - Total: 1500 × 15 = 22.500 amigos
   - Regra aplicada aos relatórios de amigos

3. AUTH_USERS:
   - 1 para cada membro (role: Membro) = 1500
   - 1 para cada amigo (role: Amigo) = 22.500
   - Total: 24.000 auth_users

4. USER_LINKS:
   - 1 para cada membro (link_type: members)
   - Total: 1500 user_links

5. RELACIONAMENTOS:
   - Membros vinculados aos amigos
   - Auth_users vinculados aos user_links
   - Dados realistas brasileiros

DADOS REALISTAS:
- Nomes brasileiros
- Telefones com DDD
- Instagram com @
- Cidades brasileiras
- Setores variados
- Datas de cadastro variadas
- Status e rankings corretos
*/
