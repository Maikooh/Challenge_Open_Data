# ============================================================================
# UI_FINESS_DONNEES.R - Base de données complète FINESS
# ============================================================================

tabItem(
  tabName = "finess_donnees",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("database"), "Base de données complète"),
    p("Consultez, filtrez et exportez les données brutes des établissements FINESS")
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
            "colonnes_affichage_finess",
            "Colonnes à afficher",
            choices = c("Essentielles", "Toutes"),
            selected = "Essentielles"
          )
        ),
        column(
          4,
          numericInput(
            "nb_lignes_page_finess",
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
            "telecharger_donnees_finess",
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
      DTOutput("tableau_principal_finess")
    )
  )
)