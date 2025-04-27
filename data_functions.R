# Fonctions de récupération des données

#' Récupération sécurisée des données de la Banque Mondiale
fetch_world_bank_data <- function(indicator_code, country_code, start_year, end_year) {
  tryCatch({
    # Vérification des paramètres
    if (missing(indicator_code) || missing(country_code)) stop("Paramètres manquants")
    
    # Construction URL avec encodage sécurisé
    url <- paste0(
      WORLD_BANK_BASE_URL, "/country/",
      URLencode(country_code), "/indicator/",
      URLencode(indicator_code),
      "?format=json&date=", start_year, ":", end_year, "&per_page=10000"
    )
    
    # Requête HTTP avec timeout
    response <- GET(url, timeout(API_TIMEOUT))
    
    # Vérification de la réponse
    if (http_error(response)) stop(paste("Erreur HTTP", status_code(response)))
    
    # Extraction et nettoyage des données
    data <- fromJSON(content(response, "text"), flatten = TRUE)
    if (length(data) < 2) stop("Structure de réponse invalide")
    
    clean_data <- data[[2]] %>%
      select(date, countryiso3code, value) %>%
      mutate(
        date = as.numeric(date),
        value = as.numeric(value)
      ) %>%
      filter(!is.na(value))
    
    return(clean_data)
    
  }, error = function(e) {
    handle_api_error(e)
    return(NULL)
  })
}

#' Préparation des données cartographiques
prepare_world_map_data <- function(indicator_code, year = year(Sys.Date()) - 1) {
  tryCatch({
    data <- fetch_world_bank_data(indicator_code, "all", year, year)
    
    # Ajouter ces lignes pour débogage
    print("Données récupérées de l'API:")
    print(head(data))
    print(paste("Nombre de lignes:", nrow(data)))
    print(paste("Codes ISO présents:", paste(head(data$countryiso3code), collapse=", ")))
    
    if (is.null(data) || nrow(data) == 0) {
      warning("Aucune donnée disponible pour cet indicateur et cette année.")
      return(NULL)
    }
    
    world <- ne_countries(scale = "medium", returnclass = "sf") %>%
      select(iso_a3, name, geometry)
    
    # Vérifier les codes ISO dans world
    print("Exemples de codes ISO dans world:")
    print(head(world$iso_a3))
    
    merged <- world %>%
      left_join(data, by = c("iso_a3" = "countryiso3code"))
    
    # Vérifier si la jointure a fonctionné
    print(paste("Nombre de valeurs non-NA après jointure:", sum(!is.na(merged$value))))
    
    return(merged)
    
  }, error = function(e) {
    handle_api_error(e)
    return(NULL)
  })
}