#Rotina para coletar a selic esperada em t+12 mensal
#Feito por: Marcelo Vilas Boas de Castro
#última atualização: 11/08/2020


#Definindo diretórios a serem utilizados
getwd()
#setwd("//srjn4/projetos/Projeto GAP-DIMAC/Automatizações/Att semanais")
setwd("D:\\Documentos")

#Carregando pacotes que serão utilizados
library("zoo")
library("fredr")
library("dplyr")
library("anytime")
library("rio")
library("data.table")
library("RQuantLib")
library("lubridate")

#1) Meta para taxa over selic semanal
meta_selic = read.csv(url(paste("https://olinda.bcb.gov.br/olinda/servico/Expectativas/versao/v1/odata/ExpectativaMercadoMensais?$top=100000&$skip=0&$filter=Indicador%20eq%20'Meta%20para%20taxa%20over-selic'&$orderby=Data%20desc&$format=text/csv&$select=Indicador,Data,DataReferencia,Mediana,numeroRespondentes")))
meta_selic$Data = as.Date(meta_selic$Data, "%Y-%m-%d")
meta_selic$DataReferencia = as.yearmon(meta_selic$DataReferencia, "%m/%Y")
meta_selic = meta_selic[order(meta_selic$Data, meta_selic$DataReferencia),]
for (i in 1:length(meta_selic$numeroRespondentes))
  if (meta_selic$numeroRespondentes[i] == "null")
    meta_selic$numeroRespondentes[i] = 100
meta_selic = setDT(meta_selic)[, .SD[which.max(numeroRespondentes)], c("Data", "DataReferencia")]
meta_selic = subset(meta_selic, select = -c(Indicador, numeroRespondentes))
meta_selic$Mediana = as.numeric(gsub(",", ".", meta_selic$Mediana))

meta_selica = meta_selic %>% group_by(Data) %>% filter(ymd(Data) == as.Date(as.yearmon(ymd(Data)), frac=1)) %>% filter(DataReferencia == as.yearmon(ymd(Data) %m+% months(12), "%m/%Y"))

export(meta_selic, "dados completos.xlsx")
export(meta_selica, "dados com buracos.xlsx")
