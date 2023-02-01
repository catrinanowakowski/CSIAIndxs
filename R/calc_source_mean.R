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
calc_source_mean <- function(id_col, corrected_data_col, data){
  # data <- df
  # id_col <- "smp"
  # corrected_data_col <- "Corrected_delta_15_N"

  s_df <-data[data$T_S =="S",]
  s_df <-aggregate(s_df[, corrected_data_col], by = list(id_col = s_df[,id_col]), FUN = "mean", na.rm = TRUE)
  names(s_df) <- c(id_col, "S_mean")

  data <- merge(data, s_df, by = c(id_col), all = TRUE)
  return(data)

}


