# Entrada de turistas internacionais no Brasil
[![NPM](https://img.shields.io/npm/l/react)](https://github.com/devsuperior/sds1-wmazoni/blob/master/LICENSE) 

# Sobre o projeto

Os objetivos específicos desse projeto são:

1)  Criar novas tabelas, novos relacionamentos e registros fictícios de forma à simular o funcionamento de um banco para armazenagem de dados referente à chegadas de turistas internacionais ao Brasil.
2)  Criar subrotinas de importação de dados para popular o PostgreSQL
3)  Realizar uma análise de dados utilizando a linguagem R a partir de dados armazenados em PostgreSQL.


# Tecnologias utilizadas
- Python
- PostgreSQL
- R

# Dataset
Foram utilizados os dados fornecidos pelo ministério do turismo que indicam a chegada dos turistas no brasil entre os anos de 1998 a 2017. Apenas os dados referentes aos anos de 2010 à 2015 foram considerados.

Disponível em: http://dados.gov.br/dataset/chegada-turistas


# Banco de dados

A fim de simular o funcionamento de um banco de dados para gerenciamento de entrada de turistas no país, o seguinte banco de dados foi proposto para armazenar as informações do dataset. 
O banco pode ser recriado executando o script cria_banco.sql desse repositório.

## Diagrama Entidade-Relacionamento



## Modelo Relacional

## Descrição do banco de dados

# Importação e manipulação de dados com Python e SQL


Foi desenvolvido uma aplicação em Python para ler os dados do arquivo csv e popular uma tabela auxiliar no banco de dados.
Código disponível no notebook "Import csv.ipynb" do repositório.

A quantidade de chegadas de turistas na tabela auxiliar foi lida de forma gerar registros individuais de viagens. Dados fictícios como, por exemplo, nome do turista, sobrenome, passaporte foram gerados a fim de complementar as informações do dataset.
Para cada tabela foi utilizado uma estratégia específica para popular com dados. Para a tabela PAIS e ESTADO_BRASILEIRO foi realizado um comando de inserção usando como base a tabela de referência, agrupando todas as ocorrências de país origem de UF destino de modo que fossem populado os registros sem duplicação. 
Código disponível no arquivo "Popular PAIS e ESTADO BRASILEIRO.sql" do repositório.

Para popular os registros na tabela TURISTAS foi criado uma aplicação em python para acessar dois arquivos de texto encontrados na web, nome.txt e sobrenome.txt com a finalidade de formar um nome fictício de turistas, demais atributos foram inseridos de forma randômica para gerar uma variação de dados. 1001 registros foram criados para serem utilizados nas viagens. 
O código pode ser consultado no notebook "Popular Turistas.ipynb" do repositório. 

Para popular a tabela VIAGEM foi necessário transformar os registros que possuem quantidades absolutas de chegadas na tabela de referência em registros individuais de viagens e de turistas, para que conseguíssemos acessar as características individuais das pessoas para gerar novas análises. 
Para isso foi criado uma aplicação para varrer a tabela de referência e a cada registro em que a quantidade de chegada fosse maior que 0, criar uma viagem individual para cada chegada, atribuindo um turista da tabela de turistas aleatoriamente.
O código pode ser consultado no notebook "Popular Viagens.ipynb" do repositório. 

# Análise de dados com R.

A partir dos dados já inseridos no banco uma aplicação em R foi criada para conectar-se ao banco de dados e gerar insights. 
O código elaborado em R está disponível para consulta no arquivo “Consultas.R” do repositório. 
Os quatro gráficos a seguir foram gerados.

<b>Consulta 1:</b> Distribuição das vias de entrada no país pelos turistas entre os anos de 2010 e 2015.

Como os dados de vias foi gerado aleatoriamente, todas apresentam uma distribuição semelhante, cerca de 25% cada.

<b>Consulta 2:</b> Gráfico que represente a entrada de turistas solteiras do sexo feminino provindas do Japão e turistas solteiros do sexo masculino provindos da Rússia por ano.

Como o sexo dos turistas foram gerados aleatoriamente a mesma quantidade de pessoas do sexo masculino é esperada nos gráficos representados acima. Dessa forma, é possível inferir que o Japão possui maior entrada de turistas no país entre os anos de 2010 á 2015 em comparação com a Rússia. Isso pode ser explicado pelo fato do Brasil possuir um forte vínculo com os nipônicos, atualmente, o Brasil possui a maior comunidade japonesa fora do Japão.

<b>Consulta 3:</b> Entrada de turistas provindos do continente Europeu por país entre os anos de 2010 e 2015.

É possível notar que as maiores entradas de estrangeiros correspondem a turistas provindos das nações detentoras das maiores economias como Alemanha, França, Itália e Reino Unido. 

<b>Consulta 4:</b>  Série temporal de entrada de turistas estrangeiros ao nordeste do Brasil por ano entre 2010 e 2015.

É possível notar uma tendência de diminuição de visita de turistas internacionais ao nordeste brasileiro entre 2011 e 2013. A tendência se inverteu entre o período de 2013 a 2015, provavelmente por conta da organização da copa do mundo realizada em 2014.

# Autores

Weber Cordeiro Godoi
Maicon Junior Silveira 
