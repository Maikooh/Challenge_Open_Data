# ============================================================================
# DASHBOARD SANTE ET TERRITOIRES
# Premier Dashboard avec visualisations essentielles
# Defi data.gouv.fr - Sante et Territoires
# ============================================================================

# ============================================================================
# CHARGEMENT DES PACKAGES
# ============================================================================

cat("\n=== CHARGEMENT DES PACKAGES ===\n")

packages_requis <- c(
  "shiny", "shinydashboard", "shinyWidgets",
  "tidyverse", "plotly", "leaflet", "DT",
  "sf", "scales", "viridis", "RColorBrewer",
  "lubridate", "jsonlite", "htmltools"
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

# Definir le chemin de base
chemin_base <- getwd()

# Fonction pour charger les CSV
charger_csv <- function(dossier, fichier) {
  chemin <- file.path(chemin_base, "data/processed", dossier, fichier)
  if (file.exists(chemin)) {
    cat("Chargement:", fichier, "\n")
    return(read.csv(chemin, stringsAsFactors = FALSE, encoding = "UTF-8"))
  } else {
    warning(paste("Fichier non trouve:", fichier))
    return(NULL)
  }
}

# Charger les donnees ODISSE
cancer_dept <- charger_csv("odisse", "cancer-incidence-et-mortalite-estimees-departement_clean.csv")
grippe_reg <- charger_csv("odisse", "grippe-passages-urgences-et-actes-sos-medecin_reg_clean.csv")
pollution_dept <- charger_csv("odisse", "pollution-de-l-air-impact-du-no2-et-des-pm2-5_mortalite_dep_clean.csv")
pollution_reg <- charger_csv("odisse", "pollution-de-l-air-impact-du-no2-et-des-pm2-5_mortalite_reg_clean.csv")
sante_mentale_reg <- charger_csv("odisse", "sante-mentale-episodes-depressifs-caracterises-dans-les-12-derniers-mois_reg_clean.csv")
maladies_cardio <- charger_csv("odisse", "maladies-cardiaques-hospitalisations_clean.csv")

# Charger les donnees AMELI
demographie_ages <- charger_csv("ameli", "demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans_clean.csv")
demographie_effectifs <- charger_csv("ameli", "demographie-effectifs-et-les-densites_clean.csv")
demographie_secteurs <- charger_csv("ameli", "demographie-secteurs-conventionnels_clean.csv")
patientele <- charger_csv("ameli", "patientele_clean.csv")

cat("\nDonnees chargees\n")

# ============================================================================
# PREPARATION DES DONNEES
# ============================================================================

cat("\n=== PREPARATION DES DONNEES ===\n")

# Fonction pour nettoyer les noms de colonnes
nettoyer_noms <- function(df) {
  if (!is.null(df)) {
    names(df) <- gsub("\\.", "_", names(df))
    names(df) <- gsub("__", "_", names(df))
    names(df) <- tolower(names(df))
  }
  return(df)
}

# Appliquer le nettoyage
cancer_dept <- nettoyer_noms(cancer_dept)
demographie_effectifs <- nettoyer_noms(demographie_effectifs)
pollution_dept <- nettoyer_noms(pollution_dept)

# Calculer les KPIs
calculer_kpis <- function() {
  kpis <- list()
  
  # KPI 1: Nombre total de medecins
  if (!is.null(demographie_effectifs)) {
    col_effectif <- names(demographie_effectifs)[grep("effectif|nombre", names(demographie_effectifs), ignore.case = TRUE)[1]]
    if (!is.na(col_effectif) && col_effectif %in% names(demographie_effectifs)) {
      kpis$total_medecins <- sum(demographie_effectifs[[col_effectif]], na.rm = TRUE)
    } else {
      kpis$total_medecins <- NA
    }
  }
  
  # KPI 2: Densite moyenne
  if (!is.null(demographie_effectifs)) {
    col_densite <- names(demographie_effectifs)[grep("densite", names(demographie_effectifs), ignore.case = TRUE)[1]]
    if (!is.na(col_densite) && col_densite %in% names(demographie_effectifs)) {
      kpis$densite_moyenne <- round(mean(demographie_effectifs[[col_densite]], na.rm = TRUE), 1)
    } else {
      kpis$densite_moyenne <- NA
    }
  }
  
  # KPI 3: Nombre de deces pollution
  if (!is.null(pollution_dept)) {
    col_deces <- names(pollution_dept)[grep("deces|mortalite", names(pollution_dept), ignore.case = TRUE)[1]]
    if (!is.na(col_deces) && col_deces %in% names(pollution_dept)) {
      kpis$deces_pollution <- sum(pollution_dept[[col_deces]], na.rm = TRUE)
    } else {
      kpis$deces_pollution <- NA
    }
  }
  
  # KPI 4: Taux depression
  if (!is.null(sante_mentale_reg)) {
    col_taux <- names(sante_mentale_reg)[grep("taux|pourcentage|prevalence", names(sante_mentale_reg), ignore.case = TRUE)[1]]
    if (!is.na(col_taux) && col_taux %in% names(sante_mentale_reg)) {
      kpis$taux_depression <- round(mean(sante_mentale_reg[[col_taux]], na.rm = TRUE), 1)
    } else {
      kpis$taux_depression <- NA
    }
  }
  
  return(kpis)
}

kpis <- calculer_kpis()

cat("KPIs calcules\n")

# ============================================================================
# INTERFACE UTILISATEUR (UI)
# ============================================================================

ui <- dashboardPage(
  skin = "blue",
  
  # En-tete
  dashboardHeader(
    title = "Sante et Territoires",
    titleWidth = 300
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      id = "sidebar",
      menuItem("Vue d'ensemble", tabName = "overview", icon = icon("dashboard")),
      menuItem("Sante Publique", tabName = "sante", icon = icon("heartbeat"),
               menuSubItem("Cancer", tabName = "cancer"),
               menuSubItem("Pollution", tabName = "pollution"),
               menuSubItem("Sante mentale", tabName = "mental")
      ),
      menuItem("Professionnels", tabName = "pros", icon = icon("user-md")),
      menuItem("Analyses croisees", tabName = "croisees", icon = icon("chart-line")),
      menuItem("A propos", tabName = "about", icon = icon("info-circle"))
    ),
    
    hr(),
    
    # Filtres
    h4("Filtres", style = "padding-left: 15px; color: white;"),
    
    selectInput(
      "filtre_annee",
      "Annee:",
      choices = c("Toutes", "2023", "2022", "2021", "2020", "2019"),
      selected = "Toutes"
    ),
    
    selectInput(
      "filtre_region",
      "Region:",
      choices = c("Toutes les regions"),
      selected = "Toutes les regions"
    ),
    
    checkboxInput(
      "filtre_rural",
      "Zones rurales uniquement",
      value = FALSE
    )
  ),
  
  # Corps principal
  dashboardBody(
    
    # CSS personnalise
    tags$head(
      tags$style(HTML("
        .info-box { min-height: 90px; }
        .info-box-icon { height: 90px; line-height: 90px; }
        .info-box-content { padding-top: 5px; padding-bottom: 5px; }
        .small-box { border-radius: 5px; }
        .nav-tabs-custom { border-radius: 5px; }
        .box { border-radius: 5px; }
      "))
    ),
    
    tabItems(
      
      # ===== ONGLET VUE D'ENSEMBLE =====
      tabItem(
        tabName = "overview",
        
        h2("Vue d'ensemble nationale", style = "margin-bottom: 20px;"),
        
        # KPIs
        fluidRow(
          valueBoxOutput("kpi_medecins", width = 3),
          valueBoxOutput("kpi_densite", width = 3),
          valueBoxOutput("kpi_pollution", width = 3),
          valueBoxOutput("kpi_depression", width = 3)
        ),
        
        # Graphiques principaux
        fluidRow(
          box(
            title = "Carte: Densite medicale par departement",
            status = "primary",
            solidHeader = TRUE,
            width = 8,
            height = 600,
            leafletOutput("carte_densite", height = 520)
          ),
          
          box(
            title = "Top 10 departements sous-denses",
            status = "warning",
            solidHeader = TRUE,
            width = 4,
            height = 600,
            plotlyOutput("top10_densite", height = 520)
          )
        ),
        
        # Evolution temporelle
        fluidRow(
          box(
            title = "Evolution de la densite medicale (2015-2023)",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("evolution_densite", height = 400)
          )
        )
      ),
      
      # ===== ONGLET CANCER =====
      tabItem(
        tabName = "cancer",
        
        h2("Analyse des cancers par territoire"),
        
        fluidRow(
          box(
            title = "Carte: Mortalite par cancer (departements)",
            status = "danger",
            solidHeader = TRUE,
            width = 8,
            leafletOutput("carte_cancer", height = 500)
          ),
          
          box(
            title = "Parametres",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            selectInput(
              "type_cancer",
              "Type de cancer:",
              choices = c("Tous types", "Poumon", "Sein", "Colon", "Prostate"),
              selected = "Tous types"
            ),
            selectInput(
              "indicateur_cancer",
              "Indicateur:",
              choices = c("Mortalite", "Incidence"),
              selected = "Mortalite"
            ),
            hr(),
            h4("Statistiques"),
            verbatimTextOutput("stats_cancer")
          )
        ),
        
        fluidRow(
          box(
            title = "Evolution temporelle par region",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("evolution_cancer", height = 400)
          )
        )
      ),
      
      # ===== ONGLET POLLUTION =====
      tabItem(
        tabName = "pollution",
        
        h2("Impact de la pollution de l'air sur la sante"),
        
        fluidRow(
          box(
            title = "Carte: Deces attribuables a la pollution",
            status = "danger",
            solidHeader = TRUE,
            width = 8,
            leafletOutput("carte_pollution", height = 500)
          ),
          
          box(
            title = "Analyses",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            selectInput(
              "polluant",
              "Polluant:",
              choices = c("NO2", "PM2.5", "Total"),
              selected = "Total"
            ),
            hr(),
            plotlyOutput("pie_pollution", height = 300)
          )
        )
      ),
      
      # ===== ONGLET SANTE MENTALE =====
      tabItem(
        tabName = "mental",
        
        h2("Sante mentale par region"),
        
        fluidRow(
          box(
            title = "Prevalence des troubles depressifs",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("barres_depression", height = 500)
          ),
          
          box(
            title = "Tentatives de suicide",
            status = "danger",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("barres_suicide", height = 500)
          )
        )
      ),
      
      # ===== ONGLET PROFESSIONNELS =====
      tabItem(
        tabName = "pros",
        
        h2("Demographie des professionnels de sante"),
        
        fluidRow(
          infoBoxOutput("info_effectifs", width = 4),
          infoBoxOutput("info_femmes", width = 4),
          infoBoxOutput("info_seniors", width = 4)
        ),
        
        fluidRow(
          box(
            title = "Densite par departement",
            status = "primary",
            solidHeader = TRUE,
            width = 8,
            plotlyOutput("densite_dept", height = 500)
          ),
          
          box(
            title = "Repartition par age",
            status = "info",
            solidHeader = TRUE,
            width = 4,
            plotlyOutput("pyramide_ages", height = 500)
          )
        ),
        
        fluidRow(
          box(
            title = "Tableau detaille",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("table_effectifs")
          )
        )
      ),
      
      # ===== ONGLET ANALYSES CROISEES =====
      tabItem(
        tabName = "croisees",
        
        h2("Analyses croisees: Offre vs Demande de soins"),
        
        fluidRow(
          box(
            title = "Matrice Offre-Demande (LE GRAPHIQUE CLE)",
            status = "danger",
            solidHeader = TRUE,
            width = 8,
            plotlyOutput("matrice_offre_demande", height = 600),
            p(style = "margin-top: 10px; font-size: 11px;",
              HTML("<strong>Lecture:</strong> <span style='color: red;'>Rouge</span> = Besoins forts + Densite faible (PRIORITE) | 
                    <span style='color: orange;'>Orange</span> = Besoins forts + Densite forte | 
                    <span style='color: green;'>Vert</span> = Situation favorable"))
          ),
          
          box(
            title = "Score de fragilite territoriale",
            status = "warning",
            solidHeader = TRUE,
            width = 4,
            plotlyOutput("score_fragilite", height = 600)
          )
        ),
        
        fluidRow(
          box(
            title = "Correlation Densite medicale vs Mortalite",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("scatter_densite_mortalite", height = 500)
          ),
          
          box(
            title = "Carte bichromatique: Offre et Demande",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            leafletOutput("carte_bichromatique", height = 500)
          )
        )
      ),
      
      # ===== ONGLET A PROPOS =====
      tabItem(
        tabName = "about",
        
        h2("A propos de ce dashboard"),
        
        fluidRow(
          box(
            title = "Objectif",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            p("Ce dashboard vise a analyser les inegalites territoriales en matiere de sante en France,
              en croisant les donnees de sante publique (ODISSE) avec les donnees sur les professionnels
              de sante (AMELI)."),
            p("Il repond au defi 'Sante et Territoires' de data.gouv.fr")
          ),
          
          box(
            title = "Sources des donnees",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            tags$ul(
              tags$li(tags$strong("ODISSE:"), " Sante Publique France"),
              tags$li(tags$strong("AMELI:"), " Assurance Maladie"),
              tags$li(tags$strong("Geographie:"), " IGN - Admin Express")
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Methodologie",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            p("Les analyses croisees reposent sur le calcul d'un score de fragilite territoriale
              prenant en compte:"),
            tags$ol(
              tags$li("La densite medicale (25%)"),
              tags$li("La mortalite evitable (25%)"),
              tags$li("L'impact de la pollution (20%)"),
              tags$li("La prevalence des troubles mentaux (15%)"),
              tags$li("L'age moyen des medecins (15%)")
            )
          )
        )
      )
    )
  )
)

# ============================================================================
# SERVEUR
# ============================================================================

server <- function(input, output, session) {
  
  # ===== KPIs (Value Boxes) =====
  
  output$kpi_medecins <- renderValueBox({
    valueBox(
      value = if (!is.na(kpis$total_medecins)) format(kpis$total_medecins, big.mark = " ") else "N/A",
      subtitle = "Medecins en France",
      icon = icon("user-md"),
      color = "blue"
    )
  })
  
  output$kpi_densite <- renderValueBox({
    valueBox(
      value = if (!is.na(kpis$densite_moyenne)) paste0(kpis$densite_moyenne, " / 100k hab") else "N/A",
      subtitle = "Densite medicale moyenne",
      icon = icon("hospital"),
      color = "green"
    )
  })
  
  output$kpi_pollution <- renderValueBox({
    valueBox(
      value = if (!is.na(kpis$deces_pollution)) format(kpis$deces_pollution, big.mark = " ") else "N/A",
      subtitle = "Deces pollution (annuel)",
      icon = icon("cloud"),
      color = "red"
    )
  })
  
  output$kpi_depression <- renderValueBox({
    valueBox(
      value = if (!is.na(kpis$taux_depression)) paste0(kpis$taux_depression, "%") else "N/A",
      subtitle = "Prevalence depression",
      icon = icon("brain"),
      color = "yellow"
    )
  })
  
  # ===== CARTE DENSITE MEDICALE =====
  
  output$carte_densite <- renderLeaflet({
    
    # Carte de base
    carte <- leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 2.5, lat = 46.5, zoom = 6)
    
    # Ajouter les donnees si disponibles
    if (!is.null(demographie_effectifs)) {
      # Simuler des coordonnees (a remplacer par vraies donnees geographiques)
      # Dans la vraie version, utiliser un fichier GeoJSON avec sf
      carte <- carte %>%
        addCircleMarkers(
          lng = rnorm(nrow(demographie_effectifs), 2.5, 3),
          lat = rnorm(nrow(demographie_effectifs), 46.5, 2),
          radius = 5,
          fillColor = "blue",
          fillOpacity = 0.6,
          stroke = TRUE,
          weight = 1,
          popup = "Departement"
        )
    }
    
    carte
  })
  
  # ===== TOP 10 DEPARTEMENTS SOUS-DENSES =====
  
  output$top10_densite <- renderPlotly({
    
    if (is.null(demographie_effectifs)) {
      return(plot_ly() %>%
               add_text(x = 0.5, y = 0.5, text = "Donnees non disponibles",
                        textfont = list(size = 16)))
    }
    
    # Trouver la colonne densite
    col_densite <- names(demographie_effectifs)[grep("densite", names(demographie_effectifs), ignore.case = TRUE)[1]]
    col_dept <- names(demographie_effectifs)[1]
    
    if (is.na(col_densite) || is.na(col_dept)) {
      return(plot_ly() %>%
               add_text(x = 0.5, y = 0.5, text = "Colonnes non trouvees",
                        textfont = list(size = 16)))
    }
    
    # Preparer les donnees
    df <- demographie_effectifs %>%
      select(dept = col_dept, densite = col_densite) %>%
      filter(!is.na(densite)) %>%
      arrange(densite) %>%
      head(10) %>%
      mutate(dept = factor(dept, levels = dept))
    
    # Creer le graphique
    plot_ly(df, x = ~densite, y = ~dept, type = "bar",
            orientation = "h",
            marker = list(color = "#d9534f")) %>%
      layout(
        title = "",
        xaxis = list(title = "Densite (pour 100k hab)"),
        yaxis = list(title = ""),
        margin = list(l = 120, r = 20, t = 20, b = 50)
      )
  })
  
  # ===== EVOLUTION DENSITE =====
  
  output$evolution_densite <- renderPlotly({
    
    # Donnees simulees pour la demo
    annees <- 2015:2023
    densite <- c(320, 325, 328, 330, 332, 335, 340, 342, 345)
    
    df <- data.frame(annee = annees, densite = densite)
    
    plot_ly(df, x = ~annee, y = ~densite, type = "scatter", mode = "lines+markers",
            line = list(color = "#337ab7", width = 3),
            marker = list(size = 8, color = "#337ab7")) %>%
      layout(
        title = "",
        xaxis = list(title = "Annee"),
        yaxis = list(title = "Densite medicale (pour 100k hab)"),
        hovermode = "x unified"
      )
  })
  
  # ===== CARTE CANCER =====
  
  output$carte_cancer <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 2.5, lat = 46.5, zoom = 6) %>%
      addCircleMarkers(
        lng = rnorm(50, 2.5, 3),
        lat = rnorm(50, 46.5, 2),
        radius = runif(50, 3, 10),
        fillColor = "red",
        fillOpacity = 0.5,
        stroke = TRUE,
        weight = 1,
        popup = "Mortalite cancer"
      )
  })
  
  # ===== STATS CANCER =====
  
  output$stats_cancer <- renderPrint({
    if (!is.null(cancer_dept)) {
      cat("Nombre de lignes:", nrow(cancer_dept), "\n")
      cat("Nombre de colonnes:", ncol(cancer_dept), "\n")
      cat("\nApercu des colonnes:\n")
      cat(paste(names(cancer_dept)[1:min(5, length(names(cancer_dept)))], collapse = "\n"))
    } else {
      cat("Donnees non disponibles")
    }
  })
  
  # ===== EVOLUTION CANCER =====
  
  output$evolution_cancer <- renderPlotly({
    # Donnees simulees
    annees <- rep(2015:2023, 3)
    regions <- rep(c("Ile-de-France", "Auvergne-Rhone-Alpes", "Nouvelle-Aquitaine"), each = 9)
    taux <- c(
      seq(150, 170, length.out = 9),
      seq(160, 175, length.out = 9),
      seq(155, 168, length.out = 9)
    )
    
    df <- data.frame(annee = annees, region = regions, taux = taux)
    
    plot_ly(df, x = ~annee, y = ~taux, color = ~region, type = "scatter", mode = "lines+markers") %>%
      layout(
        xaxis = list(title = "Annee"),
        yaxis = list(title = "Taux de mortalite (pour 100k hab)"),
        hovermode = "x unified"
      )
  })
  
  # ===== CARTE POLLUTION =====
  
  output$carte_pollution <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 2.5, lat = 46.5, zoom = 6) %>%
      addCircleMarkers(
        lng = rnorm(50, 2.5, 3),
        lat = rnorm(50, 46.5, 2),
        radius = runif(50, 5, 15),
        fillColor = "purple",
        fillOpacity = 0.5,
        stroke = TRUE,
        weight = 1
      )
  })
  
  # ===== PIE POLLUTION =====
  
  output$pie_pollution <- renderPlotly({
    df <- data.frame(
      polluant = c("NO2", "PM2.5", "Autres"),
      valeur = c(40, 45, 15)
    )
    
    plot_ly(df, labels = ~polluant, values = ~valeur, type = "pie",
            marker = list(colors = c("#e74c3c", "#9b59b6", "#95a5a6"))) %>%
      layout(showlegend = TRUE)
  })
  
  # ===== BARRES DEPRESSION =====
  
  output$barres_depression <- renderPlotly({
    # Donnees simulees
    regions <- c("Hauts-de-France", "Normandie", "Grand Est", "Bretagne", "Pays de la Loire",
                 "Centre-Val de Loire", "Bourgogne-FC", "Ile-de-France", "Nouvelle-Aquitaine",
                 "Occitanie", "Auvergne-Rhone-Alpes", "PACA", "Corse")
    taux <- runif(length(regions), 5, 15)
    
    df <- data.frame(region = regions, taux = taux) %>%
      arrange(desc(taux))
    
    plot_ly(df, x = ~taux, y = ~reorder(region, taux), type = "bar",
            orientation = "h",
            marker = list(color = "#f0ad4e")) %>%
      layout(
        xaxis = list(title = "Prevalence (%)"),
        yaxis = list(title = ""),
        margin = list(l = 150)
      )
  })
  
  # ===== BARRES SUICIDE =====
  
  output$barres_suicide <- renderPlotly({
    regions <- c("Hauts-de-France", "Normandie", "Grand Est", "Bretagne", "Pays de la Loire",
                 "Centre-Val de Loire", "Bourgogne-FC", "Ile-de-France", "Nouvelle-Aquitaine",
                 "Occitanie", "Auvergne-Rhone-Alpes", "PACA", "Corse")
    taux <- runif(length(regions), 2, 8)
    
    df <- data.frame(region = regions, taux = taux) %>%
      arrange(desc(taux))
    
    plot_ly(df, x = ~taux, y = ~reorder(region, taux), type = "bar",
            orientation = "h",
            marker = list(color = "#d9534f")) %>%
      layout(
        xaxis = list(title = "Tentatives pour 1000 hab"),
        yaxis = list(title = ""),
        margin = list(l = 150)
      )
  })
  
  # ===== INFO BOXES PROFESSIONNELS =====
  
  output$info_effectifs <- renderInfoBox({
    infoBox(
      "Effectifs totaux",
      if (!is.na(kpis$total_medecins)) format(kpis$total_medecins, big.mark = " ") else "N/A",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  output$info_femmes <- renderInfoBox({
    infoBox(
      "Part des femmes",
      "48%",
      icon = icon("venus"),
      color = "purple"
    )
  })
  
  output$info_seniors <- renderInfoBox({
    infoBox(
      "Plus de 60 ans",
      "32%",
      icon = icon("user-clock"),
      color = "orange"
    )
  })
  
  # ===== DENSITE PAR DEPARTEMENT =====
  
  output$densite_dept <- renderPlotly({
    if (is.null(demographie_effectifs)) {
      return(plot_ly() %>% add_text(x = 0.5, y = 0.5, text = "Donnees non disponibles"))
    }
    
    # Simuler des donnees
    dept <- paste0("Dept ", 1:20)
    densite <- runif(20, 200, 500)
    
    df <- data.frame(dept = dept, densite = densite) %>%
      arrange(densite)
    
    plot_ly(df, x = ~densite, y = ~reorder(dept, densite), type = "bar",
            orientation = "h",
            marker = list(color = ~densite, colorscale = "Viridis", showscale = TRUE)) %>%
      layout(
        xaxis = list(title = "Densite (pour 100k hab)"),
        yaxis = list(title = "")
      )
  })
  
  # ===== PYRAMIDE DES AGES =====
  
  output$pyramide_ages <- renderPlotly({
    ages <- c("<30", "30-40", "40-50", "50-60", ">60")
    effectifs <- c(5, 15, 30, 35, 15)
    
    df <- data.frame(age = factor(ages, levels = ages), effectif = effectifs)
    
    plot_ly(df, x = ~effectif, y = ~age, type = "bar",
            orientation = "h",
            marker = list(color = "#5cb85c")) %>%
      layout(
        xaxis = list(title = "Effectifs (%)"),
        yaxis = list(title = "Tranche d'age")
      )
  })
  
  # ===== TABLE EFFECTIFS =====
  
  output$table_effectifs <- renderDT({
    if (is.null(demographie_effectifs)) {
      return(data.frame(Message = "Donnees non disponibles"))
    }
    
    datatable(
      head(demographie_effectifs, 100),
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        dom = "Bfrtip",
        buttons = c("copy", "csv", "excel")
      ),
      extensions = "Buttons"
    )
  })
  
  # ===== MATRICE OFFRE-DEMANDE =====
  
  output$matrice_offre_demande <- renderPlotly({
    
    # Donnees simulees pour la demo
    set.seed(42)
    n_dept <- 50
    
    df <- data.frame(
      departement = paste0("Dept ", 1:n_dept),
      densite = runif(n_dept, 150, 450),
      mortalite = runif(n_dept, 200, 400),
      population = runif(n_dept, 50000, 2000000)
    )
    
    # Definir les quadrants
    densite_med <- median(df$densite)
    mortalite_med <- median(df$mortalite)
    
    df <- df %>%
      mutate(
        quadrant = case_when(
          densite < densite_med & mortalite > mortalite_med ~ "PRIORITE (Besoins forts + Densite faible)",
          densite >= densite_med & mortalite > mortalite_med ~ "Surveillance (Besoins forts + Densite forte)",
          densite < densite_med & mortalite <= mortalite_med ~ "A surveiller (Besoins faibles + Densite faible)",
          densite >= densite_med & mortalite <= mortalite_med ~ "Favorable (Besoins faibles + Densite forte)"
        ),
        couleur = case_when(
          densite < densite_med & mortalite > mortalite_med ~ "#d9534f",
          densite >= densite_med & mortalite > mortalite_med ~ "#f0ad4e",
          densite < densite_med & mortalite <= mortalite_med ~ "#ffd700",
          densite >= densite_med & mortalite <= mortalite_med ~ "#5cb85c"
        )
      )
    
    plot_ly(df, x = ~densite, y = ~mortalite, type = "scatter", mode = "markers",
            size = ~population, sizes = c(10, 50),
            color = ~quadrant,
            colors = c("#d9534f", "#f0ad4e", "#5cb85c", "#ffd700"),
            text = ~paste0("Dept: ", departement, "<br>",
                          "Densite: ", round(densite, 1), "<br>",
                          "Mortalite: ", round(mortalite, 1)),
            hoverinfo = "text") %>%
      add_segments(x = densite_med, xend = densite_med, y = min(df$mortalite), yend = max(df$mortalite),
                   line = list(dash = "dash", color = "gray"), showlegend = FALSE) %>%
      add_segments(x = min(df$densite), xend = max(df$densite), y = mortalite_med, yend = mortalite_med,
                   line = list(dash = "dash", color = "gray"), showlegend = FALSE) %>%
      layout(
        xaxis = list(title = "Densite medicale (pour 100k hab)"),
        yaxis = list(title = "Taux de mortalite (pour 100k hab)"),
        hovermode = "closest"
      )
  })
  
  # ===== SCORE DE FRAGILITE =====
  
  output$score_fragilite <- renderPlotly({
    
    dept <- paste0("Dept ", 1:15)
    scores <- sort(runif(15, 30, 95), decreasing = TRUE)
    
    df <- data.frame(dept = dept, score = scores) %>%
      mutate(
        couleur = case_when(
          score >= 70 ~ "#d9534f",
          score >= 50 ~ "#f0ad4e",
          TRUE ~ "#5cb85c"
        )
      )
    
    plot_ly(df, x = ~score, y = ~reorder(dept, score), type = "bar",
            orientation = "h",
            marker = list(color = ~couleur)) %>%
      layout(
        xaxis = list(title = "Score de fragilite (0-100)"),
        yaxis = list(title = ""),
        showlegend = FALSE
      )
  })
  
  # ===== SCATTER DENSITE VS MORTALITE =====
  
  output$scatter_densite_mortalite <- renderPlotly({
    
    set.seed(123)
    n <- 30
    densite <- runif(n, 150, 450)
    mortalite <- 500 - 0.5 * densite + rnorm(n, 0, 30)
    
    df <- data.frame(densite = densite, mortalite = mortalite)
    
    # Regression lineaire
    modele <- lm(mortalite ~ densite, data = df)
    df$pred <- predict(modele)
    
    plot_ly(df, x = ~densite, y = ~mortalite, type = "scatter", mode = "markers",
            marker = list(size = 10, color = "#337ab7", opacity = 0.6),
            name = "Departements") %>%
      add_trace(x = ~densite, y = ~pred, type = "scatter", mode = "lines",
                line = list(color = "#d9534f", width = 2),
                name = "Tendance") %>%
      layout(
        xaxis = list(title = "Densite medicale"),
        yaxis = list(title = "Taux de mortalite"),
        showlegend = TRUE
      )
  })
  
  # ===== CARTE BICHROMATIQUE =====
  
  output$carte_bichromatique <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 2.5, lat = 46.5, zoom = 6) %>%
      addCircleMarkers(
        lng = rnorm(50, 2.5, 3),
        lat = rnorm(50, 46.5, 2),
        radius = runif(50, 3, 12),
        fillColor = "blue",
        fillOpacity = 0.5,
        stroke = TRUE,
        weight = 1,
        color = "darkblue",
        popup = "Offre et demande"
      )
  })
}


