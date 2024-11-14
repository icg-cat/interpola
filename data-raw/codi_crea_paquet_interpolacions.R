# # # # # # # # # # # # # # # # # # # #
#    create package interpolacions    #
# # # # # # # # # # # # # # # # # # # #


# 0. setup ----------------------------------------------------------------
library("usethis")

usethis::use_mit_license("Irene Cruz Gómez")


# 1. Escriu i documenta funcions ------------------------------------------

# escriu funcions amb capçalera roxygen
## escriu codi de funcions a /R. una funció per script
## escriu roxygen fent: In RStudio, Code > Insert Roxygen Skeleton (Keyboard shortcut: Mac Shift+Option+Cmd+R , Windows/Linux Shift+Alt+Ctrl+R )

devtools::document()
devtools::check()

# 2. Adjunta i documenta datasets -----------------------------------------
# Document each data set with a roxygen block above the name of the data set in quotes.
# prep dataset en aquest arxiu: "data-raw/prep_dades_seccionat.R"

dir.create(path = here::here("data-raw/"))
SCdesti  <- readRDS("data-raw/241108_REFCAT_SC_ESPOB_2011-2023.RDS")

e1 <- openxlsx::read.xlsx("data-raw/Taxa d'atur_sc.xlsx", colNames = F)
names(e1) <- c("SECCIO", "taxa_atur")
e1$ANYO <- 2021
e1$seccionat <- 2021
e1 <- e1 %>%
  slice(1:100)

seccions <- c(e1$SECCIO, e2$SECCIO[!(e2$SECCIO %in% e1$SECCIO)][1])


e2 <- SCdesti %>%
  filter(SECCIO %in% seccions) %>%
  filter(ANYO == 2022) %>%
  select(ANYO, REFCAT, SECCIO, ESPOB2_hab)

ex_data <- list(indicador = e1, cad_AMB = e2)

usethis::use_data(SCdesti, ex_data,
                  overwrite = TRUE,
                  compress = "xz")


# documenta data.R
cat(
  paste0(
    "#' Taula de correspondències entre referències catastrals i seccions censals per anualitats. \n",
    "#' Inclou estimacions de població per parcel·la en base al nombre d'habitatges. Dades de 2011 fins a 2023, pel conjunt del territori de Catalunya. Darrera actualització el 28 del 10 de 2024. El procediment d'estimació de població per parcel·la es pot trobar aquí:  \n",
    "#' @format 1 Taula de correspondència entre parcel·les catastrals i seccions censals.  \n",
    "#' \\describe{  \n",
    "#'   \\item{ANYO}{Anualitat del seccionat}  \n",
    "#'   \\item{REFCAT}{codi de la referència catastral}  \n",
    "#'   \\item{SECCIO}{Codi de la secció censal}  \n",
    "#'   \\item{POBSC}{Població total de la secció censal (padró fins 2021)}  \n",
    "#'   \\item{ESPOB2_hab}{Estimació de població per parcel·la}  \n",
    "#'   \\item{codi_mun}{Codi del municipi}  \n",
    "#'   \\item{AMB}{Designa si el territori pertany a l'AMB}  \n",
    "#'   \\item{pc_ac}{Any de construcció (mitjana de la parcel·la)}  \n",
    "#'   \\item{COORX}{coordenades centroide parcel·la (X)}  \n",
    "#'   \\item{COORY}{coordenades centroide parcel·la (Y)}  \n",
    "#'   \\item{SUM_AREA}{superfície de la parcel·la}  \n",
    "#'   \\item{pc_Nhabitatges}{Nombre d'habitatges a la parcel·la}  \n",
    "#'   \\item{pc_sumSupfHab_utl}{suma de la superfície útils dels habitatges a la parcel·la}  \n",
    "#'   ...  \n",
    "#' }  \n",
    "#' @source \\url{} \n",
    "'SCdesti' \n",
    "\n",
    "\n"
  ),
  paste0(
    "#' Dades de joguina pels exemples \n",
    "#' inclou dos df: un indicador amb la taxa d'atur segons el cens i una submostra de les dades cadastrals del 2022 per l'AMB  \n",
    "#' @format 1 Named list amb dues taules  \n",
    "#' \\describe{  \n",
    "#'   \\item{indicador}{taula de dades d'atur}  \n",
    "#'   \\item{cad_AMB}{taula amb dades cadastre}  \n",
    "#'   ...  \n",
    "#' }  \n",
    "'ex_data' \n",
    "\n",
    "\n"
  ),
  file = "R/data.R")


# ignora directori raw-data
usethis::use_build_ignore(c("data-raw"))

devtools::document()

devtools::check()


# 3. dependències ---------------------------------------------------------


# specify package dependency:
usethis::use_package("dplyr")
usethis::use_package("magrittr")
usethis::use_package("janitor")
usethis::use_package("tidyselect")

# add pipe
usethis::use_pipe()  # step 1 ----
devtools::document() # step 2 ----



# 99. Notes ---------------------------------------------------------------

# per gestionar No visible bindig for global variable:
# he afegit .data davant de tots lazy eval
# he afegit utils::globalVariables(c("english", "temp")) al final de fesVars_14
# afegeixo utils a use_package



# 100. github repo --------------------------------------------------------

# creem un repo a GitHub a partir del projecte
usethis::use_git()
usethis::use_github()

# (Bonus) Step 6: Make the package a GitHub repo
# This isn’t a post about learning to use git and GitHub — for that I recommend Karl Broman’s Git/GitHub Guide. The benefit, however, to putting your package onto GitHub is that you can use the devtools install_github() function to install your new package directly from the GitHub page.

devtools::install_github('interpola','icg-cat')




# 98. Updates i versions --------------------------------------------------
# aquests canvis s'han de fer després de repo a github


# aplica canvis en la versió del paquet:
## major: changes that might break user's code
## minor: new functionality, but maintains compatibility
## patch: bug fixes
## dev: internal work development versions

usethis::use_version()
