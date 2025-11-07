# ============================================================================
# UI.R - Interface utilisateur de l'application Shiny
# ============================================================================
# Ce fichier contient toute la structure de l'interface utilisateur
# ============================================================================

ui <- dashboardPage(
  skin = "blue",
  
  # ----------- 1. HEADER -----------
  dashboardHeader(
    title = span(icon("heartbeat", class = "fa-lg"), "Santé & Territoires"),
    titleWidth = 320
  ),
  
  # ----------- 2. SIDEBAR -----------
  dashboardSidebar(
    width = 320,
    
    sidebarMenu(
      id = "sidebar_menu",
      
      ## ----- 2.1. Titre Navigation -----
      div(
        style = "padding: 20px 15px 10px 15px; border-bottom: 2px solid rgba(255,255,255,0.1);",
        h4(icon("bars"), "Navigation", style = "color: #ecf0f1; font-weight: 600; margin: 0;")
      ),
      
      ## ----- 2.2. Menu Principal -----
      
      ### --- 2.2.1. Accueil ---
      menuItem("Accueil", tabName = "accueil", icon = icon("home")),
      
      ### --- 2.2.2. Section Établissements FINESS ---
      menuItem(
        "Établissements FINESS",
        tabName = "finess_section",
        icon = icon("hospital"),
        menuSubItem("Vue d'ensemble", tabName = "finess_overview", icon = icon("chart-pie")),
        menuSubItem("Carte interactive", tabName = "finess_carte", icon = icon("map-marked-alt")),
        menuSubItem("Analyses", tabName = "finess_analyses", icon = icon("chart-bar")),
        menuSubItem("Base de données", tabName = "finess_donnees", icon = icon("database"))
      ),
      
      ### --- 2.2.3. Section Professionnels de santé ---
      menuItem(
        "Professionnels de santé",
        tabName = "pro_section",
        icon = icon("user-md"),
        menuSubItem("Vue d'ensemble", tabName = "pro_overview", icon = icon("chart-pie")),
        menuSubItem("Carte de densité", tabName = "pro_carte", icon = icon("map-marked-alt")),
        menuSubItem("Analyses", tabName = "pro_analyses", icon = icon("chart-bar")),
        menuSubItem("Base de données", tabName = "pro_donnees", icon = icon("database"))
      ),
      
      ### --- 2.2.4. À propos ---
      menuItem("À propos du projet", tabName = "apropos", icon = icon("info-circle"))
    ),
    
    ## ----- 2.3. Filtres FINESS -----
    conditionalPanel(
      condition = "input.sidebar_menu.match(/^finess_/)",
      
      div(
        style = "padding: 20px 15px 10px 15px; margin-top: 15px; border-top: 2px solid rgba(255,255,255,0.1); border-bottom: 2px solid rgba(255,255,255,0.1);",
        h4(icon("filter"), "Filtres FINESS", style = "color: #ecf0f1; font-weight: 600; margin: 0;")
      ),
      
      div(
        style = "padding: 0 15px;",
        
        selectInput(
          "filtre_departement_finess",
          tags$label(icon("map-marker-alt"), "Département", style = "color: #ecf0f1; font-weight: 500;"),
          choices = c("Tous les départements" = "TOUS", choix_depts_finess),
          selected = "TOUS"
        ),
        
        selectInput(
          "filtre_categorie",
          tags$label(icon("building"), "Catégorie", style = "color: #ecf0f1; font-weight: 500;"),
          choices = c("Toutes les catégories" = "TOUTES", liste_categories),
          selected = "TOUTES"
        ),
        
        selectInput(
          "filtre_annee_finess",
          tags$label(icon("calendar"), "Année", style = "color: #ecf0f1; font-weight: 500;"),
          choices = c("Toutes les années" = "TOUTES", liste_annees_finess),
          selected = "TOUTES"
        ),
        
        div(
          style = "background: rgba(255,255,255,0.05); padding: 12px; border-radius: 6px; margin: 15px 0;",
          checkboxInput(
            "filtre_coords_valides",
            tags$span(icon("location-dot"), "Avec coordonnées GPS uniquement", style = "color: #ecf0f1; font-weight: 500;"),
            value = TRUE
          )
        ),
        
        actionButton(
          "reset_filtres_finess",
          "Réinitialiser",
          icon = icon("rotate-right"),
          width = "100%",
          class = "btn-warning btn-block",
          style = "margin-top: 10px; font-weight: 600; border-radius: 6px;"
        )
      )
    ),
    
    ## ----- 2.4. Filtres Professionnels -----
    conditionalPanel(
      condition = "input.sidebar_menu.match(/^pro_/)",
      
      div(
        style = "padding: 20px 15px 10px 15px; margin-top: 15px; border-top: 2px solid rgba(255,255,255,0.1); border-bottom: 2px solid rgba(255,255,255,0.1);",
        h4(icon("filter"), "Filtres Professionnels", style = "color: #ecf0f1; font-weight: 600; margin: 0;")
      ),
      
      div(
        style = "padding: 0 15px;",
        
        selectInput(
          "filtre_annee_pro",
          tags$label(icon("calendar"), "Année", style = "color: #ecf0f1; font-weight: 500;"),
          choices = liste_annees_pro,
          selected = if (length(liste_annees_pro) > 0) max(liste_annees_pro) else 2024
        ),
        
        selectInput(
          "filtre_profession",
          tags$label(icon("stethoscope"), "Profession", style = "color: #ecf0f1; font-weight: 500;"),
          choices = c("Toutes" = "TOUTES", liste_professions),
          selected = "TOUTES"
        ),
        
        selectInput(
          "filtre_region",
          tags$label(icon("map"), "Région", style = "color: #ecf0f1; font-weight: 500;"),
          choices = c("Toute la France" = "99", choix_regions),
          selected = "99"
        ),
        
        selectInput(
          "filtre_departement_pro",
          tags$label(icon("map-marker-alt"), "Département", style = "color: #ecf0f1; font-weight: 500;"),
          choices = c("Tous" = "999", choix_departements),
          selected = "999"
        ),
        
        selectInput(
          "filtre_classe_age",
          tags$label(icon("birthday-cake"), "Classe d'âge", style = "color: #ecf0f1; font-weight: 500;"),
          choices = c("Tous les âges" = "tout_age", liste_classes_age),
          selected = "tout_age"
        ),
        
        actionButton(
          "reset_filtres_pro",
          "Réinitialiser",
          icon = icon("rotate-right"),
          width = "100%",
          class = "btn-warning btn-block",
          style = "margin-top: 10px; font-weight: 600; border-radius: 6px;"
        )
      )
    ),
    
    ## ----- 2.5. Pied de Sidebar -----
    div(
      style = "position: absolute; bottom: 0; width: 100%; padding: 20px; background: rgba(0,0,0,0.2); color: rgba(255,255,255,0.7); font-size: 11px;",
      p(icon("database"), strong("Sources :"), "FINESS, data.ameli.fr", style = "margin: 5px 0;"),
      p(icon("clock"), strong("MAJ :"), format(Sys.Date(), "%d/%m/%Y"), style = "margin: 5px 0;")
    )
  ),
  
  # ----------- 3. BODY -----------
  dashboardBody(
    
    ## ----- 3.1. Chargement du CSS -----
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
    
    ## ----- 3.2. Contenu des onglets -----
    tabItems(
      
      ### --- 3.2.1. Page Accueil ---
      source("ui/ui_accueil.R", local = TRUE)$value,
      
      ### --- 3.2.2. Onglets FINESS ---
      source("ui/ui_finess_overview.R", local = TRUE)$value,
      source("ui/ui_finess_carte.R", local = TRUE)$value,
      source("ui/ui_finess_analyses.R", local = TRUE)$value,
      source("ui/ui_finess_donnees.R", local = TRUE)$value,
      
      ### --- 3.2.3. Onglets Professionnels ---
      source("ui/ui_pro_overview.R", local = TRUE)$value,
      source("ui/ui_pro_carte.R", local = TRUE)$value,
      source("ui/ui_pro_analyses.R", local = TRUE)$value,
      source("ui/ui_pro_donnees.R", local = TRUE)$value,
      
      ### --- 3.2.4. Page À propos ---
      source("ui/ui_apropos.R", local = TRUE)$value
    )
  )
)