# ============================================================================
# SERVER_FINESS.R - Logique serveur pour les établissements FINESS
# ============================================================================

# ----------- 1. KPIs FINESS -----------

## ----- 1.1. KPI Nombre d'établissements -----
output$kpi_nb_etablissements <- renderValueBox({
  df <- donnees_finess_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée disponible", br(), "Vérifiez vos filtres"),
      icon = icon("hospital"),
      color = "red"
    ))
  }
  
  nb <- nrow(df)
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", format(nb, big.mark = " ")),
    subtitle = tags$div(style = "color: #2c3e50;", "Établissements"),
    icon = icon("hospital"),
    color = "purple"
  )
})

## ----- 1.2. KPI Nombre de catégories -----
output$kpi_nb_categories <- renderValueBox({
  df <- donnees_finess_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée disponible", br(), "Vérifiez vos filtres"),
      icon = icon("list"),
      color = "red"
    ))
  }
  
  nb_cat <- length(unique(df$libcategetab))
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", nb_cat),
    subtitle = tags$div(style = "color: #2c3e50;", "Catégories"),
    icon = icon("list"),
    color = "blue"
  )
})

## ----- 1.3. KPI Nombre de départements -----
output$kpi_nb_departements <- renderValueBox({
  df <- donnees_finess_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée disponible", br(), "Vérifiez vos filtres"),
      icon = icon("map-marked"),
      color = "red"
    ))
  }
  
  nb_dept <- length(unique(df$departement))
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", nb_dept),
    subtitle = tags$div(style = "color: #2c3e50;", "Départements"),
    icon = icon("map-marked"),
    color = "green"
  )
})

## ----- 1.4. KPI Dernière MAJ -----
output$kpi_maj_recente <- renderValueBox({
  df <- donnees_finess_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée disponible", br(), "Vérifiez vos filtres"),
      icon = icon("calendar-check"),
      color = "red"
    ))
  }
  
  annees_valides <- df$annee[!is.na(df$annee)]
  
  if (length(annees_valides) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Dates non disponibles", br(), "dans les données"),
      icon = icon("calendar-check"),
      color = "red"
    ))
  }
  
  derniere <- max(annees_valides)
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", derniere),
    subtitle = tags$div(style = "color: #2c3e50;", "Dernière MAJ"),
    icon = icon("calendar-check"),
    color = "yellow"
  )
})

# ----------- 2. GRAPHIQUES OVERVIEW -----------

## ----- 2.1. Graphique Top catégories -----
output$graph_top_categories <- renderPlotly({
  df <- donnees_finess_filtrees()
  if (is.null(df) || nrow(df) == 0)
    return(plotly_empty())
  
  df_cat <- df |>
    group_by(libcategetab) |>
    summarise(n = n(), .groups = "drop")
  
  if (input$top_bottom_categories == "top") {
    df_cat <- df_cat |> arrange(desc(n)) |> head(10)
    couleur_fill <- "#667eea"
  } else {
    df_cat <- df_cat |> arrange(n) |> head(10)
    couleur_fill <- "#f093fb"
  }
  
  p <- ggplot(df_cat, aes(x = reorder(libcategetab, n), y = n)) +
    geom_col(fill = couleur_fill, alpha = 0.85) +
    geom_text(aes(label = format(n, big.mark = " ")), hjust = -0.1, size = 3.5, fontface = "bold") +
    coord_flip() +
    labs(title = "", x = "", y = "Nombre d'établissements") +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 10, face = "bold"),
          axis.text.x = element_text(size = 10),
          panel.grid.major.y = element_blank())
  
  ggplotly(p, tooltip = "y") |> layout(showlegend = FALSE, margin = list(l = 250))
})

## ----- 2.2. Graphique Départements -----
output$graph_dept_repartition <- renderPlotly({
  df <- donnees_finess_filtrees()
  if (is.null(df) || nrow(df) == 0)
    return(plotly_empty())
  
  df_dept <- df |>
    group_by(departement, libdepartement) |>
    summarise(n = n(), .groups = "drop") |>
    mutate(display = paste0(departement, " - ", substr(libdepartement, 1, 20)))
  
  if (input$top_bottom_departements == "top") {
    df_dept <- df_dept |> arrange(desc(n)) |> head(10)
    couleur_fill <- "#4facfe"
  } else {
    df_dept <- df_dept |> arrange(n) |> head(10)
    couleur_fill <- "#fa709a"
  }
  
  p <- ggplot(df_dept, aes(x = reorder(display, n), y = n)) +
    geom_col(fill = couleur_fill, alpha = 0.85) +
    geom_text(aes(label = format(n, big.mark = " ")), hjust = -0.1, size = 3, fontface = "bold") +
    coord_flip() +
    labs(title = "", x = "", y = "Nombre d'établissements") +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 9, face = "bold"),
          panel.grid.major.y = element_blank())
  
  ggplotly(p, tooltip = "y") |> layout(margin = list(l = 180))
})

## ----- 2.3. Carte d'aperçu -----
output$carte_apercu_finess <- renderLeaflet({
  df <- donnees_finess_filtrees()
  if (is.null(df) ||
      nrow(df) == 0 ||
      sum(!is.na(df$longitude) & !is.na(df$latitude)) == 0) {
    return(
      leaflet() |>
        addProviderTiles(providers$CartoDB.Positron) |>
        setView(lng = 2.5, lat = 46.6, zoom = 5.5)
    )
  }
  
  if (nrow(df) > 3000) {
    df <- df |> sample_n(3000)
  }
  
  leaflet(df) |>
    addProviderTiles(providers$CartoDB.Positron) |>
    addCircleMarkers(
      lng = ~ longitude,
      lat = ~ latitude,
      radius = 4,
      color = "#667eea",
      fillColor = "#667eea",
      fillOpacity = 0.6,
      stroke = TRUE,
      weight = 1,
      clusterOptions = markerClusterOptions()
    ) |>
    setView(lng = 2.5, lat = 46.6, zoom = 5.5)
})

# ----------- 3. CARTE INTERACTIVE -----------

## ----- 3.1. Info boxes -----
output$info_nb_points_carte <- renderInfoBox({
  df <- donnees_finess_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(infoBox(
      title = "Points",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Aucune donnée"),
      icon = icon("map-pin"),
      color = "red",
      fill = TRUE
    ))
  }
  
  nb_coords <- sum(!is.na(df$longitude) & !is.na(df$latitude))
  
  if (nb_coords == 0) {
    return(infoBox(
      title = "Points",
      value = tags$div(style = "color: #2c3e50;", "0"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Aucune coordonnée GPS"),
      icon = icon("map-pin"),
      color = "red",
      fill = TRUE
    ))
  }
  
  infoBox(
    title = "Points sur la carte",
    value = tags$div(style = "color: #2c3e50;", format(min(nb_coords, 5000), big.mark = " ")),
    subtitle = tags$div(style = "color: #2c3e50;", if (nb_coords > 5000) "(échantillon)" else "(total)"),
    icon = icon("map-pin"),
    color = "blue",
    fill = TRUE
  )
})

output$info_precision_geo <- renderInfoBox({
  df <- donnees_finess_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(infoBox(
      title = "Précision",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Aucune donnée"),
      icon = icon("crosshairs"),
      color = "red",
      fill = TRUE
    ))
  }
  
  df <- df |> mutate(precision = substr(sourcecoordet, 1, 1))
  precision_1 <- sum(df$precision == "1", na.rm = TRUE)
  
  if (nrow(df) == 0) {
    return(infoBox(
      title = "Précision",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Données non disponibles"),
      icon = icon("crosshairs"),
      color = "red",
      fill = TRUE
    ))
  }
  
  pct <- round(100 * precision_1 / nrow(df), 1)
  
  infoBox(
    title = "Précision maximale",
    value = tags$div(style = "color: #2c3e50;", paste0(pct, "%")),
    subtitle = tags$div(style = "color: #2c3e50;", "Adresses exactes"),
    icon = icon("crosshairs"),
    color = if (pct > 70) "green" else if (pct > 50) "yellow" else "red",
    fill = TRUE
  )
})

output$info_dernier_filtre <- renderInfoBox({
  filtre_actif <- "Tous"
  
  if (!is.null(input$filtre_departement_finess) && input$filtre_departement_finess != "TOUS") {
    filtre_actif <- paste("Dept:", input$filtre_departement_finess)
  } else if (!is.null(input$filtre_categorie) && input$filtre_categorie != "TOUTES") {
    filtre_actif <- "Catégorie active"
  }
  
  infoBox(
    title = "Filtre actif",
    value = tags$div(style = "color: #2c3e50;", filtre_actif),
    subtitle = tags$div(style = "color: #2c3e50;", "Filtres appliqués"),
    icon = icon("filter"),
    color = "purple",
    fill = TRUE
  )
})

## ----- 3.2. Carte principale -----
output$carte_principale_finess <- renderLeaflet({
  df <- donnees_finess_filtrees()
  
  if (is.null(df) ||
      nrow(df) == 0 ||
      sum(!is.na(df$longitude) & !is.na(df$latitude)) == 0) {
    return(
      leaflet() |>
        addProviderTiles(providers$CartoDB.Positron) |>
        setView(lng = 2.5, lat = 46.6, zoom = 5.5)
    )
  }
  
  if (nrow(df) > 5000) {
    df <- df |> sample_n(5000)
  }
  
  categories_uniques <- unique(df$libcategetab)
  pal <- colorFactor(palette = "Set3", domain = categories_uniques)
  
  map <- leaflet(df) |>
    addProviderTiles(providers$CartoDB.Positron)
  
  if (input$show_cluster) {
    map <- map |>
      addCircleMarkers(
        lng = ~ longitude,
        lat = ~ latitude,
        radius = 6,
        color = ~ pal(libcategetab),
        fillOpacity = 0.7,
        stroke = TRUE,
        weight = 1,
        popup = ~ paste0(
          "<div style='min-width:280px;'>",
          "<h4 style='margin:5px 0; color:#667eea;'>", rs, "</h4>",
          "<hr style='margin:10px 0;'/>",
          "<p><strong>📋 Catégorie :</strong> ", libcategetab, "</p>",
          "<p><strong>📍 Département :</strong> ", departement, " - ", libdepartement, "</p>",
          "<p><strong>🏠 Adresse :</strong> ", ligneacheminement, "</p>",
          "<p><strong>🆔 N° FINESS :</strong> ", nofinesset, "</p>",
          "</div>"
        ),
        clusterOptions = markerClusterOptions()
      )
  } else {
    map <- map |>
      addCircleMarkers(
        lng = ~ longitude,
        lat = ~ latitude,
        radius = 5,
        color = ~ pal(libcategetab),
        fillOpacity = 0.7,
        stroke = TRUE,
        weight = 1,
        popup = ~ paste0(
          "<div style='min-width:280px;'>",
          "<h4 style='margin:5px 0; color:#667eea;'>", rs, "</h4>",
          "<hr style='margin:10px 0;'/>",
          "<p><strong>📋 Catégorie :</strong> ", libcategetab, "</p>",
          "<p><strong>📍 Département :</strong> ", departement, " - ", libdepartement, "</p>",
          "</div>"
        )
      )
  }
  
  if (input$show_legend && length(categories_uniques) <= 10) {
    map <- map |>
      addLegend(
        pal = pal,
        values = ~ libcategetab,
        title = "Catégorie",
        position = "bottomright",
        opacity = 0.8
      )
  }
  
  map
})

# ----------- 4. GRAPHIQUES D'ANALYSE -----------

## ----- 4.1. Évolution temporelle -----
output$graph_evolution_annuelle_finess <- renderPlotly({
  if (is.null(finess_data))
    return(plotly_empty())
  
  df <- finess_data
  
  if (!is.null(input$filtre_departement_finess) && input$filtre_departement_finess != "TOUS") {
    df <- df |> filter(departement == input$filtre_departement_finess)
  }
  
  if (!is.null(input$filtre_categorie) && input$filtre_categorie != "TOUTES") {
    df <- df |> filter(libcategetab == input$filtre_categorie)
  }
  
  df_evol <- df |>
    filter(annee >= input$periode_evolution_finess[1], annee <= input$periode_evolution_finess[2]) |>
    group_by(annee) |>
    summarise(n = n(), .groups = "drop")
  
  p <- ggplot(df_evol, aes(x = annee, y = n)) +
    geom_line(color = "#667eea", size = 2) +
    geom_point(color = "#764ba2", size = 5) +
    geom_area(fill = "#667eea", alpha = 0.2) +
    labs(title = "", x = "Année", y = "Nombre d'établissements") +
    theme_minimal()
  
  ggplotly(p, tooltip = c("x", "y"))
})

## ----- 4.2. Densité par département -----
output$graph_densite_dept_finess <- renderPlotly({
  df <- donnees_finess_filtrees()
  if (is.null(df) || nrow(df) == 0)
    return(plotly_empty())
  
  df_dept <- df |>
    group_by(departement, libdepartement) |>
    summarise(n = n(), .groups = "drop")
  
  p <- ggplot(df_dept, aes(x = n)) +
    geom_histogram(bins = 30, fill = "#4facfe", color = "white", alpha = 0.85) +
    labs(title = "", x = "Nombre d'établissements", y = "Fréquence") +
    theme_minimal()
  
  ggplotly(p)
})

## ----- 4.3. Distribution par catégorie -----
output$graph_pie_categories_finess <- renderPlotly({
  df <- donnees_finess_filtrees()
  if (is.null(df) || nrow(df) == 0)
    return(plotly_empty())
  
  df_top <- df |>
    group_by(libcategetab) |>
    summarise(n = n(), .groups = "drop") |>
    arrange(desc(n)) |>
    head(10)
  
  plot_ly(
    df_top,
    labels = ~ libcategetab,
    values = ~ n,
    type = "pie",
    textposition = "inside",
    textinfo = "label+percent",
    marker = list(colors = RColorBrewer::brewer.pal(10, "Set3")),
    hole = 0.4
  )
})

## ----- 4.4. Évolution par catégorie -----
output$graph_evol_categories_finess <- renderPlotly({
  if (is.null(finess_data))
    return(plotly_empty())
  
  df <- finess_data
  
  if (!is.null(input$filtre_departement_finess) && input$filtre_departement_finess != "TOUS") {
    df <- df |> filter(departement == input$filtre_departement_finess)
  }
  
  top_cat <- df |>
    group_by(libcategetab) |>
    summarise(n = n(), .groups = "drop") |>
    arrange(desc(n)) |>
    head(5) |>
    pull(libcategetab)
  
  df_evol <- df |>
    filter(libcategetab %in% top_cat) |>
    filter(annee >= input$periode_evolution_cat_finess[1],
           annee <= input$periode_evolution_cat_finess[2]) |>
    group_by(annee, libcategetab) |>
    summarise(n = n(), .groups = "drop")
  
  p <- ggplot(df_evol, aes(x = annee, y = n, color = libcategetab)) +
    geom_line(size = 1.5) +
    geom_point(size = 3.5) +
    labs(title = "", x = "Année", y = "Nombre", color = "Catégorie") +
    theme_minimal()
  
  ggplotly(p, tooltip = c("x", "y", "color"))
})

## ----- 4.5. Statistiques descriptives -----
output$stats_descriptives_finess <- renderPrint({
  df <- donnees_finess_filtrees()
  if (is.null(df)) {
    cat("❌ Aucune donnée disponible\n")
    return()
  }
  
  cat("╔═══════════════════════════════════════════════════════╗\n")
  cat("║         STATISTIQUES DESCRIPTIVES - FINESS           ║\n")
  cat("╚═══════════════════════════════════════════════════════╝\n\n")
  
  cat("📊 DONNÉES GÉNÉRALES\n")
  cat("   └─ Établissements totaux :", format(nrow(df), big.mark = " "), "\n")
  cat("   └─ Catégories distinctes :", length(unique(df$libcategetab)), "\n")
  cat("   └─ Départements couverts :", length(unique(df$departement)), "\n\n")
  
  cat("🌍 GÉOLOCALISATION\n")
  nb_geo <- sum(!is.na(df$longitude) & !is.na(df$latitude))
  cat("   └─ Avec coordonnées GPS :", format(nb_geo, big.mark = " "), "\n")
  cat("   └─ Taux de couverture   :", round(100 * nb_geo / nrow(df), 1), "%\n\n")
})

## ----- 4.6. Qualité des données -----
output$graph_qualite_donnees_finess <- renderPlotly({
  df <- donnees_finess_filtrees()
  if (is.null(df))
    return(plotly_empty())
  
  qualite <- data.frame(
    indicateur = c("Avec coordonnées GPS", "Sans coordonnées GPS", 
                   "Avec adresse complète", "Sans adresse"),
    valeur = c(
      sum(!is.na(df$longitude) & !is.na(df$latitude)),
      sum(is.na(df$longitude) | is.na(df$latitude)),
      sum(!is.na(df$ligneacheminement)),
      sum(is.na(df$ligneacheminement))
    )
  )
  
  qualite$pct <- round(100 * qualite$valeur / nrow(df), 1)
  
  plot_ly(
    qualite,
    x = ~ pct,
    y = ~ indicateur,
    type = "bar",
    orientation = "h",
    text = ~ paste0(format(valeur, big.mark = " "), " (", pct, "%)"),
    textposition = "outside",
    marker = list(color = c("#43e97b", "#fa709a", "#4facfe", "#f093fb"))
  )
})

# ----------- 5. TABLEAU DE DONNÉES -----------

output$tableau_principal_finess <- renderDT({
  df <- donnees_finess_filtrees()
  if (is.null(df) || nrow(df) == 0) {
    return(datatable(data.frame(Message = "Aucune donnée disponible")))
  }
  
  if (input$colonnes_affichage_finess == "Essentielles") {
    df <- df |>
      select(nofinesset, rs, libcategetab, departement, libdepartement, 
             ligneacheminement, datemaj, annee)
  }
  
  datatable(
    df,
    options = list(
      responsive = TRUE,
      pageLength = input$nb_lignes_page_finess,
      scrollX = TRUE,
      language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/French.json')
    ),
    rownames = FALSE,
    filter = "top",
    class = 'cell-border stripe hover'
  )
})

# ----------- 6. TÉLÉCHARGEMENT -----------

output$telecharger_donnees_finess <- downloadHandler(
  filename = function() {
    paste0("finess_export_", Sys.Date(), ".csv")
  },
  content = function(file) {
    df <- donnees_finess_filtrees()
    if (!is.null(df)) {
      write.csv(df, file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  }
)