library(shiny)
library(shinydashboard)

source("global.R")
source("ui.R")
source("server.R")

# Configuration pour améliorer les performances et la sécurité
options(shiny.sanitize.errors = TRUE)  # Nettoie les erreurs pour éviter l'exposition d'infos sensibles
options(shiny.fullstacktrace = FALSE)  # Réduit les traces d'erreur inutiles
options(shiny.deprecation.messages = FALSE)  # Désactive les messages de dépréciation

shinyApp(ui, server)