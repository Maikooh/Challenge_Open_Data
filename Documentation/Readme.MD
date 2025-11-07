# Santé & Territoires - Dashboard Shiny

Dashboard interactif pour l'exploration des données de santé en France (établissements FINESS et professionnels de santé).

## 📁 Structure du projet

```
Challenge_Open_Data/
│
├── global.R                    # Chargement des bibliothèques et des données
├── ui.R                        # Interface utilisateur principale
├── server.R                    # Serveur principal
│
├── ui/                         # Modules d'interface
│   ├── ui_accueil.R
│   ├── ui_finess_overview.R
│   ├── ui_finess_carte.R
│   ├── ui_finess_analyses.R
│   ├── ui_finess_donnees.R
│   ├── ui_pro_overview.R
│   ├── ui_pro_carte.R
│   ├── ui_pro_analyses.R
│   ├── ui_pro_donnees.R
│   └── ui_apropos.R
│
├── server/                     # Modules serveur
│   ├── server_navigation.R    # Gestion de la navigation
│   ├── server_donnees_filtrees.R  # Données filtrées
│   ├── server_reset.R          # Réinitialisation des filtres
│   ├── server_maj_departements.R  # Mise à jour des départements
│   ├── server_finess.R         # Logique FINESS
│   └── server_professionnels.R # Logique professionnels
│
├── www/                        # Ressources web
│   └── custom.css              # Styles personnalisés
│
└── data/                       # Données (à créer)
    ├── finess_geolocalise.csv
    ├── demographie-effectifs-et-les-densites.rds
    ├── demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json
    ├── patientele.json
    └── demographie-secteurs-conventionnels.json
```

## 🚀 Installation

### 1. Prérequis

```R
install.packages(c(
  "shiny",
  "shinydashboard",
  "tidyverse",
  "dplyr",
  "DT",
  "leaflet",
  "sf",
  "ggplot2",
  "plotly",
  "jsonlite"
))
```

### 2. Structure des données

Créez un dossier `data/` à la racine du projet et placez-y vos fichiers de données :

- `finess_geolocalise.csv` : Données des établissements FINESS
- `demographie-effectifs-et-les-densites.rds` : Effectifs et densités des professionnels
- `demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json` : Âges moyens
- `patientele.json` : Données de patientèle
- `demographie-secteurs-conventionnels.json` : Secteurs conventionnels

### 3. Lancement

```R
# Depuis RStudio
shiny::runApp()

# Ou depuis R
library(shiny)
runApp("chemin/vers/le/projet")
```

## 📊 Fonctionnalités

### Établissements FINESS
- **Vue d'ensemble** : KPIs et statistiques globales
- **Carte interactive** : Géolocalisation des établissements
- **Analyses** : Évolutions temporelles, répartitions géographiques
- **Base de données** : Export et consultation des données brutes

### Professionnels de santé
- **Vue d'ensemble** : Effectifs, densités, professions
- **Carte de densité** : Densité médicale par département
- **Analyses** : Évolutions, analyses démographiques
- **Base de données** : Consultation de 4 datasets différents

## 🎨 Structure du code

### Nomenclature des commentaires

Le projet utilise une structure de commentaires hiérarchique :

```R
# ----------- 1. Section principale -----------

## ----- 1.1. Sous-section -----

### --- 1.1.1. Sous-sous-section ---
```

### Modules UI

Chaque page de l'interface est dans un fichier séparé :
- Facilite la maintenance
- Améliore la lisibilité
- Permet le développement parallèle

### Modules Serveur

La logique serveur est divisée par fonctionnalité :
- **Navigation** : Gestion des transitions entre pages
- **Données filtrées** : Application des filtres
- **Reset** : Réinitialisation des filtres
- **FINESS** : Toute la logique des établissements
- **Professionnels** : Toute la logique des professionnels de santé

## 🎯 Sources de données

- **FINESS** : [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/finess-extraction-du-fichier-des-etablissements/)
- **Professionnels** : [data.ameli.fr](https://data.ameli.fr/)
- **Géolocalisation** : [France GeoJSON](https://github.com/gregoiredavid/france-geojson)

## 👥 Auteurs

- **Fadli Aaron** - [LinkedIn](https://www.linkedin.com/in/aaron-fadli/) | [GitHub](https://github.com/Maikooh)
- **Kurnaz Kubra** - [LinkedIn](https://www.linkedin.com/in/kubra-kurnaz-56ba35387/) | [GitHub](https://github.com/Kubra2918)
- **Moreau Matteo** - [GitHub](https://github.com/MatteoHmmm)

## 📄 Licence

CC-by-sa - Master MECEN 2025-2026

Projet réalisé dans le cadre de l'[Open Data University](https://latitudes.notion.site/)

## 🛠️ Développement

### Ajouter une nouvelle page

1. Créer un fichier `ui/ui_nom_page.R`
2. Ajouter le source dans `ui.R`
3. Créer la logique dans `server/server_nom_page.R`
4. Ajouter le source dans `server.R`

### Modifier le CSS

Tous les styles sont dans `www/custom.css`, organisés par sections numérotées.

### Ajouter des données

1. Placer les fichiers dans le dossier `data/`
2. Ajouter le chargement dans `global.R`
3. Créer les filtres si nécessaire

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter les auteurs par email