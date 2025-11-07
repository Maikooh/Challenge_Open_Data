# ============================================================================
# UI_FINESS_CARTE.R - Carte interactive des établissements FINESS
# ============================================================================

tabItem(
  tabName = "finess_carte",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("map-marked-alt"), "Carte interactive des établissements"),
    p("Explorez la géolocalisation précise des établissements de santé sur le territoire")
  )),
  
  # ----------- 2. INFO BOXES -----------
  fluidRow(
    infoBoxOutput("info_nb_points_carte", width = 4),
    infoBoxOutput("info_precision_geo", width = 4),
    infoBoxOutput("info_dernier_filtre", width = 4)
  ),
  
  # ----------- 3. CARTE -----------
  fluidRow(
    box(
      title = NULL,
      status = "primary",
      solidHeader = FALSE,
      width = 12,
      style = "height: calc(100vh - 270px);",
      
      div(
        style = "margin-bottom: 10px; background: #f8f9fa; padding: 10px; border-radius: 8px;",
        fluidRow(
          column(
            6,
            checkboxInput(
              "show_cluster",
              span(icon("object-group"), "Activer le clustering des points"),
              value = TRUE
            )
          ),
          column(
            6,
            checkboxInput(
              "show_legend",
              span(icon("list"), "Afficher la légende"),
              value = TRUE
            )
          )
        )
      ),
      
      leafletOutput("carte_principale_finess", height = "calc(100vh - 360px)")
    )
  )
)