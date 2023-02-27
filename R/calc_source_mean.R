#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param id_col PARAM_DESCRIPTION
#' @param corrected_data_col PARAM_DESCRIPTION
#' @param data PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname calc_source_mean
#' @export
calc_source_mean <- function(id_col, corrected_data_col,std_col , data){
  # data <- df
  # id_col <- "smp"
  # corrected_data_col <- "Corrected_delta_15_N"
  # std_col <- "Stdev"

  # s_df <-data[data$T_S =="S",]
  s_df <-data[data$AAs %in% c("Lys", "Phe","Ser","Gly"),]
  s_df <-aggregate(s_df[, corrected_data_col], by = list(id_col = s_df[,id_col]), FUN = "mean", na.rm = TRUE)
  names(s_df) <- c(id_col, "S_mean")
  s_df$S_mean_sd <- NA


  # s_df_forsd <-data[data$T_S =="S",]
  s_df_forsd <-data[data$AAs %in% c("Lys", "Phe"),]
  ids <- unique(data[,id_col])
  for(i in 1:length(ids) ){
    # i <- 1
    sds <- s_df_forsd[s_df_forsd[,id_col] == ids[i],std_col]
    sds <- sds[!is.na(sds)]
    s_df$S_mean_sd[s_df[,id_col] == ids[i]] <- sqrt(sum(sds^2))/2
  }


  data <- merge(data, s_df, by = c(id_col), all = TRUE)
  return(data)

}


