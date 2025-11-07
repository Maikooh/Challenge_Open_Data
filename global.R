# ============================================================================
# GLOBAL.R - Configuration globale de l'application Shiny
# ============================================================================
# Ce fichier contient :
# - Le chargement des bibliothèques
# - Le chargement des données
# - La préparation des filtres et variables globales
# ============================================================================

# ----------- 1. CHARGEMENT DES BIBLIOTHÈQUES -----------
library(shiny)
library(shinydashboard)
library(tidyverse)
library(dplyr)
library(DT)
library(leaflet)
library(sf)
library(ggplot2)
library(plotly)
library(jsonlite)

# ----------- 2. DÉTERMINATION DU CHEMIN DE BASE -----------
if (basename(getwd()) == "R") {
  chemin_base <- dirname(getwd())
} else {
  chemin_base <- getwd()
}

# ----------- 3. CHARGEMENT DES DONNÉES -----------

## ----- 3.1. Données FINESS -----
finess_data <- tryCatch({
  df <- read.csv(
    file.path(chemin_base, "data/finess_geolocalise.csv"),
    encoding = "UTF-8",
    stringsAsFactors = FALSE
  )
  
  # Conversion des colonnes numériques
  df$longitude <- as.numeric(as.character(df$longitude))
  df$latitude <- as.numeric(as.character(df$latitude))
  df$annee <- as.numeric(as.character(df$annee))
  
  cat("✅ FINESS chargé:", nrow(df), "établissements\n")
  df
}, error = function(e) {
  cat("❌ Erreur FINESS:", e$message, "\n")
  NULL
})

## ----- 3.2. Fonction de chargement JSON -----
charger_json_local <- function(nom_fichier, chemin_base) {
  chemins_possibles <- c(
    file.path(chemin_base, "data", nom_fichier),
    file.path(chemin_base, "data/processed", nom_fichier)
  )
  
  chemin_complet <- NULL
  for (chemin in chemins_possibles) {
    if (file.exists(chemin)) {
      chemin_complet <- chemin
      break
    }
  }
  
  if (is.null(chemin_complet)) {
    cat("❌ Fichier introuvable:", nom_fichier, "\n")
    return(NULL)
  }
  
  tryCatch({
    data <- fromJSON(chemin_complet, flatten = TRUE)
    
    if ("records" %in% names(data)) {
      df <- data$records
      if ("fields" %in% names(df)) {
        df <- df$fields
      }
      cat("✅", nom_fichier, ":", format(nrow(df), big.mark = " "), "enregistrements\n")
      return(df)
    } else {
      df <- as.data.frame(data)
      cat("✅", nom_fichier, ":", format(nrow(df), big.mark = " "), "enregistrements\n")
      return(df)
    }
  }, error = function(e) {
    cat("❌ Erreur:", nom_fichier, ":", e$message, "\n")
    return(NULL)
  })
}

## ----- 3.3. Données des professionnels de santé -----
demographie_effectifs <- tryCatch({
  df <- readRDS(file.path(chemin_base, "data/demographie-effectifs-et-les-densites.rds"))
  
  # Conversion des colonnes numériques
  df$annee <- as.numeric(as.character(df$annee))
  df$effectif <- as.numeric(as.character(df$effectif))
  df$densite <- as.numeric(as.character(df$densite))
  
  cat("✅ Démographie effectifs chargé:", nrow(df), "enregistrements\n")
  df
}, error = function(e) {
  cat("❌ Erreur démographie effectifs:", e$message, "\n")
  NULL
})

ages_moyens <- charger_json_local(
  "demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json",
  chemin_base
)

# Conversion des colonnes numériques dans ages_moyens
if (!is.null(ages_moyens)) {
  if ("part_des_60_ans_et_plus" %in% names(ages_moyens)) {
    ages_moyens$part_des_60_ans_et_plus <- as.numeric(as.character(ages_moyens$part_des_60_ans_et_plus))
  }
}

patientele <- charger_json_local("patientele.json", chemin_base)
secteurs <- charger_json_local("demographie-secteurs-conventionnels.json", chemin_base)

## ----- 3.4. Données géographiques -----
france_depts <- tryCatch({
  cat("📍 Chargement des données géographiques...\n")
  geojson <- st_read(
    "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson",
    quiet = TRUE
  )
  cat("✅ Données géographiques chargées:", nrow(geojson), "départements\n")
  geojson
}, error = function(e) {
  cat("❌ Erreur chargement GeoJSON:", e$message, "\n")
  cat("⚠️  Les cartes ne fonctionneront pas correctement\n")
  NULL
})

# ----------- 4. PRÉPARATION DES FILTRES -----------

## ----- 4.1. Filtres FINESS -----
if (!is.null(finess_data)) {
  # Convertir les années en numérique et filtrer les NA
  finess_data$annee <- as.numeric(as.character(finess_data$annee))
  
  liste_categories <- finess_data |>
    distinct(libcategetab) |>
    arrange(libcategetab) |>
    pull(libcategetab)
  
  liste_depts_finess <- finess_data |>
    distinct(departement, libdepartement) |>
    arrange(departement) |>
    filter(!is.na(libdepartement)) |>
    mutate(display = paste0(departement, " - ", libdepartement))
  
  choix_depts_finess <- setNames(liste_depts_finess$departement, liste_depts_finess$display)
  
  liste_annees_finess <- sort(unique(finess_data$annee[!is.na(finess_data$annee)]), decreasing = TRUE)
  
  # Calculer min/max pour les sliders
  annee_min_finess <- if (length(liste_annees_finess) > 0) min(liste_annees_finess) else 2010
  annee_max_finess <- if (length(liste_annees_finess) > 0) max(liste_annees_finess) else 2024
} else {
  liste_categories <- character(0)
  choix_depts_finess <- character(0)
  liste_annees_finess <- numeric(0)
  annee_min_finess <- 2010
  annee_max_finess <- 2024
}

## ----- 4.2. Filtres Professionnels -----
if (!is.null(demographie_effectifs)) {
  # Convertir les années en numérique et filtrer les NA
  demographie_effectifs$annee <- as.numeric(as.character(demographie_effectifs$annee))
  
  liste_annees_pro <- sort(unique(demographie_effectifs$annee[!is.na(demographie_effectifs$annee)]), decreasing = TRUE)
  
  liste_professions <- demographie_effectifs |>
    distinct(profession_sante) |>
    filter(!grepl("^Ensemble", profession_sante)) |>
    arrange(profession_sante) |>
    pull(profession_sante)
  
  liste_regions <- demographie_effectifs |>
    distinct(region, libelle_region) |>
    filter(!is.na(region), !is.na(libelle_region)) |>
    arrange(region) |>
    mutate(display = paste0(region, " - ", libelle_region))
  
  choix_regions <- setNames(liste_regions$region, liste_regions$display)
  
  liste_departements <- demographie_effectifs |>
    distinct(departement, libelle_departement) |>
    filter(!is.na(departement), !is.na(libelle_departement)) |>
    arrange(departement) |>
    mutate(display = paste0(departement, " - ", libelle_departement))
  
  choix_departements <- setNames(liste_departements$departement, liste_departements$display)
  
  liste_classes_age <- demographie_effectifs |>
    distinct(classe_age, libelle_classe_age) |>
    filter(!is.na(libelle_classe_age)) |>
    arrange(classe_age) |>
    pull(libelle_classe_age)
  
  # Calculer min/max pour les sliders
  annee_min_pro <- if (length(liste_annees_pro) > 0) min(liste_annees_pro) else 2010
  annee_max_pro <- if (length(liste_annees_pro) > 0) max(liste_annees_pro) else 2024
} else {
  liste_annees_pro <- numeric(0)
  liste_professions <- character(0)
  choix_regions <- character(0)
  choix_departements <- character(0)
  liste_classes_age <- character(0)
  annee_min_pro <- 2010
  annee_max_pro <- 2024
}

cat("\n✅ Chargement global terminé\n")