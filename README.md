# 📊 Challenge Open Data

👉 [Lien du dépôt GitHub](https://github.com/Maikooh/Challenge_Open_Data)

Ce projet contient les scripts et la structure de données nécessaires pour le **Challenge Open Data**.  
Suivez attentivement les étapes ci-dessous pour installer et exécuter correctement le projet.

---

## 🧭 Étapes d’installation

### **Étape 1 — Télécharger le projet**
Téléchargez le projet au format `.zip` depuis le dépôt GitHub :  
➡️ [https://github.com/Maikooh/Challenge_Open_Data](https://github.com/Maikooh/Challenge_Open_Data)

---

### **Étape 2 — Décompresser le projet**
Décompressez le fichier `.zip` dans un dossier nommé **`opendata`**.  
Ce dossier doit contenir les **deux dossiers principaux** du dépôt GitHub.

Exemple de structure :
```
opendata/
├── data/
└── R/
```

---

### **Étape 3 — Préparer les bases de données**

#### **a) Données ODISSE**
1. Ouvrez le fichier texte dans `data/raw/odisse/` — il contient les **liens de téléchargement** des bases de données.  
2. Téléchargez **tous les fichiers indiqués**.  
3. Placez-les dans le dossier :
```
data/raw/odisse/
```

#### **b) Données AMELI**
1. Faites de même pour les données du dossier :
```
data/raw/ameli/
```
2. Téléchargez les fichiers listés et placez-les dans ce dossier.

---

### **Étape 4 — Ouvrir le projet dans RStudio**
1. Lancez **RStudio**.  
2. Définissez le dossier `opendata` comme **working directory** :  
   ```R
   setwd("chemin/vers/opendata")
   ```

---

### **Étape 5 — Exécuter les scripts R**
Les scripts sont situés dans le dossier **`R/`**.  
Exécutez-les **dans l’ordre numérique** :

```text
00_nom_du_script.R
01_nom_du_script.R
02_nom_du_script.R
...
```

---

### 🆘 En cas de problème
Si vous rencontrez un souci à une étape, **contactez-moi** ou **ouvrez une issue** sur le dépôt GitHub.

---
