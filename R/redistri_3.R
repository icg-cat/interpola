#' Redistribueix dades d'una secció censal a una altra
#'
#' @description
#' Aquesta és una de les versions possibles per la funció de redistribució de dades. A partir d'un seccionat d'origen, redistribueix les dades d'un indicador a un altre seccionat de destí. S'enten que els seccionats d'origen i destí fan referència al mateix territori però pertanyen a edicions diferents. La redistribució es fa passant les dades al nivell de parcel·la i reagrupant-les posteriorment amb el nou seccionat. Les dades a nivell de parcel·la sel's assigna un pes del seccionat d'origen. Aquest pes pot ser poblacional o d'habitatges, i cal especificar-ho entre els arguments de la funció.
#'
#' @param indicador dades a interpolar
#' @param seccionat_origen cadena de text que descrigui l'any del seccionat d'origen
#' @param seccionat_desti cadena de text que descrigui l'any del seccionat de destí
#' @param pes cadena de text que descrigui si el pes ha de ser per persones o per habitatges
#'
#' @return tibble amb dades redistribuides en el seccionat de destí
#'
#' @examples
#' data(ex_data, package = "interpola")
#' redistri_sc_3(ex_data$indicador, "2021", "2023", "persones")
redistri_sc_3 <- function(indicador, seccionat_origen, seccionat_desti, pes){

  if(!(pes %in% c("persones", "habitatges"))) stop("Error: l'argument 'pes' ha de ser 'persones' o 'habitatges'")

  # prepara objectes
  myvars <- setdiff(names(indicador), c("SECCIO", "ANYO", "REFCAT"))

  # prepara dades destí
  desti <- SCdesti %>%
    dplyr::filter(ANYO == as.numeric(seccionat_desti)) %>%
    dplyr::select(ANYO, REFCAT, SECCIO, ESPOB2_hab, pc_Nhabitatges)

  # prepara dades origen
  origen <- SCdesti %>%
    dplyr::filter(ANYO == as.numeric(seccionat_origen)) %>%
    dplyr::select(ANYO, REFCAT, SECCIO, ESPOB2_hab, pc_Nhabitatges) %>%
    dplyr::group_by(SECCIO, ANYO) %>%
    dplyr::mutate(
      TT_pob_sc = sum(ESPOB2_hab, na.rm = T),
      TT_hab_sc = sum(pc_Nhabitatges, na.rm = T),
      pes_pob = ESPOB2_hab/TT_pob_sc,
      pes_hab = pc_Nhabitatges/TT_hab_sc,
      pes = case_when(
        pes == "persones" ~ pes_pob,
        pes == "habitatges" ~ pes_hab
                      )
    ) %>%
    dplyr::ungroup(.) %>%
    dplyr::select(-c(TT_pob_sc, TT_hab_sc))

  # trasllada dades
    origen[, myvars] <- indicador[match(origen$SECCIO, indicador$SECCIO), myvars]
    desti[, c(myvars, "pes")] <- origen[match(desti$REFCAT, origen$REFCAT), c(myvars, "pes")]
    rm("indicador", "origen")

  # reagrupa per secció de destí segons pes d'origen
  desti <- desti %>%
    dplyr::group_by(SECCIO, ANYO) %>%
    dplyr::summarise(across(myvars, ~sum(as.numeric(.x)*.data$pes, na.rm = T), .names = "SC_{.col}")) %>%
    dplyr::ungroup() %>%
    dplyr::filter(SECCIO %in% origen$SECCIO)

  return(desti)

}
