# ============================================================================
# UI_PRO_CARTE.R - Carte de densité des professionnels de santé
# ============================================================================

tabItem(
  tabName = "pro_carte",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("map-marked-alt"), "Carte de densité médicale"),
    p("Explorez la densité des professionnels de santé par département")
  )),
  
  # ----------- 2. INFO BOXES -----------
  fluidRow(
    infoBoxOutput("info_densite_min", width = 4),
    infoBoxOutput("info_densite_max", width = 4),
    infoBoxOutput("info_densite_moy", width = 4)
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
              "show_legend_pro",
              span(icon("list"), "Afficher la légende"),
              value = TRUE
            )
          ),
          column(
            6,
            checkboxInput(
              "show_labels_pro",
              span(icon("tags"), "Afficher les étiquettes"),
              value = FALSE
            )
          )
        )
      ),
      
      leafletOutput("carte_densite_pro", height = "calc(100vh - 360px)")
    )
  )
)