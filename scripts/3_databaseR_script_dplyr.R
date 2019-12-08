## Operazioni preliminari # -------------------------------------------

## Importare Librerie ## ------------------------

library(dplyr)
library(dbplyr)
library(RSQLite)
library(downloader)

## Scaricare dati ## ------------------------

url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/msleep_ggplot2.csv"

filename <- "msleep_ggplot2.csv"

if (!file.exists(filename)) download(url,filename)

msleep <- read.csv("msleep_ggplot2.csv")

head(msleep)

## Verbi di dplyr # -------------------------------------------

## select() ## ------------------------

## Selezionare colonne

sleepData <- select(msleep, name, sleep_total)

head(sleepData)

# Deselezionare colonne

head(select(msleep, -name))

## Selezionare un range di colonne

head(select(msleep, name:order))

## Selezionare tutte le colonne il cui nome inizia con una certa stringa

head(select(msleep, starts_with("sl")))

## filter() ## ------------------------

## Filtriamo i mammiferi che hanno un numero totale di ore di sonno superiore a 16.

filter(msleep, sleep_total >= 16)

## righe che corrisponsono a mammiferi che dormono più di 16 ore e che hanno un peso corporeo maggiore di 1 kg.

filter(msleep, sleep_total >= 16, bodywt >= 1)

## ordine tassonomico dei Perissodattili (Perissodactyla) e Primati(Primates)

filter(msleep, order %in% c("Perissodactyla", "Primates"))

# pipe %>% # -------------------------------------------

head(select(msleep, name, sleep_total))

msleep %>% 
  select(name, sleep_total) %>% 
  head


## Altri verbi di dplyr # -------------------------------------------

## Organizzare (o ri-ordinare) righe usando arrange() ## ------------------------

msleep %>% arrange(order) %>% head

msleep %>% 
  select(name, order, sleep_total) %>%
  arrange(order, sleep_total) %>% 
  head

## uso congiunto ## ------------------------

msleep %>% 
  select(name, order, sleep_total) %>%
  arrange(order, sleep_total) %>% 
  filter(sleep_total >= 16)

## mutate() per generare nuove colonne ## ------------------------


msleep %>% 
  mutate(rem_proportion = sleep_rem / sleep_total) %>%
  head

msleep %>% 
  mutate(rem_proportion = sleep_rem / sleep_total, 
         bodywt_grams = bodywt * 1000) %>%
  head

## Creare summaries dei dati usando summarise()  ## ------------------------

msleep %>% 
  summarise(avg_sleep = mean(sleep_total))

## Si possono usare diverse statistiche di sintesi, usando le funzioni: 
  
# sd()
# min()
# max()
# median( 
# sum()
# n() (lunghezza di un vettore)
# first() (primo valore di un vettore)
# last() (ultimo valore di un vettore)  
# n_distinct() (numero di valori distinti di un vettore).

msleep %>% 
  summarise(avg_sleep = mean(sleep_total), 
            min_sleep = min(sleep_total),
            max_sleep = max(sleep_total),
            total = n())

## Operazioni di raggruppamento con group_by() ## ------------------------

msleep %>% 
  group_by(order) %>%
  summarise(avg_sleep = mean(sleep_total), 
            min_sleep = min(sleep_total), 
            max_sleep = max(sleep_total),
            total = n())
