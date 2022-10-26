#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
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
  require(dplyr)
  require(propagate)
  smp <- sum_v <- NULL


  T_AAs <- unique(as.character(df$AAs[df$T_S == "T"]))
  T_AAs <- T_AAs[!is.na(T_AAs)]
  for(i in 1:length(T_AAs)){
    df <- pull_AA(df = df, AA_nm = T_AAs[i] )
  }

  df_smp <- df[df$AAs == "Glu",]
  df_smp <- df_smp[!is.na(df_smp$AAs),]
  trophic_names <- c("Ala", "Asp", "Glu", "Ile", "Leu", "Pro", "Val")

  smp_nms <- unique(df$smp)
  for(i in 1:length(smp_nms)){
    df_smp$T_mean[df_smp$smp == smp_nms[i]] <-mean( as.numeric(df_smp[df_smp$smp == smp_nms[i],names(df_smp)%in%trophic_names ]), na.rm = TRUE)
    df_smp$T_SD[df_smp$smp == smp_nms[i]] <-sd( as.numeric(df_smp[df_smp$smp == smp_nms[i],names(df_smp)%in%trophic_names ]), na.rm = TRUE)
    # df_smp$nT[df_smp$smp == smp_nms[i]] <-length( as.numeric(df_smp[df_smp$smp == smp_nms[i],names(df_smp)%in%trophic_names ]))
    # df_smp$nT_SD[df_smp$smp == smp_nms[i]] <- 0 ## Needed for format
  }


  for(i in 1:length(smp_nms) ){
    df_calc <- df_smp[df_smp$smp == smp_nms[i] ,]
    df_calc <- df_calc[,!is.na( df_calc[1,])]

    df_calc$nT <- length( as.numeric(df_calc[,names(df_calc)%in%trophic_names ]))
    df_calc$nT_SD <- 0 ## Needed for format


    T_smp_nms <- names(df_calc)[names(df_calc) %in% trophic_names]
    sum_txt <-paste0("(((",T_smp_nms," - T_mean)^2)^(1/2))",collapse="+")
    EXPR_char <- paste0("(",sum_txt,")/nT")
    EXPR <- str2expression(EXPR_char)


    df_calc <- df_smp[df_smp$smp == smp_nms[i] ,]
    values <- c(T_smp_nms, "T_mean", "nT")
    SDs <- c(paste0(T_smp_nms,"_SD"), "T_SD", "nT_SD")

    df_fmt <- df_calc[,names(df_calc) %in% values]
    df_fmt[2,] <- df_calc[,names(df_calc) %in% SDs]
    rownames(df_fmt) <- NULL

    res <- propagate(EXPR, as.matrix(df_fmt), second.order=FALSE, do.sim=TRUE, cov=TRUE, df=NULL,
                     nsim=10000, alpha=0.05)

    df$sum_v[df$smp == smp_nms[i]] <-         as.numeric(res$prop[1])
    df$sum_v_SD[df$smp == smp_nms[i]] <-      as.numeric(res$prop[3])
    df$sum_v_low2.5[df$smp == smp_nms[i]] <-  as.numeric(res$prop[5])
    df$sum_v_low97.5[df$smp == smp_nms[i]] <- as.numeric(res$prop[6])

  }



  df_agg <- aggregate(df[,c("sum_v", "sum_v_SD")], by = list(smp = df$smp), FUN = "mean")

  plt <- ggplot2::ggplot() +
    ggplot2::geom_point(data = df_agg, ggplot2::aes(x = smp, y = sum_v, color = smp), size = 3) +
    ggplot2::theme_bw()

  plot(plt)

  return(df)
}


