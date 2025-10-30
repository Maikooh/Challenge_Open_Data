# ============================================================================
# Dashboard Shiny - Santé et Territoires
# KPIs Dynamiques : Nombre de médecins et Densité médicale
# ============================================================================

# Chargement des packages
library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)
library(leaflet)
library(sf)
library(ggplot2)
library(plotly)


# ============================================================================
# CHARGEMENT DES DONNÉES
# ============================================================================

# Définir le chemin de base
if (basename(getwd()) == "R") {
  chemin_base <- dirname(getwd())
} else {
  chemin_base <- getwd()
}

cat("Chemin de base:", chemin_base, "\n")

# Charger les données démographiques
demographie_effectifs <- read.csv(
  file.path(
    chemin_base,
    "data/processed/ameli/demographie-effectifs-et-les-densites_clean.csv"
  ),
  encoding = "UTF-8",
  stringsAsFactors = FALSE
)

cat("Données chargées:", nrow(demographie_effectifs), "lignes\n")

# ============================================================================
# PRÉPARATION DES LISTES POUR LES FILTRES
# ============================================================================

liste_annees <- sort(unique(demographie_effectifs$annee), decreasing = TRUE)

liste_professions <- demographie_effectifs %>%
  distinct(profession_sante) %>%
  filter(!grepl("^Ensemble", profession_sante)) %>%
  arrange(profession_sante) %>%
  pull(profession_sante)

liste_regions <- demographie_effectifs %>%
  distinct(region, libelle_region) %>%
  arrange(region) %>%
  mutate(display = paste0(region, " - ", libelle_region))

choix_regions <- setNames(liste_regions$region, liste_regions$display)

liste_departements <- demographie_effectifs %>%
  distinct(departement, libelle_departement) %>%
  arrange(departement) %>%
  mutate(display = paste0(departement, " - ", libelle_departement))

choix_departements <- setNames(liste_departements$departement, liste_departements$display)

liste_classes_age <- demographie_effectifs %>%
  distinct(classe_age, libelle_classe_age) %>%
  arrange(classe_age) %>%
  pull(libelle_classe_age)

# ============================================================================
# INTERFACE UTILISATEUR (UI)
# ============================================================================

ui <- dashboardPage(
  dashboardHeader(title = "Santé & Territoires", titleWidth = 300),
  
  dashboardSidebar(
    width = 300,
    
    sidebarMenu(
      menuItem(
        "Tableau de bord",
        tabName = "dashboard",
        icon = icon("dashboard")
      ),
      menuItem("Carte de densité", tabName = "carte_densite", icon = icon("map")),
      
      hr(),
      h4("Filtres", style = "padding-left: 15px; color: white;"),
      
      selectInput(
        "filtre_annee",
        "Année",
        choices = liste_annees,
        selected = max(liste_annees)
      ),
      selectInput(
        "filtre_profession",
        "Profession",
        choices = c("Toutes" = "TOUTES", liste_professions),
        selected = "TOUTES"
      ),
      selectInput(
        "filtre_region",
        "Région",
        choices = c("Toute la France" = "99", choix_regions),
        selected = "99"
      ),
      selectInput(
        "filtre_departement",
        "Département",
        choices = c("Tous" = "999", choix_departements),
        selected = "999"
      ),
      selectInput(
        "filtre_classe_age",
        "Classe d'âge",
        choices = c("Tous les âges" = "tout_age", liste_classes_age),
        selected = "tout_age"
      ),
      
      hr(),
      actionButton(
        "reset_filtres",
        "Réinitialiser les filtres",
        icon = icon("refresh"),
        width = "90%",
        style = "margin-left: 15px;"
      )
    )
  ),
  
  dashboardBody(# --- Style CSS global ---
    tags$head(tags$style(
      HTML(
        "
        /* Style KPI (small-box) */
        .small-box {
          border-radius: 5px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .small-box h3 { font-size: 38px; font-weight: bold; }
        .small-box p { font-size: 16px; }

        /* Désactivation du scroll */
        html, body {
          overflow: hidden !important;
        }
        .content-wrapper, .right-side {
          overflow-y: hidden !important;
        }

        /* Responsive sans supprimer la hauteur */
        .shiny-plot-output, .leaflet, .datatables {
          width: 100% !important;
          max-width: 100%;
        }

        /* Sidebar adaptative */
        @media (max-width: 768px) {
          .main-header .logo { font-size: 16px; }
          .sidebar { width: 100% !important; }
        }

        /* Taille minimale du corps pour éviter figure margins too large */
        .content-wrapper { min-height: 900px !important; }
      "
      )
    )), tabItems(
      # === TAB 1 : Dashboard principal ===
      tabItem(
        tabName = "dashboard",
        fluidRow(column(
          12,
          h2("Indicateurs Clés - Professionnels de Santé"),
          p("Données AMELI - Source : data.gouv.fr")
        )),
        fluidRow(
          valueBoxOutput("kpi_effectif", width = 4),
          valueBoxOutput("kpi_densite", width = 4),
          valueBoxOutput("kpi_evolution", width = 4)
        ),
        fluidRow(
          box(
            title = "Évolution de la densité médicale",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("graph_densite", height = "50vh")
          ),
          box(
            title = "Carte – Densité par région",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            leafletOutput("carte_densite_box", height = "50vh")
          )
        ),
        fluidRow(
          box(
            title = "Détails des données",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            collapsed = TRUE,
            DTOutput("tableau_details")
          )
        )
        
      ),
      
      # === TAB 2 : Carte leaflet ===
      tabItem(tabName = "carte_densite", fluidRow(column(
        12,
        h2("Densité médicale par département"),
        p("Indicateur : Nombre de médecins pour 100 000 habitants"),
        leafletOutput("carte_densite", height = "70vh")
      )))
    ))
)

# ============================================================================
# SERVEUR
# ============================================================================

server <- function(input, output, session) {
  # -------------------------------------------------------------------------
  # DONNÉES FILTRÉES RÉACTIVES
  # -------------------------------------------------------------------------
  donnees_filtrees <- reactive({
    df <- demographie_effectifs %>%
      filter(annee == input$filtre_annee, libelle_sexe == "tout sexe")
    
    # Profession
    if (input$filtre_profession != "TOUTES") {
      df <- df %>% filter(profession_sante == input$filtre_profession)
    } else {
      df <- df %>% filter(!grepl("^Ensemble", profession_sante))
    }
    
    # Région (filtrer seulement si une région spécifique est sélectionnée)
    if (input$filtre_region != "99") {
      df <- df %>% filter(region == input$filtre_region)
    }
    
    # Département (filtrer seulement si un département spécifique est sélectionné)
    if (input$filtre_departement != "999") {
      df <- df %>% filter(departement == input$filtre_departement)
    }
    
    # --- CAS SPÉCIAL : Région = Toute la France ET Département = Tous (France)
    # on exclut les lignes "FRANCE" globales, sauf si ce sont les seules
    if (input$filtre_region == "99" &&
        input$filtre_departement == "999") {
      # Si on a des lignes agrégées "FRANCE", on ne garde que les autres
      if (any(df$libelle_region == "FRANCE" |
              df$libelle_departement == "FRANCE")) {
        df <- df %>% filter(libelle_region == "FRANCE" &
                              libelle_departement == "FRANCE")
      }
    }
    
    # Classe d'âge
    if (input$filtre_classe_age != "tout_age") {
      df <- df %>% filter(libelle_classe_age == input$filtre_classe_age)
    } else {
      df <- df %>% filter(classe_age == "tout_age")
    }
    
    df
  })
  
  
  
  
  # -------------------------------------------------------------------------
  # CARTE INTERACTIVE LEAFLET
  # -------------------------------------------------------------------------
  output$carte_densite <- renderLeaflet({
    france_depts <- st_read("https://france-geojson.gregoiredavid.fr/repo/departements.geojson",
                            quiet = TRUE)
    
    df <- demographie_effectifs %>%
      filter(
        annee == input$filtre_annee,
        libelle_sexe == "tout sexe",
        classe_age == "tout_age",
        !grepl("^Ensemble", profession_sante)
      )
    
    if (input$filtre_profession != "TOUTES") {
      df <- df %>% filter(profession_sante == input$filtre_profession)
    }
    
    if (input$filtre_region != "99") {
      df <- df %>% filter(region == input$filtre_region)
    }
    
    if (input$filtre_departement != "999") {
      df <- df %>% filter(departement == input$filtre_departement)
    }
    
    densite_dep <- df %>%
      group_by(departement, libelle_departement) %>%
      summarise(densite = mean(densite, na.rm = TRUE),
                .groups = "drop") %>%
      arrange(desc(densite)) %>%
      mutate(rang = row_number())
    
    france_data <- france_depts %>%
      filter(code %in% c(sprintf("%02d", 1:95), "2A", "2B")) %>%
      left_join(densite_dep, by = c("code" = "departement"))
    
    is_region <- input$filtre_region != "99" &&
      input$filtre_departement == "999"
    is_departement <- input$filtre_departement != "999"
    
    if (nrow(densite_dep) == 0 || all(is.na(france_data$densite))) {
      return(
        leaflet(france_depts) %>%
          addTiles() %>%
          setView(
            lng = 2.5,
            lat = 46.6,
            zoom = 5.5
          ) %>%
          addPolygons(
            color = "grey",
            weight = 1,
            fillColor = "lightgrey",
            fillOpacity = 0.3,
            popup = ~ paste0("<b>", nom, "</b><br>Pas de données")
          )
      )
    }
    
    france_data <- france_data %>% filter(!is.na(densite))
    pal <- colorNumeric(palette = "RdYlBu",
                        domain = france_data$densite,
                        reverse = TRUE)
    
    # --- Carte ---
    map <- leaflet(france_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~ pal(densite),
        color = "white",
        weight = 1,
        fillOpacity = 0.8,
        label = lapply(1:nrow(france_data), function(i) {
          htmltools::HTML(
            sprintf(
              "<div style='background-color:white;padding:6px;border-radius:6px;
                   box-shadow:0 2px 6px rgba(0,0,0,0.3);'>
                   <b>%s</b><br>
                   Densité : %.1f /100 000 hab.<br>
                   Rang : %d</div>",
              france_data$libelle_departement[i],
              france_data$densite[i],
              france_data$rang[i]
            )
          )
        }),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal"),
          textsize = "13px",
          direction = "auto",
          opacity = 0.95
        ),
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#333",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        pal = pal,
        values = france_data$densite,
        title = "Densité médicale<br>(pour 100 000 hab.)",
        position = "bottomright"
      )
    
    
    
    map
  })
  
  
  
  # -------------------------------------------------------------------------
  # KPI 1 : EFFECTIF (Nombre de médecins)
  # -------------------------------------------------------------------------
  
  output$kpi_effectif <- renderValueBox({
    df <- donnees_filtrees()
    
    if (nrow(df) > 0) {
      effectif_total <- sum(df$effectif, na.rm = TRUE)
      
      # Formater le nombre avec des espaces
      effectif_format <- format(effectif_total,
                                big.mark = " ",
                                scientific = FALSE)
      
      valueBox(
        value = effectif_format,
        subtitle = "Nombre de professionnels",
        icon = icon("user-md"),
        color = "blue"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Nombre de professionnels",
        icon = icon("user-md"),
        color = "red"
      )
    }
  })
  
  # -------------------------------------------------------------------------
  # KPI 2 : DENSITÉ MÉDICALE
  # -------------------------------------------------------------------------
  
  output$kpi_densite <- renderValueBox({
    df <- donnees_filtrees()
    
    if (nrow(df) > 0 && sum(df$densite, na.rm = TRUE) > 0) {
      densite_moyenne <- mean(df$densite, na.rm = TRUE)
      
      # Formater avec 1 décimale
      densite_format <- format(round(densite_moyenne, 1), nsmall = 1)
      
      valueBox(
        value = densite_format,
        subtitle = "Pour 100 000 habitants",
        icon = icon("heartbeat"),
        color = "yellow"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Pour 100 000 habitants",
        icon = icon("heartbeat"),
        color = "red"
      )
    }
  })
  
  # -------------------------------------------------------------------------
  # KPI 3 : PART DES 60 ANS ET PLUS (Vieillissement de la profession)
  # -------------------------------------------------------------------------
  
  output$kpi_evolution <- renderValueBox({
    # Si un filtre de classe d'âge spécifique est sélectionné, on ne peut pas calculer
    if (input$filtre_classe_age != "tout_age") {
      return(
        valueBox(
          value = "N/A",
          subtitle = "Part des 60 ans et +",
          icon = icon("user-clock"),
          color = "light-blue"
        )
      )
    }
    
    # Préparer les filtres de base
    df <- demographie_effectifs
    
    # Filtre Année
    df <- df %>% filter(annee == input$filtre_annee)
    
    # Filtre Profession
    if (input$filtre_profession != "TOUTES") {
      df <- df %>% filter(profession_sante == input$filtre_profession)
    } else {
      df <- df %>% filter(!grepl("^Ensemble", profession_sante))
    }
    
    # Filtre Région
    df <- df %>% filter(region == input$filtre_region)
    
    # Filtre Département
    df <- df %>% filter(departement == input$filtre_departement)
    
    # Filtrer sur "tout sexe"
    df <- df %>% filter(libelle_sexe == "tout sexe")
    
    # Calculer l'effectif total (toutes classes d'âge)
    df_total <- df %>%
      filter(classe_age == "tout_age")
    effectif_total <- sum(df_total$effectif, na.rm = TRUE)
    
    # Calculer l'effectif des 60 ans et plus
    # Les classes concernées : 60-64, 65-69, 70+
    df_60plus <- df %>%
      filter(classe_age %in% c("60-64", "65-69", "70+"))
    effectif_60plus <- sum(df_60plus$effectif, na.rm = TRUE)
    
    if (effectif_total > 0) {
      # Calculer le pourcentage
      part_60plus <- (effectif_60plus / effectif_total) * 100
      
      # Formater l'affichage
      part_txt <- paste0(format(round(part_60plus, 1), nsmall = 1), "%")
      
      # Couleur selon le niveau d'alerte
      if (part_60plus >= 40) {
        couleur <- "red"  # Alerte forte : plus de 40% ont 60+ ans
        icone <- icon("exclamation-triangle")
      } else if (part_60plus >= 30) {
        couleur <- "orange"  # Alerte modérée : entre 30% et 40%
        icone <- icon("user-clock")
      } else if (part_60plus >= 20) {
        couleur <- "yellow"  # Vigilance : entre 20% et 30%
        icone <- icon("user-clock")
      } else {
        couleur <- "green"  # Situation favorable : moins de 20%
        icone <- icon("user-check")
      }
      
      valueBox(
        value = part_txt,
        subtitle = "Part des 60 ans et +",
        icon = icone,
        color = couleur
      )
      
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Part des 60 ans et +",
        icon = icon("user-clock"),
        color = "red"
      )
    }
  })
  
  # -------------------------------------------------------------------------
  # TABLEAU DE DÉTAILS
  # -------------------------------------------------------------------------
  
  output$tableau_details <- renderDT({
    df <- donnees_filtrees()
    
    if (nrow(df) > 0) {
      df %>%
        select(
          annee,
          profession_sante,
          libelle_region,
          libelle_departement,
          libelle_classe_age,
          libelle_sexe,
          effectif,
          densite
        ) %>%
        datatable(
          options = list(
            responsive = TRUE,
            pageLength = 10,
            language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/French.json'),
            scrollX = TRUE
          ),
          rownames = FALSE,
          colnames = c(
            "Année",
            "Profession",
            "Région",
            "Département",
            "Classe d'âge",
            "Sexe",
            "Effectif",
            "Densité"
          )
        )
    } else {
      datatable(data.frame(Message = "Aucune donnée disponible pour cette sélection"))
    }
  })
  
  # -------------------------------------------------------------------------
  # MISE À JOUR DES DÉPARTEMENTS SELON LA RÉGION SÉLECTIONNÉE
  # -------------------------------------------------------------------------
  
  observeEvent(input$filtre_region, {
    if (input$filtre_region == "99") {
      # Si "Toute la France", afficher tous les départements
      choix_dept <- c("Tous (France)" = "999", choix_departements)
    } else {
      # Filtrer les départements de la région sélectionnée
      dept_region <- demographie_effectifs %>%
        filter(region == input$filtre_region) %>%
        select(departement, libelle_departement) %>%
        distinct() %>%
        arrange(departement) %>%
        mutate(display = paste0(departement, " - ", libelle_departement))
      
      choix_dept <- c("Tous" = "999",
                      setNames(dept_region$departement, dept_region$display))
    }
    
    updateSelectInput(session,
                      "filtre_departement",
                      choices = choix_dept,
                      selected = "999")
  })
  
  # -------------------------------------------------------------------------
  # BOUTON RESET
  # -------------------------------------------------------------------------
  
  observeEvent(input$reset_filtres, {
    updateSelectInput(session, "filtre_annee", selected = max(liste_annees))
    updateSelectInput(session, "filtre_profession", selected = "TOUTES")
    updateSelectInput(session, "filtre_region", selected = "99")
    updateSelectInput(session, "filtre_departement", selected = "999")
    updateSelectInput(session, "filtre_classe_age", selected = "tout_age")
  })
  
  # -------------------------------------------------------------------------
  # Carte interactive box
  # -------------------------------------------------------------------------
  output$carte_densite_box <- renderLeaflet({
    france_depts <- st_read("https://france-geojson.gregoiredavid.fr/repo/departements.geojson",
                            quiet = TRUE)
    
    df <- demographie_effectifs %>%
      filter(
        annee == input$filtre_annee,
        libelle_sexe == "tout sexe",
        classe_age == "tout_age",
        !grepl("^Ensemble", profession_sante)
      )
    
    if (input$filtre_profession != "TOUTES") {
      df <- df %>% filter(profession_sante == input$filtre_profession)
    }
    
    if (input$filtre_region != "99") {
      df <- df %>% filter(region == input$filtre_region)
    }
    
    if (input$filtre_departement != "999") {
      df <- df %>% filter(departement == input$filtre_departement)
    }
    
    densite_dep <- df %>%
      group_by(departement, libelle_departement) %>%
      summarise(densite = mean(densite, na.rm = TRUE),
                .groups = "drop") %>%
      arrange(desc(densite)) %>%
      mutate(rang = row_number())
    
    france_data <- france_depts %>%
      filter(code %in% c(sprintf("%02d", 1:95), "2A", "2B")) %>%
      left_join(densite_dep, by = c("code" = "departement"))
    
    is_region <- input$filtre_region != "99" &&
      input$filtre_departement == "999"
    is_departement <- input$filtre_departement != "999"
    
    if (nrow(densite_dep) == 0 || all(is.na(france_data$densite))) {
      return(
        leaflet(france_depts) %>%
          addTiles() %>%
          setView(
            lng = 2.5,
            lat = 46.6,
            zoom = 5.5
          ) %>%
          addPolygons(
            color = "grey",
            weight = 1,
            fillColor = "lightgrey",
            fillOpacity = 0.3,
            popup = ~ paste0("<b>", nom, "</b><br>Pas de données")
          )
      )
    }
    
    france_data <- france_data %>% filter(!is.na(densite))
    pal <- colorNumeric(palette = "RdYlBu",
                        domain = france_data$densite,
                        reverse = TRUE)
    
    # --- Carte ---
    map <- leaflet(france_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~ pal(densite),
        color = "white",
        weight = 1,
        fillOpacity = 0.8,
        label = lapply(1:nrow(france_data), function(i) {
          htmltools::HTML(
            sprintf(
              "<div style='background-color:white;padding:6px;border-radius:6px;
                   box-shadow:0 2px 6px rgba(0,0,0,0.3);'>
                   <b>%s</b><br>
                   Densité : %.1f /100 000 hab.<br>
                   Rang : %d</div>",
              france_data$libelle_departement[i],
              france_data$densite[i],
              france_data$rang[i]
            )
          )
        }),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal"),
          textsize = "13px",
          direction = "auto",
          opacity = 0.95
        ),
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#333",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        pal = pal,
        values = france_data$densite,
        title = "Densité médicale<br>(pour 100 000 hab.)",
        position = "bottomright"
      )
    
    
    
    map
  })
  
  
}

# ============================================================================
# LANCEMENT DE L'APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
