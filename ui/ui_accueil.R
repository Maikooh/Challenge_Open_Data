# ============================================================================
# UI_ACCUEIL.R - Page d'accueil de l'application
# ============================================================================

tabItem(
  tabName = "accueil",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("home"), "Bienvenue sur le Dashboard Santé & Territoires"),
    p("Explorez les données des établissements de santé et des professionnels médicaux en France")
  )),
  
  # ----------- 2. CARTES DE PRÉSENTATION -----------
  fluidRow(
    
    ## ----- 2.1. Section FINESS -----
    box(
      title = span(icon("hospital"), "Établissements FINESS"),
      status = "primary",
      solidHeader = TRUE,
      width = 6,
      style = "height: calc((100vh - 250px) / 2); max-height: 350px;",
      
      div(
        style = "padding: 15px; text-align: center; height: 100%; display: flex; flex-direction: column; justify-content: space-between;",
        div(
          icon("hospital-user", "fa-4x", style = "color: #667eea; margin-bottom: 15px;"),
          h3("Base de données FINESS", style = "color: #2c3e50; margin-bottom: 10px; font-size: 18px;"),
          p("Explorez les établissements de santé et médico-sociaux sur tout le territoire français.",
            style = "color: #7f8c8d; font-size: 13px; margin-bottom: 15px;"),
          if (!is.null(finess_data)) {
            tags$div(
              tags$p(strong(format(nrow(finess_data), big.mark = " ")), " établissements",
                     style = "font-size: 20px; color: #667eea; margin: 8px 0;"),
              tags$p(strong(length(unique(finess_data$libcategetab))), " catégories",
                     style = "font-size: 16px; color: #7f8c8d;")
            )
          } else {
            tags$p("⚠️ Données non chargées", style = "color: #e74c3c;")
          }
        ),
        actionButton(
          "goto_finess",
          "Accéder aux établissements",
          icon = icon("arrow-right"),
          class = "btn-primary",
          style = "margin-top: 10px;"
        )
      )
    ),
    
    ## ----- 2.2. Section Professionnels -----
    box(
      title = span(icon("user-md"), "Professionnels de santé"),
      status = "info",
      solidHeader = TRUE,
      width = 6,
      style = "height: calc((100vh - 250px) / 2); max-height: 350px;",
      
      div(
        style = "padding: 15px; text-align: center; height: 100%; display: flex; flex-direction: column; justify-content: space-between;",
        div(
          icon("stethoscope", "fa-4x", style = "color: #4facfe; margin-bottom: 15px;"),
          h3("Démographie médicale", style = "color: #2c3e50; margin-bottom: 10px; font-size: 18px;"),
          p("Analysez la répartition et la densité des professionnels de santé sur le territoire.",
            style = "color: #7f8c8d; font-size: 13px; margin-bottom: 15px;"),
          if (!is.null(demographie_effectifs)) {
            tags$div(
              tags$p(strong(length(liste_professions)), " professions",
                     style = "font-size: 20px; color: #4facfe; margin: 8px 0;"),
              tags$p(strong(length(liste_annees_pro)), " années de données",
                     style = "font-size: 16px; color: #7f8c8d;")
            )
          } else {
            tags$p("⚠️ Données non chargées", style = "color: #e74c3c;")
          }
        ),
        actionButton(
          "goto_pro",
          "Accéder aux professionnels",
          icon = icon("arrow-right"),
          class = "btn-info",
          style = "margin-top: 10px;"
        )
      )
    )
  ),
  
  # ----------- 3. À PROPOS -----------
  fluidRow(
    box(
      title = span(icon("info-circle"), "À propos"),
      status = "success",
      solidHeader = TRUE,
      width = 12,
      style = "height: calc((100vh - 250px) / 2); max-height: 350px; overflow: auto;",
      
      div(
        style = "padding: 15px;",
        h4("Sources de données", style = "color: #2c3e50; margin-bottom: 12px; font-size: 16px;"),
        tags$ul(
          style = "font-size: 12px; color: #5a6c7d; line-height: 1.8;",
          tags$li(icon("hospital"), strong(" FINESS :"), " Fichier National des Établissements Sanitaires et Sociaux (data.gouv.fr)"),
          tags$li(icon("user-md"), strong(" Professionnels :"), " Données de démographie médicale (data.ameli.fr)"),
          tags$li(icon("map-marked-alt"), strong(" Géolocalisation :"), " France GeoJson de Gregoiredavid sur Github")
        ),
        hr(style = "margin: 10px 0;"),
        p(icon("sync-alt"), " Dernière mise à jour : ", strong(format(Sys.Date(), "%d/%m/%Y")),
          style = "color: #7f8c8d; margin: 8px 0; font-size: 12px;")
      )
    )
  )
)