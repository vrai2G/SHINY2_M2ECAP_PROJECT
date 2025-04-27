# server.R

library(shiny)
library(shinydashboard)
library(plotly)
library(leaflet)
library(dplyr)
library(DT)
library(shinyWidgets)
library(purrr)

source("data_functions.R")

server <- function(input, output, session) {
  
  # Initialisation et gestion d'état
  rv <- reactiveValues(
    last_update = NULL,
    data_cache = list()
  )
  
  # Gestion des erreurs API
  handle_api_error <- function(error) {
    error_msg <- paste(Sys.time(), "- Erreur API:", error$message)
    message(error_msg)
    write(error_msg, file = "api_errors.log", append = TRUE)
    showNotification(
      paste("Erreur de récupération des données:", error$message),
      type = "error",
      duration = 10
    )
    return(NULL)
  }
  
  # Système de cache
  cache_data <- function(data, key, expiry_hours = 24) {
    if (!dir.exists("cache")) dir.create("cache")
    cache_file <- file.path("cache", paste0("cached_", key, ".rds"))
    saveRDS(
      list(data = data, timestamp = Sys.time(), expiry = expiry_hours),
      file = cache_file
    )
  }
  
  get_cached_data <- function(key) {
    cache_file <- file.path("cache", paste0("cached_", key, ".rds"))
    if (file.exists(cache_file)) {
      cached <- readRDS(cache_file)
      if (difftime(Sys.time(), cached$timestamp, units = "hours") < cached$expiry) {
        return(cached$data)
      }
      file.remove(cache_file)
    }
    return(NULL)
  }
  
  # Récupération des données économiques avec debounce
  donnees_economiques <- debounce(eventReactive(input$update_data, {
    req(input$indicateur, input$pays)
    
    cache_key <- paste(input$indicateur, input$pays, 
                       format(input$periode[1], "%Y"), 
                       format(input$periode[2], "%Y"), sep = "_")
    
    if (!is.null(rv$data_cache[[cache_key]])) return(rv$data_cache[[cache_key]])
    
    showModal(modalDialog("Chargement des données...", footer = NULL))
    
    indicator_code <- ECONOMIC_INDICATORS[[input$indicateur]]$code
    country_code <- COUNTRY_CODES[[input$pays]]
    start_year <- as.numeric(format(input$periode[1], "%Y"))
    end_year <- as.numeric(format(input$periode[2], "%Y"))
    
    data <- fetch_world_bank_data(
      indicator_code = indicator_code,
      country_code = country_code,
      start_year = start_year,
      end_year = end_year
    )
    
    removeModal()
    
    if (is.null(data) || nrow(data) == 0) {
      showNotification("Aucune donnée disponible pour cette sélection", type = "warning")
      return(NULL)
    }
    
    rv$data_cache[[cache_key]] <- data
    rv$last_update <- Sys.time()
    return(data)
  }), millis = 1000)  
  
  # Carte mondiale interactive
  output$world_map <- renderLeaflet({
    req(input$map_indicator, input$map_year)
    
    showModal(modalDialog("Génération de la carte...", footer = NULL))
    data <- prepare_world_map_data(input$map_indicator, input$map_year)
    removeModal()
    
    if (is.null(data) || all(is.na(data$value))) {
      return(leaflet() %>% 
               addTiles() %>% 
               setView(lng = 0, lat = 30, zoom = 2) %>%
               addControl("Aucune donnée disponible pour cette sélection", position = "topright"))
    }
    
    valid_values <- na.omit(data$value)
    if (length(valid_values) == 0) {
      pal <- colorNumeric("Greys", domain = NULL, na.color = "#808080")
    } else {
      pal <- colorNumeric("YlOrRd", domain = valid_values, na.color = "#808080")
    }
    
    leaflet(data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(value),
        weight = 1,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(weight = 2, color = "#666", bringToFront = TRUE),
        popup = ~paste(
          "<b>", name, "</b><br>",
          names(ECONOMIC_INDICATORS)[which(sapply(ECONOMIC_INDICATORS, `[[`, "code") == input$map_indicator)],
          ": ", ifelse(is.na(value), "N/A", format(value, big.mark = " "))
        ),
        label = ~name
      ) %>%
      addLegend(pal = pal, values = valid_values,
                title = names(ECONOMIC_INDICATORS)[which(sapply(ECONOMIC_INDICATORS, `[[`, "code") == input$map_indicator)],
                position = "bottomright", na.label = "N/A") %>%
      setView(lng = 0, lat = 30, zoom = 2)
  })
  
  output$tendance_economique <- renderPlotly({
    req(donnees_economiques())
    data <- donnees_economiques() %>% arrange(date)  # Tri par date croissante
    if (is.null(data) || nrow(data) < 2) return(NULL)
    
    first_val <- first(na.omit(data$value))
    last_val <- last(na.omit(data$value))
    change_pct <- ifelse(first_val != 0, (last_val - first_val)/first_val * 100, NA)
    
    plot_ly(data, x = ~date, y = ~value, type = 'scatter', mode = 'lines+markers',
            line = list(width = 3, color = '#3c8dbc'),
            marker = list(size = 8, color = '#3c8dbc'),
            hoverinfo = 'text',
            text = ~paste('Année:', date, '<br>Valeur:', round(value, 2))) %>%
      layout(
        title = list(
          text = paste0("Évolution de ", input$indicateur, " en ", input$pays,
                        "<br><sup>", ECONOMIC_INDICATORS[[input$indicateur]]$description, "</sup>"),
          x = 0.05
        ),
        xaxis = list(title = "Année", gridcolor = '#e6e6e6', type = 'category', categoryorder = "array", categoryarray = sort(unique(data$date))),
        yaxis = list(title = "", gridcolor = '#e6e6e6'),
        plot_bgcolor = 'rgba(0,0,0,0)',
        paper_bgcolor = 'rgba(0,0,0,0)',
        hoverlabel = list(bgcolor = 'white'),
        margin = list(t = 80)
      ) %>%
      add_annotations(
        xref = "paper", yref = "paper", x = 0.05, y = 0.95,
        text = paste0("Évolution: ", ifelse(change_pct >= 0, "+", ""), round(change_pct, 1), "%"),
        showarrow = FALSE,
        font = list(size = 14, color = ifelse(change_pct >= 0, "green", "red"))
      )
  })
  
  # Graphique de comparaison entre pays
  output$comparaison_pays <- renderPlotly({
    req(input$indicateur_comparaison, input$pays_comparaison)
    
    showModal(modalDialog("Chargement des données de comparaison...", footer = NULL))
    plot_data <- map_dfr(input$pays_comparaison, ~{
      df <- fetch_world_bank_data(
        indicator_code = ECONOMIC_INDICATORS[[input$indicateur_comparaison]]$code,
        country_code = COUNTRY_CODES[[.x]],
        start_year = input$periode_comparaison[1],
        end_year = input$periode_comparaison[2]
      )
      if (!is.null(df)) mutate(df, pays = .x)
    })
    removeModal()
    
    if (is.null(plot_data) || nrow(plot_data) == 0) {
      showNotification("Aucune donnée disponible pour cette comparaison", type = "warning")
      return(NULL)
    }
    
    plot_ly(plot_data, x = ~date, y = ~value, color = ~pays,
            type = 'scatter', mode = 'lines+markers',
            line = list(width = 2),
            marker = list(size = 6),
            hoverinfo = 'text',
            text = ~paste('Pays:', pays, '<br>Année:', date, '<br>Valeur:', round(value, 2))) %>%
      layout(
        title = paste("Comparaison de", input$indicateur_comparaison),
        xaxis = list(title = "Année"),
        yaxis = list(title = ""),
        legend = list(orientation = 'h', x = 0, y = -0.2)
      )
  })
  
  # Tableau de données interactif
  output$tableau_donnees <- renderDT({
    req(donnees_economiques())
    data <- donnees_economiques()
    if (is.null(data)) return(NULL)
    
    datatable(
      data %>% transmute(Année = date, Valeur = round(value, 2), Pays = input$pays, Indicateur = input$indicateur),
      extensions = c('Buttons', 'Scroller'),
      options = list(
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf'),
        scrollX = TRUE,
        scrollY = "300px",
        scroller = TRUE,
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/French.json')
      ),
      rownames = FALSE,
      caption = tags$caption(
        style = 'caption-side: top; text-align: center;',
        'Données économiques - ', tags$b(input$pays), ' - ', tags$b(input$indicateur)
      )
    )
  })
  
  # Value Boxes
  output$pib_mondial <- renderValueBox({
    data <- get_cached_data("world_gdp") %||% fetch_world_bank_data("NY.GDP.MKTP.CD", "all", 2021, 2021)
    value <- if (!is.null(data)) sum(data$value, na.rm = TRUE) / 1e12 else NA
    valueBox(if (!is.na(value)) paste(round(value, 1), "T $") else "N/A",
             "PIB Mondial (2021)", icon = icon("globe"), color = "green")
  })
  
  output$croissance <- renderValueBox({
    data <- get_cached_data("world_growth") %||% fetch_world_bank_data("NY.GDP.MKTP.KD.ZG", "all", 2021, 2021)
    value <- if (!is.null(data)) mean(data$value, na.rm = TRUE) else NA
    valueBox(if (!is.na(value)) paste(round(value, 1), "%") else "N/A",
             "Croissance Mondiale (2021)", icon = icon("chart-line"), color = "blue")
  })
  
  output$inflation <- renderValueBox({
    data <- get_cached_data("world_inflation") %||% fetch_world_bank_data("FP.CPI.TOTL.ZG", "all", 2021, 2021)
    value <- if (!is.null(data)) mean(data$value, na.rm = TRUE) else NA
    valueBox(if (!is.na(value)) paste(round(value, 1), "%") else "N/A",
             "Inflation Mondiale (2021)", icon = icon("dollar-sign"), color = "red")
  })
  
  # Export des données
  output$export_data <- downloadHandler(
    filename = function() paste0("donnees_", input$pays, "_", input$indicateur, "_", format(Sys.Date(), "%Y%m%d"), ".csv"),
    content = function(file) {
      data <- donnees_economiques()
      if (!is.null(data)) {
        write.csv2(data %>% mutate(Pays = input$pays, Indicateur = input$indicateur), file, row.names = FALSE, fileEncoding = "UTF-8")
      }
    }
  )
  
  # Commentaires dynamiques
  output$commentaire_tendance <- renderUI({
    req(donnees_economiques())
    data <- donnees_economiques()
    if (is.null(data) || nrow(data) < 2) return(NULL)
    
    first_val <- last(na.omit(data$value))
    last_val <- first(na.omit(data$value))
    change_pct <- ifelse(first_val != 0, (last_val - first_val)/first_val * 100, NA)
    
    tagList(
      div(class = "panel panel-default", style = "margin-top: 20px;",
          div(class = "panel-heading", h4(class = "panel-title", "Analyse de la tendance")),
          div(class = "panel-body",
              if (!is.na(change_pct)) {
                p(style = paste0("color:", ifelse(change_pct >= 0, "green", "red"), ";"),
                  strong(ifelse(change_pct >= 0, "Augmentation", "Diminution")),
                  " de ", round(abs(change_pct), 1), "% sur la période")
              },
              p("Valeur finale (", first(data$date), "): ", strong(format(round(last_val, 2), big.mark = " "))),
              p("Valeur initiale (", last(data$date), "): ", strong(format(round(first_val, 2), big.mark = " "))))
      )
    )
  })
  
  # Mise à jour dynamique des sélecteurs
  observe({
    updateSelectInput(session, "indicateur", choices = names(ECONOMIC_INDICATORS))
    updateSelectInput(session, "pays", choices = names(COUNTRY_CODES))
    updateSliderInput(session, "map_year", min = 2000, max = year(Sys.Date()), value = year(Sys.Date()) - 1)
  })
  
  # Gestion des erreurs et rechargement
  observeEvent(input$reload_app, { session$reload() })
}