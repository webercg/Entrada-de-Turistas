####CONSULTAS SQL

library(RPostgres)
library(tidyverse)
library(dplyr)

##########################################COnexão com o BD
con <-dbConnect(Postgres(),
                user = "postgres",
                password = "qp34ja8u",
                host = "localhost",
                port = 5432,
                dbname = "postgres")

########################################## CONSULTA_1

consulta_1 <- as_tibble(dbGetQuery(con,"SELECT   COUNT(nome) as total, via as tipo_via
                                 FROM turista t, viagem v 
                                 WHERE t.num_passaporte = v.num_passaporte
                                 GROUP BY tipo_via"))

#Tratamento de dados1 (SIMPLES)
consulta_1 <- mutate(consulta_1,per=round((total/sum(total, na.rm = FALSE)*100),2))


###PLOT1
graficopizza_1 <- ggplot(consulta_1, aes(x ="", y=as.numeric(total), fill=tipo_via)) + geom_bar(width = 1, stat = "identity") + 
  coord_polar("y", start = 0, direction = -1) + 
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    axis.text.x=element_blank(),
    legend.title = element_blank()) + 
  geom_text(data = consulta_1, aes(x ="", y=as.numeric(total), label = paste("",per,"%",sep="")),
            position = position_stack(vjust = 0.5))+
  labs(title = "Quantidade de turistas por tipo de via ",
       subtitle = "Período:2010 a 2015")
graficopizza_1



########################################## CONSULTA_2 ##########

consulta_2 <- as_tibble(dbGetQuery(con,"SELECT t.nome, t.sexo, v.data_chegada, v.pais_origem 
FROM turista t, viagem v where t.num_passaporte = v.num_passaporte AND t.estado_civil = 'S' AND t.sexo = 'M' AND v.pais_origem = 'Rússia'
UNION ALL
SELECT t.nome, t.sexo, v.data_chegada, v.pais_origem 
FROM turista t, viagem v where t.num_passaporte = v.num_passaporte AND t.estado_civil = 'S' AND t.sexo = 'F' AND v.pais_origem = 'Japão';
"))

###Tratamento de dados2

consulta_2 <- mutate(consulta_2,
                     Dia = as.numeric(format(data_chegada, "%d"
                                        )),
                     Mes = as.numeric(format(data_chegada, "%m"
                                        )),
                     Ano = as.numeric(format(data_chegada, "%Y"
                                        )))%>%
  select(pais_origem, Ano)%>%
  mutate(entrada = Ano/Ano)%>%
  group_by(pais_origem,Ano)%>%
  summarise(Entradas = sum(entrada))


###GGplot2
grafico_bar2 <- ggplot(data = consulta_2) +
  geom_col(aes(x = as.factor(Ano), y = Entradas,
               fill = pais_origem),
           position = position_dodge(), linetype = "solid", colour = "black", size = 0.5
  ) +
  labs(x = "Ano", y = "Entrada de Turistas", title = "Entradas de turistas do sexo masculinos da Rússia e femininos do Japão por ano", subtitle = "País de referência: Brasil")
  theme(axis.title = element_text(size=10), plot.title = element_text(size=10, face="bold"))

  grafico_bar2
  
#################################### CONSULTA_3
  
consulta_3 <- as_tibble(dbGetQuery(con,"SELECT id_viagem, pais_origem FROM viagem 
WHERE continente_origem = 'Europa'"))

##tratamento de dados3

consulta_3 <-
  group_by(consulta_3, pais_origem) %>%
  summarise(Qtde_turista = sum(id_viagem/id_viagem))
  


####plot 3
grafico_bar3 <- ggplot(data = consulta_3) +
  geom_col(aes(x = pais_origem, y = `Qtde_turista`, fill = pais_origem),
           position = position_dodge(), linetype = "solid", colour = "black", size = 0.5)+
  labs(x = "País", y = "Quantidade de Turistas", title = "Quantidade de turistas provindos da Europa por pais", subtitle = "Período: 2010 à 2015")
theme(axis.title = element_text(size=10), plot.title = element_text(size=10, face="bold"))

grafico_bar3



########################################## CONSULTA_4
consulta_4 <- as_tibble(dbGetQuery(con,"select nome, data_chegada
from turista, viagem
where turista.num_passaporte=viagem.num_passaporte and viagem.num_passaporte in (SELECT num_passaporte
FROM turista
WHERE NOT EXISTS
( (SELECT DISTINCT regiao
FROM estado_brasileiro
   where regiao = 'Nordeste')
EXCEPT
(SELECT regiao
FROM viagem, estado_brasileiro
WHERE viagem.cod_uf=estado_brasileiro.cod_uf AND viagem.num_passaporte = turista.num_passaporte)
))
and cod_uf in (select cod_uf from estado_brasileiro where regiao = 'Nordeste')
"))

consulta_4 <- mutate(consulta_4,
                     Dia = as.numeric(format(data_chegada, "%d"
                     )),
                     Mes = as.numeric(format(data_chegada, "%m"
                     )),
                     Ano = as.numeric(format(data_chegada, "%Y"
                     )),
                     entrada = 1)%>%
  select(Ano,entrada)%>%
  group_by(Ano)%>%
  summarise(Entradas = sum(entrada))
  
######Plot4
grafico_linha4 <- ggplot(data = consulta_4) +
  geom_line(aes(x = Ano, y = Entradas)) + 
  labs(x = "Ano", y = "Quantidade de Turistas", title = "Entrada de turistas no Nordeste Brasileiro entre os anos de 2010 e 2015",subtitle = "Brasil")

grafico_linha4

########################################## CONSULTA_5

consulta_5 <- as_tibble(dbGetQuery(con, "SELECT 'PaisSemViagem' as Paises, count(distinct p.nome_pais_origem) as Total FROM pais p 
LEFT JOIN viagem v on p.nome_pais_origem = v.pais_origem
WHERE id_viagem is null 
UNION
SELECT 'PaisComViagem' as Paises, count(distinct p.nome_pais_origem) as Total FROM pais p 
LEFT JOIN viagem v on p.nome_pais_origem = v.pais_origem
WHERE id_viagem is not null;"))



###Plot5
graficopizza_5 <- ggplot(consulta_5, aes(x ="", y=as.numeric(total), fill=paises)) + geom_bar(width = 1, stat = "identity") + 
  coord_polar("y", start = 0, direction = -1) + 
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    axis.text.x=element_blank(),
    legend.title = element_blank()) + 
  geom_text(data = consulta_5, aes(x ="", y=as.numeric(total), label = paste("",total," Países",sep="")),
            position = position_stack(vjust = 0.5))+
  labs(title = "Quantidade de países cadastrados no banco de dados por tipo de registros de viagens ao Brasil",
       subtitle = "Período:2010 a 2015")
graficopizza_5
