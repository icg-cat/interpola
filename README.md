# "Package interpola - vignette"
**Irene Cruz**
**20-11-24**

# Presentació

El paquet `interpola` simplifica un seguit de tasques per la interpolació espacial de dades d'indicadors informats al nivell de la secció censal. En la seva versió actual (1.0.0, el paquet consta de 3 funcions:

* estandarditza_1(): funció per estandarditzar les dades inicials a un format que es pugui integrar posteriorment amb les dades catastrals, que són les que permeten dividir i reagrupar en altres divisions territorials
* identifica_seccionat_2(): funció que identifica l'any de seccionat de les dades inicials (que no té per què coincidir amb l'any dels indicadors informats)
* redistri_sc_3(): funció que redistribueix els indicadors d'un seccionat a un altre, ponderant per individus o per nombre d'habitatges. 

🙈: *En la versió pública del paquet (GitHub) no s'inclou la taula amb la correspondència entre parcel·les i seccions, estimacions de la població i recompte del nombre d'habitatges entre 2011 i 2023, que sí s'inclou al repositori local del paquet. Les dades d'aquesta taula s'estructuren igual que a la sub-mostra de les dades d'exemple, anomenades cad_AMB.* 

L'estat de desenvolupament actual del paquet es resumeix en aquest diagrama de procés: 
![flow](https://github.com/user-attachments/assets/b8b98059-60be-4e93-9ad8-ace6e612cc9c)

# Exemples d'ús

Posem per cas que tenim unes dades sobre mercat de treball corresponents a l'any 2021. Les tenim informades per secció censal. En aquest exemple més simple, l'any de l'indicador (taxa d'atur) i l'any del seccionat coincideixen (2021), però podria no ser el cas. Suposem que, per motius analítics, necessitem interpolar aquest indicador al seccionat de l'any 2011 (i així integrar-lo en una base pre-existent que fa servir aquest seccionat). Farem servir les dades de mostra contingudes al paquet per il·lustrar el procediment. 

Primer carreguem les dades d'exemple, que es troben en format de llista, i contenen tres conjunts diferents: 

* `indicador`: conté una taula amb la taxa d'atur informada per una submostra de seccions censals. Serveix també d'exemple del format (long) que cal fer servir pel procediment, on hi haurà un mínim de tres columnes o variables, sent una el seccionat, una altra l'any pel qual s'informa l'indicador, i una tercera l'indicador. 
* `cad_AMB`: conté una taula amb una submostra de parcel·les catastrals de les seccions contingudes al primer conjunt de dades. El paquet conté un conjunt de dades de mostra, consistent en la correspondència entre parcel·les catastrals i seccions censals, així com estimacions de població i nombre d'habitatges per parcel·la, pels anys 2011 i per l'interval de 2015 a 2023. Aquesta taula no està inclosa en la versió pública del paquet (a GitHub), però està inclosa a la versió local del paquet. 
* `shapes`: conté una taula amb les geometries que permeten mapejar les seccions censals contingudes a les dues taules anteriors. 

Carreguem la llista de conjunts de dades:

``` r
data("ex_data", package = "interpola")
```

En un primer pas, podem preparar les dades d'input (l'indicador), donant a les variables noms consistents (que caldrà pel pas següent). 

* `grep_edicio`: expressió regular que ha de permetre identificar de manera única la variable que designa l'any de la dada informada o indicador. Aquesta variable passarà a dir-se "ANYO"
* `grep_seccio`: expressió regular que ha de permetre identificar de manera única la variable que designa el codi de secció censal. Aquesta variable passarà a dir-se "SECCIO"

El resultat és un dataframe amb l'indicador inicial, amb els noms estandarditzats, i sense files ni columnes buides. Altres tractaments de depuració o reestructuració de dades que puguin necessitar-se s'han de fer a banda d'aquesta funció. 


``` r
d1 <- interpola::estandarditza_1(
  indicador = ex_data$indicador, 
  grep_edicio = "edicio", 
  grep_seccio = "sc_")

head(d1)
```

```
##   ANYO     SECCIO          taxa_atur
## 1 2021 0800101001 8.4388185654008439
## 2 2021 0800101002 14.492753623188406
## 3 2021 0800101003 5.3527980535279802
## 4 2021 0800101004 9.6267190569744603
## 5 2021 0800101005 10.672853828306264
## 6 2021 0800101007 10.588235294117647
```


En un segon pas, identificarem el seccionat d'origen de l'indicador. Aquest pas respon al fet que sovint les dades porten informada una columna amb l'any de referència de l'indicador, i aquest no necessita correspondre's amb l'any del seccionat. D'altra banda, l'any del seccionat a vegades està informat al nom de la variable de la secció censal, però a efectes d'automatitzar processos, necessitem donar un nom uniforme a les variables de seccionat. En qualsevol cas, aquest pas és opcional. 


``` r
(seccionat_origen <- interpola::identifica_seccionat_2(d1))
```

```
## [1] "2023"
```

En darrer lloc, aplicarem la interpolació espacial de les dades. Perquè l'indicador informa una dada poblacional, farem servir la ponderació de distribució que té en compte les persones per parcel·la, en lloc del nombre d'habitatges. 


``` r
res <- interpola::redistri_sc_3(indicador = d1, 
                                seccionat_origen = seccionat_origen, 
                                seccionat_desti = "2011", 
                                pes = "persones")
```

```
## [1] "Atenció, no coincideix el nombre de seccions d'origen i destí"
## [1] "Atenció, no coincideix el nombre de referències catastrals inicial i final. La inicial és 25095, i la final és 26345"
```

El procés aplica una sèrie de controls de qualitat sobre els resultats i genera avisos. Aquests no són missatges d'error, sinó que ens avisen i hem de valorar nosaltres si cal que apliquem cap revisió adicional. 

L'objecte `res` conté els resultats d'interpolar les dades de la taxa d'atur de 2021 al seccionat de 2011. 

# Mapejar els resultats

Revisem els resultats obtinguts. Primer hem de preparar les dades. Agafem la mostra de shapefile de les dades d'exemple, i li agreguem les dades interpolades. 

El paquet conté una funció que ens facilitarà visualitzar els resultats: `fes_mapa()`

``` r
sp <- ex_data$shapes %>% 
  mutate(
    Tatur = res$SC_taxa_atur[match(ex_data$shapes$Sc2021, res$SECCIO)]
  )
```



``` r
fes_mapa(shape_data = sp, nom_indicador = "Tatur", ciutat = "Badalona", focus = 14)
```
![mapa](https://github.com/user-attachments/assets/8d8866e4-dd73-44b9-adc2-c951aa763cd7)








