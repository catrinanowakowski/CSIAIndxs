#' @title label_TS_Nitrogen
#' @description factors your samples as tropic and source and plots to check data
#' @param df data frame formatted as "DATASET"
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  data("DATASET")
#'  label_TS_Nitrogen(df = DATASET)
#'  }
#' }
#' @seealso
#'  \code{\link[pacman]{p_load}}
#' @rdname label_TS_Nitrogen
#' @export
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 geom_point
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 theme_bw
label_TS_Nitrogen <- function(df){
  # df <- DATASET
  AAs <- Corrected_delta_15_N <- smp <- NULL

  order_AA <- data.frame(AA  = c("Ala", "Asp", "Glu", "Ile", "Leu", "Pro", "Val",  "Gly", "Lys", "Phe", "Ser", "Thr", "Tyr"),
                         type = c("T", "T",    "T",   "T",   "T",   "T",   "T",     "S",  "S",   "S",   "S",   "S",  "S"),
                         order = c(1,   2,      3,     4,     5,     6,     7,       8,    9,    10,    11,    12,    13 ) )

  df$AAs <- factor(df$AAs, levels = order_AA$AA)

  df$T_S <- NA
  df$T_S[df$AAs %in% c("Ala", "Asp", "Glu", "Ile", "Leu", "Pro", "Val")] <- "T"
  df$T_S[df$AAs %in% c( "Gly", "Lys", "Phe", "Ser", "Thr", "Tyr")] <- "S"

  plt <- ggplot() +
    ggplot2::geom_point(data = df, ggplot2::aes(x = AAs, y = Corrected_delta_15_N, color = as.factor(smp)), size = 3) +
    ggplot2::geom_point(data = df, ggplot2::aes(x = AAs, y = Corrected_delta_15_N, color = as.factor(smp)), shape = 15) +
    ggplot2::theme_bw()

  plot(plt)


  return(df)

}
