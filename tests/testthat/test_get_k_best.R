############################################
#
# Test script for Murty's algorithm
#
# Updated on 28/04/2019
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
  expectedOutput1 <- list(solutions = list(structure(c(1, 0, 0, 0, 1, 0, 0, 0, 1), .Dim = c(3L,3L)),
                                          structure(c(1, 0, 0, 0, 0, 1, 0, 1, 0), .Dim = c(3L, 3L)),
                                          structure(c(0, 1, 0, 1, 0, 0, 0, 0, 1), .Dim = c(3L, 3L)),
                                          structure(c(0, 0, 1, 1, 0, 0, 0, 1, 0), .Dim = c(3L, 3L)),
                                          structure(c(0, 0, 1, 0, 1, 0, 1, 0, 0), .Dim = c(3L, 3L))),
                         costs = list(3, 7, 13, 15, 107))

  expect_equal(matTest, expectedOutput1)
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
  expectedOutput2 <- 12L

  expect_equal(length(matSolLarger$costs[matSolLarger$costs == 29]), expectedOutput2)

})

test_that("get_k_best functions as expected with objective max and n_possible < k_best, no warning for n_possible == k_best", {
  
  mat <- read.table(
      text = "0 5 99
      6 1 3
      7 4 2",
      header = FALSE)
  
  matTest <- muRty::get_k_best(mat, 10, objective = 'max')
  matTest <- unlist(matTest$costs)
  expectedOutput3 <- c(109, 107, 15, 13, 7, 3)
  
  expect_equal(matTest, expectedOutput3)

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
  
  mat <- structure(c(9L, 4L, 7L, 1L, 2L, 13L, 7L, 11L, 14L, 2L, 11L, 3L, 
                     1L, 5L, 5L, 10L, 6L, 14L, 10L, 7L, 9L, 15L, 5L, 5L, 9L, 9L, 14L, 
                     5L, 5L, 2L, 10L, 14L, 9L, 12L, 15L, 1L, 4L, 3L, 6L, 10L, 10L, 
                     6L, 15L, 4L, 12L, 4L, 10L, 12L, 9L, 7L, 6L, 9L, 8L, 12L, 9L, 
                     7L, 8L, 6L, 10L, 7L, 3L, 10L, 6L, 8L, 14L, 2L, 13L, 2L, 6L, 14L, 
                     6L, 1L, 3L, 3L, 8L, 6L, 7L, 15L, 12L, 6L, 8L, 7L, 11L, 1L, 4L, 
                     13L, 8L, 9L, 9L, 7L, 14L, 4L, 7L, 13L, 13L, 12L, 6L, 13L, 12L, 
                     12L), .Dim = c(10L, 10L))
  
  test_by_rank <- muRty::get_k_best(mat, k_best = 3, by_rank = TRUE)
  
  expectedOutput4 <- list(solutions = list(list(structure(c(0, 0, 0, 0, 1, 0, 0, 0, 
                                                            0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                            1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 
                                                            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                            0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L)), structure(c(0, 
                                                                                                                      0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                      0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                      0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                      0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 
                                                                                                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L
                                                                                                                      ))), list(structure(c(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                                                                                                            0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                            0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                                                                                                            0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                            0, 0, 0), .Dim = c(10L, 10L)), structure(c(0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                       0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                       0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                                                                                                                                                       0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 
                                                                                                                                                                                       0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                                                                                       0, 0, 0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L)), structure(c(0, 
                                                                                                                                                                                                                                                       0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                       0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                       0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                       0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 
                                                                                                                                                                                                                                                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L
                                                                                                                                                                                                                                                       )), structure(c(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                                                                                                                                                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                       0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                                       0), .Dim = c(10L, 10L)), structure(c(0, 0, 0, 0, 1, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                            1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 
                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L))), list(structure(c(0, 
                                                                                                                                                                                                                                                                                                                                                                            0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                            0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 
                                                                                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L
                                                                                                                                                                                                                                                                                                                                                                            )), structure(c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                            1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                            0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                            0), .Dim = c(10L, 10L)), structure(c(0, 0, 0, 0, 1, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                                                                                                                                                                                                                                                                                                                 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                 0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L)), structure(c(0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           )), structure(c(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0), .Dim = c(10L, 10L)), structure(c(0, 0, 0, 0, 1, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L)), structure(c(0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0), .Dim = c(10L, 10L
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          )))), costs = list(c(31, 31), c(32, 32, 32, 32, 32), c(33, 33, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 33, 33, 33, 33, 33)))
  expect_equal(test_by_rank, expectedOutput4)
  
})

test_that("get_k_best functions as expected with matrices", {
  
  mat <- structure(c(9L, 4L, 7L, 1L, 2L, 13L, 7L, 11L, 14L, 2L, 11L, 3L, 
                     1L, 5L, 5L, 10L, 6L, 14L, 10L, 7L, 9L, 15L, 5L, 5L, 9L, 9L, 14L, 
                     5L, 5L, 2L, 10L, 14L, 9L, 12L, 15L, 1L, 4L, 3L, 6L, 10L, 10L, 
                     6L, 15L, 4L, 12L, 4L, 10L, 12L, 9L, 7L, 6L, 9L, 8L, 12L, 9L, 
                     7L, 8L, 6L, 10L, 7L, 3L, 10L, 6L, 8L, 14L, 2L, 13L, 2L, 6L, 14L, 
                     6L, 1L, 3L, 3L, 8L, 6L, 7L, 15L, 12L, 6L, 8L, 7L, 11L, 1L, 4L, 
                     13L, 8L, 9L, 9L, 7L, 14L, 4L, 7L, 13L, 13L, 12L, 6L, 13L, 12L, 
                     12L), .Dim = c(10L, 10L))
  
  matTest <- muRty::get_k_best(mat, 35)
  matTest <- sum(unlist(matTest$costs) == 32)
  
  expectedOutput5 <- 5L
  
  expect_equal(matTest, expectedOutput5)
  
})

test_that("get_k_best functions as expected with decimal weights", {
  
  mat <- read.table(
    text = "0.5 5 0.5
    3 1 3
    2.5 4 2.5",
      header = FALSE)

  matTest <- muRty::get_k_best(mat, 3, by_rank = TRUE)
  expectedOutput6 <- list(solutions = list(list(structure(c(0, 0, 1, 0, 1, 0, 1, 0, 
                                                            0), .Dim = c(3L, 3L)), structure(c(1, 0, 0, 0, 1, 0, 0, 0, 1), .Dim = c(3L, 
                                                                                                                                    3L))), list(structure(c(0, 1, 0, 0, 0, 1, 1, 0, 0), .Dim = c(3L, 
                                                                                                                                                                                                 3L)), structure(c(1, 0, 0, 0, 0, 1, 0, 1, 0), .Dim = c(3L, 3L
                                                                                                                                                                                                 ))), list(structure(c(0, 1, 0, 1, 0, 0, 0, 0, 1), .Dim = c(3L, 
                                                                                                                                                                                                                                                            3L)), structure(c(0, 0, 1, 1, 0, 0, 0, 1, 0), .Dim = c(3L, 3L
                                                                                                                                                                                                                                                            )))), costs = list(c(4, 4), c(7.5, 7.5), c(10.5, 10.5)))

  expect_equal(matTest, expectedOutput6)

})