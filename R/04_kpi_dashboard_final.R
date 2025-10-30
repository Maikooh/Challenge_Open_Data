# ============================================================================
# Dashboard Shiny - Santé et Territoires
# KPIs Dynamiques : Nombre de médecins et Densité médicale
# ============================================================================

# Chargement des packages
library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)

# ============================================================================
# CHARGEMENT DES DONNÉES
# ============================================================================

# Définir le chemin de base
# Si le script est dans R/, remonter d'un niveau
if (basename(getwd()) == "R") {
  chemin_base <- dirname(getwd())
} else {
  chemin_base <- getwd()
}

cat("Chemin de base:", chemin_base, "\n")

# Charger les données démographiques
demographie_effectifs <- read.csv(
  file.path(chemin_base, "data/processed/ameli/demographie-effectifs-et-les-densites_clean.csv"),
  encoding = "UTF-8",
  stringsAsFactors = FALSE
)

cat("Données chargées:", nrow(demographie_effectifs), "lignes\n")
cat("Colonnes:", paste(names(demographie_effectifs), collapse = ", "), "\n")

# ============================================================================
# PRÉPARATION DES LISTES POUR LES FILTRES
# ============================================================================

# Liste des années (triée par ordre décroissant)
liste_annees <- sort(unique(demographie_effectifs$annee), decreasing = TRUE)

# Liste des professions (avec libellé)
# Exclure les agrégats (lignes commençant par "Ensemble")
liste_professions <- demographie_effectifs %>%
  select(profession_sante) %>%
  distinct() %>%
  filter(!grepl("^Ensemble", profession_sante)) %>%
  arrange(profession_sante) %>%
  pull(profession_sante)

# Liste des régions (avec code et libellé)
liste_regions <- demographie_effectifs %>%
  select(region, libelle_region) %>%
  distinct() %>%
  arrange(region) %>%
  mutate(display = paste0(region, " - ", libelle_region))

choix_regions <- setNames(liste_regions$region, liste_regions$display)

# Liste des départements (avec code et libellé)
liste_departements <- demographie_effectifs %>%
  select(departement, libelle_departement) %>%
  distinct() %>%
  arrange(departement) %>%
  mutate(display = paste0(departement, " - ", libelle_departement))

choix_departements <- setNames(liste_departements$departement, liste_departements$display)

# Liste des classes d'âge (avec libellé)
liste_classes_age <- demographie_effectifs %>%
  select(classe_age, libelle_classe_age) %>%
  distinct() %>%
  # Ordonner selon la classe_age pour avoir un ordre logique
  arrange(classe_age) %>%
  pull(libelle_classe_age)

# ============================================================================
# INTERFACE UTILISATEUR (UI)
# ============================================================================

ui <- dashboardPage(
  
  # En-tête
  dashboardHeader(
    title = "Santé & Territoires",
    titleWidth = 300
  ),
  
  # Sidebar avec les filtres
  dashboardSidebar(
    width = 300,
    
    sidebarMenu(
      menuItem("Tableau de bord", tabName = "dashboard", icon = icon("dashboard")),
      
      hr(),
      
      # FILTRES
      h4("Filtres", style = "padding-left: 15px; color: white;"),
      
      # Filtre Année
      selectInput(
        inputId = "filtre_annee",
        label = "Année",
        choices = liste_annees,
        selected = max(liste_annees)
      ),
      
      # Filtre Profession
      selectInput(
        inputId = "filtre_profession",
        label = "Profession",
        choices = c("Toutes" = "TOUTES", liste_professions),
        selected = "TOUTES"
      ),
      
      # Filtre Région
      selectInput(
        inputId = "filtre_region",
        label = "Région",
        choices = c("Toute la France" = "99", choix_regions),
        selected = "99"
      ),
      
      # Filtre Département (conditionnel selon la région)
      selectInput(
        inputId = "filtre_departement",
        label = "Département",
        choices = c("Tous" = "999", choix_departements),
        selected = "999"
      ),
      
      # Filtre Classe d'âge
      selectInput(
        inputId = "filtre_classe_age",
        label = "Classe d'âge",
        choices = c("Tous les âges" = "tout_age", liste_classes_age),
        selected = "tout_age"
      ),
      
      hr(),
      
      # Bouton Reset
      actionButton(
        inputId = "reset_filtres",
        label = "Réinitialiser les filtres",
        icon = icon("refresh"),
        width = "90%",
        style = "margin-left: 15px;"
      )
    )
  ),
  
  # Corps du dashboard
  dashboardBody(
    
    # Style CSS personnalisé
    tags$head(
      tags$style(HTML("
        .small-box {
          border-radius: 5px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .small-box h3 {
          font-size: 38px;
          font-weight: bold;
        }
        .small-box p {
          font-size: 16px;
        }
      "))
    ),
    
    tabItems(
      tabItem(
        tabName = "dashboard",
        
        # Titre de la page
        fluidRow(
          column(
            width = 12,
            h2("Indicateurs Clés - Professionnels de Santé"),
            p("Données AMELI - Source : data.gouv.fr")
          )
        ),
        
        # Ligne 1 : KPIs principaux
        fluidRow(
          
          # KPI 1 : Nombre de médecins
          valueBoxOutput("kpi_effectif", width = 4),
          
          # KPI 2 : Densité médicale
          valueBoxOutput("kpi_densite", width = 4),
          
          # KPI 3 : Part des 60 ans et +
          valueBoxOutput("kpi_evolution", width = 4)
        ),
        
        # Ligne 2 : Tableau de détail
        fluidRow(
          box(
            title = "Détails des données",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            collapsed = TRUE,
            DTOutput("tableau_details")
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
  
  # -------------------------------------------------------------------------
  # DONNÉES RÉACTIVES - Filtrage selon les sélections
  # -------------------------------------------------------------------------
  
  donnees_filtrees <- reactive({
    
    # Partir des données complètes
    df <- demographie_effectifs
    
    # Filtre Année
    df <- df %>% filter(annee == input$filtre_annee)
    
    # Filtre Profession
    if (input$filtre_profession != "TOUTES") {
      df <- df %>% filter(profession_sante == input$filtre_profession)
    } else {
      # Si "TOUTES", exclure les lignes agrégées pour éviter le double comptage
      # Exclure les professions qui commencent par "Ensemble"
      df <- df %>% filter(!grepl("^Ensemble", profession_sante))
    }
    
    # Filtre Région (99 = toute la France)
    df <- df %>% filter(region == input$filtre_region)
    
    # Filtre Département (999 = tous les départements)
    df <- df %>% filter(departement == input$filtre_departement)
    
    # Filtre Classe d'âge (tout_age = toutes les classes)
    if (input$filtre_classe_age != "tout_age") {
      df <- df %>% filter(libelle_classe_age == input$filtre_classe_age)
    } else {
      # Si "tout_age", on prend la ligne agrégée qui a classe_age = "tout_age"
      df <- df %>% filter(classe_age == "tout_age")
    }
    
    # Filtrer sur "tout sexe" pour éviter les doublons
    df <- df %>% filter(libelle_sexe == "tout sexe")
    
    return(df)
  })
  
  # -------------------------------------------------------------------------
  # KPI 1 : EFFECTIF (Nombre de médecins)
  # -------------------------------------------------------------------------
  
  output$kpi_effectif <- renderValueBox({
    
    df <- donnees_filtrees()
    
    if (nrow(df) > 0) {
      effectif_total <- sum(df$effectif, na.rm = TRUE)
      
      # Formater le nombre avec des espaces
      effectif_format <- format(effectif_total, big.mark = " ", scientific = FALSE)
      
      valueBox(
        value = effectif_format,
        subtitle = "Nombre de professionnels",
        icon = icon("user-md"),
        color = "blue"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Nombre de professionnels",
        icon = icon("user-md"),
        color = "red"
      )
    }
  })
  
  # -------------------------------------------------------------------------
  # KPI 2 : DENSITÉ MÉDICALE
  # -------------------------------------------------------------------------
  
  output$kpi_densite <- renderValueBox({
    
    df <- donnees_filtrees()
    
    if (nrow(df) > 0 && sum(df$densite, na.rm = TRUE) > 0) {
      densite_moyenne <- mean(df$densite, na.rm = TRUE)
      
      # Formater avec 1 décimale
      densite_format <- format(round(densite_moyenne, 1), nsmall = 1)
      
      valueBox(
        value = densite_format,
        subtitle = "Pour 100 000 habitants",
        icon = icon("heartbeat"),
        color = "yellow"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Pour 100 000 habitants",
        icon = icon("heartbeat"),
        color = "red"
      )
    }
  })
  
  # -------------------------------------------------------------------------
  # KPI 3 : PART DES 60 ANS ET PLUS (Vieillissement de la profession)
  # -------------------------------------------------------------------------
  
  output$kpi_evolution <- renderValueBox({
    
    # Si un filtre de classe d'âge spécifique est sélectionné, on ne peut pas calculer
    if (input$filtre_classe_age != "tout_age") {
      return(
        valueBox(
          value = "N/A",
          subtitle = "Part des 60 ans et +",
          icon = icon("user-clock"),
          color = "light-blue"
        )
      )
    }
    
    # Préparer les filtres de base
    df <- demographie_effectifs
    
    # Filtre Année
    df <- df %>% filter(annee == input$filtre_annee)
    
    # Filtre Profession
    if (input$filtre_profession != "TOUTES") {
      df <- df %>% filter(profession_sante == input$filtre_profession)
    } else {
      df <- df %>% filter(!grepl("^Ensemble", profession_sante))
    }
    
    # Filtre Région
    df <- df %>% filter(region == input$filtre_region)
    
    # Filtre Département
    df <- df %>% filter(departement == input$filtre_departement)
    
    # Filtrer sur "tout sexe"
    df <- df %>% filter(libelle_sexe == "tout sexe")
    
    # Calculer l'effectif total (toutes classes d'âge)
    df_total <- df %>% 
      filter(classe_age == "tout_age")
    effectif_total <- sum(df_total$effectif, na.rm = TRUE)
    
    # Calculer l'effectif des 60 ans et plus
    # Les classes concernées : 60-64, 65-69, 70+
    df_60plus <- df %>%
      filter(classe_age %in% c("60-64", "65-69", "70+"))
    effectif_60plus <- sum(df_60plus$effectif, na.rm = TRUE)
    
    if (effectif_total > 0) {
      
      # Calculer le pourcentage
      part_60plus <- (effectif_60plus / effectif_total) * 100
      
      # Formater l'affichage
      part_txt <- paste0(format(round(part_60plus, 1), nsmall = 1), "%")
      
      # Couleur selon le niveau d'alerte
      if (part_60plus >= 40) {
        couleur <- "red"  # Alerte forte : plus de 40% ont 60+ ans
        icone <- icon("exclamation-triangle")
      } else if (part_60plus >= 30) {
        couleur <- "orange"  # Alerte modérée : entre 30% et 40%
        icone <- icon("user-clock")
      } else if (part_60plus >= 20) {
        couleur <- "yellow"  # Vigilance : entre 20% et 30%
        icone <- icon("user-clock")
      } else {
        couleur <- "green"  # Situation favorable : moins de 20%
        icone <- icon("user-check")
      }
      
      valueBox(
        value = part_txt,
        subtitle = "Part des 60 ans et +",
        icon = icone,
        color = couleur
      )
      
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Part des 60 ans et +",
        icon = icon("user-clock"),
        color = "red"
      )
    }
  })
  
  # -------------------------------------------------------------------------
  # TABLEAU DE DÉTAILS
  # -------------------------------------------------------------------------
  
  output$tableau_details <- renderDT({
    
    df <- donnees_filtrees()
    
    if (nrow(df) > 0) {
      df %>%
        select(
          annee,
          profession_sante,
          libelle_region,
          libelle_departement,
          libelle_classe_age,
          libelle_sexe,
          effectif,
          densite
        ) %>%
        datatable(
          options = list(
            pageLength = 10,
            language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/French.json'),
            scrollX = TRUE
          ),
          rownames = FALSE,
          colnames = c(
            "Année",
            "Profession",
            "Région",
            "Département",
            "Classe d'âge",
            "Sexe",
            "Effectif",
            "Densité"
          )
        )
    } else {
      datatable(data.frame(Message = "Aucune donnée disponible pour cette sélection"))
    }
  })
  
  # -------------------------------------------------------------------------
  # MISE À JOUR DES DÉPARTEMENTS SELON LA RÉGION SÉLECTIONNÉE
  # -------------------------------------------------------------------------
  
  observeEvent(input$filtre_region, {
    
    if (input$filtre_region == "99") {
      # Si "Toute la France", afficher tous les départements
      choix_dept <- c("Tous (France)" = "999", choix_departements)
    } else {
      # Filtrer les départements de la région sélectionnée
      dept_region <- demographie_effectifs %>%
        filter(region == input$filtre_region) %>%
        select(departement, libelle_departement) %>%
        distinct() %>%
        arrange(departement) %>%
        mutate(display = paste0(departement, " - ", libelle_departement))
      
      choix_dept <- c(
        "Tous" = "999",
        setNames(dept_region$departement, dept_region$display)
      )
    }
    
    updateSelectInput(
      session,
      "filtre_departement",
      choices = choix_dept,
      selected = "999"
    )
  })
  
  # -------------------------------------------------------------------------
  # BOUTON RESET
  # -------------------------------------------------------------------------
  
  observeEvent(input$reset_filtres, {
    updateSelectInput(session, "filtre_annee", selected = max(liste_annees))
    updateSelectInput(session, "filtre_profession", selected = "TOUTES")
    updateSelectInput(session, "filtre_region", selected = "99")
    updateSelectInput(session, "filtre_departement", selected = "999")
    updateSelectInput(session, "filtre_classe_age", selected = "tout_age")
  })
}

# ============================================================================
# LANCEMENT DE L'APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)