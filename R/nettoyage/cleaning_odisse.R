#-------------------------
#----odissedata[1]
#-------------------------
library(dplyr)

#correction de la corse pour odisse[1]
odisse_data2[[1]] <- odisse_data2[[1]] %>%
  mutate(
    departement = ifelse(
      is.na(departement) & departement_code == 20,
      "Corse",
      departement
    ),
    region = ifelse(
      is.na(region) & departement_code == 20,
      "Corse",
      region
    ),
    region_code = ifelse(
      is.na(region_code) & departement_code == 20,
      94,
      region_code
    )
  )

#suppression de la ligne avec NA non justifié

odisse_data2[[1]] <- odisse_data2[[1]][-which(rowSums(is.na(odisse_data2[[1]])) > 0), ]

#vérification du nettoyage
which(rowSums(is.na(odisse_data2[[1]])) > 0)


#-------------------------
#----odissedata[5]
#-------------------------

# na_rows <- odisse_data2[[5]] %>% filter(if_any(everything(), is.na))
# View(na_rows) 
# View(odisse_data2[[5]])

#correction de la corse 

#correction de la corse pour odisse[1]
odisse_data2[[5]] <- odisse_data2[[5]] %>%
  mutate(
    departement = ifelse(
      is.na(departement) & departement_code == 20,
      "Corse",
      departement
    ),
    region = ifelse(
      is.na(region) & departement_code == 20,
      "Corse",
      region
    ),
    region_code = ifelse(
      is.na(region_code) & departement_code == 20,
      94,
      region_code
    )
  )

# vérification

which(rowSums(is.na(odisse_data2[[5]])) > 0)



#-------------------------
#----odissedata[2]
#-------------------------

# na_rows <- odisse_data2[[2]] %>% filter(if_any(everything(), is.na))
# View(na_rows) 
# View(odisse_data2[[2]])

#remplacement des NA du taux par 0 pour ne pas fausser les calculs en les ignorant

odisse_data2[[2]] <- odisse_data2[[2]] %>%
  mutate(across(
    starts_with("taux_"),
    ~ replace_na(., 0)
  ))

# vérification

which(rowSums(is.na(odisse_data2[[2]])) > 0)


#-------------------------
#----odissedata[6]
#-------------------------

# na_rows <- odisse_data2[[6]] %>% filter(if_any(everything(), is.na))
# View(na_rows) 
# View(odisse_data2[[6]])

#on conserve les NA car il s'agit d'une abscence du calcul la valeur n'est pas de 0 

# correction des codes region en double

odisse_data2[[6]] <- odisse_data2[[6]] %>%
  filter(nchar(region_code) > 1)



# vérification

which(rowSums(is.na(odisse_data2[[6]])) > 0)



#-------------------------
#----odissedata[11]
#-------------------------

# na_rows <- odisse_data2[[11]] %>% filter(if_any(everything(), is.na))
# View(na_rows) 
# View(odisse_data2[[11]])


#remplacement des NA du taux par 0 pour ne pas fausser les calculs en les ignorant

odisse_data2[[11]] <- odisse_data2[[11]] %>%
  mutate(across(
    starts_with("taux_"),
    ~ replace_na(., 0)
  ))

# vérification

which(rowSums(is.na(odisse_data2[[11]])) > 0)



# --- Forcer l'affichage des codes région sur 2 chiffres 
  
  odisse_data2 <- lapply(odisse_data2, function(df) {
    if ("region_code" %in% names(df)) {
      df <- df %>%
        mutate(region_code = sprintf("%02d", as.integer(region_code))) %>%
        distinct() %>%
        filter(nchar(region_code) > 1)
    }
    return(df)
  })

