# ============================================================================
# SERVER_DONNEES_FILTREES.R - Gestion des données filtrées
# ============================================================================

# ----------- 1. DONNÉES FINESS FILTRÉES -----------
donnees_finess_filtrees <- reactive({
  if (is.null(finess_data))
    return(NULL)
  
  df <- finess_data
  
  ## ----- 1.1. Filtre Département -----
  if (!is.null(input$filtre_departement_finess) &&
      input$filtre_departement_finess != "TOUS") {
    df <- df |> filter(departement == input$filtre_departement_finess)
  }
  
  ## ----- 1.2. Filtre Catégorie -----
  if (!is.null(input$filtre_categorie) &&
      input$filtre_categorie != "TOUTES") {
    df <- df |> filter(libcategetab == input$filtre_categorie)
  }
  
  ## ----- 1.3. Filtre Année -----
  if (!is.null(input$filtre_annee_finess) &&
      input$filtre_annee_finess != "TOUTES") {
    df <- df |> filter(annee == as.numeric(input$filtre_annee_finess))
  }
  
  ## ----- 1.4. Filtre Coordonnées valides -----
  if (!is.null(input$filtre_coords_valides) &&
      input$filtre_coords_valides) {
    df <- df |> filter(!is.na(longitude), !is.na(latitude))
  }
  
  df
})

# ----------- 2. DONNÉES PROFESSIONNELS FILTRÉES -----------
donnees_pro_filtrees <- reactive({
  if (is.null(demographie_effectifs))
    return(NULL)
  
  ## ----- 2.1. Sélection de l'année -----
  annee_selectionnee <- input$filtre_annee_pro
  if (is.null(annee_selectionnee)) {
    annee_selectionnee <- max(liste_annees_pro)
  }
  
  df <- demographie_effectifs |>
    filter(annee == annee_selectionnee, libelle_sexe == "tout sexe")
  
  ## ----- 2.2. Filtre Profession -----
  if (!is.null(input$filtre_profession) &&
      input$filtre_profession != "TOUTES") {
    df <- df |> filter(profession_sante == input$filtre_profession)
  } else {
    df <- df |> filter(!grepl("^Ensemble", profession_sante))
  }
  
  ## ----- 2.3. Filtre Région -----
  if (!is.null(input$filtre_region) &&
      input$filtre_region != "99") {
    df <- df |> filter(region == input$filtre_region)
  }
  
  ## ----- 2.4. Filtre Département -----
  if (!is.null(input$filtre_departement_pro) &&
      input$filtre_departement_pro != "999") {
    df <- df |> filter(departement == input$filtre_departement_pro)
  }
  
  ## ----- 2.5. Logique France entière -----
  if ((is.null(input$filtre_region) ||
       input$filtre_region == "99") &&
      (is.null(input$filtre_departement_pro) ||
       input$filtre_departement_pro == "999")) {
    if (any(df$libelle_region == "FRANCE" |
            df$libelle_departement == "FRANCE",
            na.rm = TRUE)) {
      df <- df |> filter(libelle_region == "FRANCE" &
                           libelle_departement == "FRANCE")
    }
  }
  
  ## ----- 2.6. Filtre Classe d'âge -----
  if (!is.null(input$filtre_classe_age) &&
      input$filtre_classe_age != "tout_age") {
    df <- df |> filter(libelle_classe_age == input$filtre_classe_age)
  } else {
    df <- df |> filter(classe_age == "tout_age")
  }
  
  df
})