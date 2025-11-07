# 📐 Structure détaillée du projet

## Vue d'ensemble

L'application Shiny a été restructurée pour une meilleure organisation et maintenabilité. Voici la structure complète avec le rôle de chaque fichier.

## 🎯 Fichiers principaux

### global.R
**Rôle** : Configuration globale de l'application
- Chargement de toutes les bibliothèques nécessaires
- Chargement des données depuis le dossier `data/`
- Préparation des listes de filtres pour FINESS et Professionnels
- Calcul des min/max pour les sliders

**Sections** :
1. Chargement des bibliothèques
2. Détermination du chemin de base
3. Chargement des données (FINESS, Professionnels, GeoJSON)
4. Préparation des filtres

### ui.R
**Rôle** : Point d'entrée de l'interface utilisateur
- Définit la structure du dashboard (header, sidebar, body)
- Importe tous les modules UI depuis le dossier `ui/`
- Charge le fichier CSS personnalisé

**Contient** :
- Header avec titre
- Sidebar avec navigation et filtres dynamiques
- Body qui source tous les modules UI

### server.R
**Rôle** : Point d'entrée de la logique serveur
- Importe tous les modules serveur depuis le dossier `server/`
- Orchestre toutes les fonctionnalités de l'application

**Contient** :
- Sources de tous les modules serveur

---

## 📂 Dossier ui/

### ui_accueil.R
**Page** : Accueil
**Contient** :
- Message de bienvenue
- 2 cartes de présentation (FINESS et Professionnels)
- Section "À propos" avec les sources

### ui_finess_overview.R
**Page** : Vue d'ensemble FINESS
**Contient** :
- 4 KPIs (nombre d'établissements, catégories, départements, MAJ)
- Graphique des top catégories/départements
- Carte d'aperçu géographique

### ui_finess_carte.R
**Page** : Carte interactive FINESS
**Contient** :
- 3 info boxes (points sur carte, précision GPS, filtres actifs)
- Carte interactive avec clustering
- Options d'affichage (clustering, légende)

### ui_finess_analyses.R
**Page** : Analyses FINESS
**Contient** :
- Sélecteur de type d'analyse (4 types)
- Évolution temporelle avec slider
- Répartition géographique
- Distribution par catégorie
- Statistiques descriptives

### ui_finess_donnees.R
**Page** : Base de données FINESS
**Contient** :
- Options d'affichage (colonnes, pagination)
- Bouton de téléchargement CSV
- Tableau interactif DataTables

### ui_pro_overview.R
**Page** : Vue d'ensemble Professionnels
**Contient** :
- 4 KPIs (effectif, densité, professions, part 60+)
- Graphique top professions
- Carte d'aperçu de densité

### ui_pro_carte.R
**Page** : Carte de densité
**Contient** :
- 3 info boxes (densité min, max, moyenne)
- Carte choroplèthe par département
- Options d'affichage (légende, étiquettes)

### ui_pro_analyses.R
**Page** : Analyses Professionnels
**Contient** :
- Sélecteur de type d'analyse (3 types)
- Évolution temporelle
- Analyses démographiques (âges, part 60+)
- Statistiques descriptives

### ui_pro_donnees.R
**Page** : Base de données Professionnels
**Contient** :
- Sélection du dataset (4 datasets)
- Options d'affichage
- Bouton de téléchargement
- Tableau interactif

### ui_apropos.R
**Page** : À propos du projet
**Contient** :
- Informations sur les 3 auteurs
- Sources de données avec liens
- Lien GitHub du projet
- Limites et considérations
- Technologies utilisées
- Licence et contexte universitaire

---

## 🖥️ Dossier server/

### server_navigation.R
**Rôle** : Gestion de la navigation
**Contient** :
- Navigation vers section FINESS (bouton `goto_finess`)
- Navigation vers section Professionnels (bouton `goto_pro`)

### server_donnees_filtrees.R
**Rôle** : Application des filtres
**Contient** :
- `donnees_finess_filtrees()` : Reactive pour filtrer les données FINESS
  - Filtre par département, catégorie, année, coordonnées GPS
- `donnees_pro_filtrees()` : Reactive pour filtrer les données Professionnels
  - Filtre par année, profession, région, département, classe d'âge

### server_reset.R
**Rôle** : Réinitialisation des filtres
**Contient** :
- Reset des filtres FINESS
- Reset des filtres Professionnels
- Notifications de confirmation

### server_maj_departements.R
**Rôle** : Mise à jour dynamique
**Contient** :
- Mise à jour de la liste des départements selon la région sélectionnée

### server_finess.R
**Rôle** : Logique complète FINESS
**Sections** :
1. **KPIs** (4 outputs) :
   - Nombre d'établissements
   - Nombre de catégories
   - Nombre de départements
   - Dernière mise à jour

2. **Graphiques Overview** (3 outputs) :
   - Top catégories
   - Répartition départements
   - Carte d'aperçu

3. **Carte Interactive** (4 outputs) :
   - 3 info boxes (points, précision, filtres)
   - Carte principale avec clustering/popups

4. **Graphiques d'Analyse** (6 outputs) :
   - Évolution temporelle
   - Densité par département
   - Distribution catégories (pie chart)
   - Évolution par catégorie
   - Statistiques descriptives
   - Qualité des données

5. **Tableau de données** (1 output) :
   - Tableau interactif avec filtres

6. **Téléchargement** (1 handler) :
   - Export CSV

### server_professionnels.R
**Rôle** : Logique complète Professionnels
**Sections** :
1. **KPIs** (4 outputs) :
   - Effectif total
   - Densité moyenne
   - Nombre de professions
   - Part des 60 ans et plus

2. **Graphiques Overview** (2 outputs) :
   - Top professions
   - Carte d'aperçu de densité

3. **Carte de Densité** (4 outputs) :
   - 3 info boxes (densité min, max, moy)
   - Carte choroplèthe principale

4. **Graphiques d'Analyse** (5 outputs) :
   - Évolution temporelle
   - Distribution par âge (pie chart)
   - Part des 60 ans et plus
   - Statistiques descriptives
   - Qualité des données

5. **Tableau de données** (1 output) :
   - Tableau multi-datasets

6. **Téléchargement** (1 handler) :
   - Export CSV multi-datasets

---

## 🎨 Dossier www/

### custom.css
**Rôle** : Tous les styles personnalisés
**Sections** :
1. Configuration globale (fonts, reset)
2. Layout et conteneurs (wrapper, content, tabs)
3. Header et Sidebar
4. Boxes et Cards (small-box, info-box, box)
5. Typographie (h1, h2, h3, p)
6. Formulaires (boutons, inputs, selects)
7. Tableaux (DataTables)
8. Graphiques et cartes (Plotly, Leaflet)
9. Pages spécifiques (accueil, à propos)
10. Utilitaires (animations, notifications)

---

## 📊 Dossier data/

Ce dossier doit contenir :
- `finess_geolocalise.csv` (établissements FINESS)
- `demographie-effectifs-et-les-densites.rds` (effectifs professionnels)
- `demographie-ages-moyens-part-des-femmes-part-des-plus-de-60-ans.json` (âges)
- `patientele.json` (patientèle)
- `demographie-secteurs-conventionnels.json` (secteurs)

---

## 📝 Fichiers de documentation

### README.md
Guide complet d'utilisation et d'installation

### STRUCTURE.md
Ce fichier - documentation détaillée de la structure

### .gitignore
Fichiers à exclure du versioning Git

---

## 🔄 Flux de données

```
global.R
   ↓
Chargement des données
   ↓
Préparation des filtres
   ↓
   ├── ui.R ────────→ ui/*.R (modules UI)
   │                      ↓
   │                  Interface visible
   │                      ↓
   └── server.R ────→ server/*.R (modules serveur)
                          ↓
                   Logique + Outputs
                          ↓
                    Résultats affichés
```

---

## 🎯 Points clés

### Avantages de cette structure

1. **Modularité** : Chaque fichier a une responsabilité claire
2. **Maintenabilité** : Facile de trouver et modifier du code
3. **Scalabilité** : Ajout de nouvelles fonctionnalités simplifié
4. **Collaboration** : Plusieurs développeurs peuvent travailler en parallèle
5. **Lisibilité** : Nomenclature cohérente et commentaires hiérarchiques

### Conventions de nommage

- **Fichiers UI** : `ui_nom_section.R`
- **Fichiers Server** : `server_nom_fonctionnalite.R`
- **Sections de code** : Numérotation hiérarchique (1., 1.1., 1.1.1.)
- **Commentaires** : `# ---`, `## ---`, `### ---`

### Organisation des commentaires

```R
# ----------- 1. Section principale -----------

## ----- 1.1. Sous-section -----

### --- 1.1.1. Détail spécifique ---
```

---

## 📈 Statistiques du projet

- **Fichiers R** : 22 fichiers
- **Lignes de code** : ~3500 lignes (réparties sur tous les fichiers)
- **Modules UI** : 10 fichiers
- **Modules Serveur** : 6 fichiers
- **Outputs** : ~50 outputs (graphiques, cartes, tableaux, KPIs)
- **Datasets** : 5 fichiers de données

---

## 🚀 Pour démarrer

1. Cloner le repository
2. Créer le dossier `data/` et y placer les fichiers de données
3. Installer les packages (voir README.md)
4. Lancer `shiny::runApp()`
5. Enjoy! 🎉