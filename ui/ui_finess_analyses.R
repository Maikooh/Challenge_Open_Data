# ============================================================================
# UI_FINESS_ANALYSES.R - Analyses approfondies des établissements FINESS
# ============================================================================

tabItem(
  tabName = "finess_analyses",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("chart-line"), "Analyses approfondies"),
    p("Statistiques détaillées et visualisations avancées des données FINESS")
  )),
  
  # ----------- 2. SÉLECTION TYPE D'ANALYSE -----------
  fluidRow(
    box(
      title = span(icon("sliders-h"), "Type d'analyse"),
      status = "warning",
      solidHeader = TRUE,
      width = 12,
      
      radioButtons(
        "type_analyse_finess",
        NULL,
        choices = c(
          "Évolution temporelle" = "temporelle",
          "Répartition géographique" = "geo",
          "Analyse par catégorie" = "categorie",
          "Statistiques détaillées" = "stats"
        ),
        selected = "temporelle",
        inline = TRUE
      )
    )
  ),
  
  # ----------- 3. GRAPHIQUES D'ANALYSE -----------
  fluidRow(
    
    ## ----- 3.1. Évolution temporelle -----
    conditionalPanel(
      condition = "input.type_analyse_finess == 'temporelle'",
      box(
        title = span(icon("chart-line"), "Évolution du nombre d'établissements"),
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        style = "height: calc(100vh - 300px);",
        
        sliderInput(
          "periode_evolution_finess",
          "Période à afficher :",
          min = annee_min_finess,
          max = annee_max_finess,
          value = c(annee_min_finess, annee_max_finess),
          step = 1,
          sep = "",
          width = "100%"
        ),
        
        plotlyOutput("graph_evolution_annuelle_finess", height = "calc(100vh - 450px)")
      )
    ),
    
    ## ----- 3.2. Répartition géographique -----
    conditionalPanel(
      condition = "input.type_analyse_finess == 'geo'",
      box(
        title = span(icon("map"), "Densité d'établissements par département"),
        status = "info",
        solidHeader = TRUE,
        width = 12,
        style = "height: calc(100vh - 300px);",
        plotlyOutput("graph_densite_dept_finess", height = "calc(100vh - 420px)")
      )
    ),
    
    ## ----- 3.3. Analyse par catégorie -----
    conditionalPanel(
      condition = "input.type_analyse_finess == 'categorie'",
      fluidRow(
        box(
          title = span(icon("chart-pie"), "Distribution des catégories"),
          status = "success",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          plotlyOutput("graph_pie_categories_finess", height = "calc(100vh - 420px)")
        ),
        box(
          title = span(icon("chart-area"), "Évolution par catégorie (Top 5)"),
          status = "success",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          
          sliderInput(
            "periode_evolution_cat_finess",
            "Période à afficher :",
            min = annee_min_finess,
            max = annee_max_finess,
            value = c(annee_min_finess, annee_max_finess),
            step = 1,
            sep = "",
            width = "100%"
          ),
          
          plotlyOutput("graph_evol_categories_finess", height = "calc(100vh - 550px)")
        )
      )
    ),
    
    ## ----- 3.4. Statistiques détaillées -----
    conditionalPanel(
      condition = "input.type_analyse_finess == 'stats'",
      fluidRow(
        box(
          title = span(icon("table"), "Statistiques descriptives"),
          status = "warning",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          verbatimTextOutput("stats_descriptives_finess")
        ),
        box(
          title = span(icon("check-circle"), "Qualité des données"),
          status = "warning",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          plotlyOutput("graph_qualite_donnees_finess", height = "calc(100vh - 420px)")
        )
      )
    )
  )
)