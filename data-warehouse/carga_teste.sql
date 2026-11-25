CREATE USER metabase WITH PASSWORD '<DEFINA_UMA_SENHA>';
GRANT CONNECT ON DATABASE dw_feiraja TO metabase;
GRANT USAGE ON SCHEMA public TO metabase;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO metabase;
-- dados fictícios de teste
INSERT INTO dim_tempo (data,dia_semana,semana,mes,ano,feriado,faixa_horaria)
 SELECT d::date, to_char(d,'TMDay'), extract(week from d), extract(month from d), extract(year from d), false, 'manhã'
 FROM generate_series('2026-10-01'::date,'2026-10-31'::date,'1 day') d;
INSERT INTO dim_feira (endereco,bairro,zona,dia_da_feira) VALUES
 ('R. Curuçá','Vila Maria','Norte','sábado'),('R. Voluntários da Pátria','Santana','Norte','domingo'),
 ('Av. Tucuruvi','Tucuruvi','Norte','quinta'),('R. Chico Pontes','Vila Guilherme','Norte','sexta'),('Av. Guapira','Jaçanã','Norte','terça');
INSERT INTO dim_produto (nome,categoria,unidade_medida,perecibilidade_dias) VALUES
 ('Alface crespa','Folhas','un',2),('Rúcula','Folhas','maço',2),('Tomate','Legumes','kg',6),('Banana prata','Frutas','kg',5),
 ('Ovos brancos','Ovos','dz',20),('Cheiro-verde','Temperos','maço',3),('Mamão formosa','Frutas','kg',4),('Cenoura','Legumes','kg',15);
INSERT INTO dim_feirante (nome_banca,tipo,data_adesao,valido_de,atual) SELECT 'Banca '||g, CASE WHEN g%3=0 THEN 'produtor' ELSE 'revenda' END, '2026-08-01','2026-08-01',true FROM generate_series(101,120) g;
INSERT INTO dim_canal (canal,tipo_entrega) VALUES ('app','delivery'),('app','retirada'),('site','delivery');
INSERT INTO dim_pagamento (forma,parcelas,status) VALUES ('Pix',1,'aprovado'),('Cartão',1,'aprovado');
INSERT INTO dim_cliente (bairro,regiao,data_cadastro,segmento) SELECT (ARRAY['Vila Maria','Santana','Tucuruvi','Vila Guilherme','Jaçanã'])[1+g%5],'Zona Norte','2026-09-01', CASE WHEN g%4=0 THEN 'novo' ELSE 'recorrente' END FROM generate_series(1,300) g;
SELECT setseed(0.42);
INSERT INTO fato_vendas (id_tempo,id_cliente,id_produto,id_feirante,id_feira,id_canal,id_pagamento,quantidade_kg,valor_bruto,valor_desconto,valor_liquido,valor_frete)
 SELECT 1+floor(random()*31), 1+floor(random()*300), 1+floor(random()*8), 1+floor(random()*20), 1+floor(random()*5), 1+floor(random()*3), 1+floor(random()*2),
        q, round((q*v)::numeric,2), round((q*v*dsc)::numeric,2), round((q*v*(1-dsc))::numeric,2), CASE WHEN random()<0.58 THEN 7.90 ELSE 0 END
 FROM (SELECT round((0.3+random()*3)::numeric,3) q, 4+random()*9 v, CASE WHEN random()<0.15 THEN 0.3 ELSE 0 END dsc FROM generate_series(1,6000)) s;
INSERT INTO fato_sobras (id_tempo,id_produto,id_feirante,id_feira,kg_ofertado,kg_vendido,kg_vendido_desconto,kg_sobra,kg_doado)
 SELECT t, p, f, 1+(f%5), o, round((o*0.80)::numeric,3), round((o*0.06)::numeric,3), round((o*(CASE WHEN p IN (1,2,6) THEN 0.14 ELSE 0.07 END))::numeric,3), round((o*0.03)::numeric,3)
 FROM generate_series(1,31) t, generate_series(1,8) p, generate_series(1,20) f, LATERAL (SELECT round((20+random()*40)::numeric,3) o) x WHERE (t+f)%7=0;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO metabase;
