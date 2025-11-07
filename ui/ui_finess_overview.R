# ============================================================================
# UI_FINESS_OVERVIEW.R - Vue d'ensemble des établissements FINESS
# ============================================================================

tabItem(
  tabName = "finess_overview",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("chart-pie"), "Vue d'ensemble des établissements"),
    p("Explorez les statistiques globales des établissements de santé et médico-sociaux en France")
  )),
  
  # ----------- 2. KPIs -----------
  fluidRow(
    valueBoxOutput("kpi_nb_etablissements", width = 3),
    valueBoxOutput("kpi_nb_categories", width = 3),
    valueBoxOutput("kpi_nb_departements", width = 3),
    valueBoxOutput("kpi_maj_recente", width = 3)
  ),
  
  # ----------- 3. GRAPHIQUES -----------
  fluidRow(
    
    ## ----- 3.1. Visualisations -----
    box(
      title = span(icon("chart-bar"), "Visualisation des établissements"),
      status = "primary",
      solidHeader = TRUE,
      width = 6,
      style = "height: calc((100vh - 350px) / 2);",
      
      selectInput(
        "type_graphique",
        label = NULL,
        choices = c(
          "Catégories d'établissements" = "categorie",
          "Répartition par département" = "departement"
        ),
        selected = "categorie",
        width = "50%"
      ),
      
      conditionalPanel(
        condition = "input.type_graphique == 'categorie'",
        radioButtons(
          "top_bottom_categories",
          NULL,
          choices = c("10 plus fréquents" = "top", "10 moins fréquents" = "bottom"),
          selected = "top",
          inline = TRUE
        ),
        plotlyOutput("graph_top_categories", height = "calc(100vh - 500px)")
      ),
      
      conditionalPanel(
        condition = "input.type_graphique == 'departement'",
        radioButtons(
          "top_bottom_departements",
          NULL,
          choices = c("10 plus fréquents" = "top", "10 moins fréquents" = "bottom"),
          selected = "top",
          inline = TRUE
        ),
        plotlyOutput("graph_dept_repartition", height = "calc(100vh - 500px)")
      )
    ),
    
    ## ----- 3.2. Carte d'aperçu -----
    box(
      title = span(icon("globe"), "Aperçu géographique"),
      status = "success",
      solidHeader = TRUE,
      width = 6,
      style = "height: calc((100vh - 350px) / 2);",
      leafletOutput("carte_apercu_finess", height = "calc(100vh - 490px)")
    )
  )
)