# Install devtools, if you haven't already.
#install.packages("devtools")
#library(devtools)
#install_github("anspiess/propagate")
#source("https://install-github.me/anspiess/propagate")

#################################################################
#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @param AA_src PARAM_DESCRIPTION, Default: 'Phe'
#' @param AA_trp PARAM_DESCRIPTION, Default: 'Glu'
#' @param Beta PARAM_DESCRIPTION, Default: 3.3
#' @param Beta_SD PARAM_DESCRIPTION, Default: 1.8
#' @param eq_TDF_n PARAM_DESCRIPTION, Default: 1
#' @param TDF1 PARAM_DESCRIPTION, Default: 7.6
#' @param TDF1_SD PARAM_DESCRIPTION, Default: 1.4
#' @param TDF2 PARAM_DESCRIPTION, Default: 5.5
#' @param TDF2_SD PARAM_DESCRIPTION, Default: 0
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname calc_TP
#' @export
calc_TP <- function(df,
                    AA_src = "Phe",
                    AA_trp = "Glu",
                    Beta = 3.3, # Non Vascular beta #. Ramirez et al 2021
                    Beta_SD = 1.8,
                    eq_TDF_n = 1, #2
                    TDF1 = 7.6, #copepod
                    TDF1_SD = 1.4, # Chikaraishi et al 2007
                    TDF2 = 5.5, #flying fish
                    TDF2_SD = 0){
  ############################################
  # ## test function inputs
  # df <- DATASET
  # df <- label_TS_Nitrogen(df)
  # df <- df[!is.na(df$AAs),]
  # AA_src <- "Phe"
  # AA_trp <- "Glu"
  # # primary, secondar, tertiary # from matts 2021 paper, he has a section that talks about pacific ocean and copepods
  # Beta <- 3.3 # Non Vascular beta
  # Beta_SD <- 1.8
  #
  # eq_TDF_n <- 3 #2
  #
  # TDF1 <- 7.6 #copepod
  # TDF1_SD <- 1.4 # Chikaraishi et al 2007
  # TDF2 <- 5.5 #flying fish
  # TDF2_SD <- 0
  ############################################
  # Load packages:
  require(propagate)
  require(dplyr)


  df <- df[!is.na(df$AAs),]
  mydata <- pull_AA(df, AA_nm = AA_src)
  mydata <- pull_AA(mydata, AA_nm = AA_trp)


  # grab just one row of data
  mydata <- mydata[mydata$AAs == AA_trp,]
  mydata <- mydata[!is.na(mydata$n),]

  if(eq_TDF_n == 1){
    # Single TDF Equation
    EXPR <- expression((AA_trp - AA_src - Beta)/TDF1 + 1)
  }else if(eq_TDF_n == 2){
    # Multi-TDF Equation
    EXPR <- expression((AA_trp - AA_src - TDF1 - Beta)/TDF2 + 2)
  }else if(eq_TDF_n == 3){
    #coral equation
    EXPR <- expression(( (AA_trp+offset) - AA_src - Beta)/TDF1 + 1)
  }


  # Get list of sample names
  smp_nms <- unique(mydata$smp)

  for(i in 1:length(smp_nms) ){

    if(eq_TDF_n == 1){
      DAT <- data.frame(
        AA_trp= c(mydata[mydata$smp == smp_nms[i],AA_trp], mydata[mydata$smp == smp_nms[i], paste0(AA_trp,"_SD")]),
        AA_src  = c(mydata[mydata$smp == smp_nms[i],AA_src], mydata[mydata$smp == smp_nms[i], paste0(AA_src,"_SD")]),
        Beta = c(Beta, Beta_SD),
        TDF1 = c(TDF1, TDF1_SD)  )
    }else if(eq_TDF_n == 2){
      DAT <- data.frame(
        AA_trp= c(mydata[mydata$smp == smp_nms[i],AA_trp], mydata[mydata$smp == smp_nms[i], paste0(AA_trp,"_SD")]),
        AA_src  = c(mydata[mydata$smp == smp_nms[i],AA_src], mydata[mydata$smp == smp_nms[i], paste0(AA_src,"_SD")]),
        Beta = c(Beta, Beta_SD),
        TDF1 = c(TDF1, TDF1_SD),
        TDF2 = c(TDF2,TDF2_SD )   )
    }else if(eq_TDF_n == 3){
      DAT <- data.frame(
        AA_trp= c(mydata[mydata$smp == smp_nms[i],AA_trp], mydata[mydata$smp == smp_nms[i], paste0(AA_trp,"_SD")]),
        offset = c(3.4, 0.1),
        AA_src  = c(mydata[mydata$smp == smp_nms[i],AA_src], mydata[mydata$smp == smp_nms[i], paste0(AA_src,"_SD")]),
        Beta = c(Beta, Beta_SD),
        TDF1 = c(TDF1, TDF1_SD)
        )
    }



    # Conduct uncertainty propagation using default settings (see `?propagate` for more options)
    res <- propagate(EXPR, as.matrix(DAT), second.order=FALSE, do.sim=TRUE, cov=TRUE, df=NULL,
                     nsim=10000, alpha=0.05)

    df$TP[df$smp == smp_nms[i]] <-         as.numeric(res$prop[1])
    df$TP_SD[df$smp == smp_nms[i]] <-      as.numeric(res$prop[3])
    df$TP_low2.5[df$smp == smp_nms[i]] <-  as.numeric(res$prop[5])
    df$TP_low97.5[df$smp == smp_nms[i]] <- as.numeric(res$prop[6])
  }

  return(df)

}



