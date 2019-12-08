## Introduzione #### ----

## Librerie ### ----
## Installare le librerie ## ----

# install.packages(c("DBI", "dbplyr", "dplyr", "dbplot", "ggplot2", "modeldb",
# "tidypredict", "config"))

## Caricare le librerie ## ----

library(DBI)
library(dbplyr)
library(dplyr)
library(dbplot)
library(ggplot2)
library(modeldb)
library(tidypredict)
library(config)

## Connessione ed esplorazione ### --------------------------------------------------------------

## Connessione #### -------------------------------- 

con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "data/mydatabase.db")

con

summary(con)

## Lista delle tabelle #### -------------------------------- 

DBI::dbListTables(con)

## Lista deli campi (colonne) di una tabella #### -------------------------------- 

DBI::dbListFields(con, "ecom")

## Interrograzione del Database ### --------------------------------------------------------------

## Leggere l'intera tabella #### -------------------------------- 

DBI::dbReadTable(con, "ecom")

## Leggere alcune righe #### -------------------------------- 

DBI::dbGetQuery(con, "select * from ecom limit 10")

## Leggere i dati in batches #### -------------------------------- 

## impostare la query ##### --------
query  <- DBI::dbSendQuery(con, 'select * from ecom')
result <- DBI::dbFetch(query, n = 15)
result

## stato della query ##### --------
DBI::dbHasCompleted(query)

## Informazioni sulla query ##### --------
DBI::dbGetInfo(query)

## Lo statement della query ###### ----
DBI::dbGetStatement(query)

## Righe richiamate ###### ----
DBI::dbGetRowCount(query)

## Righe modificate ###### ----
DBI:dbGetRowsAffected(query)

## Informazioni sulle colonne ###### ----
DBI::dbColumnInfo(query)

## Eliminare la query ###### ----
DBI::dbClearResult(query)

## Lavorare con le Tabelle ### --------------------------------------------------------------

## Creare una tabella #### -------------------------------- 

DBI::dbExistsTable(con, "trial_db")

# sample data
x          <- 1:10
y          <- letters[1:10]
trial_data <- tibble::tibble(x, y)

DBI::dbWriteTable(con, "trial", trial_data)

DBI::dbListTables(con)

DBI::dbGetQuery(con, "SELECT * FROM trial LIMIT 5")

## Sovrascrivere una tabella #### -------------------------------- 

# sample data 2
x           <- sample(100, 10)
y           <- letters[11:20]
trial2_data <- tibble::tibble(x, y)

## Aggiungere righe ad una tabella #### -------------------------------- 

DBI::dbWriteTable(con, "trial", trial_data, append = TRUE)

DBI::dbReadTable(con, "trial")

## Aggiungere singole righe ad una tabella #### -------------------------------- 

## Metodo 1 ##### --------

DBI::dbExecute(con,
               "INSERT into trial (x, y) VALUES (32, 'c'), (45, 'k'), (61, 'h')"
)

## Metodo 2 ##### --------

DBI::dbSendStatement(con,
                     "INSERT into trial (x, y) VALUES (25, 'm'), (54, 'l'), (16, 'y')"
)

DBI::dbReadTable(con, "trial")

## Eliminare una tabella #### -------------------------------- 

DBI::dbRemoveTable(con, "trial")

