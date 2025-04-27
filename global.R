# Config de l'appli

library(shiny)
library(shinydashboard)
library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)
library(plotly)
library(leaflet)
library(sf)
library(rnaturalearth)
library(DT)
library(shinyWidgets)
library(purrr)

# Configuration générale
options(
  scipen = 999,               # Désactive la notation scientifique
  tz = "Europe/Paris",        # Fuseau horaire
  stringsAsFactors = FALSE,   # Désactive les facteurs par défaut
  shiny.maxRequestSize = 50*1024^2  # Limite de taille des requêtes
)

# Constantes API
WORLD_BANK_BASE_URL <- "https://api.worldbank.org/v2"
API_TIMEOUT <- 30

# Vérification de la connexion API
test_api_connection <- function() {
  tryCatch({
    res <- GET(paste0(WORLD_BANK_BASE_URL, "/country"), timeout(5))
    if (http_error(res)) stop(paste("Erreur HTTP:", status_code(res)))
    TRUE
  }, error = function(e) {
    message("Erreur de connexion API: ", e$message)
    FALSE
  })
}

if (!test_api_connection()) {
  warning("L'API Banque Mondiale semble indisponible - certaines fonctionnalités seront limitées")
}

# Dictionnaires de données
ECONOMIC_INDICATORS <- list(
  "PIB Total (USD courants)" = list(
    code = "NY.GDP.MKTP.CD",
    description = "Produit Intérieur Brut en dollars courants"
  ),
  "PIB par habitant (USD courants)" = list(
    code = "NY.GDP.PCAP.CD",
    description = "PIB divisé par la population"
  ),
  "Croissance du PIB (% annuel)" = list(
    code = "NY.GDP.MKTP.KD.ZG",
    description = "Taux de croissance annuel du PIB en volume"
  ),
  "Inflation (% annuel)" = list(
    code = "FP.CPI.TOTL.ZG",
    description = "Indice des prix à la consommation"
  ),
  "Taux de chômage (% population active)" = list(
    code = "SL.UEM.TOTL.ZS",
    description = "Pourcentage de la population active au chômage"
  )
)

COUNTRY_CODES <- list(
  "France" = "FRA",
  "Allemagne" = "DEU",
  "États-Unis" = "USA",
  "Chine" = "CHN",
  "Japon" = "JPN",
  "Espagne" = "ESP",
  "Italie" = "ITA",
  "Royaume-Uni" = "GBR",
  "Suisse" = "CHE",
  "Canada" = "CAN"
)

# Initialisation des logs
if (!dir.exists("logs")) dir.create("logs")
log_file <- file.path("logs", paste0("app_", format(Sys.Date(), "%Y%m%d"), ".log"))
cat(paste0("\n", Sys.time(), " - Démarrage application\n"), file = log_file, append = TRUE)


source("data_functions.R")