# Entrada de turistas internacionais no Brasil


# Sobre o projeto

Os objetivos específicos desse projeto são:

1) Criação de indexes para otimizar consultas ao banco de dados
2) Criação de 3 usuários com diferentes ivilégios ao banco de dados
3) Simulação no banco de dados para agendamento de viagens (TRANSACTIONS)
4) Criação de triggers para recalcular registros automáticamente;
5) Estabelecer interface Python - PostgreSQL
6) Análise de dados com Python


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
analyze turista
analyze viagem
analyze pais
analyze estado_brasileiro

Criação de um índex bitmap para a via de preferência de viagem dos turistas (Terrestre, Fluvial, Marítima ou Aérea)

-- Index 1 Bitmap -- Via
create index idxviaBitmap on viagem using gin (via);
explain analyze
select * from viagem where via = 'Fluvial'


Criação de um index de Texto para otimizar as consultas baseando-se no seus nomes cadastrados.

-- Index 2 Texto -- Nome Turista
create index idxnomeTrgm on turista using GIN(nome gin_trgm_ops);
explain analyze;
select * from turista where nome like 'Coral%'


Criação de um índex bitmap para otimizar as consultas pelas buscas de turistas provindos de diversos continentes.

-- Index 3 -- Bitmap - Continente
create index idxcontinBitmap on viagem using gin (continente_origem);
explain analyze;
select * from viagem where continente_origem = 'Europa';


Criação de um índex de chave estrangeira para otimizar as consultas por uma busca comum como por exemplo os principais continentes de origem do turista em um estado de destino específico.

-- Index 4 Foreign Key -- CodUF (Estado - Viagem)
create index idxestadoviagem on viagem(cod_uf);
EXPLAIN ANALYZE;
SELECT continente_origem , nome_estado
FROM estado_brasileiro NATURAL JOIN viagem
WHERE viagem.cod_uf=6

Criação de um índex bitmap para otimizar as consultas pelas buscas de turistas baseado em seu gênero (Masculino ou Feminino)

-- index 5 Bitmap -- Genero
create index idxgeneroBitmap on turista using gin (sexo);
explain analyze;
select * from turista where sexo = 'F'

## Criação de usuarios e privilégios no banco de dados

## Simulação agendamento de viagens (TRANSACTIONS)


# Análise de dados com Python

A partir dos dados já inseridos no banco uma aplicação em R foi criada para conectar-se ao banco de dados e gerar insights. 
O código elaborado em R está disponível para consulta no arquivo “Consultas.R” do repositório. 
Os quatro gráficos a seguir foram gerados.

<b>Consulta 1:</b> Distribuição das vias de entrada no país pelos turistas entre os anos de 2010 e 2015.

![Consulta1](https://github.com/webercg/assets/blob/main/4.png)

Como os dados de vias foi gerado aleatoriamente, todas apresentam uma distribuição semelhante, cerca de 25% cada.

<b>Consulta 2:</b> Gráfico que represente a entrada de turistas solteiras do sexo feminino provindas do Japão e turistas solteiros do sexo masculino provindos da Rússia por ano.

![Consulta2](https://github.com/webercg/assets/blob/main/5.png)

Como o sexo dos turistas foram gerados aleatoriamente a mesma quantidade de pessoas do sexo masculino é esperada nos gráficos representados acima. Dessa forma, é possível inferir que o Japão possui maior entrada de turistas no país entre os anos de 2010 á 2015 em comparação com a Rússia. Isso pode ser explicado pelo fato do Brasil possuir um forte vínculo com os nipônicos, atualmente, o Brasil possui a maior comunidade japonesa fora do Japão.

<b>Consulta 3:</b> Entrada de turistas provindos do continente Europeu por país entre os anos de 2010 e 2015.

![Consulta3](https://github.com/webercg/assets/blob/main/6.png)

É possível notar que as maiores entradas de estrangeiros correspondem a turistas provindos das nações detentoras das maiores economias como Alemanha, França, Itália e Reino Unido. 

<b>Consulta 4:</b>  Série temporal de entrada de turistas estrangeiros ao nordeste do Brasil por ano entre 2010 e 2015.

![Consulta3](https://github.com/webercg/assets/blob/main/7.png)

É possível notar uma tendência de diminuição de visita de turistas internacionais ao nordeste brasileiro entre 2011 e 2013. A tendência se inverteu entre o período de 2013 a 2015, provavelmente por conta da organização da copa do mundo realizada em 2014.

# Autores

Weber Cordeiro Godoi

Maicon Junior Silveira
