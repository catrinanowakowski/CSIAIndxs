## code to prepare `DATASET` dataset goes here
DATASET <- read.csv(here::here("data-raw","cyno_fish_raw.csv" ))

usethis::use_data(DATASET, overwrite = TRUE)
