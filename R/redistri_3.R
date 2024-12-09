#' Redistribueix dades d'una secció censal a una altra
#'
#' @description
#' Aquesta és una de les versions possibles per la funció de redistribució de dades. A partir d'un seccionat d'origen, redistribueix les dades d'un indicador a un altre seccionat de destí. S'enten que els seccionats d'origen i destí fan referència al mateix territori però pertanyen a edicions diferents. Es suposa també que l'indicador inicial informa les dades de l'any del seccionat de destí, però s'organitzen amb el seccionat d'origen. Per exemple, dades de salut de 2021, amb seccionat de 2011, es volen passar a seccionat de 2021. La redistribució es fa passant les dades al nivell de parcel·la i reagrupant-les posteriorment amb el nou seccionat. Les dades a nivell de parcel·la sel's assigna un pes del seccionat de destí (sota el benentès que s'ha de correspondre la distribució de població amb l'indicador que s'informa). Aquest pes pot ser poblacional o d'habitatges, i cal especificar-ho entre els arguments de la funció.
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

  # prepara dades intermedies
  intermedies <- SCdesti %>%
    dplyr::filter(ANYO == as.numeric(seccionat_origen)) %>%
    dplyr::select(ANYO, REFCAT, SECCIO, ESPOB2_hab, pc_Nhabitatges)%>%
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

  ## punts de control
  xx <- intermedies %>% filter(SECCIO %in% indicador$SECCIO)
  n_refcat_ini <- length(unique(xx$REFCAT))

  # prepara dades de destí
  desti <- SCdesti %>%
    dplyr::filter(ANYO == as.numeric(seccionat_desti)) %>%
    dplyr::select(ANYO, REFCAT, SECCIO, ESPOB2_hab)

  # punts de control
  x1 <- intermedies %>%
    filter(SECCIO %in% indicador$SECCIO)
  SCfinals <- desti %>%
    filter(REFCAT %in% x1$REFCAT) %>%
    pull(SECCIO) %>% unique()

  yy <- desti %>% filter(SECCIO %in% SCfinals)
  n_refcat_fin <- length(unique(yy$REFCAT))

  # trasllada dades
  ## 1. variables de l'indicador d'origen a REFCATS intermedies, by SECCIO
  intermedies[,myvars] <- indicador[match(intermedies$SECCIO, indicador$SECCIO), myvars]

  ## 2. variables del conjunt intermedi i pes al conjunt de destí, by REFCAT
  desti[,c(myvars, "pes")] <- intermedies[match(desti$REFCAT, intermedies$REFCAT), c(myvars, "pes")]

  ## 3. redistribueix variables de nivell SECCIO a nivell REFCAT amb pesos
  ## 4. agrega i reagrupa per SECCIO de destí
  desti2 <- desti %>%
    dplyr::group_by(SECCIO, ANYO) %>%
    dplyr::summarise(across(myvars, ~sum(as.numeric(.x)*.data$pes, na.rm = T), .names = "SC_{.col}")) %>%
    dplyr::ungroup() %>%
    dplyr::filter(SECCIO %in% SCfinals)

  # Checks de qualitat
  ## 1. compara nº seccions origen i destí
  if(length(desti$SECCIO) != length(indicador$SECCIO)){print("Atenció, no coincideix el nombre de seccions d'origen i destí")}
  ## 2. compara suma poblacions origen i destí: Aquesta comparació no té sentit. La trec
  # if(pob_ini != pob_fin) {print(paste0("Atenció, no coincideix la N poblacional inicial i final. La inicial és ", pob_ini, ", i la final és ", pob_fin))}

  ## 3. compara nombre de referències catastrals
  if(n_refcat_ini != n_refcat_fin) {print(paste0("Atenció, no coincideix el nombre de referències catastrals inicial i final. La inicial és ", n_refcat_ini, ", i la final és ", n_refcat_fin))}

  # origen[, myvars] <- indicador[match(origen$SECCIO, indicador$SECCIO), myvars]
  # desti[, c(myvars, "pes")] <- origen[match(desti$REFCAT, origen$REFCAT), c(myvars, "pes")]
  # rm("indicador", "origen")
  # # reagrupa per secció de destí segons pes d'origen

  return(desti2)

}
