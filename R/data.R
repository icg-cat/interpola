#' Taula de correspondències entre referències catastrals i seccions censals per anualitats. 
#' Inclou estimacions de població per parcel·la en base al nombre d'habitatges. Dades de 2011 fins a 2023, pel conjunt del territori de Catalunya. Darrera actualització el 28 del 10 de 2024. El procediment d'estimació de població per parcel·la es pot trobar aquí:  
#' @format 1 Taula de correspondència entre parcel·les catastrals i seccions censals.  
#' \describe{  
#'   \item{ANYO}{Anualitat del seccionat}  
#'   \item{REFCAT}{codi de la referència catastral}  
#'   \item{SECCIO}{Codi de la secció censal}  
#'   \item{POBSC}{Població total de la secció censal (padró fins 2021)}  
#'   \item{ESPOB2_hab}{Estimació de població per parcel·la}  
#'   \item{codi_mun}{Codi del municipi}  
#'   \item{AMB}{Designa si el territori pertany a l'AMB}  
#'   \item{pc_ac}{Any de construcció (mitjana de la parcel·la)}  
#'   \item{COORX}{coordenades centroide parcel·la (X)}  
#'   \item{COORY}{coordenades centroide parcel·la (Y)}  
#'   \item{SUM_AREA}{superfície de la parcel·la}  
#'   \item{pc_Nhabitatges}{Nombre d'habitatges a la parcel·la}  
#'   \item{pc_sumSupfHab_utl}{suma de la superfície útils dels habitatges a la parcel·la}  
#'   ...  
#' }  
#' @source \url{} 
'SCdesti' 


 #' Dades de joguina pels exemples 
#' inclou dos df: un indicador amb la taxa d'atur segons el cens i una submostra de les dades cadastrals del 2022 per l'AMB  
#' @format 1 Named list amb dues taules  
#' \describe{  
#'   \item{indicador}{taula de dades d'atur}  
#'   \item{cad_AMB}{taula amb dades cadastre}  
#'   ...  
#' }  
'ex_data' 


