############################################
#
# Test script for Murty's algorithm
#
# Updated on 03/04/2019
#
############################################
context("get_k_best")

test_that("get_k_best functions as expected with data frames and matrices", {

  mat <- read.table(
      text = "0 5 99
  6 1 3
  7 4 2",
      header = FALSE)

  matTest <- muRty::get_k_best(mat, 5)
  expectedOutput <- list(solutions = list(structure(c(1, 0, 0, 0, 1, 0, 0, 0, 1), .Dim = c(3L,3L)),
                                          structure(c(1, 0, 0, 0, 0, 1, 0, 1, 0), .Dim = c(3L, 3L)),
                                          structure(c(0, 1, 0, 1, 0, 0, 0, 0, 1), .Dim = c(3L, 3L)),
                                          structure(c(0, 0, 1, 1, 0, 0, 0, 1, 0), .Dim = c(3L, 3L)),
                                          structure(c(0, 0, 1, 0, 1, 0, 1, 0, 0), .Dim = c(3L, 3L))),
                         costs = list(3L, 7L, 13L, 15L, 107L))

  expect_equal(matTest, expectedOutput)
  expect_warning(muRty::get_k_best(mat, 5), 
                 "You haven't provided an object of class matrix. Attempting to convert to matrix ..")

  matLarger <- as.matrix(
    read.table(
    text = "7	51	52	87	38	60	74	66	0	20
  50	12	0	64	8	53	0	46	76	42
  27	77	0	18	22	48	44	13	0	57
  62	0	3	8	5	6	14	0	26	39
  0	97	0	5	13	0	41	31	62	48
  79	68	0	0	15	12	17	47	35	43
  76	99	48	27	34	0	0	0	28	0
  0	20	9	27	46	15	84	19	3	24
  56	10	45	39	0	93	67	79	19	38
  27	0	39	53	46	24	69	46	23	1",
    header = FALSE
    )
  )
  
  attr(matLarger, "dimnames") <- NULL

  matSolLarger <- muRty::get_k_best(matLarger, 70)
  expectedOutput <- 12L

  expect_equal(length(matSolLarger$costs[matSolLarger$costs == 29]), expectedOutput)

})

test_that("get_k_best functions as expected with objective max and n_possible < k_best, no warning for n_possible == k_best", {
  
  mat <- read.table(
      text = "0 5 99
      6 1 3
      7 4 2",
      header = FALSE)
  
  matTest <- muRty::get_k_best(mat, 10, objective = 'max')
  matTest <- unlist(matTest$costs)
  expectedOutput <- c(109L, 107L, 15L, 13L, 7L, 3L)
  
  expect_equal(matTest, expectedOutput)

  expect_warning(muRty::get_k_best(mat, 10, objective = 'max'), 
                 paste0("There are only ", factorial(nrow(mat)), " possible solutions - terminating earlier.")
                 )
  
  expect_warning(muRty::get_k_best(as.matrix(mat), 6, objective = 'max'), regexp = NA)
  
})

test_that("get_k_best throws errors with 1x1 matrices, unequal dimensions, but no error for 2x2", {
  
  mat <- matrix(3, ncol = 1, nrow = 1)
  
  expect_error(
    muRty::get_k_best(mat, 2), 
    "Have you provided an empty set or matrix with only a single value? Your matrix should have at least 2 rows and 2 columns.", 
    fixed = TRUE
    )
  
  mat <- matrix(3, ncol = 5, nrow = 7)
  
  expect_error(
    muRty::get_k_best(mat, 2), 
    "Number of rows and number of columns are not equal. You need to provide a square matrix (N x N).", 
    fixed = TRUE
  )
  
  mat <- matrix(3, ncol = 2, nrow = 2)
  
  expect_error(muRty::get_k_best(mat, 1), regexp = NA)
  
})

test_that("by_rank argument functions as expected", {
  
  set.seed(1)
  
  mat <- matrix(sample.int(15, 10*10, TRUE), 10, 10)
  
  test_by_rank <- get_k_best(mat, k_best = 3, by_rank = TRUE)
  
  expectedOutput <- list(solutions = list(structure(c(0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 
                                                      0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                      0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 
                                                      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 
                                                      0, 0, 0, 0, 0, 0, 0), .Dim = c(10L, 10L)), list(structure(c(0, 
                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                  0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                  0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                  0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                  1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0), .Dim = c(10L, 10L
                                                                                                                  )), structure(c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 
                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 
                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                  0), .Dim = c(10L, 10L)), structure(c(0, 0, 0, 0, 1, 0, 0, 0, 
                                                                                                                                                                       0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                                                                       0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 
                                                                                                                                                                       0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                       0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 
                                                                                                                                                                       0, 0, 0, 0, 0, 0, 0, 0), .Dim = c(10L, 10L)), structure(c(0, 
                                                                                                                                                                                                                                 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0), .Dim = c(10L, 10L
                                                                                                                                                                                                                                 ))), structure(c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                  0), .Dim = c(10L, 10L))), costs = list(25, c(27L, 27L, 27L, 27L
                                                                                                                                                                                                                                                  ), 28L))
  expect_equal(test_by_rank, expectedOutput)
  
})

test_that("get_k_best functions as expected with matrices", {
  
  skip_on_cran()
  
  set.seed(1)
  
  mat <- matrix(sample.int(15, 10*10, TRUE), 10, 10)
  
  matTest <- muRty::get_k_best(mat, 35)
  matTest <- length(matTest$costs[matTest$costs == 31])
  
  expectedOutput <- 13L
  
  expect_equal(matTest, expectedOutput)
  
})