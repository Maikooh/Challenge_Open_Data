# ============================================================================
# UI_PRO_ANALYSES.R - Analyses approfondies des professionnels de santé
# ============================================================================

tabItem(
  tabName = "pro_analyses",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("chart-line"), "Analyses approfondies"),
    p("Statistiques détaillées et visualisations avancées des professionnels de santé")
  )),
  
  # ----------- 2. SÉLECTION TYPE D'ANALYSE -----------
  fluidRow(
    box(
      title = span(icon("sliders-h"), "Type d'analyse"),
      status = "warning",
      solidHeader = TRUE,
      width = 12,
      
      radioButtons(
        "type_analyse_pro",
        NULL,
        choices = c(
          "Évolution temporelle" = "temporelle",
          "Analyse démographique" = "demographie",
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
      condition = "input.type_analyse_pro == 'temporelle'",
      box(
        title = span(icon("chart-line"), "Évolution du nombre de professionnels"),
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        style = "height: calc(100vh - 300px);",
        
        sliderInput(
          "periode_evolution_pro",
          "Période à afficher :",
          min = annee_min_pro,
          max = annee_max_pro,
          value = c(annee_min_pro, annee_max_pro),
          step = 1,
          sep = "",
          width = "100%"
        ),
        
        plotlyOutput("graph_evolution_densite_pro", height = "calc(100vh - 450px)")
      )
    ),
    
    ## ----- 3.2. Analyse démographique -----
    conditionalPanel(
      condition = "input.type_analyse_pro == 'demographie'",
      fluidRow(
        box(
          title = span(icon("chart-pie"), "Distribution par classe d'âge"),
          status = "success",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          plotlyOutput("graph_pie_ages_pro", height = "calc(100vh - 420px)")
        ),
        box(
          title = span(icon("chart-area"), "Part des 60 ans et plus"),
          status = "success",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          plotlyOutput("graph_part_60ans_pro", height = "calc(100vh - 420px)")
        )
      )
    ),
    
    ## ----- 3.3. Statistiques détaillées -----
    conditionalPanel(
      condition = "input.type_analyse_pro == 'stats'",
      fluidRow(
        box(
          title = span(icon("table"), "Statistiques descriptives"),
          status = "warning",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          verbatimTextOutput("stats_descriptives_pro")
        ),
        box(
          title = span(icon("check-circle"), "Qualité des données"),
          status = "warning",
          solidHeader = TRUE,
          width = 6,
          style = "height: calc(100vh - 300px);",
          plotlyOutput("graph_qualite_donnees_pro", height = "calc(100vh - 420px)")
        )
      )
    )
  )
)