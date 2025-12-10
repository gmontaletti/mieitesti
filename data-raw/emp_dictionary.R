# 1. Generate emp_dictionary.rda -----
# Run this script to regenerate the employment topic dictionary

emp_dictionary <- list(
  match = c("mercat*", "denaro", "banc*", "stock*", "industr*",
            "impres*", "pil", "salar*", "pover*"),
  politica = c("sindacat*", "parlament*", "govern*", "partit*",
               "parlamentar*", "politic*", "legislator*", "region*"),
  pal = c("formazio*", "programm*", "garanz*", "cpi", "agenz*",
          "support*", "gol", "orientament*"),
  offerta = c("occupa*", "disoccupa*", "inattiv*", "classe et*",
              "forze", "lavor*", "ricerca lavor*", "offer*"),
  domanda = c("competenz*", "skil*", "bisogn*", "domand*",
              "settor*", "impres*", "dator*")
)

usethis::use_data(emp_dictionary, overwrite = TRUE)
