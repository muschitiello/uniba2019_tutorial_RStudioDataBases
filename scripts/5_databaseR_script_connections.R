## librerie # ----------------------------------------

library(DBI)
library(dbplot)
library(bigrquery)

## Esempio Google BigQuery

# Google BigQuery fornisce i dati relativi alle chiamate al 3-1-1 
# nella città di Austin (Texas) 

# Il 3-1-1 è il numero delle chiamate NON di emergenza della polizia. 

## Connessione ad un DB di tipo Google BigQuery # ----------------------------------------

con <- dbConnect(
  bigquery(),
  project = "bigquery-public-data",
  dataset = "austin_311",
  billing = "rstudio-bigquery-event",
  use_legacy_sql = FALSE
)

# puntiamo alla tabella di nostro interesse: 311_service_requests

service <- tbl(con, "311_service_requests")

# (La prima volta che si esegue questo comando, 
# si viene rimandati ad una pagina di Google per l'autenticazione.)

# il comando `glimpse()` di `dplyr` ci permette di vedere il contenuto della tabella, 
# senza bisogno di scaricarla sul constro computer:

glimpse(service)


