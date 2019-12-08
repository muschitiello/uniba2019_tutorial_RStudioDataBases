## Le librerie # -------------------------------------------


# install.packages(c("dbplyr", "RSQLite"))
library(dplyr)
library(dbplyr)
library(RSQLite)

## Il database portal_mammals # -------------------------------------------
dir.create("data", showWarnings = FALSE)
download.file(url = "https://ndownloader.figshare.com/files/2292171",
              destfile = "data/portal_mammals.sqlite", mode = "wb")

## Operazioni con dplyr # -------------------------------------------

## Connessione ed esplorazione ## ------------

mammals <- DBI::dbConnect(RSQLite::SQLite(), "data/portal_mammals.sqlite")
src_dbi(mammals)

## Interrogazioni ## ------------

tbl(mammals,"surveys")

## Interrogazioni del DB tramite comandi SQL ### ----

tbl(mammals, sql("SELECT year, species_id, plot_id FROM surveys"))

## Interrogazioni del DB tramite la sintassi dplyr ### ----

surveys <- tbl(mammals, "surveys")
surveys %>%
    select(year, species_id, plot_id)

head(surveys, n = 10)

# non tutte le funzioni di dplyr si comportano come ci aspetteremmo su un data frame. Per esempio, il comando `nrow()` restitutisce `NA`:
nrow(surveys)

## Traduzione da SQL ## ------------

# ```sql
# SELECT *
# FROM `surveys`
# LIMIT 10
# ```

# Cio' che fa `dplyr` e':
# 
#  1. Tradurre il codice R in codice SQL
#  2. inviare tale comando al database
#  3. tradurre la risposta del database in un dataframe R.
 
show_query(head(surveys, n = 10))

## Semplici interrogazioni su DB tramite `dplyr`

surveys %>%
  filter(weight < 5) %>%
  select(species_id, sex, weight)

# ... with more rows

## Laziness # -------------------------------------------

# When working with databases, **`dplyr`** tries to be as lazy as possible:
# 
#   * It never pulls data into R unless you explicitly ask for it.
#   * It delays doing any work until the last possible moment - it collects together
#  everything you want to do and then sends it to the database in one step.

## `%>%` pipe # -------------------------------------------

data_subset <- surveys %>%
  filter(weight < 5) %>%
  select(species_id, sex, weight)
data_subset %>%
  select(-sex)

data_subset <- surveys %>%
  filter(weight < 5) %>%
  select(species_id, sex, weight) %>%
  collect()

data_subset

## Interrogazioni complesse su BD # -------------------------------------------

## Join ## ------------

# Uniamo le tabelle `plots` e `surveys`.
# La tabella `plots` del database contiene informazioni relative alle aree coperte 
# dai ricercatori nell'ambito della ricerca svolta. 

plots <- tbl(mammals, "plots")
plots

# La colonna `plot_id` compare anche nella tabella `surveys`:


surveys

# 1. *`inner_join()`* : restituisce tutte le righe di *x* e *y* aventi la chiave di join in comune fra le tabelle. 

# 2. *`left_join()`* : restituisce tutte le righe di *x* e le colonne di *x* e *y*. 
# LE righe di *x* senza un corrispondente in *y* avranno un `NA` come valore.

# In entrambi i tipi di join, in caso di match multiplo fra le tabelle, 
# restituite tante righe quante sono le combinazioni delle corrispondenze. 
plots %>%
  filter(plot_id == 1) %>%
  inner_join(surveys) %>%
  collect()

## Raggruppamenti e sintesi dei dati ## ------------

# N di roditori osservati in ciascuna area in ciascun anno.

# La colonna `taxa` contiene informazioni relative al tipo di mammifero 
# ed è contenuta anche nella tabella `survey`. Dovremo pertanto eseguire le seguenti operazioni: 

 # - fare una left_join fra le tabelle species e survey
 # - filtrare per taxa = "Rodent"
 # - raggruppare per anno e per specie
 # - calcolare il numero di esemplari

# Cio' puo' essere fatto in un'unica sequenza di comandi:
 
species <- tbl(mammals, "species")
species

left_join(surveys, species) %>%
 filter(taxa == "Rodent") %>%
 group_by(taxa, year) %>%
 tally %>%
 collect()


# La funzione `tally()` restituisce il numero di unità per ciascun gruppo. 

# N di generi rilevati in ciascuna area, 
# cioè il numero di `genera` per `plot_id` dalla tabella `survey`, 
# potremmo utilizzare il comando `n_distinct()` che conta il numero di valori univoci in una colonna: 

species <- tbl(mammals, "species")
unique_genera <- left_join(surveys, plots) %>%
    left_join(species) %>%
    group_by(plot_type) %>%
    summarize(
        n_genera = n_distinct(genus)
    ) %>%
    collect()
unique_genera

## Creare un nuovo database SQLite  # -------------------------------------------

# Creiamo lo stesso DB a partire dalle tabelle csv

download.file("https://ndownloader.figshare.com/files/3299483",
              "data/species.csv")
download.file("https://ndownloader.figshare.com/files/10717177",
              "data/surveys.csv")
download.file("https://ndownloader.figshare.com/files/3299474",
              "data/plots.csv")

# carichiamo tidyverse

library(tidyverse)
species <- read_csv("data/species.csv")
surveys <- read_csv("data/surveys.csv")
plots <- read_csv("data/plots.csv")

my_db_file <- "data/out_mammals.sqlite"
my_db <- src_sqlite(my_db_file, create = TRUE)
my_db

# Per aggiungere delle tabelle si *copiano* le tabelle nel database, una alla volta:

copy_to(my_db, surveys)
copy_to(my_db, plots)
copy_to(my_db, species)
my_db

