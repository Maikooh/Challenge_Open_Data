# ============================================================================
# SERVER_MAJ_DEPARTEMENTS.R - Mise à jour départements selon région
# ============================================================================

# ----------- 1. MISE À JOUR DÉPARTEMENTS SELON RÉGION -----------
observeEvent(input$filtre_region, {
  if (!is.null(input$filtre_region)) {
    
    ## ----- 1.1. France entière -----
    if (input$filtre_region == "99") {
      choix_dept <- c("Tous (France)" = "999", choix_departements)
    } else {
      ## ----- 1.2. Région spécifique -----
      dept_region <- demographie_effectifs |>
        filter(region == input$filtre_region) |>
        select(departement, libelle_departement) |>
        distinct() |>
        arrange(departement) |>
        mutate(display = paste0(departement, " - ", libelle_departement))
      
      choix_dept <- c("Tous" = "999",
                      setNames(dept_region$departement, dept_region$display))
    }
    
    ## ----- 1.3. Mise à jour du selectInput -----
    updateSelectInput(session,
                      "filtre_departement_pro",
                      choices = choix_dept,
                      selected = "999")
  }
})