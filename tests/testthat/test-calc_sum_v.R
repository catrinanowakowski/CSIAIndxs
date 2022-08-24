
context("run calc_sum_v with packaged dataset DATASET")

data("DATASET")

df <- try(calc_sum_v(df = label_TS_Nitrogen(DATASET)),
          silent = TRUE)

test_that("no error in calculating sum v", {

  expect_false(inherits(df, "try-error"))

})
