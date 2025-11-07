# ============================================================================
# UI_PRO_OVERVIEW.R - Vue d'ensemble des professionnels de santé
# ============================================================================

tabItem(
  tabName = "pro_overview",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("chart-pie"), "Vue d'ensemble des professionnels"),
    p("Explorez les statistiques globales des professionnels de santé en France")
  )),
  
  # ----------- 2. KPIs -----------
  fluidRow(
    valueBoxOutput("kpi_effectif_pro", width = 3),
    valueBoxOutput("kpi_densite_pro", width = 3),
    valueBoxOutput("kpi_nb_professions", width = 3),
    valueBoxOutput("kpi_part_60ans_pro", width = 3)
  ),
  
  # ----------- 3. GRAPHIQUES -----------
  fluidRow(
    
    ## ----- 3.1. Visualisations -----
    box(
      title = span(icon("chart-bar"), "Visualisation des professionnels"),
      status = "primary",
      solidHeader = TRUE,
      width = 6,
      style = "height: calc((100vh - 350px) / 2);",
      
      selectInput(
        "type_graphique_pro",
        label = NULL,
        choices = c("Top professions" = "professions"),
        selected = "professions",
        width = "50%"
      ),
      
      conditionalPanel(
        condition = "input.type_graphique_pro == 'professions'",
        radioButtons(
          "top_bottom_professions",
          NULL,
          choices = c("10 plus nombreux" = "top", "10 moins nombreux" = "bottom"),
          selected = "top",
          inline = TRUE
        ),
        plotlyOutput("graph_top_professions_overview", height = "calc(100vh - 500px)")
      )
    ),
    
    ## ----- 3.2. Carte d'aperçu -----
    box(
      title = span(icon("globe"), "Aperçu géographique"),
      status = "success",
      solidHeader = TRUE,
      width = 6,
      style = "height: calc((100vh - 350px) / 2);",
      leafletOutput("carte_apercu_pro", height = "calc(100vh - 490px)")
    )
  )
)