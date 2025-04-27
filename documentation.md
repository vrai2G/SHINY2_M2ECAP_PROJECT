# Documentation de l'Observatoire Économique Mondial

## 1. Introduction
L'**Observatoire Économique Mondial** est une application interactive développée avec R Shiny pour visualiser et analyser des indicateurs économiques mondiaux. Elle permet aux utilisateurs d'explorer des données telles que le PIB, l'inflation, et le taux de chômage pour différents pays, ainsi que de comparer ces indicateurs entre plusieurs nations. L'application est conçue pour être intuitive et accessible, tout en offrant des fonctionnalités avancées pour l'analyse de données économiques.

Cette documentation décrit les principales fonctionnalités de l'application, les sources de données utilisées, et les instructions pour interagir avec les différentes sections.

---

## 2. Fonctionnalités principales

L'application est divisée en trois onglets principaux :

- **Tableau de bord** : Fournit une vue d'ensemble des indicateurs économiques mondiaux avec une carte interactive et des indicateurs clés.
- **Analyse par pays** : Permet d'explorer en détail les données économiques d'un pays spécifique sur une période donnée.
- **Comparaisons** : Offre la possibilité de comparer plusieurs pays sur un indicateur économique commun.

---

## 3. Description des onglets

### 3.1 Tableau de bord

Le **Tableau de bord** présente une vue globale des données économiques :

- **Carte économique interactive** : Affiche une carte du monde avec des données économiques pour une année et un indicateur sélectionnés. Les utilisateurs peuvent choisir l'indicateur et l'année via des menus déroulants.
  - **Indicateur** : Sélectionnez parmi les indicateurs disponibles (PIB, inflation, etc.).
  - **Année** : Choisissez l'année pour laquelle vous souhaitez afficher les données.
- **Indicateurs clés** : Trois boîtes de valeur affichent des statistiques mondiales pour l'année 2021 :
  - PIB mondial total.
  - Croissance moyenne du PIB.
  - Inflation moyenne.

---

### 3.2 Analyse par pays

L'onglet **Analyse par pays** permet une exploration détaillée des données économiques d'un pays spécifique :

- **Paramètres d'analyse** :
  - **Indicateur économique** : Sélectionnez l'indicateur à analyser (par exemple, PIB total, taux de chômage).
  - **Pays** : Choisissez le pays à analyser parmi une liste prédéfinie.
  - **Période d'analyse** : Sélectionnez une plage de dates pour filtrer les données.
  - **Mettre à jour** : Cliquez pour charger les données avec les paramètres sélectionnés.
  
- **Visualisations** :
  - **Tendance** : Un graphique interactif (Plotly) montrant l'évolution de l'indicateur sélectionné sur la période choisie.
  - **Données brutes** : Un tableau interactif (DT) affichant les données sous forme tabulaire, avec des options d'exportation (CSV, Excel, etc.).

- **Commentaires analytiques** : Un résumé textuel de la tendance observée, incluant l'évolution en pourcentage et les valeurs initiales et finales.

---

### 3.3 Comparaisons

L'onglet **Comparaisons** permet de comparer plusieurs pays sur un même indicateur :

- **Paramètres de comparaison** :
  - **Indicateur** : Sélectionnez l'indicateur à comparer.
  - **Pays à comparer** : Choisissez plusieurs pays via un sélecteur multiple.
  - **Période** : Sélectionnez la plage d'années pour la comparaison.

- **Visualisation** : Un graphique interactif (Plotly) superposant les tendances de l'indicateur pour chaque pays sélectionné.

---

## 4. Sources de données

Les données économiques sont récupérées via l'**API de la Banque Mondiale** (World Development Indicators). Cette API fournit des données fiables et à jour sur une large gamme d'indicateurs économiques pour les pays du monde entier.

- **URL de l'API** : [https://api.worldbank.org/v2](https://api.worldbank.org/v2)
- **Documentation API** : [Documentation officielle](https://datahelpdesk.worldbank.org/knowledgebase/topics/125589-developer-information)

Les données géographiques pour la carte sont issues de **Natural Earth Data**, une source libre de données cartographiques.

- **Site web** : [https://www.naturalearthdata.com](https://www.naturalearthdata.com)

---

## 5. Instructions d'utilisation

### 5.1 Tableau de bord
- Sélectionnez un indicateur et une année pour mettre à jour la carte.
- La carte affichera les données disponibles pour chaque pays. Survolez un pays pour voir les détails.
- Les indicateurs clés en bas fournissent des statistiques mondiales pour l'année 2021.

### 5.2 Analyse par pays
1. Choisissez un indicateur, un pays et une période.
2. Cliquez sur "Mettre à jour" pour charger les données.
3. Consultez le graphique de tendance pour voir l'évolution de l'indicateur.
4. Explorez le tableau de données brutes et utilisez les options d'exportation si nécessaire.

### 5.3 Comparaisons
1. Sélectionnez un indicateur et plusieurs pays à comparer.
2. Choisissez la période d'analyse.
3. Le graphique affichera les tendances pour chaque pays sélectionné.

---

## 6. Gestion des erreurs et limitations

- **Connexion API** : Si l'API de la Banque Mondiale est indisponible, un message d'erreur s'affichera. Essayez de recharger l'application ou vérifiez votre connexion internet.
- **Données manquantes** : Pour certaines années ou indicateurs, les données peuvent être indisponibles. Dans ce cas, un message apparaîtra sur la carte ou dans les graphiques.
- **Périodes futures** : Les données pour les années futures (par exemple, après l'année en cours) ne sont pas disponibles et peuvent entraîner des erreurs.
- **Sélection des pays et indicateurs** : Seuls quelques pays et indicateurs ont été sélectionnés pour optimiser les performances et éviter un chargement trop long.

---

## 7. Développeur et version

- **Développeur** : [Votre nom]
- **Version** : 1.0.0
- **Date de dernière mise à jour** : [Date]
- **Contexte académique** : Cette application a été développée dans le cadre d'un projet de Master 2 en Économétrie Appliquée à l'IAE de Nantes.

---

## 8. Licence et droits

Cette application est développée à des fins éducatives dans le cadre d'un projet de Master 2 en Économétrie Appliquée à l'IAE de Nantes. Les données sont fournies par la Banque Mondiale sous licence ouverte.
---

*SINEAU Angel*
*angel.sineau@gmail.com*