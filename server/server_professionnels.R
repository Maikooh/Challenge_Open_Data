# ============================================================================
# SERVER_PROFESSIONNELS.R - Logique serveur pour les professionnels de santé
# ============================================================================

# ----------- 1. KPIs PROFESSIONNELS -----------

## ----- 1.1. KPI Effectif total -----
output$kpi_effectif_pro <- renderValueBox({
  df <- donnees_pro_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée disponible", br(), "Vérifiez vos filtres"),
      icon = icon("user-md"),
      color = "red"
    ))
  }
  
  effectif_total <- sum(as.numeric(df$effectif), na.rm = TRUE)
  
  if (effectif_total == 0 || is.na(effectif_total)) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "0"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucun professionnel", br(), "pour cette sélection"),
      icon = icon("user-md"),
      color = "red"
    ))
  }
  
  effectif_format <- format(effectif_total, big.mark = " ", scientific = FALSE)
  
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", effectif_format),
    subtitle = tags$div(style = "color: #2c3e50;", "Nombre de professionnels"),
    icon = icon("user-md"),
    color = "purple"
  )
})

## ----- 1.2. KPI Densité moyenne -----
output$kpi_densite_pro <- renderValueBox({
  df <- donnees_pro_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée disponible", br(), "Vérifiez vos filtres"),
      icon = icon("heartbeat"),
      color = "red"
    ))
  }
  
  densite_valeurs <- as.numeric(df$densite)
  densite_valeurs <- densite_valeurs[!is.na(densite_valeurs)]
  
  if (length(densite_valeurs) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Données de densité", br(), "non disponibles"),
      icon = icon("heartbeat"),
      color = "red"
    ))
  }
  
  densite_moyenne <- mean(densite_valeurs)
  densite_format <- format(round(densite_moyenne, 1), nsmall = 1)
  
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", densite_format),
    subtitle = tags$div(style = "color: #2c3e50;", "Pour 100 000 habitants"),
    icon = icon("heartbeat"),
    color = "blue"
  )
})

## ----- 1.3. KPI Nombre de professions -----
output$kpi_nb_professions <- renderValueBox({
  df <- donnees_pro_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée disponible", br(), "Vérifiez vos filtres"),
      icon = icon("stethoscope"),
      color = "red"
    ))
  }
  
  nb_prof <- length(unique(df$profession_sante))
  
  if (nb_prof == 0) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "0"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune profession", br(), "pour cette sélection"),
      icon = icon("stethoscope"),
      color = "red"
    ))
  }
  
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", nb_prof),
    subtitle = tags$div(style = "color: #2c3e50;", "Professions"),
    icon = icon("stethoscope"),
    color = "green"
  )
})

## ----- 1.4. KPI Part des 60 ans et plus -----
output$kpi_part_60ans_pro <- renderValueBox({
  if (!is.null(input$filtre_classe_age) && input$filtre_classe_age != "tout_age") {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Filtre classe d'âge actif", br(), "Sélectionnez 'Tous les âges'"),
      icon = icon("user-clock"),
      color = "light-blue"
    ))
  }
  
  if (is.null(demographie_effectifs)) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Données non chargées", br(), "Erreur de chargement"),
      icon = icon("user-clock"),
      color = "red"
    ))
  }
  
  annee_selectionnee <- input$filtre_annee_pro
  if (is.null(annee_selectionnee))
    annee_selectionnee <- max(liste_annees_pro)
  
  df <- demographie_effectifs |>
    filter(annee == annee_selectionnee, libelle_sexe == "tout sexe")
  
  if (!is.null(input$filtre_profession) && input$filtre_profession != "TOUTES") {
    df <- df |> filter(profession_sante == input$filtre_profession)
  } else {
    df <- df |> filter(!grepl("^Ensemble", profession_sante))
  }
  
  if (!is.null(input$filtre_region) && input$filtre_region != "99") {
    df <- df |> filter(region == input$filtre_region)
  }
  
  if (!is.null(input$filtre_departement_pro) && input$filtre_departement_pro != "999") {
    df <- df |> filter(departement == input$filtre_departement_pro)
  }
  
  df_total <- df |> filter(classe_age == "tout_age")
  effectif_total <- sum(as.numeric(df_total$effectif), na.rm = TRUE)
  
  df_60plus <- df |> filter(classe_age %in% c("60-64", "65-69", "70+"))
  effectif_60plus <- sum(as.numeric(df_60plus$effectif), na.rm = TRUE)
  
  if (effectif_total == 0 || is.na(effectif_total)) {
    return(valueBox(
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 11px;", "Aucune donnée d'effectif", br(), "Vérifiez vos filtres"),
      icon = icon("user-clock"),
      color = "red"
    ))
  }
  
  part_60plus <- (effectif_60plus / effectif_total) * 100
  part_txt <- paste0(format(round(part_60plus, 1), nsmall = 1), "%")
  
  couleur <- if (part_60plus >= 40) "red"
             else if (part_60plus >= 30) "orange"
             else if (part_60plus >= 20) "yellow"
             else "green"
  
  valueBox(
    value = tags$div(style = "color: #2c3e50; font-size: 32px;", part_txt),
    subtitle = tags$div(style = "color: #2c3e50;", "Part des 60 ans et +"),
    icon = icon("user-clock"),
    color = couleur
  )
})

# ----------- 2. GRAPHIQUES OVERVIEW -----------

## ----- 2.1. Top professions -----
output$graph_top_professions_overview <- renderPlotly({
  df <- donnees_pro_filtrees()
  
  if (is.null(df) || nrow(df) == 0)
    return(plotly_empty())
  
  df_prof <- df |>
    group_by(profession_sante) |>
    summarise(total = sum(as.numeric(effectif), na.rm = TRUE), .groups = "drop")
  
  if (input$top_bottom_professions == "top") {
    df_prof <- df_prof |> arrange(desc(total)) |> head(10)
    couleur_fill <- "#667eea"
  } else {
    df_prof <- df_prof |> arrange(total) |> head(10)
    couleur_fill <- "#f093fb"
  }
  
  p <- ggplot(df_prof, aes(x = reorder(profession_sante, total), y = total)) +
    geom_col(fill = couleur_fill, alpha = 0.85) +
    geom_text(aes(label = format(total, big.mark = " ")), hjust = -0.1, size = 3.5, fontface = "bold") +
    coord_flip() +
    labs(title = "", x = "", y = "Effectif total") +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 10, face = "bold"),
          axis.text.x = element_text(size = 10),
          panel.grid.major.y = element_blank())
  
  ggplotly(p, tooltip = "y") |> layout(margin = list(l = 180))
})

## ----- 2.2. Carte d'aperçu -----
output$carte_apercu_pro <- renderLeaflet({
  if (is.null(france_depts)) {
    return(leaflet() |>
             addTiles() |>
             setView(lng = 2.5, lat = 46.6, zoom = 5.5))
  }
  
  annee_selectionnee <- input$filtre_annee_pro
  if (is.null(annee_selectionnee))
    annee_selectionnee <- max(liste_annees_pro)
  
  df <- demographie_effectifs |>
    filter(annee == annee_selectionnee, libelle_sexe == "tout sexe",
           classe_age == "tout_age", !grepl("^Ensemble", profession_sante))
  
  if (!is.null(input$filtre_profession) && input$filtre_profession != "TOUTES") {
    df <- df |> filter(profession_sante == input$filtre_profession)
  }
  
  densite_dep <- df |>
    group_by(departement) |>
    summarise(densite = mean(as.numeric(densite), na.rm = TRUE), .groups = "drop")
  
  france_data <- france_depts |>
    filter(code %in% c(sprintf("%02d", 1:95), "2A", "2B")) |>
    left_join(densite_dep, by = c("code" = "departement"))
  
  if (all(is.na(france_data$densite))) {
    return(leaflet(france_depts) |>
             addTiles() |>
             setView(lng = 2.5, lat = 46.6, zoom = 5.5) |>
             addPolygons(color = "grey", weight = 1, fillColor = "lightgrey", fillOpacity = 0.3))
  }
  
  france_data <- france_data |> filter(!is.na(densite))
  pal <- colorNumeric(palette = "RdYlBu", domain = france_data$densite, reverse = TRUE)
  
  leaflet(france_data) |>
    addTiles() |>
    addPolygons(
      fillColor = ~ pal(densite),
      color = "white",
      weight = 1,
      fillOpacity = 0.6,
      highlightOptions = highlightOptions(weight = 2, color = "#333", fillOpacity = 0.8)
    ) |>
    setView(lng = 2.5, lat = 46.6, zoom = 5.5)
})

# ----------- 3. CARTE DE DENSITÉ -----------

## ----- 3.1. Info boxes -----
output$info_densite_min <- renderInfoBox({
  df <- donnees_pro_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(infoBox(
      title = "Densité Min",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Aucune donnée"),
      icon = icon("arrow-down"),
      color = "red",
      fill = TRUE
    ))
  }
  
  densite_valeurs <- as.numeric(df$densite)
  densite_valeurs <- densite_valeurs[!is.na(densite_valeurs) & densite_valeurs > 0]
  
  if (length(densite_valeurs) == 0) {
    return(infoBox(
      title = "Densité Min",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Données non disponibles"),
      icon = icon("arrow-down"),
      color = "red",
      fill = TRUE
    ))
  }
  
  densite_min <- min(densite_valeurs)
  
  infoBox(
    title = "Densité minimale",
    value = tags$div(style = "color: #2c3e50;", format(round(densite_min, 1), nsmall = 1)),
    subtitle = tags$div(style = "color: #2c3e50;", "Pour 100k hab."),
    icon = icon("arrow-down"),
    color = "red",
    fill = TRUE
  )
})

output$info_densite_max <- renderInfoBox({
  df <- donnees_pro_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(infoBox(
      title = "Densité Max",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Aucune donnée"),
      icon = icon("arrow-up"),
      color = "red",
      fill = TRUE
    ))
  }
  
  densite_valeurs <- as.numeric(df$densite)
  densite_valeurs <- densite_valeurs[!is.na(densite_valeurs) & densite_valeurs > 0]
  
  if (length(densite_valeurs) == 0) {
    return(infoBox(
      title = "Densité Max",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Données non disponibles"),
      icon = icon("arrow-up"),
      color = "red",
      fill = TRUE
    ))
  }
  
  densite_max <- max(densite_valeurs)
  
  infoBox(
    title = "Densité maximale",
    value = tags$div(style = "color: #2c3e50;", format(round(densite_max, 1), nsmall = 1)),
    subtitle = tags$div(style = "color: #2c3e50;", "Pour 100k hab."),
    icon = icon("arrow-up"),
    color = "green",
    fill = TRUE
  )
})

output$info_densite_moy <- renderInfoBox({
  df <- donnees_pro_filtrees()
  
  if (is.null(df) || nrow(df) == 0) {
    return(infoBox(
      title = "Densité Moy",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Aucune donnée"),
      icon = icon("equals"),
      color = "red",
      fill = TRUE
    ))
  }
  
  densite_valeurs <- as.numeric(df$densite)
  densite_valeurs <- densite_valeurs[!is.na(densite_valeurs) & densite_valeurs > 0]
  
  if (length(densite_valeurs) == 0) {
    return(infoBox(
      title = "Densité Moy",
      value = tags$div(style = "color: #2c3e50;", "N/A"),
      subtitle = tags$div(style = "color: #2c3e50; font-size: 10px;", "Données non disponibles"),
      icon = icon("equals"),
      color = "red",
      fill = TRUE
    ))
  }
  
  densite_moy <- mean(densite_valeurs)
  
  infoBox(
    title = "Densité moyenne",
    value = tags$div(style = "color: #2c3e50;", format(round(densite_moy, 1), nsmall = 1)),
    subtitle = tags$div(style = "color: #2c3e50;", "Pour 100k hab."),
    icon = icon("equals"),
    color = "blue",
    fill = TRUE
  )
})

## ----- 3.2. Carte principale de densité -----
output$carte_densite_pro <- renderLeaflet({
  if (is.null(france_depts)) {
    return(leaflet() |>
             addTiles() |>
             setView(lng = 2.5, lat = 46.6, zoom = 5.5))
  }
  
  annee_selectionnee <- input$filtre_annee_pro
  if (is.null(annee_selectionnee))
    annee_selectionnee <- max(liste_annees_pro)
  
  df <- demographie_effectifs |>
    filter(annee == annee_selectionnee, libelle_sexe == "tout sexe",
           classe_age == "tout_age", !grepl("^Ensemble", profession_sante))
  
  if (!is.null(input$filtre_profession) && input$filtre_profession != "TOUTES") {
    df <- df |> filter(profession_sante == input$filtre_profession)
  }
  
  if (!is.null(input$filtre_region) && input$filtre_region != "99") {
    df <- df |> filter(region == input$filtre_region)
  }
  
  if (!is.null(input$filtre_departement_pro) && input$filtre_departement_pro != "999") {
    df <- df |> filter(departement == input$filtre_departement_pro)
  }
  
  densite_dep <- df |>
    group_by(departement, libelle_departement) |>
    summarise(densite = mean(as.numeric(densite), na.rm = TRUE), .groups = "drop") |>
    arrange(desc(densite)) |>
    mutate(rang = row_number())
  
  france_data <- france_depts |>
    filter(code %in% c(sprintf("%02d", 1:95), "2A", "2B")) |>
    left_join(densite_dep, by = c("code" = "departement"))
  
  if (nrow(densite_dep) == 0 || all(is.na(france_data$densite))) {
    return(leaflet(france_depts) |>
             addTiles() |>
             setView(lng = 2.5, lat = 46.6, zoom = 5.5) |>
             addPolygons(color = "grey", weight = 1, fillColor = "lightgrey", fillOpacity = 0.3))
  }
  
  france_data <- france_data |> filter(!is.na(densite))
  pal <- colorNumeric(palette = "RdYlBu", domain = france_data$densite, reverse = TRUE)
  
  map <- leaflet(france_data) |>
    addTiles() |>
    addPolygons(
      fillColor = ~ pal(densite),
      color = "white",
      weight = 1,
      fillOpacity = 0.8,
      label = lapply(1:nrow(france_data), function(i) {
        htmltools::HTML(
          sprintf(
            "<b>%s</b><br>Densité : %.1f /100 000 hab.<br>Rang : %d",
            france_data$libelle_departement[i],
            france_data$densite[i],
            france_data$rang[i]
          )
        )
      }),
      highlightOptions = highlightOptions(weight = 3, color = "#333", fillOpacity = 0.9)
    )
  
  if (!is.null(input$show_legend_pro) && input$show_legend_pro) {
    map <- map |>
      addLegend(
        pal = pal,
        values = france_data$densite,
        title = "Densité médicale",
        position = "bottomright"
      )
  }
  
  map
})

# ----------- 4. GRAPHIQUES D'ANALYSE -----------

## ----- 4.1. Évolution temporelle -----
output$graph_evolution_densite_pro <- renderPlotly({
  if (is.null(demographie_effectifs))
    return(plotly_empty())
  
  df <- demographie_effectifs |>
    filter(libelle_sexe == "tout sexe", classe_age == "tout_age")
  
  if (!is.null(input$filtre_profession) && input$filtre_profession != "TOUTES") {
    df <- df |> filter(profession_sante == input$filtre_profession)
  } else {
    df <- df |> filter(!grepl("^Ensemble", profession_sante))
  }
  
  if (!is.null(input$filtre_region) && input$filtre_region != "99") {
    df <- df |> filter(region == input$filtre_region)
  }
  
  if (!is.null(input$filtre_departement_pro) && input$filtre_departement_pro != "999") {
    df <- df |> filter(departement == input$filtre_departement_pro)
  }
  
  if ((is.null(input$filtre_region) || input$filtre_region == "99") &&
      (is.null(input$filtre_departement_pro) || input$filtre_departement_pro == "999")) {
    if (any(df$libelle_region == "FRANCE" | df$libelle_departement == "FRANCE", na.rm = TRUE)) {
      df <- df |> filter(libelle_region == "FRANCE" & libelle_departement == "FRANCE")
    }
  }
  
  df_evol <- df |>
    filter(annee >= input$periode_evolution_pro[1], annee <= input$periode_evolution_pro[2]) |>
    group_by(annee) |>
    summarise(effectif_total = sum(as.numeric(effectif), na.rm = TRUE), .groups = "drop")
  
  p <- ggplot(df_evol, aes(x = annee, y = effectif_total)) +
    geom_line(color = "#667eea", size = 2) +
    geom_point(color = "#764ba2", size = 5) +
    geom_area(fill = "#667eea", alpha = 0.2) +
    labs(title = "", x = "Année", y = "Nombre de professionnels") +
    theme_minimal()
  
  ggplotly(p, tooltip = c("x", "y"))
})

## ----- 4.2. Distribution par âge -----
output$graph_pie_ages_pro <- renderPlotly({
  if (is.null(demographie_effectifs))
    return(plotly_empty())
  
  annee_selectionnee <- input$filtre_annee_pro
  if (is.null(annee_selectionnee))
    annee_selectionnee <- max(liste_annees_pro)
  
  df <- demographie_effectifs |>
    filter(annee == annee_selectionnee, libelle_sexe == "tout sexe",
           !grepl("^Ensemble", profession_sante), classe_age != "tout_age")
  
  if (!is.null(input$filtre_profession) && input$filtre_profession != "TOUTES") {
    df <- df |> filter(profession_sante == input$filtre_profession)
  }
  
  if (!is.null(input$filtre_region) && input$filtre_region != "99") {
    df <- df |> filter(region == input$filtre_region)
  }
  
  if (!is.null(input$filtre_departement_pro) && input$filtre_departement_pro != "999") {
    df <- df |> filter(departement == input$filtre_departement_pro)
  }
  
  df_ages <- df |>
    group_by(libelle_classe_age) |>
    summarise(total = sum(as.numeric(effectif), na.rm = TRUE), .groups = "drop")
  
  plot_ly(
    df_ages,
    labels = ~ libelle_classe_age,
    values = ~ total,
    type = "pie",
    textposition = "inside",
    textinfo = "label+percent",
    marker = list(colors = RColorBrewer::brewer.pal(nrow(df_ages), "Set3")),
    hole = 0.4
  )
})

## ----- 4.3. Part des 60 ans et plus -----
output$graph_part_60ans_pro <- renderPlotly({
  if (is.null(ages_moyens) ||
      !"profession_sante" %in% names(ages_moyens) ||
      !"part_des_60_ans_et_plus" %in% names(ages_moyens)) {
    return(plotly_empty())
  }
  
  df_60 <- ages_moyens |>
    filter(!is.na(profession_sante), !is.na(part_des_60_ans_et_plus)) |>
    group_by(profession_sante) |>
    summarise(part_60 = mean(as.numeric(part_des_60_ans_et_plus), na.rm = TRUE), .groups = "drop") |>
    arrange(desc(part_60)) |>
    head(15)
  
  p <- ggplot(df_60, aes(x = reorder(profession_sante, part_60), y = part_60)) +
    geom_col(fill = "#f5576c", alpha = 0.85) +
    coord_flip() +
    labs(title = "", x = "", y = "Part des 60 ans et + (%)") +
    theme_minimal()
  
  ggplotly(p) |> layout(margin = list(l = 180))
})

## ----- 4.4. Statistiques descriptives -----
output$stats_descriptives_pro <- renderPrint({
  df <- donnees_pro_filtrees()
  if (is.null(df)) {
    cat("❌ Aucune donnée disponible\n")
    return()
  }
  
  cat("╔═══════════════════════════════════════════════════════╗\n")
  cat("║      STATISTIQUES DESCRIPTIVES - PROFESSIONNELS      ║\n")
  cat("╚═══════════════════════════════════════════════════════╝\n\n")
  
  cat("📊 DONNÉES GÉNÉRALES\n")
  cat("   └─ Effectif total     :", format(sum(as.numeric(df$effectif), na.rm = TRUE), big.mark = " "), "\n")
  cat("   └─ Professions        :", length(unique(df$profession_sante)), "\n")
  cat("   └─ Départements       :", length(unique(df$departement)), "\n\n")
  
  cat("🏥 DENSITÉS\n")
  densite_moy <- mean(as.numeric(df$densite), na.rm = TRUE)
  densite_min <- min(as.numeric(df$densite), na.rm = TRUE)
  densite_max <- max(as.numeric(df$densite), na.rm = TRUE)
  cat("   └─ Densité moyenne   :", round(densite_moy, 1), "/100k hab.\n")
  cat("   └─ Densité minimale  :", round(densite_min, 1), "/100k hab.\n")
  cat("   └─ Densité maximale  :", round(densite_max, 1), "/100k hab.\n\n")
})

## ----- 4.5. Qualité des données -----
output$graph_qualite_donnees_pro <- renderPlotly({
  df <- donnees_pro_filtrees()
  if (is.null(df))
    return(plotly_empty())
  
  qualite <- data.frame(
    indicateur = c("Avec effectif", "Avec densité", "Données complètes", "Données partielles"),
    valeur = c(
      sum(!is.na(df$effectif)),
      sum(!is.na(df$densite)),
      sum(!is.na(df$effectif) & !is.na(df$densite)),
      sum(is.na(df$effectif) | is.na(df$densite))
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
    marker = list(color = c("#43e97b", "#4facfe", "#667eea", "#fa709a"))
  )
})

# ----------- 5. TABLEAU DE DONNÉES -----------

output$tableau_principal_pro <- renderDT({
  dataset <- switch(
    input$dataset_choisi_pro,
    "effectifs" = demographie_effectifs,
    "ages" = ages_moyens,
    "patientele" = patientele,
    "secteurs" = secteurs
  )
  
  if (is.null(dataset)) {
    return(datatable(data.frame(Message = "Dataset non disponible")))
  }
  
  datatable(
    dataset,
    options = list(
      responsive = TRUE,
      pageLength = input$nb_lignes_page_pro,
      scrollX = TRUE,
      language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/French.json')
    ),
    rownames = FALSE,
    filter = "top",
    class = 'cell-border stripe hover'
  )
})

# ----------- 6. TÉLÉCHARGEMENT -----------

output$telecharger_donnees_pro <- downloadHandler(
  filename = function() {
    paste0("ameli_", input$dataset_choisi_pro, "_", Sys.Date(), ".csv")
  },
  content = function(file) {
    dataset <- switch(
      input$dataset_choisi_pro,
      "effectifs" = demographie_effectifs,
      "ages" = ages_moyens,
      "patientele" = patientele,
      "secteurs" = secteurs
    )
    
    if (!is.null(dataset)) {
      write.csv(dataset, file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  }
)