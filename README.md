# Santé & Territoires - Dashboard Shiny

> 📝 *Ce README a été généré avec l'assistance de l'IA*  
> 🇬🇧 [English version below](#english-version) | 🇫🇷 Version française

Dashboard interactif pour l'exploration des données de santé en France (établissements FINESS et professionnels de santé).

## 📁 Structure du projet

```
Challenge_Open_Data/
│
├── global.R                    # Chargement des bibliothèques et des données
├── ui.R                        # Interface utilisateur principale
├── server.R                    # Serveur principal
├── finess.R                    # Script de génération des données FINESS
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
    ├── finess_geolocalise.csv  # Généré par finess.R
    ├── demographie-effectifs-et-les-densites.rds
    ├── demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json
    ├── patientele.json
    └── demographie-secteurs-conventionnels.json
```

## 🚀 Installation

### 1. Prérequis

Téléchargez le projet au format `.zip` depuis le dépôt GitHub :  
➡️ [https://github.com/Maikooh/Challenge_Open_Data](https://github.com/Maikooh/Challenge_Open_Data)

Décompressez le fichier `.zip`


Si vous n'avez pas les packages, à faire dans la console R : 

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

#### ⚠️ Important - Préparation des données

**Fichier FINESS** : Le fichier `finess_geolocalise.csv` n'est pas fourni directement. Il doit être généré en exécutant le script `finess.R` situé à la racine du projet. Une fois l'exécution terminée et le fichier créé dans le dossier `data/`, vous pouvez supprimer le script `finess.R`.

**Fichier RDS** : Le fichier `.rds` est déjà inclus dans le dépôt. Il a été préalablement généré à partir du fichier JSON correspondant pour optimiser les temps de chargement.

**Autres fichiers** : Les fichiers JSON suivants doivent être téléchargés depuis leurs sources respectives et placer dans le dossier data :

| Fichiers | Description | Source |
|------|--------------|---------|
| `finess_geolocalise.csv` | Données des établissements FINESS | Généré par `finess.R` |
| `demographie-effectifs-et-les-densites.rds` | Effectifs et densités des professionnels | Déjà inclus (généré depuis JSON) |
| `demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json` | Âges moyens | [data.ameli.fr – Demography: Age and Gender Breakdown](https://data.ameli.fr/explore/dataset/demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans/export/) |
| `patientele.json` | Données de patientèle | [data.ameli.fr – Patientele](https://data.ameli.fr/explore/dataset/patientele/export/?disjunctive.region&disjunctive.departement) |
| `demographie-secteurs-conventionnels.json` | Secteurs conventionnels | [data.ameli.fr – Demography: Contractual Sectors](https://data.ameli.fr/explore/dataset/demographie-secteurs-conventionnels/export/?disjunctive.region&disjunctive.departement) |

### 3. Lancement

```R
# Depuis RStudio : dans la console en ayant mis le dossier décompresser en tant que working directory

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

---

<a name="english-version"></a>

# Health & Territories - Shiny Dashboard

> 📝 *This README was generated with AI assistance*  
> 🇫🇷 [Version française ci-dessus](#santé--territoires---dashboard-shiny) | 🇬🇧 English version

Interactive dashboard for exploring health data in France (FINESS establishments and healthcare professionals).

## 📁 Project Structure

```
Challenge_Open_Data/
│
├── global.R                    # Loads libraries and datasets
├── ui.R                        # Main user interface
├── server.R                    # Main server logic
├── finess.R                    # FINESS data generation script
│
├── ui/                         # UI modules
│   ├── ui_home.R
│   ├── ui_finess_overview.R
│   ├── ui_finess_map.R
│   ├── ui_finess_analyses.R
│   ├── ui_finess_data.R
│   ├── ui_pro_overview.R
│   ├── ui_pro_map.R
│   ├── ui_pro_analyses.R
│   ├── ui_pro_data.R
│   └── ui_about.R
│
├── server/                     # Server modules
│   ├── server_navigation.R         # Page navigation
│   ├── server_filtered_data.R      # Filtered datasets
│   ├── server_reset.R              # Reset filters
│   ├── server_update_departments.R # Department updates
│   ├── server_finess.R             # FINESS logic
│   └── server_professionals.R      # Healthcare professionals logic
│
├── www/                        # Web resources
│   └── custom.css              # Custom styles
│
└── data/                       # Data folder (to create)
    ├── finess_geolocalise.csv      # Generated by finess.R
    ├── demographie-effectifs-et-les-densites.rds
    ├── demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json
    ├── patientele.json
    └── demographie-secteurs-conventionnels.json
```

## 🚀 Installation

### 1. Requirements

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

### 2. Data Structure

#### ⚠️ Important - Data Preparation

**FINESS file**: The `finess_geolocalise.csv` file is not provided directly. It must be generated by running the `finess.R` script located at the project root. Once execution is complete and the file is created in the `data/` folder, you can delete the `finess.R` script.

**RDS file**: The `.rds` file is already included in the repository. It was pre-generated from the corresponding JSON file to optimize loading times.

**Other files**: The following JSON files must be downloaded from their respective sources:

| File | Description | Source |
|------|--------------|---------|
| `finess_geolocalise.csv` | FINESS establishments data | Generated by `finess.R` |
| `demographie-effectifs-et-les-densites.rds` | Professionals headcount and density | Already included (generated from JSON) |
| `demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json` | Average ages, share of women and over-60 professionals | [data.ameli.fr – Demography: Age and Gender Breakdown](https://data.ameli.fr/explore/dataset/demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans/export/) |
| `patientele.json` | Patient base data | [data.ameli.fr – Patientele](https://data.ameli.fr/explore/dataset/patientele/export/?disjunctive.region&disjunctive.departement) |
| `demographie-secteurs-conventionnels.json` | Breakdown by contractual sector | [data.ameli.fr – Demography: Contractual Sectors](https://data.ameli.fr/explore/dataset/demographie-secteurs-conventionnels/export/?disjunctive.region&disjunctive.departement) |

### 3. Run the App

```R
# From RStudio
shiny::runApp()

# Or from R
library(shiny)
runApp("path/to/project")
```

## 📊 Features

### FINESS Establishments
- **Overview**: KPIs and global statistics  
- **Interactive map**: Geolocation of establishments  
- **Analyses**: Temporal evolution and geographical distribution  
- **Database**: Raw data view and export  

### Healthcare Professionals
- **Overview**: Headcounts, densities, and professions  
- **Density map**: Medical density by department  
- **Analyses**: Temporal and demographic insights  
- **Database**: Four datasets available for consultation  

## 🎨 Code Structure

### Comment Convention

Comments follow a clear hierarchical structure:

```R
# ----------- 1. Main Section -----------

## ----- 1.1. Sub-section -----

### --- 1.1.1. Sub-sub-section ---
```

### UI Modules

Each interface page is in its own file:
- Improves maintainability  
- Enhances readability  
- Enables parallel development  

### Server Modules

Server logic is organized by functionality:
- **Navigation**: Page transitions  
- **Filtered Data**: Apply and update filters  
- **Reset**: Reset filters  
- **FINESS**: Establishment-related logic  
- **Professionals**: Healthcare professionals logic  

## 🎯 Data Sources

- **FINESS**: [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/finess-extraction-du-fichier-des-etablissements/)  
- **Healthcare professionals**: [data.ameli.fr](https://data.ameli.fr/)  
- **Geolocation**: [France GeoJSON](https://github.com/gregoiredavid/france-geojson)

## 👥 Authors

- **Fadli Aaron** - [LinkedIn](https://www.linkedin.com/in/aaron-fadli/) | [GitHub](https://github.com/Maikooh)  
- **Kurnaz Kubra** - [LinkedIn](https://www.linkedin.com/in/kubra-kurnaz-56ba35387/) | [GitHub](https://github.com/Kubra2918)  
- **Moreau Matteo** - [GitHub](https://github.com/MatteoHmmm)

## 📄 License

CC-by-sa - Master MECEN 2025-2026  

Project developed as part of the [Open Data University](https://latitudes.notion.site/)

## 🛠️ Development

### Add a New Page

1. Create a file `ui/ui_page_name.R`  
2. Source it in `ui.R`  
3. Add the logic in `server/server_page_name.R`  
4. Source it in `server.R`

### Edit CSS

All custom styles are located in `www/custom.css`, organized by numbered sections.

### Add New Data

1. Place the files in the `data/` folder  
2. Load them in `global.R`  
3. Add filters if necessary  

## 📞 Support

For any question or issue:
- Open a GitHub issue  
- Contact the authors by email
