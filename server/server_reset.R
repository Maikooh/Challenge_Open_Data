# ============================================================================
# SERVER_RESET.R - Gestion des boutons de réinitialisation
# ============================================================================

# ----------- 1. RESET FILTRES FINESS -----------
observeEvent(input$reset_filtres_finess, {
  updateSelectInput(session, "filtre_departement_finess", selected = "TOUS")
  updateSelectInput(session, "filtre_categorie", selected = "TOUTES")
  updateSelectInput(session, "filtre_annee_finess", selected = "TOUTES")
  updateCheckboxInput(session, "filtre_coords_valides", value = TRUE)
  
  showNotification("✅ Filtres FINESS réinitialisés",
                   type = "message",
                   duration = 3)
})

# ----------- 2. RESET FILTRES PROFESSIONNELS -----------
observeEvent(input$reset_filtres_pro, {
  updateSelectInput(session, "filtre_annee_pro", selected = max(liste_annees_pro))
  updateSelectInput(session, "filtre_profession", selected = "TOUTES")
  updateSelectInput(session, "filtre_region", selected = "99")
  updateSelectInput(session, "filtre_departement_pro", selected = "999")
  updateSelectInput(session, "filtre_classe_age", selected = "tout_age")
  
  showNotification("✅ Filtres Professionnels réinitialisés",
                   type = "message",
                   duration = 3)
})