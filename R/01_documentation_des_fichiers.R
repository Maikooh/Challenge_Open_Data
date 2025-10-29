# ============================================================================
# Script d'exploration des donnees Sante France
# Generation d'un rapport HTML
# Dashboard Environnement Sante France
# VERSION CORRIGEE - Utilise des chemins absolus
# ============================================================================

# Afficher le working directory actuel
cat("\n Working Directory actuel:", getwd(), "\n\n")

# Chargement des packages necessaires
cat(" Installation/chargement des packages...\n")
packages_requis <- c("tidyverse", "knitr", "rmarkdown", "DT")

for (pkg in packages_requis) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE, repos = "https://cran.rstudio.com/")
    library(pkg, character.only = TRUE)
  }
}
cat(" Packages charges\n\n")

# ============================================================================
# Fonctions utilitaires
# ============================================================================

# Fonction pour lire un CSV avec detection automatique du separateur
lire_csv_auto <- function(chemin) {
  # Essayer avec virgule
  tryCatch({
    df <- read.csv(chemin, nrows = 10, encoding = "UTF-8", stringsAsFactors = FALSE)
    if (ncol(df) > 1) {
      return(read.csv(chemin, encoding = "UTF-8", stringsAsFactors = FALSE))
    }
  }, error = function(e) {})
  
  # Essayer avec point-virgule
  tryCatch({
    df <- read.csv2(chemin, nrows = 10, encoding = "UTF-8", stringsAsFactors = FALSE)
    if (ncol(df) > 1) {
      return(read.csv2(chemin, encoding = "UTF-8", stringsAsFactors = FALSE))
    }
  }, error = function(e) {})
  
  # Essayer avec tabulation
  tryCatch({
    return(read.delim(chemin, encoding = "UTF-8", stringsAsFactors = FALSE))
  }, error = function(e) {})
  
  stop("Impossible de determiner le separateur du fichier CSV")
}

# Fonction pour obtenir les informations d'un fichier
info_fichier <- function(chemin_fichier) {
  
  info <- list(
    nom = basename(chemin_fichier),
    chemin = chemin_fichier,
    taille = file.size(chemin_fichier),
    taille_format = format(file.size(chemin_fichier) / 1024^2, digits = 2, nsmall = 2),
    date_modif = as.character(file.mtime(chemin_fichier)),
    erreur = NULL
  )
  
  tryCatch({
    donnees <- lire_csv_auto(chemin_fichier)
    
    info$nrows <- nrow(donnees)
    info$ncols <- ncol(donnees)
    info$colonnes <- names(donnees)
    info$types <- sapply(donnees, function(x) class(x)[1])
    info$na_count <- sapply(donnees, function(x) sum(is.na(x)))
    info$na_percent <- round(info$na_count / nrow(donnees) * 100, 2)
    info$apercu <- head(donnees, 10)
    
    # Statistiques pour colonnes numeriques
    cols_num <- names(donnees)[sapply(donnees, is.numeric)]
    if (length(cols_num) > 0) {
      info$stats_num <- lapply(cols_num, function(col) {
        list(
          colonne = col,
          min = min(donnees[[col]], na.rm = TRUE),
          max = max(donnees[[col]], na.rm = TRUE),
          moyenne = mean(donnees[[col]], na.rm = TRUE),
          mediane = median(donnees[[col]], na.rm = TRUE),
          na_count = sum(is.na(donnees[[col]]))
        )
      })
    }
    
    # Exemples de valeurs uniques pour colonnes categorielles
    cols_cat <- names(donnees)[sapply(donnees, function(x) is.character(x) | is.factor(x))]
    if (length(cols_cat) > 0) {
      info$exemples_cat <- lapply(cols_cat, function(col) {
        valeurs_uniques <- unique(na.omit(donnees[[col]]))
        list(
          colonne = col,
          n_uniques = length(valeurs_uniques),
          exemples = paste(head(valeurs_uniques, 5), collapse = ", ")
        )
      })
    }
    
  }, error = function(e) {
    info$erreur <<- e$message
  })
  
  return(info)
}

# ============================================================================
# Fonction principale d'exploration
# ============================================================================

explorer_dossiers <- function(dossiers, output_html) {
  
  # Collecter les informations sur tous les fichiers
  toutes_infos <- list()
  
  for (dossier in dossiers) {
    # Creer le dossier s'il n'existe pas
    if (!dir.exists(dossier)) {
      cat(paste("  Creation du dossier:", dossier, "\n"))
      dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
      
      # Verifier si la creation a reussi
      if (!dir.exists(dossier)) {
        stop(paste(" Impossible de creer le dossier:", dossier, "\nVerifiez les permissions."))
      }
    }
    
    fichiers_csv <- list.files(dossier, pattern = "\\.csv$", full.names = TRUE, ignore.case = TRUE)
    
    if (length(fichiers_csv) > 0) {
      for (fichier in fichiers_csv) {
        cat("    Traitement de:", basename(fichier), "\n")
        info <- info_fichier(fichier)
        info$source_dossier <- basename(dossier)
        toutes_infos[[length(toutes_infos) + 1]] <- info
      }
    }
  }
  
  if (length(toutes_infos) == 0) {
    cat("\n  ATTENTION: Aucun fichier CSV trouve!\n")
    cat("\n Veuillez placer vos fichiers CSV dans:\n")
    for (d in dossiers) {
      cat("   - ", d, "\n")
    }
    stop("Aucun fichier a traiter")
  }
  
  # Creer le dossier de sortie si necessaire
  output_dir <- dirname(output_html)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  # Generer le rapport HTML
  generer_rapport_html(toutes_infos, output_html)
  
  return(toutes_infos)
}

# ============================================================================
# Generation du rapport HTML
# ============================================================================

generer_rapport_html <- function(infos, output_file) {
  
  cat("\n Generation du rapport HTML...\n")
  
  # Sauvegarder les donnees dans un fichier temporaire
  temp_data <- tempfile(fileext = ".rds")
  saveRDS(infos, temp_data)
  
  # Creer le contenu RMarkdown avec echappement correct
  rmd_lines <- c(
    '---',
    'title: "Rapport Exploration des Donnees - Sante France"',
    'author: "Dashboard Environnement Sante"',
    'date: "`r format(Sys.time(), \'%d %B %Y a %H:%M\')`"',
    'output:',
    '  html_document:',
    '    theme: cosmo',
    '    toc: true',
    '    toc_float: true',
    '    toc_depth: 3',
    '    code_folding: hide',
    '    number_sections: true',
    '---',
    '',
    '```{r setup, include=FALSE}',
    'knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)',
    'library(knitr)',
    'library(DT)',
    paste0('infos_list <- readRDS("', gsub("\\\\", "/", temp_data), '")'),
    '```',
    '',
    '<style>',
    'body { font-family: "Segoe UI", Arial, sans-serif; }',
    '.fichier-section {',
    '  background-color: #f8f9fa;',
    '  border-left: 4px solid #007bff;',
    '  padding: 15px;',
    '  margin: 20px 0;',
    '  border-radius: 5px;',
    '}',
    '.info-box {',
    '  background-color: #e7f3ff;',
    '  padding: 10px;',
    '  border-radius: 5px;',
    '  margin: 10px 0;',
    '}',
    '.warning-box {',
    '  background-color: #fff3cd;',
    '  border-left: 4px solid #ffc107;',
    '  padding: 10px;',
    '  margin: 10px 0;',
    '}',
    '.success-box {',
    '  background-color: #d4edda;',
    '  border-left: 4px solid #28a745;',
    '  padding: 10px;',
    '  margin: 10px 0;',
    '}',
    'h1 { color: #2c3e50; }',
    'h2 { color: #34495e; margin-top: 30px; }',
    'h3 { color: #5a6c7d; }',
    '</style>',
    '',
    '# Resume Executif',
    '',
    '```{r summary}',
    'n_fichiers <- length(infos_list)',
    'n_odisse <- sum(sapply(infos_list, function(x) x$source_dossier == "odisse"))',
    'n_ameli <- sum(sapply(infos_list, function(x) x$source_dossier == "ameli"))',
    'n_erreurs <- sum(sapply(infos_list, function(x) !is.null(x$erreur)))',
    'taille_totale <- sum(sapply(infos_list, function(x) x$taille)) / 1024^2',
    '',
    'cat(paste0(',
    '  "<div class=\\"success-box\\">",',
    '  "<h3>Statistiques Globales</h3>",',
    '  "<ul>",',
    '  "<li><strong>Nombre total de fichiers CSV :</strong> ", n_fichiers, "</li>",',
    '  "<li><strong>Fichiers ODISSE :</strong> ", n_odisse, "</li>",',
    '  "<li><strong>Fichiers AMELI :</strong> ", n_ameli, "</li>",',
    '  "<li><strong>Taille totale des donnees :</strong> ", round(taille_totale, 2), " Mo</li>",',
    '  "<li><strong>Fichiers avec erreurs :</strong> ", n_erreurs, "</li>",',
    '  "</ul>",',
    '  "</div>"',
    '))',
    '```',
    '',
    '# Vue Ensemble des Fichiers',
    '',
    '```{r overview_table}',
    'df_overview <- data.frame(',
    '  Fichier = sapply(infos_list, function(x) x$nom),',
    '  Source = toupper(sapply(infos_list, function(x) x$source_dossier)),',
    '  Lignes = sapply(infos_list, function(x) ifelse(is.null(x$nrows), "Erreur", format(x$nrows, big.mark = " "))),',
    '  Colonnes = sapply(infos_list, function(x) ifelse(is.null(x$ncols), "Erreur", x$ncols)),',
    '  Taille_Mo = sapply(infos_list, function(x) x$taille_format),',
    '  Derniere_Modif = sapply(infos_list, function(x) format(as.POSIXct(x$date_modif), "%Y-%m-%d")),',
    '  stringsAsFactors = FALSE',
    ')',
    '',
    'DT::datatable(df_overview,',
    '              options = list(pageLength = 25, dom = "Bfrtip"),',
    '              caption = "Tableau recapitulatif de tous les fichiers")',
    '```',
    ''
  )
  
  # Ajouter une section pour chaque fichier
  for (i in seq_along(infos)) {
    info <- infos[[i]]
    
    rmd_lines <- c(rmd_lines,
      '',
      paste0('# Fichier ', i, ' : ', info$nom),
      '',
      '<div class="fichier-section">',
      '',
      '## Informations Generales',
      '',
      '<div class="info-box">',
      paste0('- **Nom du fichier :** `', info$nom, '`'),
      paste0('- **Source :** ', toupper(info$source_dossier)),
      paste0('- **Chemin :** `', info$chemin, '`'),
      paste0('- **Taille :** ', info$taille_format, ' Mo'),
      paste0('- **Derniere modification :** ', info$date_modif),
      paste0('- **Nombre de lignes :** ', ifelse(is.null(info$nrows), "Erreur de lecture", format(info$nrows, big.mark = " "))),
      paste0('- **Nombre de colonnes :** ', ifelse(is.null(info$ncols), "Erreur de lecture", info$ncols)),
      '</div>',
      ''
    )
    
    if (!is.null(info$erreur)) {
      rmd_lines <- c(rmd_lines,
        '<div class="warning-box">',
        paste0('**Erreur lors de la lecture du fichier :** ', info$erreur),
        '</div>',
        '',
        '</div>',
        ''
      )
      next
    }
    
    # Structure des colonnes
    rmd_lines <- c(rmd_lines,
      '## Structure des Colonnes',
      '',
      paste0('```{r fichier_', i, '_structure}'),
      paste0('df_structure <- data.frame('),
      paste0('  Colonne = infos_list[[', i, ']]$colonnes,'),
      paste0('  Type = infos_list[[', i, ']]$types,'),
      paste0('  NA_count = infos_list[[', i, ']]$na_count,'),
      paste0('  NA_percent = paste0(infos_list[[', i, ']]$na_percent, "%"),'),
      paste0('  stringsAsFactors = FALSE'),
      paste0(')'),
      '',
      'kable(df_structure, caption = "Structure des donnees", align = c("l", "l", "r", "r"))',
      '```',
      ''
    )
    
    # Statistiques numeriques
    if (!is.null(info$stats_num) && length(info$stats_num) > 0) {
      rmd_lines <- c(rmd_lines,
        '## Statistiques Descriptives (Colonnes Numeriques)',
        '',
        paste0('```{r fichier_', i, '_stats}'),
        paste0('df_stats <- do.call(rbind, lapply(infos_list[[', i, ']]$stats_num, function(s) {'),
        '  data.frame(',
        '    Colonne = s$colonne,',
        '    Min = round(s$min, 2),',
        '    Max = round(s$max, 2),',
        '    Moyenne = round(s$moyenne, 2),',
        '    Mediane = round(s$mediane, 2),',
        '    NA = s$na_count,',
        '    stringsAsFactors = FALSE',
        '  )',
        '}))','',
        'kable(df_stats, caption = "Statistiques des colonnes numeriques", align = c("l", rep("r", 5)))',
        '```',
        ''
      )
    }
    
    # Colonnes categorielles
    if (!is.null(info$exemples_cat) && length(info$exemples_cat) > 0) {
      rmd_lines <- c(rmd_lines,
        '## Colonnes Categorielles',
        '',
        paste0('```{r fichier_', i, '_cat}'),
        paste0('df_cat <- do.call(rbind, lapply(infos_list[[', i, ']]$exemples_cat, function(c) {'),
        '  data.frame(',
        '    Colonne = c$colonne,',
        '    Valeurs_Uniques = c$n_uniques,',
        '    Exemples = c$exemples,',
        '    stringsAsFactors = FALSE',
        '  )',
        '}))','',
        'kable(df_cat, caption = "Apercu des colonnes categorielles")',
        '```',
        ''
      )
    }
    
    # Apercu des donnees
    rmd_lines <- c(rmd_lines,
      '## Apercu des Donnees (10 premieres lignes)',
      '',
      paste0('```{r fichier_', i, '_apercu}'),
      paste0('DT::datatable(infos_list[[', i, ']]$apercu,'),
      '              options = list(pageLength = 10, scrollX = TRUE, dom = "t"),',
      '              caption = "Apercu des donnees")',
      '```',
      '',
      '</div>',
      ''
    )
  }
  
  # Ajouter la conclusion
  rmd_lines <- c(rmd_lines,
    '# Conclusion',
    '',
    'Ce rapport presente une vue ensemble complete de tous les fichiers CSV disponibles dans les dossiers ODISSE et AMELI.',
    '',
    '**Prochaines etapes suggerees :**',
    '',
    '1. Verifier la qualite des donnees (valeurs manquantes, outliers)',
    '2. Harmoniser les structures de donnees si necessaire',
    '3. Definir les indicateurs cles pour le dashboard',
    '4. Creer les visualisations appropriees',
    '',
    '---',
    '',
    '*Rapport genere automatiquement le `r format(Sys.time(), "%d %B %Y a %H:%M")`*'
  )
  
  # Sauvegarder le fichier RMarkdown temporaire
  temp_rmd <- tempfile(fileext = ".Rmd")
  writeLines(rmd_lines, temp_rmd, useBytes = TRUE)
  
  # Generer le HTML
  tryCatch({
    rmarkdown::render(temp_rmd, output_file = output_file, quiet = TRUE)
    cat(" Rapport HTML genere avec succes!\n")
    cat(" Fichier:", output_file, "\n")
  }, error = function(e) {
    cat(" Erreur lors de la generation du rapport HTML:\n")
    cat("   ", e$message, "\n")
    stop("La generation du rapport a echoue")
  })
  
  # Nettoyer les fichiers temporaires
  unlink(c(temp_rmd, temp_data))
}

# ============================================================================
# EXECUTION
# ============================================================================

cat("
╔════════════════════════════════════════════════════════════════════════════╗
║     EXPLORATION DES DONNEES SANTE FRANCE - ODISSE & AMELI                  ║
╚════════════════════════════════════════════════════════════════════════════╝
\n")

# Definir les chemins absolus
chemin_base <- "D:/MASTER MECEN/MASTER 1/opendata"
dossier_odisse <- file.path(chemin_base, "data/processed/odisse")
dossier_ameli <- file.path(chemin_base, "data/processed/ameli")
fichier_sortie <- file.path(chemin_base, "data/processed/rapport_exploration_donnees.html")

# Verifier l'arborescence
cat(" Verification de l'arborescence des dossiers...\n")
cat("   Chemin de base:", chemin_base, "\n\n")

# Creer les sous-dossiers necessaires s'ils n'existent pas
cat(" Creation des sous-dossiers si necessaire...\n")
dir.create(file.path(chemin_base, "data/processed"), recursive = TRUE, showWarnings = FALSE)
dir.create(dossier_odisse, recursive = TRUE, showWarnings = FALSE)
dir.create(dossier_ameli, recursive = TRUE, showWarnings = FALSE)

# Verifier s'il y a des fichiers CSV
fichiers_odisse <- list.files(dossier_odisse, pattern = "\\.csv$", ignore.case = TRUE)
fichiers_ameli <- list.files(dossier_ameli, pattern = "\\.csv$", ignore.case = TRUE)

cat(sprintf("\n Fichiers trouves:\n"))
cat(sprintf("   - ODISSE: %d fichier(s)\n", length(fichiers_odisse)))
cat(sprintf("   - AMELI: %d fichier(s)\n", length(fichiers_ameli)))

if (length(fichiers_odisse) > 0) {
  cat("\n   Fichiers ODISSE:\n")
  for (f in fichiers_odisse) cat("      ", f, "\n")
}

if (length(fichiers_ameli) > 0) {
  cat("\n   Fichiers AMELI:\n")
  for (f in fichiers_ameli) cat("      ", f, "\n")
}

if (length(fichiers_odisse) == 0 && length(fichiers_ameli) == 0) {
  cat("\n  ATTENTION: Aucun fichier CSV trouve!\n")
  cat("\n Veuillez placer vos fichiers CSV dans:\n")
  cat("   - ", dossier_odisse, "\n")
  cat("   - ", dossier_ameli, "\n\n")
  stop("Aucun fichier a traiter")
}

cat("\n Demarrage de l'exploration...\n\n")

# Explorer les dossiers et generer le rapport
infos <- explorer_dossiers(
  dossiers = c(dossier_odisse, dossier_ameli),
  output_html = fichier_sortie
)

cat(sprintf("
╔════════════════════════════════════════════════════════════════════════════╗
║                     EXPLORATION TERMINEE AVEC SUCCES                       ║
║                                                                            ║
║   Rapport HTML : %s
╚════════════════════════════════════════════════════════════════════════════╝
\n", fichier_sortie))
