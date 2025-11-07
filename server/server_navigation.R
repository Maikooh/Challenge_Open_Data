# ============================================================================
# SERVER_NAVIGATION.R - Gestion de la navigation entre sections
# ============================================================================

# ----------- 1. NAVIGATION VERS FINESS -----------
observeEvent(input$goto_finess, {
  updateTabItems(session, "sidebar_menu", "finess_overview")
})

# ----------- 2. NAVIGATION VERS PROFESSIONNELS -----------
observeEvent(input$goto_pro, {
  updateTabItems(session, "sidebar_menu", "pro_overview")
})