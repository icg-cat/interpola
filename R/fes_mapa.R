#' fes_mapa
#' @description
#' Fes mapa (choropleth) amb els resultats de les interpolacions. Per defecte, fa servir `colorNumeric` per definir els colors.
#'
#' @param shape_data conjunt de dades tipus shapefile que contingui les geometries de les divisions territorials d'interès. També cal que contingui la variable que es vol dibuixar. Veure exemple.
#' @param nom_indicador cadena de text que representa el nom de la variable que es vol dibuixar.
#' @param ciutat cadena de text amb el nom de la ciutat on es posa el focus inicial del mapa. Per defecte, Barcelona.
#' @param focus Xifra que indica el nivell de zoom. Per defecte, 14.
#'
#' @return Un widget html amb un choropleth
#'
#' @examples
#' data("ex_data", package = "interpola") # carrega dades de mostra
#' sp <- ex_data$shapes %>% # afegeix variable pels colors a dades shape
#' mutate(
#'  Tatur = ex_data$indicador$taxa_atur[match(ex_data$shapes$Sc2021, ex_data$indicador$sc_2021)],
#'  Tatur = round(readr::parse_double(Tatur),2)
#')
#'fes_mapa(shape_data = sp, nom_indicador = "Tatur", ciutat = "Badalona", focus = 14) # fes gràfic
fes_mapa <- function(shape_data, nom_indicador, ciutat = "Barcelona", focus = 14){
  if(all(is.na(shape_data[[nom_indicador]]))) stop("La variable a graficar no conté valors.")
  if(!(class(shape_data[[nom_indicador]]) %in% c("numeric", "double", "integer"))) stop("La variable a graficar ha de ser numèrica.")

  shape_data <- sf::st_transform(shape_data, crs = 4326)

  city_lat <- tidygeocoder::geo(ciutat)$lat[[1]]
  city_lng <- tidygeocoder::geo(ciutat)$long[[1]]

  pal <- leaflet::colorNumeric(palette = "YlOrRd",
                               domain = range(shape_data[[nom_indicador]], na.rm = T),
                               na.color = "grey90")

  leaflet::leaflet(data = shape_data) %>%
    leaflet::addTiles() %>%
    leaflet::setView(
      lng  = city_lng,
      lat  = city_lat,
      zoom = focus) %>%
    leaflet::addPolygons(
      fillColor   = ~leaflet::colorQuantile(
                                "YlOrRd",
                                 shape_data[[nom_indicador]]) (shape_data[[nom_indicador]]),
      fillOpacity = ~ifelse(is.na(shape_data[[nom_indicador]]), 0.95, 0.6),
      color       = "grey90",
      weight      = 1
    ) %>%
    leaflet::addLegend(
      pal     = pal, # for continuous
      values  = shape_data[[nom_indicador]],
      title   = nom_indicador,
      opacity = 1
    )

}
