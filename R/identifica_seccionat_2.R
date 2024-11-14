#' Identifica seccionat de les dades d'origen
#'
#' @param indicador conjunt de dades que ha passat per la fase 1
#'
#' @return cadena de text amb l'any de l'edició que té el màxim número de matches, i missatge de text amb el número de matches
#' @export
#'
#' @examples
#' data(ex_data, package = "interpola")
#' identifica_seccionat_2(ex_data$indicador)
identifica_seccionat_2 <- function(indicador){
 # browser()
  dl <- SCdesti %>%
    dplyr::select(ANYO, SECCIO) %>%
    split(., as.factor(SCdesti$ANYO))

  xx <- lapply(dl, function(x){
    sum(indicador$SECCIO %in% x$SECCIO)
  })

  ed <- names(which(xx == max(unlist(xx))))

  message(paste0("L'edició amb el màxim nombre de coincidències (",
                 paste0(ed, collapse = "//"),
                 ") ",
                "conté ",
                 max(unlist(xx)),
                 " de ",
                 length(unique(indicador$SECCIO)),
                 " seccions."
                 ))

  if(length(ed) > 1) message("Atenció: més d'una edició conté el màxim de coincidències. per defecte es proporciona l'edició més recent")

  return(rev(ed)[[1]])

}
