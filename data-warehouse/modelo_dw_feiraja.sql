CREATE TABLE dim_tempo (id_tempo SERIAL PRIMARY KEY, data DATE NOT NULL, dia_semana VARCHAR(15), semana INT, mes INT, ano INT, feriado BOOLEAN DEFAULT FALSE, faixa_horaria VARCHAR(20));
CREATE TABLE dim_cliente (id_cliente SERIAL PRIMARY KEY, bairro VARCHAR(60), cep CHAR(9), regiao VARCHAR(30), data_cadastro DATE, segmento VARCHAR(20));
CREATE TABLE dim_produto (id_produto SERIAL PRIMARY KEY, nome VARCHAR(80), categoria VARCHAR(30), unidade_medida VARCHAR(10), perecibilidade_dias INT);
CREATE TABLE dim_feirante (id_feirante SERIAL PRIMARY KEY, nome_banca VARCHAR(80), tipo VARCHAR(20), data_adesao DATE, valido_de DATE, valido_ate DATE, atual BOOLEAN DEFAULT TRUE);
CREATE TABLE dim_feira (id_feira SERIAL PRIMARY KEY, endereco VARCHAR(120), bairro VARCHAR(60), zona VARCHAR(10), dia_da_feira VARCHAR(15));
CREATE TABLE dim_canal (id_canal SERIAL PRIMARY KEY, canal VARCHAR(20), tipo_entrega VARCHAR(20));
CREATE TABLE dim_pagamento (id_pagamento SERIAL PRIMARY KEY, forma VARCHAR(20), parcelas INT, status VARCHAR(20));
CREATE TABLE fato_vendas (
  id_venda_item BIGSERIAL PRIMARY KEY,
  id_tempo INT REFERENCES dim_tempo, id_cliente INT REFERENCES dim_cliente, id_produto INT REFERENCES dim_produto,
  id_feirante INT REFERENCES dim_feirante, id_feira INT REFERENCES dim_feira, id_canal INT REFERENCES dim_canal, id_pagamento INT REFERENCES dim_pagamento,
  quantidade_kg NUMERIC(10,3), valor_bruto NUMERIC(10,2), valor_desconto NUMERIC(10,2), valor_liquido NUMERIC(10,2), valor_frete NUMERIC(10,2));
CREATE TABLE fato_sobras (
  id_sobra BIGSERIAL PRIMARY KEY, id_tempo INT REFERENCES dim_tempo, id_produto INT REFERENCES dim_produto, id_feirante INT REFERENCES dim_feirante, id_feira INT REFERENCES dim_feira,
  kg_ofertado NUMERIC(10,3), kg_vendido NUMERIC(10,3), kg_vendido_desconto NUMERIC(10,3), kg_sobra NUMERIC(10,3), kg_doado NUMERIC(10,3));
