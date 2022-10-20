# Install devtools, if you haven't already.
#install.packages("devtools")
#library(devtools)
#install_github("anspiess/propagate")
#source("https://install-github.me/anspiess/propagate")

#################################################################

# Load packages:
require(propagate)
require(dplyr)

 # df <- DATASET
  # df <- label_TS_Nitrogen(df)

# Load data:
mydata <- read.csv("Ei_prop_error.csv")

# Define TDF and Beta values:

# TDFs from Lemons et al. 2020 (green turtle skin), Betas from Ramirez et al. 2021
# (Beta, Beta_SD, TDF2, TDF2_SD, TDF1, TDF1_SD)

parms_glu_phe <- c(3.3, 1.8, 4.0, 0.5, 0, 0) # Glu-Phe
parms_tr_sr <- c(2.7, 3.0, 4.8, 0.7, 0, 0) # Weighted mean Tr (Ala,Val,Leu,Ile,Pro,Glu) - Sr (Phe,Lys) AAs

# Expression for which to propagate error:

# Single TDF Equations
EXPR1 <- expression((Glu - Phe - Beta)/TDF + 1)
EXPR2 <- expression((Tr - Sr - Beta)/TDF + 1)

# Multi-TDF Equations
EXPR1.2 <- expression((Glu - Phe - TDF1 - Beta)/TDF2 + 2)
EXPR2.2 <- expression((Tr - Sr - TDF1 - Beta)/TDF2 + 2)


propResults <- lapply(1:nrow(mydata), function(i){
  # For each row in the dataframe, i.e. for each individual, make a data.frame with the individual's values
  # in the first row and the error in the second.
  #
  # (This is a slightly non-intuitive format, but it is what `propagate` expects).
  # See `?propagate` for more info
  DAT <- data.frame(
    Tr  = c(mydata[i,"Tr"], mydata[i, "TrSD"]),
    Sr  = c(mydata[i,"Sr"], mydata[i, "SrSD"]),
    Beta = c(parms_tr_sr[1],parms_tr_sr[2]),
    #TDF  = c(parms_tr_sr[3],parms_tr_sr[4]) #,
    TDF2  = c(parms_tr_sr[3],parms_tr_sr[4]),    # 2nd+ trophic transfer
    TDF1  = c(parms_tr_sr[5],parms_tr_sr[6])     # 1st trophic transfer
  )

  # Conduct uncertainty propagation using default settings (see `?propagate` for more options)
  #res <- propagate::propagate(EXPR1, as.matrix(DAT))
  res <- propagate(EXPR2.2, as.matrix(DAT), second.order=FALSE, do.sim=TRUE, cov=TRUE, df=NULL,
                   nsim=1000000, alpha=0.05)

  # Output the results from the uncertainty propagation for that individual, bound to the original data.frame columns:
  propResults_stitched <- cbind( mydata[i, ], rbind(res$prop) )

  # Change the names of min and max CI's (`2.5%` and `97.5%` are bad column names!)
  names(propResults_stitched)[
    {ncol(propResults_stitched)-1}:ncol(propResults_stitched)
    ] <- c("CImin", "CImax")
  return(propResults_stitched)
})

# Finally, put back as a data.frame.
#propResults_ts_single <- dplyr::bind_rows(propResults)
#write.csv(propResults_ts_single, "propResults_ts_single.csv")

propResults_ts_mult <- dplyr::bind_rows(propResults)
write.csv(propResults_ts_mult, "propResults_ts_mult.csv")

