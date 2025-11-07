# ============================================================================
# UI_PRO_DONNEES.R - Base de données complète des professionnels
# ============================================================================

tabItem(
  tabName = "pro_donnees",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("database"), "Base de données complète"),
    p("Consultez, filtrez et exportez les données des professionnels de santé")
  )),
  
  # ----------- 2. OPTIONS D'AFFICHAGE -----------
  fluidRow(
    box(
      title = span(icon("cog"), "Options d'affichage"),
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      
      fluidRow(
        column(
          4,
          selectInput(
            "dataset_choisi_pro",
            "Dataset à afficher",
            choices = c(
              "Effectifs et densités" = "effectifs",
              "Âges moyens" = "ages",
              "Patientèle" = "patientele",
              "Secteurs" = "secteurs"
            ),
            selected = "effectifs"
          )
        ),
        column(
          4,
          numericInput(
            "nb_lignes_page_pro",
            "Lignes par page",
            value = 25,
            min = 10,
            max = 100,
            step = 5
          )
        ),
        column(
          4,
          br(),
          downloadButton(
            "telecharger_donnees_pro",
            span(icon("download"), "Télécharger CSV"),
            class = "btn-success btn-block"
          )
        )
      )
    )
  ),
  
  # ----------- 3. TABLEAU -----------
  fluidRow(
    box(
      title = NULL,
      status = "primary",
      solidHeader = FALSE,
      width = 12,
      DTOutput("tableau_principal_pro")
    )
  )
)