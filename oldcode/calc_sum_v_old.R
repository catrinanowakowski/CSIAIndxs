#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'    df <- DATASET
#'    df <- label_TS_Nitrogen(df)
#'    df <- calc_sum_v(df)
#'  }
#' }
#' @seealso
#'  \code{\link[ggplot2]{ggplot}},\code{\link[ggplot2]{geom_point}},\code{\link[ggplot2]{aes}},\code{\link[ggplot2]{ggtheme}}
#' @rdname calc_sum_v
#' @export
#' @importFrom ggplot2 ggplot geom_point aes theme_bw
calc_sum_v <- function(df){
  # df <- DATASET
  # df <- label_TS_Nitrogen(df)
  smp <- sum_v <- NULL


  df$T_mean <- NA
  df$sum_v_sd <- NA
  df$sum_v <- NA

  smp_lst <- unique(df$smp)
  for(i in 1:length(smp_lst)){
    df$T_mean[df$smp == smp_lst[i]] <- mean(df$Corrected_delta_15_N[df$smp == smp_lst[i] & df$T_S == "T"], na.rm = TRUE)
    df$sum_v_sd[df$smp == smp_lst[i]]   <- sqrt(sum((df$Stdev[df$smp == smp_lst[i] & df$T_S == "T"])^2, na.rm = TRUE))
    df$sum_v[df$smp == smp_lst[i]]  <- sum(abs(df$T_mean[df$smp == smp_lst[i] & df$T_S == "T"]-df$Corrected_delta_15_N[df$smp == smp_lst[i] & df$T_S == "T"]), na.rm = TRUE)/(nrow(df[df$smp == smp_lst[i] & df$T_S == "T",]))
  }


  df_agg <- aggregate(df[,c("sum_v", "sum_v_sd")], by = list(smp = df$smp), FUN = "mean")

  plt <- ggplot2::ggplot() +
    ggplot2::geom_point(data = df_agg, ggplot2::aes(x = smp, y = sum_v, color = smp), size = 3) +
    ggplot2::theme_bw()

  plot(plt)

  return(df)
}


