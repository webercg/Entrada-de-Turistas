# Entrada de turistas internacionais no Brasil


# Sobre o projeto

Os objetivos específicos desse projeto são:

1) Criação de indexes para otimizar consultas ao banco de dados
2) Criação de 3 usuários com diferentes ivilégios ao banco de dados
3) Simulação no banco de dados para agendamento de viagens (TRANSACTIONS) e seleção de grau de isolamento
4) Criação de funções no banco de dados
5) Criação de triggers para recalcular registros automáticamente;
6) Estabelecer interface Python - PostgreSQL
7) Análise de dados com Python


# Tecnologias utilizadas
- Python
- PostgreSQL

# Dataset
Foram utilizados os dados fornecidos pelo ministério do turismo que indicam a chegada dos turistas no brasil entre os anos de 1998 a 2017. Apenas os dados referentes aos anos de 2010 à 2015 foram considerados.

Disponível em: http://dados.gov.br/dataset/chegada-turistas


# Banco de dados

A fim de simular o funcionamento de um banco de dados para gerenciamento de entrada de turistas no país, o seguinte banco de dados foi proposto para armazenar as informações do dataset. 
O banco pode ser recriado realizando o backup do arquivo "Backup BD" desse repositório


## Criação de indexes

Antes de iniciar a criação de indexes é importante atualizar as métricas das tabelas do banco de dados com o comando analyze

--- analyzes
<i>analyze turista;
analyze viagem;
analyze pais;
analyze estado_brasileiro</i>

Criação de um índex bitmap para a via de preferência de viagem dos turistas (Terrestre, Fluvial, Marítima ou Aérea)

-- Index 1 Bitmap -- Via
<i>create index idxviaBitmap on viagem using gin (via);
explain analyze;
select * from viagem where via = 'Fluvial'</i>


Criação de um index de Texto para otimizar as consultas baseando-se no seus nomes cadastrados.

-- Index 2 Texto -- Nome Turista
<i>create index idxnomeTrgm on turista using GIN(nome gin_trgm_ops);
explain analyze;
select * from turista where nome like 'Coral%'</i>


Criação de um índex bitmap para otimizar as consultas pelas buscas de turistas provindos de diversos continentes.

-- Index 3 -- Bitmap - Continente
<i>create index idxcontinBitmap on viagem using gin (continente_origem);
explain analyze;
select * from viagem where continente_origem = 'Europa';</i>


Criação de um índex de chave estrangeira para otimizar as consultas por uma busca comum como por exemplo os principais continentes de origem do turista em um estado de destino específico.

-- Index 4 Foreign Key -- CodUF (Estado - Viagem)
<i>create index idxestadoviagem on viagem(cod_uf);
EXPLAIN ANALYZE;
SELECT continente_origem , nome_estado
FROM estado_brasileiro NATURAL JOIN viagem
WHERE viagem.cod_uf=6 </i>

Criação de um índex bitmap para otimizar as consultas pelas buscas de turistas baseado em seu gênero (Masculino ou Feminino)

-- index 5 Bitmap -- Genero
<i>create index idxgeneroBitmap on turista using gin (sexo);
explain analyze;
select * from turista where sexo = 'F'</i>

## Criação de usuarios e privilégios no banco de dados

O primeiro passo foi mapear 3 papéis que fossem coerentes existir na estrutura de dados. A partir disso, foram identificados 3 personas: Consumidor, Operador e Gerente.

<b>Consumidor:</b> Se refere ao cliente que poderá realizar seu cadastro na plataforma e eventualmente realizar uma atualização de dados.
<b>Operador:</b> Se refere ao usuário que é responsável por lançar uma viagem para um consumidor, possibilitando atualizar os dados da viagem e também do turista.
<b>Gerente:</b> Usuário com acesso total para todas as tabelas. 

 <b>Iniciamos criando os grupos, para que novos usuários herdem os privilégios:</b>
- CREATE GROUP consumidor;
- CREATE GROUP operador;
- CREATE GROUP gerente;

<b> Em seguida vinculamos os privilégios aos grupos:</b>
- GRANT SELECT, INSERT ON turista TO consumidor WITH GRANT OPTION;
- GRANT SELECT, INSERT, UPDATE, DELETE ON turista, viagem TO operador
WITH GRANT OPTION;
- GRANT SELECT, INSERT, UPDATE, DELETE ON estado_brasileiro, pais, turista,
viagem TO gerente WITH GRANT OPTION;

<b>Para finalizar criamos os usuários e alocamos nos seus respectivos grupos:</b>
- CREATE USER consumidor1 ENCRYPTED PASSWORD 'con123' CREATEDB IN
GROUP consumidor;
- CREATE USER operador1 ENCRYPTED PASSWORD 'oper123' CREATEDB IN
GROUP operador;
- CREATE USER gerente1 ENCRYPTED PASSWORD 'ger123' CREATEDB IN
GROUP gerente; 

## Definição de funções e acionamento de triggers.
O trigger viagem_trigger foi criado no banco de dados com o objetivo de acionar a função verifica_covid sempre que a tabela de viagens receber um novo registro ou uma atualização.

<i>CREATE TRIGGER viagem_trigger
 AFTER INSERT OR UPDATE
 ON viagem FOR EACH ROW
 WHEN (pg_trigger_depth() = 0)
 EXECUTE PROCEDURE verifica_covid();</i>
 
Para contextualizar é necessário o entendimento da função verifica_covid. O objetivo dessa função é verificar a temperatura coletada do turista e atualizar o atributo libera_viagem da tabela viagem. Caso a temperatura seja superior a 37.5 graus, o turista é proibido de viajar, caso não, é liberado.

<i>CREATE OR REPLACE FUNCTION verifica_covid() RETURNS Trigger AS
$BODY$
BEGIN
 if (new.temperatura > 37.5) then
 update viagem set libera_viagem = false where id_viagem = new.id_viagem;
 RETURN NULL;
 ELSE
 update viagem set libera_viagem = true where id_viagem = new.id_viagem;
 RETURN NULL;
 END IF;
END;
$BODY$
LANGUAGE plpgsql; </i>

## Simulação de agendamentos de viagens e seleção de grau de isolamento

### Descrição do cenário hipotético das transações:

Um cliente vai até uma agência para se cadastrar e agendar uma viagem, o sistema da agência fica indisponível de forma que o atendente 1 decide anotar as informações para cadastrá-lo posteriormente e retornar para marcar a viagem por telefone. Um dia depois o mesmo cliente volta a agência para verificar se já está cadastrado uma vez que não recebeu ligação nenhuma, mas é atendido por outro atendente 2 pois de acordo com a escala da agência o atendente 1 esta de Home Office.

O atendente 2 irá se basear na informação retornada pela consulta dele para decidir se irá ou não cadastrar o cliente no banco de dados. O grau de isolamento utilizado será read uncommited e a consulta deveria retornar que o cliente já está cadastrado ou em processo de ser cadastrado pelo atendente 1 o que iria economizar, portanto, o tempo do atendente 2 e do cliente evitando que ele fornecesse todos seus dados pessoais novamente e o atendente 2 digitasse essas informações no sistema para tentar cadastrá-lo.
Por padrão o postgres trata todo read uncommited como read commited, portanto, essa situação não é aplicável a esse banco de dados em específico mas pode ser reproduzido
em outros que permitem esse grau de isolamento 

Atendente 1:

<i>begin;
set transaction isolation level read uncommitted;
select * from turista where num_passaporte = '799698778782977';
insert into turista values (799698778782977,'José Bezerra','S','M','1958-09-
20', 40);
select * from turista where num_passaporte = '799698778782977';
commit;:</i>

Atendente 2:

<i>begin;
set transaction isolation level read uncommitted;
select * from turista where num_passaporte = '799698778782977';
commit; </i>

Vantagem sobre a decisão pelo grau de isolamento read uncommitted: Para gerar a informação para o Atendente 2 que o processo de agendamento já está em andamento pelo Atendente 1.

# Análise de dados com Python

A partir dos dados já inseridos no banco uma aplicação em R foi criada para conectar-se ao banco de dados e gerar insights. 
O código elaborado em R está disponível para consulta no arquivo “Consultas.R” do repositório. 
Os quatro gráficos a seguir foram gerados.

<b>Consulta 1:</b> Entrada de turistas no ano de 2015 vs IDH do país de origem 

![Consulta1](https://github.com/webercg/assets/blob/main/8.jpg)

Em virtude da geração de IDH’s aleatórios para popular a tabela países , não se pode ter uma conclusão realista, o que era de se esperar seria uma correlação positiva entre o IDH e a quantidade de turistas uma vez que países com maiores IDH são também mais desenvolvidos economicamente. 

<b>Consulta 2:</b> Média Móvel 30 dias de check-in diário de turistas em São Paulo, Rio de Janeiro e Bahia entre 2010 e 2015 

![Consulta2](https://github.com/webercg/assets/blob/main/9.jpg)

A idéia é identificar tendências na quantidade de entrada de turistas diariamente nos principais pólos turísticos do Pais. Observamos que, São Paulo lidera na recepção de turistas, seguido por Rio de Janeiro e Bahia. Uma observação interessante é que durante o ano da copa de 2014 houve um aumento significativo do numero de turistas nos dois primeiros estados, já no estado da Bahia não se observou essa tendência revelando, portanto, a preferência pelo pólo econômico e o eixo Rio-São Paulo.

Sumarização consulta 2:

![Consulta2s](https://github.com/webercg/assets/blob/main/10.jpg)

De acordo com os dados sumarizados, constata-se que a média diária de entrada de turistas provindos de São Paulo é quase duas vezes maior que a média do Rio de Janeiro, embora o desvio padrão seja 34% maior também. Apesar de não aparecer no gráfico 2, a quantidade máxima de check-ins de turistas nos Estados de São Paulo e Rio de Janeiro idênticas e
equivalem a 13 turistas em um único dia, isso por que o gráfico 2 condensa a média ponderada de 5 dias e não o valor absoluto em um dia. 

<b>Consulta 3:</b> Entrada de turistas provindos da Europa e América do Sul nas altas temporadas 

![Consulta3](https://github.com/webercg/assets/blob/main/11.jpg)

Durante as férias escolares e o carnaval nota-se um aumento na recepção de turistas ao Brasil. Observou-se que o país recebe um numero maior de turistas provindos da América do Sul em comparação com a Europa, o que pode explicar esse comportamento é a proximidade do Brasil com os países da America do Sul. Outro comportamento interessante é
que observou-se um aumento da entrada de turistas provindos da America do Sul nos primeiros meses do ano em detrimento da queda do número de turistas provindos da Europa para o mesmo período. . 

<b>Consulta 4:</b> Entrada de turistas por continente de origem um ano antes da copa de 2014 (2013) 

![Consulta4](https://github.com/webercg/assets/blob/main/12.jpg)

A maior quantidade de turistas no ano de 2013 foram provindos da América do Sul, Europa e América do Norte. Destaque para os visitantes da América do Sul onde os números são quase 3 vezes maior que o número de visitantes da Europa. 

<b>Consulta 5:</b> Entrada de turistas por continente de origem no ano da copa de 2014 

![Consulta5](https://github.com/webercg/assets/blob/main/13.jpg)

Comparando-se o gráfico anterior com esse é possível identificar um aumento do número de turistas de cerca de 1670 da América do Sul e 594 da Europa para 1776 da América do Sul e 710 da Europa. Em termos relativos durante o ano da copa houve um aumento de 6,35% do número de turistas da América do Sul e 19,53% de turistas da Europa.

<b>Consulta 6:</b> Entrada de turistas argentinos por região de destino 

![Consulta6](https://github.com/webercg/assets/blob/main/14.jpg)

Observa-se pelo gráfico a preferência dos turistas argentinos pelo Sul e Sudeste do país. Uma explicação para esse comportamento seria a proximidade da Argentina com essas
duas regiões, outro fator que deve ser levado em consideração é que são as duas regiões mais desenvolvidas do país mais fortes no turismo corporativo. 

# Autores

Weber Cordeiro Godoi

Maicon Junior Silveira
