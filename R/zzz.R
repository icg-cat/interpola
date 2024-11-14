current_version <- packageVersion("interpola")

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "Gràcies per fer servir aquest paquet. L'heu de referenciar com segueix:\n\n",
    "Cruz-Gómez, Irene (2024). interpola. Eines per la interpolació de dades espacials. ",
    "Versió ", current_version[[1]],
    ". https://github.com/icg-cat/interpola")
}
