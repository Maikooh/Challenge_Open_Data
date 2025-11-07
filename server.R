# ============================================================================
# SERVER.R - Logique serveur de l'application Shiny
# ============================================================================
# Ce fichier contient toute la logique serveur de l'application
# ============================================================================

server <- function(input, output, session) {
  
  # ----------- 1. NAVIGATION -----------
  source("server/server_navigation.R", local = TRUE)
  
  # ----------- 2. DONNÉES FILTRÉES -----------
  source("server/server_donnees_filtrees.R", local = TRUE)
  
  # ----------- 3. BOUTONS RESET -----------
  source("server/server_reset.R", local = TRUE)
  
  # ----------- 4. MISE À JOUR DÉPARTEMENTS SELON RÉGION -----------
  source("server/server_maj_departements.R", local = TRUE)
  
  # ----------- 5. SERVEUR FINESS -----------
  source("server/server_finess.R", local = TRUE)
  
  # ----------- 6. SERVEUR PROFESSIONNELS -----------
  source("server/server_professionnels.R", local = TRUE)
}