# ============================================================================
# UI_APROPOS.R - Page À propos du projet
# ============================================================================

tabItem(
  tabName = "apropos",
  
  # ----------- 1. TITRE -----------
  fluidRow(column(
    12,
    h2(icon("info-circle"), "À propos du projet"),
    p(
      "Informations sur le projet, les auteurs, les sources et les limites"
    )
  )),
  
  # ----------- 2. AUTEURS ET SOURCES -----------
  fluidRow(
    ## ----- 2.1. Les auteurs -----
    box(
      title = span(icon("users"), "Les auteurs"),
      status = "primary",
      solidHeader = TRUE,
      width = 6,
      style = "min-height: 280px;",
      
      div(
        style = "padding: 15px;",
        
        ### --- Auteur 1 ---
        div(
          style = "margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #667eea;",
          h4(icon("user"), "Fadli Aaron", style = "margin: 0 0 10px 0; color: #2c3e50; font-size: 16px;"),
          p(
            a(
              href = "https://www.linkedin.com/in/aaron-fadli/",
              target = "_blank",
              class = "author-link",
              icon("linkedin"),
              " LinkedIn"
            ),
            " | ",
            a(
              href = "https://github.com/Maikooh",
              target = "_blank",
              class = "author-link",
              icon("github"),
              " GitHub"
            ),
            " | ",
            a(href = "mailto:aaron.fadli@etu.univ-tours.fr", class = "author-link", icon("envelope"), " Email"),
            style = "margin: 5px 0; font-size: 13px;"
          )
        ),
        
        ### --- Auteur 2 ---
        div(
          style = "margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #4facfe;",
          h4(icon("user"), "Kurnaz Kubra", style = "margin: 0 0 10px 0; color: #2c3e50; font-size: 16px;"),
          p(
            a(
              href = "https://www.linkedin.com/in/kubra-kurnaz-56ba35387/",
              target = "_blank",
              class = "author-link",
              icon("linkedin"),
              " LinkedIn"
            ),
            " | ",
            a(
              href = "https://github.com/Kubra2918",
              target = "_blank",
              class = "author-link",
              icon("github"),
              " GitHub"
            ),
            " | ",
            a(href = "mailto:kubra.kurnaz@etu.univ-tours.fr", class = "author-link", icon("envelope"), " Email"),
            style = "margin: 5px 0; font-size: 13px;"
          )
        ),
        
        ### --- Auteur 3 ---
        div(
          style = "margin-bottom: 5px; padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #43e97b;",
          h4(icon("user"), "Moreau Matteo", style = "margin: 0 0 10px 0; color: #2c3e50; font-size: 16px;"),
          p(
            a(
              href = "https://github.com/MatteoHmmm",
              target = "_blank",
              class = "author-link",
              icon("github"),
              " GitHub"
            ),
            " | ",
            a(href = "mailto:matteo.moreau@etu.univ-tours.fr", class = "author-link", icon("envelope"), " Email"),
            style = "margin: 5px 0; font-size: 13px;"
          )
        )
      )
    ),
    
    ## ----- 2.2. Sources & Ressources -----
    box(
      title = span(icon("database"), "Sources & Ressources"),
      status = "info",
      solidHeader = TRUE,
      width = 6,
      style = "min-height: 280px;",
      
      div(
        style = "padding: 15px;",
        
        ### --- Sources de données ---
        div(
          style = "margin-bottom: 25px;",
          h4(icon("table"), "Sources de données", style = "color: #2c3e50; margin-bottom: 12px; font-size: 16px;"),
          tags$ul(
            style = "font-size: 13px; color: #5a6c7d; line-height: 2;",
            tags$li(
              icon("hospital", style = "color: #667eea;"),
              strong(" FINESS : "),
              a(
                href = "https://www.data.gouv.fr/fr/datasets/finess-extraction-du-fichier-des-etablissements/",
                target = "_blank",
                class = "source-link",
                "Fichier National des Établissements (data.gouv.fr)",
                icon("external-link-alt", style = "font-size: 10px;")
              )
            ),
            tags$li(
              icon("user-md", style = "color: #4facfe;"),
              strong(" Professionnels de santé : "),
              a(
                href = "https://data.ameli.fr/explore/dataset/demographie-effectifs-et-les-densites/information/",
                target = "_blank",
                class = "source-link",
                "Données Ameli - Démographie médicale",
                icon("external-link-alt", style = "font-size: 10px;")
              )
            ),
            tags$li(
              icon("user-md", style = "color: #4facfe;"),
              strong(" Age des professionnels : "),
              a(
                href = "https://data.ameli.fr/explore/dataset/demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans/information/",
                target = "_blank",
                class = "source-link",
                "Données Ameli - Démographie médicale",
                icon("external-link-alt", style = "font-size: 10px;")
              )
            ),
            tags$li(
              icon("map-marked-alt", style = "color: #43e97b;"),
              strong(" Géolocalisation : "),
              a(
                href = "https://github.com/gregoiredavid/france-geojson",
                target = "_blank",
                class = "source-link",
                "Github France GeoJson",
                icon("external-link-alt", style = "font-size: 10px;")
              )
            )
          )
        ),
        
        ### --- GitHub Repository ---
        div(
          style = "padding: 15px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; text-align: center;",
          h4(icon("github", style = "font-size: 24px;"), style = "color: white; margin: 0 0 10px 0;"),
          p(strong("Code source du projet"), style = "color: white; margin: 5px 0; font-size: 13px;"),
          a(
            href = "https://github.com/Maikooh/Challenge_Open_Data",
            target = "_blank",
            class = "btn btn-light btn-sm",
            style = "margin-top: 5px; font-weight: 600;",
            icon("github"),
            " Voir le repository GitHub"
          )
        )
      )
    )
  ),
  
  # ----------- 3. LIMITES -----------
  fluidRow(
    box(
      title = span(icon("exclamation-triangle"), "Limites et considérations"),
      status = "warning",
      solidHeader = TRUE,
      width = 12,
      
      div(
        style = "padding: 15px;",
        
        tags$ul(
          style = "font-size: 13px; color: #5a6c7d; line-height: 2;",
          tags$li(
            icon("calendar-times", style = "color: #f5576c;"),
            strong(" Données incomplètes : "),
            "Certaines années peuvent présenter des données manquantes ou partielles, notamment pour les périodes les plus anciennes."
          ),
          tags$li(
            icon("map-marker-alt", style = "color: #fa709a;"),
            strong(" Géolocalisation : "),
            "Tous les établissements ne disposent pas de coordonnées GPS précises. La précision varie selon les sources."
          ),
          tags$li(
            icon("sync-alt", style = "color: #fee140;"),
            strong(" Mise à jour : "),
            "Les données sont mises à jour périodiquement selon la disponibilité sur les sources officielles. Un délai peut exister entre la collecte et la publication."
          ),
          tags$li(
            icon("chart-line", style = "color: #f093fb;"),
            strong(" Représentativité : "),
            "Les analyses statistiques sont basées sur les données disponibles et peuvent ne pas refléter la totalité de la situation actuelle."
          ),
          tags$li(
            icon("database", style = "color: #667eea;"),
            strong(" Qualité des données : "),
            "Malgré nos efforts de vérification, des erreurs ou incohérences peuvent subsister dans les données sources."
          )
        ),
        
        hr(style = "margin: 20px 0;"),
        
        div(
          style = "background: #fff3cd; padding: 15px; border-radius: 8px; border-left: 4px solid #ffc107;",
          p(
            icon("info-circle", style = "color: #856404;"),
            strong(" Note importante : "),
            "Ce dashboard est un outil d'analyse et de visualisation. Pour toute utilisation professionnelle ou décision stratégique, veuillez vous référer aux sources officielles.",
            style = "margin: 0; color: #856404; font-size: 13px;"
          )
        )
      )
    )
  ),
  
  # ----------- 4. TECHNOLOGIE & LICENCE -----------
  fluidRow(
    ## ----- 4.1. Technologies utilisées -----
    box(
      title = span(icon("code"), "Technologies utilisées"),
      status = "success",
      solidHeader = TRUE,
      width = 6,
      
      div(
        style = "padding: 15px;",
        tags$ul(
          style = "font-size: 13px; color: #5a6c7d; line-height: 1.8;",
          tags$li(
            icon("r-project", style = "color: #276DC3;"),
            strong(" R "),
            "- Langage de programmation statistique"
          ),
          tags$li(
            icon("chart-area", style = "color: #667eea;"),
            strong(" Shiny "),
            "- Framework d'applications web interactives"
          ),
          tags$li(
            icon("map", style = "color: #43e97b;"),
            strong(" Leaflet "),
            "- Cartographie interactive"
          ),
          tags$li(
            icon("chart-line", style = "color: #4facfe;"),
            strong(" Plotly "),
            "- Visualisations interactives"
          ),
          tags$li(
            icon("table", style = "color: #f093fb;"),
            strong(" DT "),
            "- Tables de données interactives"
          ),
          tags$li(
            icon("brain", style = "color: #f093fb;"),
            strong(" Claude AI (Anthropic) "),
            "- Assistant IA pour le développement et la conception"
          )
        )
      )
    ),
    
    ## ----- 4.2. Licence & Utilisation -----
    box(
      title = span(icon("balance-scale"), "Licence & Utilisation"),
      status = "success",
      solidHeader = TRUE,
      width = 6,
      
      div(
        style = "padding: 15px;",
        p(
          "Ce projet est distribué sous licence ",
          strong("CC-by-sa"),
          style = "font-size: 13px; color: #5a6c7d; margin-bottom: 15px;"
        ),
        p(
          icon("creative-commons"),
          " Vous êtes libre d'utiliser, modifier et distribuer ce code à condition de citer les auteurs.",
          style = "font-size: 12px; color: #7f8c8d; margin-bottom: 15px;"
        ),
        div(
          style = "background: #e8f5e9; padding: 12px; border-radius: 8px; border-left: 4px solid #43e97b;",
          p(
            " Projet réalisé dans le cadre du ",
            a(
              href = "https://mecen.univ-tours.fr/",
              target = "_blank",
              strong("Master MECEN"),
              icon("external-link-alt", style = "font-size: 10px; margin-left: 3px;"),
              style = "color: #2c3e50; text-decoration: none; font-weight: 600;"
            ),
            " - Année universitaire 2025-2026",
            style = "margin: 0 0 8px 0; font-size: 12px; color: #2c3e50;"
          ),
          p(
            " Pour participation au projet ",
            a(
              href = "https://latitudes.notion.site/",
              target = "_blank",
              strong("Open Data University"),
              icon("external-link-alt", style = "font-size: 10px; margin-left: 3px;"),
              style = "color: #2c3e50; text-decoration: none; font-weight: 600;"
            ),
            style = "margin: 0; font-size: 12px; color: #2c3e50;"
          )
        )
      )
    )
  )
)
