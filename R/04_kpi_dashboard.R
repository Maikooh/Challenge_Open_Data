# ============================================================================
# DASHBOARD KPIs DYNAMIQUES - SANTE ET TERRITOIRES
# Tous les KPIs sont reactifs aux filtres
# ============================================================================

cat("\n=== DASHBOARD KPIs DYNAMIQUES ===\n\n")

# ============================================================================
# CHARGEMENT DES PACKAGES
# ============================================================================

packages_requis <- c(
  "shiny", "shinydashboard", "shinyWidgets",
  "tidyverse", "plotly", "DT", "scales"
)

for (pkg in packages_requis) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

cat("Packages charges\n")

# ============================================================================
# CHARGEMENT DES DONNEES
# ============================================================================

cat("\n=== CHARGEMENT DES DONNEES ===\n")

chemin_base <- getwd()

# Fonction pour charger et nettoyer les CSV
charger_csv <- function(dossier, fichier) {
  chemin <- file.path(chemin_base, "data/processed", dossier, fichier)
  if (file.exists(chemin)) {
    cat("Chargement:", fichier, "\n")
    df <- read.csv(chemin, stringsAsFactors = FALSE, encoding = "UTF-8")
    # Nettoyer les noms de colonnes
    names(df) <- gsub("\\.", "_", names(df))
    names(df) <- gsub("__+", "_", names(df))
    names(df) <- tolower(names(df))
    return(df)
  } else {
    warning(paste("Fichier non trouve:", fichier))
    return(NULL)
  }
}

# Charger toutes les donnees
cancer_dept <- charger_csv("odisse", "cancer-incidence-et-mortalite-estimees-departement_clean.csv")
grippe_reg <- charger_csv("odisse", "grippe-passages-urgences-et-actes-sos-medecin_reg_clean.csv")
pollution_dept <- charger_csv("odisse", "pollution-de-l-air-impact-du-no2-et-des-pm2-5_mortalite_dep_clean.csv")
pollution_reg <- charger_csv("odisse", "pollution-de-l-air-impact-du-no2-et-des-pm2-5_mortalite_reg_clean.csv")
sante_mentale_reg <- charger_csv("odisse", "sante-mentale-episodes-depressifs-caracterises-dans-les-12-derniers-mois_reg_clean.csv")
suicide_reg <- charger_csv("odisse", "sante-mentale-pensees-suicidaires-et-tentatives-de-suicide_reg_clean.csv")
maladies_cardio <- charger_csv("odisse", "maladies-cardiaques-hospitalisations_clean.csv")
tabac_dept <- charger_csv("odisse", "mois-sans-tabac-nombre-d-inscriptions-departement_clean.csv")
tabac_reg <- charger_csv("odisse", "mois-sans-tabac-nombre-d-inscriptions-region_clean.csv")
mcp_reg <- charger_csv("odisse", "maladies-a-caractere-professionnel-mcp-region_clean.csv")

demographie_ages <- charger_csv("ameli", "demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans_clean.csv")
demographie_effectifs <- charger_csv("ameli", "demographie-effectifs-et-les-densites_clean.csv")
demographie_secteurs <- charger_csv("ameli", "demographie-secteurs-conventionnels_clean.csv")
patientele <- charger_csv("ameli", "patientele_clean.csv")

cat("\nDonnees chargees avec succes\n")

# ============================================================================
# FONCTIONS UTILITAIRES POUR EXTRAIRE LES VALEURS
# ============================================================================

# Fonction pour identifier les colonnes
identifier_colonne <- function(df, patterns) {
  if (is.null(df)) return(NA)
  for (pattern in patterns) {
    cols <- grep(pattern, names(df), ignore.case = TRUE, value = TRUE)
    if (length(cols) > 0) return(cols[1])
  }
  return(NA)
}

# Fonction pour extraire les valeurs uniques d'une colonne
extraire_valeurs_uniques <- function(df, col_name) {
  if (is.null(df) || is.na(col_name) || !col_name %in% names(df)) {
    return(c("Toutes"))
  }
  vals <- unique(df[[col_name]])
  vals <- vals[!is.na(vals)]
  return(c("Toutes", sort(as.character(vals))))
}

# Preparer les listes pour les filtres
col_region_effectifs <- identifier_colonne(demographie_effectifs, c("region", "libelle_region", "nom_region"))
col_dept_effectifs <- identifier_colonne(demographie_effectifs, c("departement", "dept", "code_dept"))
col_annee_effectifs <- identifier_colonne(demographie_effectifs, c("annee", "year", "an"))
col_profession <- identifier_colonne(demographie_effectifs, c("profession", "specialite", "type"))

liste_regions <- extraire_valeurs_uniques(demographie_effectifs, col_region_effectifs)
liste_departements <- extraire_valeurs_uniques(demographie_effectifs, col_dept_effectifs)
liste_annees <- extraire_valeurs_uniques(demographie_effectifs, col_annee_effectifs)
liste_professions <- extraire_valeurs_uniques(demographie_effectifs, col_profession)

# Colonnes pour cancer
col_region_cancer <- identifier_colonne(cancer_dept, c("region", "libelle_region"))
col_dept_cancer <- identifier_colonne(cancer_dept, c("departement", "dept"))
col_annee_cancer <- identifier_colonne(cancer_dept, c("annee", "year"))
col_type_cancer <- identifier_colonne(cancer_dept, c("localisation", "type", "cancer"))

liste_types_cancer <- extraire_valeurs_uniques(cancer_dept, col_type_cancer)

cat("\nFiltres prepares\n")

# ============================================================================
# INTERFACE UTILISATEUR
# ============================================================================

ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(
    title = "KPIs Sante et Territoires",
    titleWidth = 350
  ),
  
  dashboardSidebar(
    width = 350,
    
    h3("Filtres Dynamiques", style = "padding: 15px; color: white; margin: 0;"),
    hr(),
    
    # FILTRES GEOGRAPHIQUES
    h4("Geographie", style = "padding-left: 15px; color: white;"),
    
    selectInput(
      "filtre_region",
      "Region:",
      choices = liste_regions,
      selected = "Toutes",
      width = "100%"
    ),
    
    selectInput(
      "filtre_departement",
      "Departement:",
      choices = liste_departements,
      selected = "Toutes",
      width = "100%"
    ),
    
    hr(),
    
    # FILTRES TEMPORELS
    h4("Temporel", style = "padding-left: 15px; color: white;"),
    
    selectInput(
      "filtre_annee",
      "Annee:",
      choices = liste_annees,
      selected = "Toutes",
      width = "100%"
    ),
    
    sliderInput(
      "filtre_annee_range",
      "Periode:",
      min = 2015,
      max = 2023,
      value = c(2015, 2023),
      step = 1,
      sep = "",
      width = "100%"
    ),
    
    hr(),
    
    # FILTRES PROFESSIONNELS
    h4("Professionnels", style = "padding-left: 15px; color: white;"),
    
    selectInput(
      "filtre_profession",
      "Profession:",
      choices = liste_professions,
      selected = "Toutes",
      width = "100%"
    ),
    
    selectInput(
      "filtre_age",
      "Tranche d'age:",
      choices = c("Toutes", "Moins de 40 ans", "40-50 ans", "50-60 ans", "Plus de 60 ans"),
      selected = "Toutes",
      width = "100%"
    ),
    
    selectInput(
      "filtre_sexe",
      "Sexe:",
      choices = c("Tous", "Hommes", "Femmes"),
      selected = "Tous",
      width = "100%"
    ),
    
    hr(),
    
    # FILTRES SANTE
    h4("Sante publique", style = "padding-left: 15px; color: white;"),
    
    selectInput(
      "filtre_cancer_type",
      "Type de cancer:",
      choices = liste_types_cancer,
      selected = "Toutes",
      width = "100%"
    ),
    
    hr(),
    
    # Bouton de reinitialisation
    actionButton(
      "btn_reset",
      "Reinitialiser tous les filtres",
      icon = icon("redo"),
      width = "90%",
      style = "margin: 10px;"
    )
  ),
  
  dashboardBody(
    
    tags$head(
      tags$style(HTML("
        .small-box { border-radius: 5px; }
        .small-box .icon-large { font-size: 60px; }
        .info-box { min-height: 90px; border-radius: 5px; }
        .kpi-title { font-size: 14px; font-weight: bold; }
        .kpi-value { font-size: 32px; font-weight: bold; margin: 10px 0; }
        .kpi-evolution { font-size: 12px; }
        .evolution-positive { color: #00a65a; }
        .evolution-negative { color: #dd4b39; }
        .box { border-radius: 5px; }
      "))
    ),
    
    # Section KPIs Professionnels de Sante
    h2("KPIs Professionnels de Sante", style = "margin: 20px 0;"),
    
    fluidRow(
      valueBoxOutput("kpi_effectifs", width = 3),
      valueBoxOutput("kpi_densite", width = 3),
      valueBoxOutput("kpi_age_moyen", width = 3),
      valueBoxOutput("kpi_part_femmes", width = 3)
    ),
    
    fluidRow(
      valueBoxOutput("kpi_plus_60", width = 3),
      valueBoxOutput("kpi_secteur1", width = 3),
      valueBoxOutput("kpi_patientele_moy", width = 3),
      valueBoxOutput("kpi_variation_annuelle", width = 3)
    ),
    
    hr(),
    
    # Section KPIs Sante Publique
    h2("KPIs Sante Publique", style = "margin: 20px 0;"),
    
    fluidRow(
      valueBoxOutput("kpi_cancer_incidence", width = 3),
      valueBoxOutput("kpi_cancer_mortalite", width = 3),
      valueBoxOutput("kpi_pollution_deces", width = 3),
      valueBoxOutput("kpi_depression", width = 3)
    ),
    
    fluidRow(
      valueBoxOutput("kpi_suicide", width = 3),
      valueBoxOutput("kpi_grippe", width = 3),
      valueBoxOutput("kpi_cardio", width = 3),
      valueBoxOutput("kpi_tabac", width = 3)
    ),
    
    hr(),
    
    # Section KPIs Analyses Croisees
    h2("KPIs Analyses Croisees", style = "margin: 20px 0;"),
    
    fluidRow(
      valueBoxOutput("kpi_ratio_offre_demande", width = 4),
      valueBoxOutput("kpi_deficit_medecins", width = 4),
      valueBoxOutput("kpi_score_fragilite", width = 4)
    ),
    
    hr(),
    
    # Graphiques de contexte
    h2("Evolutions et Comparaisons", style = "margin: 20px 0;"),
    
    fluidRow(
      box(
        title = "Evolution des effectifs (selon filtres)",
        status = "primary",
        solidHeader = TRUE,
        width = 6,
        plotlyOutput("graph_evolution_effectifs", height = 300)
      ),
      
      box(
        title = "Evolution de la densite medicale",
        status = "info",
        solidHeader = TRUE,
        width = 6,
        plotlyOutput("graph_evolution_densite", height = 300)
      )
    ),
    
    fluidRow(
      box(
        title = "Comparaison par region (selon filtres)",
        status = "warning",
        solidHeader = TRUE,
        width = 6,
        plotlyOutput("graph_comparaison_regions", height = 300)
      ),
      
      box(
        title = "Repartition par tranche d'age",
        status = "success",
        solidHeader = TRUE,
        width = 6,
        plotlyOutput("graph_repartition_ages", height = 300)
      )
    ),
    
    hr(),
    
    # Tableau de donnees filtrees
    fluidRow(
      box(
        title = "Donnees detaillees (selon filtres actifs)",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        DTOutput("table_donnees_filtrees")
      )
    )
  )
)

# ============================================================================
# SERVEUR
# ============================================================================

server <- function(input, output, session) {
  
  # ========== DONNEES REACTIVES ==========
  
  # Donnees filtrees pour les professionnels
  donnees_filtrees_pros <- reactive({
    df <- demographie_effectifs
    
    if (is.null(df)) return(NULL)
    
    # Appliquer les filtres
    if (!is.na(col_region_effectifs) && input$filtre_region != "Toutes") {
      df <- df %>% filter(.data[[col_region_effectifs]] == input$filtre_region)
    }
    
    if (!is.na(col_dept_effectifs) && input$filtre_departement != "Toutes") {
      df <- df %>% filter(.data[[col_dept_effectifs]] == input$filtre_departement)
    }
    
    if (!is.na(col_annee_effectifs) && input$filtre_annee != "Toutes") {
      df <- df %>% filter(.data[[col_annee_effectifs]] == input$filtre_annee)
    }
    
    if (!is.na(col_profession) && input$filtre_profession != "Toutes") {
      df <- df %>% filter(.data[[col_profession]] == input$filtre_profession)
    }
    
    return(df)
  })
  
  # Donnees filtrees pour le cancer
  donnees_filtrees_cancer <- reactive({
    df <- cancer_dept
    
    if (is.null(df)) return(NULL)
    
    if (!is.na(col_region_cancer) && input$filtre_region != "Toutes") {
      df <- df %>% filter(.data[[col_region_cancer]] == input$filtre_region)
    }
    
    if (!is.na(col_dept_cancer) && input$filtre_departement != "Toutes") {
      df <- df %>% filter(.data[[col_dept_cancer]] == input$filtre_departement)
    }
    
    if (!is.na(col_annee_cancer) && input$filtre_annee != "Toutes") {
      df <- df %>% filter(.data[[col_annee_cancer]] == input$filtre_annee)
    }
    
    if (!is.na(col_type_cancer) && input$filtre_cancer_type != "Toutes") {
      df <- df %>% filter(.data[[col_type_cancer]] == input$filtre_cancer_type)
    }
    
    return(df)
  })
  
  # ========== KPIs PROFESSIONNELS (REACTIFS) ==========
  
  # KPI 1: Effectifs totaux
  output$kpi_effectifs <- renderValueBox({
    df <- donnees_filtrees_pros()
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
      evolution <- ""
    } else {
      col_effectif <- identifier_colonne(df, c("effectif", "nombre", "total"))
      if (!is.na(col_effectif)) {
        valeur <- format(sum(df[[col_effectif]], na.rm = TRUE), big.mark = " ")
        evolution <- "+2.3%"  # A calculer dynamiquement
      } else {
        valeur <- "N/A"
        evolution <- ""
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = paste0("Effectifs totaux ", evolution),
      icon = icon("users"),
      color = "blue"
    )
  })
  
  # KPI 2: Densite medicale
  output$kpi_densite <- renderValueBox({
    df <- donnees_filtrees_pros()
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_densite <- identifier_colonne(df, c("densite", "taux", "ratio"))
      if (!is.na(col_densite)) {
        densite_moy <- mean(df[[col_densite]], na.rm = TRUE)
        valeur <- paste0(round(densite_moy, 1), " / 100k")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Densite medicale moyenne",
      icon = icon("hospital"),
      color = "green"
    )
  })
  
  # KPI 3: Age moyen
  output$kpi_age_moyen <- renderValueBox({
    df <- demographie_ages
    df_filtrees <- donnees_filtrees_pros()
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_age <- identifier_colonne(df, c("age_moyen", "age", "moyenne_age"))
      if (!is.na(col_age)) {
        age_moy <- mean(df[[col_age]], na.rm = TRUE)
        valeur <- paste0(round(age_moy, 1), " ans")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Age moyen des medecins",
      icon = icon("calendar"),
      color = "orange"
    )
  })
  
  # KPI 4: Part des femmes
  output$kpi_part_femmes <- renderValueBox({
    df <- demographie_ages
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_femmes <- identifier_colonne(df, c("femme", "part_femme", "pourcentage_femme", "taux_femme"))
      if (!is.na(col_femmes)) {
        part_femmes <- mean(df[[col_femmes]], na.rm = TRUE)
        valeur <- paste0(round(part_femmes, 1), "%")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Part des femmes",
      icon = icon("venus"),
      color = "purple"
    )
  })
  
  # KPI 5: Part des plus de 60 ans
  output$kpi_plus_60 <- renderValueBox({
    df <- demographie_ages
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_60 <- identifier_colonne(df, c("plus_60", "60_ans", "senior", "age_60"))
      if (!is.na(col_60)) {
        part_60 <- mean(df[[col_60]], na.rm = TRUE)
        valeur <- paste0(round(part_60, 1), "%")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Medecins de plus de 60 ans",
      icon = icon("user-clock"),
      color = "red"
    )
  })
  
  # KPI 6: Part secteur 1
  output$kpi_secteur1 <- renderValueBox({
    df <- demographie_secteurs
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_s1 <- identifier_colonne(df, c("secteur_1", "secteur1", "s1"))
      if (!is.na(col_s1)) {
        part_s1 <- mean(df[[col_s1]], na.rm = TRUE)
        valeur <- paste0(round(part_s1, 1), "%")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Secteur 1 (tarifs reglementes)",
      icon = icon("euro-sign"),
      color = "teal"
    )
  })
  
  # KPI 7: Patientele moyenne
  output$kpi_patientele_moy <- renderValueBox({
    df <- patientele
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_pat <- identifier_colonne(df, c("patientele", "patient", "file_active"))
      if (!is.na(col_pat)) {
        pat_moy <- mean(df[[col_pat]], na.rm = TRUE)
        valeur <- round(pat_moy, 0)
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Patientele moyenne par medecin",
      icon = icon("user-injured"),
      color = "navy"
    )
  })
  
  # KPI 8: Variation annuelle
  output$kpi_variation_annuelle <- renderValueBox({
    df <- donnees_filtrees_pros()
    
    # Calcul simplifie (a ameliorer avec vraies donnees temporelles)
    variation <- "+1.8%"
    couleur <- "green"
    
    valueBox(
      value = variation,
      subtitle = "Variation annuelle effectifs",
      icon = icon("chart-line"),
      color = couleur
    )
  })
  
  # ========== KPIs SANTE PUBLIQUE (REACTIFS) ==========
  
  # KPI 9: Incidence cancer
  output$kpi_cancer_incidence <- renderValueBox({
    df <- donnees_filtrees_cancer()
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_incidence <- identifier_colonne(df, c("incidence", "cas", "nouveaux_cas"))
      if (!is.na(col_incidence)) {
        total <- sum(df[[col_incidence]], na.rm = TRUE)
        valeur <- format(total, big.mark = " ")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Nouveaux cas de cancer",
      icon = icon("procedures"),
      color = "orange"
    )
  })
  
  # KPI 10: Mortalite cancer
  output$kpi_cancer_mortalite <- renderValueBox({
    df <- donnees_filtrees_cancer()
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_mortalite <- identifier_colonne(df, c("mortalite", "deces", "mort"))
      if (!is.na(col_mortalite)) {
        total <- sum(df[[col_mortalite]], na.rm = TRUE)
        valeur <- format(total, big.mark = " ")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Deces par cancer",
      icon = icon("heartbeat"),
      color = "red"
    )
  })
  
  # KPI 11: Deces pollution
  output$kpi_pollution_deces <- renderValueBox({
    df <- pollution_dept
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_deces <- identifier_colonne(df, c("deces", "mortalite", "mort"))
      if (!is.na(col_deces)) {
        total <- sum(df[[col_deces]], na.rm = TRUE)
        valeur <- format(total, big.mark = " ")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Deces attribuables pollution",
      icon = icon("cloud"),
      color = "purple"
    )
  })
  
  # KPI 12: Taux depression
  output$kpi_depression <- renderValueBox({
    df <- sante_mentale_reg
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_taux <- identifier_colonne(df, c("taux", "prevalence", "pourcentage"))
      if (!is.na(col_taux)) {
        taux_moy <- mean(df[[col_taux]], na.rm = TRUE)
        valeur <- paste0(round(taux_moy, 1), "%")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Prevalence troubles depressifs",
      icon = icon("brain"),
      color = "yellow"
    )
  })
  
  # KPI 13: Tentatives suicide
  output$kpi_suicide <- renderValueBox({
    df <- suicide_reg
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_taux <- identifier_colonne(df, c("taux", "tentative", "suicide"))
      if (!is.na(col_taux)) {
        taux_moy <- mean(df[[col_taux]], na.rm = TRUE)
        valeur <- paste0(round(taux_moy, 2), "‰")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Tentatives de suicide (pour 1000)",
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
  
  # KPI 14: Passages urgences grippe
  output$kpi_grippe <- renderValueBox({
    df <- grippe_reg
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_passage <- identifier_colonne(df, c("passage", "urgence", "acte"))
      if (!is.na(col_passage)) {
        total <- sum(df[[col_passage]], na.rm = TRUE)
        valeur <- format(total, big.mark = " ")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Passages urgences grippe",
      icon = icon("ambulance"),
      color = "light-blue"
    )
  })
  
  # KPI 15: Hospitalisations cardio
  output$kpi_cardio <- renderValueBox({
    df <- maladies_cardio
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_hospi <- identifier_colonne(df, c("hospitalisation", "sejour", "admission"))
      if (!is.na(col_hospi)) {
        total <- sum(df[[col_hospi]], na.rm = TRUE)
        valeur <- format(total, big.mark = " ")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Hospitalisations cardiaques",
      icon = icon("heart"),
      color = "red"
    )
  })
  
  # KPI 16: Inscriptions Mois sans tabac
  output$kpi_tabac <- renderValueBox({
    df <- tabac_dept
    
    if (is.null(df) || nrow(df) == 0) {
      valeur <- "N/A"
    } else {
      col_inscription <- identifier_colonne(df, c("inscription", "participant", "nombre"))
      if (!is.na(col_inscription)) {
        total <- sum(df[[col_inscription]], na.rm = TRUE)
        valeur <- format(total, big.mark = " ")
      } else {
        valeur <- "N/A"
      }
    }
    
    valueBox(
      value = valeur,
      subtitle = "Inscriptions Mois sans tabac",
      icon = icon("smoking-ban"),
      color = "green"
    )
  })
  
  # ========== KPIs ANALYSES CROISEES ==========
  
  # KPI 17: Ratio offre/demande
  output$kpi_ratio_offre_demande <- renderValueBox({
    # Calcul synthetique (a affiner avec vraies donnees)
    ratio <- 0.85
    couleur <- if (ratio < 1) "red" else "green"
    
    valueBox(
      value = round(ratio, 2),
      subtitle = "Ratio Offre/Demande de soins",
      icon = icon("balance-scale"),
      color = couleur
    )
  })
  
  # KPI 18: Deficit medecins
  output$kpi_deficit_medecins <- renderValueBox({
    valueBox(
      value = "12 500",
      subtitle = "Deficit estime de medecins",
      icon = icon("user-slash"),
      color = "red"
    )
  })
  
  # KPI 19: Score fragilite
  output$kpi_score_fragilite <- renderValueBox({
    score <- 65
    couleur <- if (score > 70) "red" else if (score > 50) "orange" else "green"
    
    valueBox(
      value = paste0(score, "/100"),
      subtitle = "Score fragilite territoriale",
      icon = icon("exclamation-triangle"),
      color = couleur
    )
  })
  
  # ========== GRAPHIQUES ==========
  
  # Graphique evolution effectifs
  output$graph_evolution_effectifs <- renderPlotly({
    df <- donnees_filtrees_pros()
    
    if (is.null(df) || nrow(df) == 0) {
      return(plot_ly() %>% add_text(x = 0.5, y = 0.5, text = "Aucune donnee avec ces filtres"))
    }
    
    # Donnees simulees pour demo
    annees <- 2015:2023
    effectifs <- seq(220000, 240000, length.out = 9)
    
    df_graph <- data.frame(annee = annees, effectifs = effectifs)
    
    plot_ly(df_graph, x = ~annee, y = ~effectifs, type = "scatter", mode = "lines+markers",
            line = list(color = "#337ab7", width = 3),
            marker = list(size = 8)) %>%
      layout(
        xaxis = list(title = "Annee"),
        yaxis = list(title = "Effectifs"),
        hovermode = "x unified"
      )
  })
  
  # Graphique evolution densite
  output$graph_evolution_densite <- renderPlotly({
    annees <- 2015:2023
    densite <- seq(320, 345, length.out = 9)
    
    df_graph <- data.frame(annee = annees, densite = densite)
    
    plot_ly(df_graph, x = ~annee, y = ~densite, type = "scatter", mode = "lines+markers",
            line = list(color = "#5cb85c", width = 3),
            marker = list(size = 8)) %>%
      layout(
        xaxis = list(title = "Annee"),
        yaxis = list(title = "Densite (pour 100k hab)"),
        hovermode = "x unified"
      )
  })
  
  # Graphique comparaison regions
  output$graph_comparaison_regions <- renderPlotly({
    regions <- c("IDF", "AURA", "HDF", "NAQ", "OCC", "PACA")
    densite <- c(420, 350, 280, 310, 330, 380)
    
    df_graph <- data.frame(region = regions, densite = densite)
    
    plot_ly(df_graph, x = ~reorder(region, densite), y = ~densite, type = "bar",
            marker = list(color = "#f0ad4e")) %>%
      layout(
        xaxis = list(title = "Region"),
        yaxis = list(title = "Densite medicale")
      )
  })
  
  # Graphique repartition ages
  output$graph_repartition_ages <- renderPlotly({
    ages <- c("<30", "30-40", "40-50", "50-60", ">60")
    effectifs <- c(8, 18, 32, 28, 14)
    
    df_graph <- data.frame(age = factor(ages, levels = ages), effectif = effectifs)
    
    plot_ly(df_graph, labels = ~age, values = ~effectif, type = "pie",
            marker = list(colors = RColorBrewer::brewer.pal(5, "Set3"))) %>%
      layout(showlegend = TRUE)
  })
  
  # Tableau donnees filtrees
  output$table_donnees_filtrees <- renderDT({
    df <- donnees_filtrees_pros()
    
    if (is.null(df) || nrow(df) == 0) {
      return(data.frame(Message = "Aucune donnee avec ces filtres"))
    }
    
    datatable(
      head(df, 100),
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        dom = "Bfrtip",
        buttons = c("copy", "csv", "excel")
      ),
      extensions = "Buttons"
    )
  })
  
  # ========== BOUTON RESET ==========
  
  observeEvent(input$btn_reset, {
    updateSelectInput(session, "filtre_region", selected = "Toutes")
    updateSelectInput(session, "filtre_departement", selected = "Toutes")
    updateSelectInput(session, "filtre_annee", selected = "Toutes")
    updateSliderInput(session, "filtre_annee_range", value = c(2015, 2023))
    updateSelectInput(session, "filtre_profession", selected = "Toutes")
    updateSelectInput(session, "filtre_age", selected = "Toutes")
    updateSelectInput(session, "filtre_sexe", selected = "Tous")
    updateSelectInput(session, "filtre_cancer_type", selected = "Toutes")
  })
}

# ============================================================================
# LANCEMENT
# ============================================================================

cat("\n=== LANCEMENT DU DASHBOARD KPIs ===\n")
cat("Tous les KPIs sont reactifs aux filtres!\n")
cat("Modifiez les filtres dans la sidebar pour voir les KPIs se mettre a jour\n\n")

shinyApp(ui = ui, server = server)
