#-------------------------
#----ameli_data[2]
#-------------------------
# 
# na_rows <- ameli_data2[[2]] %>% filter(if_any(everything(), is.na))
# View(na_rows) 
# View(ameli_data2[[2]])

library(dplyr)

# 1️⃣ Fichier 2 : remplacer les NA dans densite
ameli_data2[[2]] <- ameli_data2[[2]] %>%
  mutate(densite = replace_na(densite, 0))

# Vérification
colSums(is.na(ameli_data2[[2]]))

#-------------------------
#----ameli_data[4]
#-------------------------

# na_rows <- ameli_data2[[4]] %>% filter(if_any(everything(), is.na))
# View(na_rows) 
# View(ameli_data2[[4]])

library(dplyr)

ameli_data2[[4]] <- ameli_data2[[4]] %>%
  mutate(
    patients_medecin_traitant_integer = replace_na(patients_medecin_traitant_integer, 0),
    patients_uniques_integer = replace_na(patients_uniques_integer, 0)
  )


# Vérification
colSums(is.na(ameli_data2[[4]]))