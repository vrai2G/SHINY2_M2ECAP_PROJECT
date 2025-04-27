# ui.R

library(shiny)
library(shinydashboard)
library(shinyWidgets)

ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(title = "Observatoire Économique Mondial", titleWidth = 350),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Tableau de bord", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Analyse par pays", tabName = "country", icon = icon("flag")),
      menuItem("Comparaisons", tabName = "compare", icon = icon("balance-scale"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"),
      tags$script(src = "custom.js")
    ),
    
    # Modal d'erreur API
    tags$div(
      id = "api-error-modal",
      class = "modal fade",
      tags$div(
        class = "modal-dialog",
        tags$div(
          class = "modal-content",
          tags$div(class = "modal-header bg-danger",
                   tags$h4(class = "modal-title", "Erreur de connexion"),
                   tags$button(type = "button", class = "close", `data-dismiss` = "modal", HTML("×"))),
          tags$div(class = "modal-body",
                   tags$p("Impossible de se connecter à l'API de la Banque Mondiale."),
                   tags$p("Veuillez vérifier votre connexion internet et réessayer.")),
          tags$div(class = "modal-footer",
                   tags$button(type = "button", class = "btn btn-default", `data-dismiss` = "modal", "Fermer"),
                   tags$button(id = "reload-app", type = "button", class = "btn btn-primary", "Recharger"))
        )
      )
    ),
    
    tabItems(
      # Tableau de bord
      tabItem(
        tabName = "dashboard",
        fluidRow(
          box(
            title = span(icon("map"), "Carte économique interactive"),
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            selectInput("map_indicator", "Indicateur :", choices = sapply(ECONOMIC_INDICATORS, `[[`, "code")),
            sliderInput("map_year", "Année :", min = 2000, max = year(Sys.Date()), value = year(Sys.Date()) - 1, step = 1, sep = ""),
            leafletOutput("world_map", height = 600)
          )
        ),
        fluidRow(
          valueBoxOutput("pib_mondial", width = 4),
          valueBoxOutput("croissance", width = 4),
          valueBoxOutput("inflation", width = 4)
        )
      ),
      
      # Analyse par pays
      tabItem(
        tabName = "country",
        fluidRow(
          box(
            title = span(icon("sliders-h"), "Paramètres d'analyse"),
            width = 4,
            status = "primary",
            solidHeader = TRUE,
            selectInput("indicateur", "Indicateur économique :", choices = names(ECONOMIC_INDICATORS)),
            selectizeInput("pays", "Pays :", choices = names(COUNTRY_CODES), options = list(placeholder = 'Sélectionnez un pays')),
            dateRangeInput("periode", "Période d'analyse :", start = "2010-01-01", end = Sys.Date(),
                           min = "2000-01-01", max = Sys.Date(), language = "fr", separator = " au ", format = "yyyy"),
            actionBttn("update_data", "Mettre à jour", icon = icon("sync"), style = "gradient", color = "primary"),
            hr(),
            uiOutput("last_update")
          ),
          tabBox(
            title = span(icon("chart-bar"), "Visualisations"),
            width = 8,
            side = "right",
            tabPanel(span(icon("line-chart"), "Tendance"), plotlyOutput("tendance_economique", height = "500px"), uiOutput("commentaire_tendance")),
            tabPanel(span(icon("table"), "Données brutes"), DTOutput("tableau_donnees"), downloadButton("export_data", "Exporter", class = "btn-primary"))
          )
        )
      ),
      
      # Comparaisons
      tabItem(
        tabName = "compare",
        fluidRow(
          box(
            title = span(icon("sliders-h"), "Paramètres de comparaison"),
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            column(6, selectInput("indicateur_comparaison", "Indicateur :", choices = names(ECONOMIC_INDICATORS))),
            column(6, pickerInput("pays_comparaison", "Pays à comparer :", choices = names(COUNTRY_CODES), multiple = TRUE,
                                  selected = c("France", "Allemagne", "États-Unis"),
                                  options = list(`actions-box` = TRUE, `selected-text-format` = "count > 2"))),
            column(12, sliderTextInput("periode_comparaison", "Période :", choices = 2000:year(Sys.Date()),
                                       selected = c(2010, year(Sys.Date())), width = "100%"))
          ),
          box(
            title = span(icon("chart-line"), "Comparaison entre pays"),
            width = 12,
            status = "primary",
            plotlyOutput("comparaison_pays", height = "600px")
          )
        )
      )
    )
  )
)