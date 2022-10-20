#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @param AA_nm PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname pull_AA
#' @export
pull_AA <- function(df, AA_nm){
  # df <- DATASET
  # df <- label_TS_Nitrogen(df)
  # AA_nm <- "Phe"


  for(smp in unique(df$smp)){
    AA_Value <- df$Corrected_delta_15_N[df$smp == smp & df$AAs == AA_nm]
    df[df$smp == smp,AA_nm] <- AA_Value[!is.na(AA_Value)]

    SD_Value <- df$Stdev[df$smp == smp & df$AAs == AA_nm]
    df[df$smp == smp,paste0(AA_nm,"_SD")] <- SD_Value[!is.na(SD_Value)]

  }



  return(df)
}
