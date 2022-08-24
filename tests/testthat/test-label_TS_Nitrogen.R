context("run label_TS_Nitrogen with packaged dataset DATASET")

data("DATASET")

df <- try(label_TS_Nitrogen(df = DATASET),
           silent = TRUE)

test_that("no error in sorting Trophic and source amino acids", {

  expect_false(inherits(df, "try-error"))

})
