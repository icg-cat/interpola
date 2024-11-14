#' estandarditza raw data en format long
#' @param description Estandarditza les dades d'origen en format long i dona noms consistents a les variables. Els arxius de dades es llegeixen fora d'aquesta funció.
#' @param indicador data frame o tibble que conté dadesd'inici, i que ha de contenir l'any de referència de les dades, les seccions censals i com a mínim una variable més amb la variable de referència.
#' @param grep_edicio expressió regular per identificar el nom de la variable que designa les edicions
#' @param grep_seccions expressió regular per identificar el nom de la variable que designa les seccions censals
#'
#' @return tibble en format long
#'
#' @examples
#' data(ex_data, package = "interpola")
#' estandarditza_1(ex_data$indicador, "ANYO", "SECCIO$")
estandarditza_1 <- function(indicador, grep_edicio, grep_seccio){
    # crec que més que estandarditzar, el que ha de fer aquest pas és verificar que hi hagi un format estàndard per les dades?
    # assumeixo que llegir els arxius es fa fora.
    # el tractament aquí aplicat rep els fulls d'indicadors un per un, de la font que sigui que s'han descarregat

  nom_edicio <- names(indicador)[grep(grep_edicio, names(indicador), ignore.case = T)]
  nom_seccio <- names(indicador)[grep(grep_seccio, names(indicador), ignore.case = T)]

  if(length(nom_seccio) > 1 | length(nom_edicio) > 1) stop("més d'una variable concideix amb la cadena proporcionada")

  altres <- setdiff(names(indicador), c(nom_edicio, nom_seccio))

  selecciona <- c(
    ANYO = nom_edicio,
    SECCIO = nom_seccio,
    altres
  )

  indicador %>%
    # estandarditza noms de variables
    dplyr::select(tidyselect::all_of(selecciona)) %>%
    # elimina files i columnes buides
    janitor::remove_empty(c("rows", "cols")) %>%
    mutate(
      SECCIO = as.character(SECCIO)
    )


}
