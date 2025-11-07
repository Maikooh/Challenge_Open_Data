# 🔄 Guide de migration vers la nouvelle structure

Ce document explique comment migrer depuis votre ancien fichier unique vers la nouvelle structure modulaire.

## 📋 Checklist de migration

### ✅ Étape 1 : Sauvegarde
- [ ] Faire une copie de votre fichier R original
- [ ] Commiter vos changements actuels sur Git

### ✅ Étape 2 : Structure des dossiers

Créer la structure suivante :

```bash
Challenge_Open_Data/
├── ui/
├── server/
├── www/
└── data/
```

Commandes :
```bash
mkdir ui server www data
```

### ✅ Étape 3 : Déplacement des fichiers

1. **Copier les nouveaux fichiers** :
   ```
   global.R          → racine/
   ui.R              → racine/
   server.R          → racine/
   
   ui/*.R            → ui/
   server/*.R        → server/
   
   custom.css        → www/
   ```

2. **Déplacer vos données** :
   ```
   Vos fichiers .csv, .rds, .json  → data/
   ```

### ✅ Étape 4 : Vérification des chemins

Dans `global.R`, vérifier que les chemins de chargement pointent vers `data/` :

```R
# Exemple pour FINESS
finess_data <- read.csv(
  file.path(chemin_base, "data/finess_geolocalise.csv"),
  # ...
)
```

### ✅ Étape 5 : Test de l'application

```R
# Depuis RStudio
shiny::runApp()
```

Vérifier que :
- [ ] Toutes les pages se chargent
- [ ] Les données s'affichent correctement
- [ ] Les filtres fonctionnent
- [ ] Les graphiques s'affichent
- [ ] Les cartes fonctionnent
- [ ] Les téléchargements CSV fonctionnent

---

## 🐛 Résolution des problèmes courants

### Problème : "Fichier non trouvé"

**Cause** : Chemin incorrect vers les données

**Solution** :
```R
# Dans global.R, vérifier la variable chemin_base
print(chemin_base)
print(getwd())

# Vérifier l'existence des fichiers
list.files("data/")
```

### Problème : "Fonction non trouvée"

**Cause** : Bibliothèque non chargée

**Solution** :
```R
# Vérifier dans global.R que toutes les bibliothèques sont chargées
library(shiny)
library(shinydashboard)
# etc...
```

### Problème : CSS ne s'applique pas

**Cause** : Fichier CSS non chargé ou mauvais chemin

**Solution** :
```R
# Dans ui.R, vérifier :
tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"))

# Vérifier que custom.css est bien dans www/
list.files("www/")
```

### Problème : Erreur au démarrage

**Cause** : Erreur de syntaxe dans un module

**Solution** :
```R
# Tester chaque module individuellement
source("ui/ui_accueil.R")
source("server/server_finess.R")
# etc...
```

---

## 🎯 Différences principales

### Avant (fichier unique)
```R
# Tout dans app.R
library(shiny)
# ... 3500 lignes de code ...
shinyApp(ui, server)
```

### Après (structure modulaire)
```R
# global.R - Configuration
# ui.R - Structure UI
# server.R - Orchestration serveur
# ui/*.R - Modules UI
# server/*.R - Modules serveur
# www/custom.css - Styles
```

### Avantages de la nouvelle structure

1. **Maintenance** : Plus facile de trouver et corriger du code
2. **Collaboration** : Plusieurs personnes peuvent travailler en parallèle
3. **Lisibilité** : Code mieux organisé et commenté
4. **Performance** : Chargement plus rapide en production
5. **Évolution** : Ajout de nouvelles fonctionnalités simplifié

---

## 📦 Déploiement

### Déploiement local

```R
# Depuis la racine du projet
shiny::runApp(port = 3838)
```

### Déploiement sur shinyapps.io

```R
library(rsconnect)

# Première fois : configurer le compte
rsconnect::setAccountInfo(
  name = "votre-nom",
  token = "votre-token",
  secret = "votre-secret"
)

# Déployer l'application
rsconnect::deployApp(
  appDir = ".",
  appName = "sante-territoires"
)
```

### Déploiement sur Shiny Server

1. Copier tout le projet dans `/srv/shiny-server/sante-territoires/`
2. S'assurer que le dossier `data/` est accessible
3. Vérifier les permissions :
   ```bash
   sudo chown -R shiny:shiny /srv/shiny-server/sante-territoires
   ```
4. Redémarrer le serveur :
   ```bash
   sudo systemctl restart shiny-server
   ```

---

## 🔧 Personnalisation

### Ajouter une nouvelle page

1. **Créer le module UI** :
   ```R
   # ui/ui_nouvelle_page.R
   tabItem(
     tabName = "nouvelle_page",
     fluidRow(
       # Votre contenu
     )
   )
   ```

2. **Ajouter dans ui.R** :
   ```R
   source("ui/ui_nouvelle_page.R", local = TRUE)$value
   ```

3. **Créer la logique serveur** :
   ```R
   # server/server_nouvelle_page.R
   output$mon_output <- renderPlot({
     # Votre logique
   })
   ```

4. **Ajouter dans server.R** :
   ```R
   source("server/server_nouvelle_page.R", local = TRUE)
   ```

5. **Ajouter dans le menu** (ui.R, sidebar) :
   ```R
   menuItem("Nouvelle page", tabName = "nouvelle_page", icon = icon("star"))
   ```

### Modifier les couleurs

Éditer `www/custom.css` :

```css
/* Changer les couleurs du gradient principal */
.main-header .logo {
  background: linear-gradient(135deg, #VOTRE_COULEUR1 0%, #VOTRE_COULEUR2 100%) !important;
}
```

### Ajouter une nouvelle bibliothèque

Dans `global.R` :
```R
# Section 1
library(nouvelle_bibliotheque)
```

---

## 📚 Ressources

### Documentation Shiny
- [Shiny Documentation](https://shiny.rstudio.com/)
- [shinydashboard](https://rstudio.github.io/shinydashboard/)

### Tutoriels
- [Shiny Modules](https://shiny.rstudio.com/articles/modules.html)
- [Leaflet for R](https://rstudio.github.io/leaflet/)
- [Plotly R](https://plotly.com/r/)

### Communauté
- [RStudio Community](https://community.rstudio.com/)
- [Stack Overflow - Shiny](https://stackoverflow.com/questions/tagged/shiny)

---

## ✅ Liste de vérification finale

Avant de déployer en production :

- [ ] Tous les tests passent
- [ ] Les données sont à jour
- [ ] Le fichier README.md est complet
- [ ] Le .gitignore est configuré
- [ ] Les secrets sont sécurisés (pas de tokens dans le code)
- [ ] Les performances sont acceptables (temps de chargement)
- [ ] L'application est responsive (fonctionne sur mobile)
- [ ] Les erreurs sont gérées gracieusement
- [ ] La documentation est à jour

---

## 🎉 Félicitations !

Votre application est maintenant restructurée et prête pour la production !

Pour toute question, n'hésitez pas à :
- Consulter la documentation (README.md, STRUCTURE.md)
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement

**Bonne chance avec votre Dashboard Santé & Territoires ! 🏥📊**