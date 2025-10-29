# --- ETAPE 1 : Importation des données ---

library(readr)
library(dplyr)

# Lecture des CSV Ameli (séparateur ;)
ameli_files <- list.files("data/raw/ameli", pattern = "\\.csv$", full.names = TRUE)
ameli_data <- lapply(ameli_files, read_delim, delim = ";", locale = locale(encoding = "UTF-8"))

# Lecture des CSV Odisse (séparateur ,)
odisse_files <- list.files("data/raw/odisse", pattern = "\\.csv$", full.names = TRUE)
odisse_data <- lapply(odisse_files, read_delim, delim = ",", locale = locale(encoding = "UTF-8"))


# --- ETAPE 2 : uniformiser les noms ---

library(janitor)

odisse_data2 <- lapply(odisse_data, janitor::clean_names)
ameli_data2  <- lapply(ameli_data, janitor::clean_names)

# --- ETAPE 3 : Nettoyage de Odisse --- 

source("R/nettoyage/cleaning_odisse.R")


for (i in seq_along(odisse_data2)) {
  cat("\n==============================\n")
  cat("🗂️  Dataframe", i, "\n")
  cat("==============================\n")
  
  na_counts <- colSums(is.na(odisse_data2[[i]]))
  na_counts <- na_counts[na_counts > 0]
  
  if (length(na_counts) == 0) {
    cat("✅ Aucun NA dans ce dataframe\n")
  } else {
    print(na_counts)
  }
}

odisse_clean <- odisse_data2

# --- ETAPE 4 : Nettoyage de Ameli --- 

source("R/nettoyage/cleaning_ameli.R")


for (i in seq_along(ameli_data2)) {
  cat("\n==============================\n")
  cat("🗂️  Dataframe", i, "\n")
  cat("==============================\n")
  
  na_counts <- colSums(is.na(ameli_data2[[i]]))
  na_counts <- na_counts[na_counts > 0]
  
  if (length(na_counts) == 0) {
    cat("✅ Aucun NA dans ce dataframe\n")
  } else {
    print(na_counts)
  }
}

ameli_clean <- ameli_data2

# --- ETAPE 5 : Sauvegarde des données nettoyées ---
saveRDS(odisse_clean, file = "data/odisse_clean.rds")
saveRDS(ameli_clean, file = "data/ameli_clean.rds")


library(readr)
library(stringr)

# Créer le dossier s’il n’existe pas
dir.create("data/processed/ameli", recursive = TRUE, showWarnings = FALSE)

# Boucle d’enregistrement
for (i in seq_along(ameli_data2)) {
  file_name <- basename(ameli_files[i])              # ex: demographie-effectifs-et-les-densites.csv
  file_name_clean <- str_replace(file_name, ".csv", "_clean.csv")  # suffixe _clean
  output_path <- file.path("data/processed/ameli", file_name_clean)
  
  write_csv(ameli_data2[[i]], output_path)
  cat("✅ Fichier enregistré :", output_path, "\n")
}

dir.create("data/processed/odisse", recursive = TRUE, showWarnings = FALSE)

for (i in seq_along(odisse_data2)) {
  file_name <- basename(odisse_files[i])             # ex: grippe-passages-urgences-et-actes-sos-medecin_reg.csv
  file_name_clean <- str_replace(file_name, ".csv", "_clean.csv")
  output_path <- file.path("data/processed/odisse", file_name_clean)
  
  write_csv(odisse_data2[[i]], output_path)
  cat("✅ Fichier enregistré :", output_path, "\n")
}

rm(list = ls())
gc()