# Observatoire Économique Mondial

Application Shiny permettant de visualiser et d'analyser des données économiques mondiales à partir de l'API de la Banque Mondiale.

## Fonctionnalités principales
- Carte économique interactive mondiale
- Analyse détaillée des indicateurs par pays
- Comparaison d'indicateurs entre plusieurs pays
- Visualisations interactives et tableaux exportables

## Documentation
Pour plus de détails sur le fonctionnement de l'application, consultez la [documentation complète](documentation.md).

## Installation

```bash
# Cloner le dépôt
git clone https://github.com/vrai2G/SHINY2_M2ECAP_PROJECT.git

# Installer les dépendances R requises
R -e "install.packages(c('shiny', 'shinydashboard', 'plotly', 'leaflet', 'dplyr', 'DT', 'shinyWidgets', 'httr', 'jsonlite', 'lubridate', 'sf', 'rnaturalearth', 'purrr'))"

# Lancer l'application
R -e "shiny::runApp('SHINY2_M2ECAP_PROJECT')"