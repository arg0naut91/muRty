############################################
#
# A short test script for Murty's algorithm
#
############################################
context("get_k_best")

test_that("Murty's algorithm functions as expected with data frames", {

  mat <- as.matrix(
    read.table(
      text = "0 5 99
  6 1 3
  7 4 2",
      header = FALSE)
  )

  matTest <- muRty::get_k_best(mat, 5)
  expectedOutput <- list(solutions = list(structure(c(1, 0, 0, 0, 1, 0, 0, 0, 1), .Dim = c(3L,3L)),
                                          structure(c(1, 0, 0, 0, 0, 1, 0, 1, 0), .Dim = c(3L, 3L)),
                                          structure(c(0, 1, 0, 1, 0, 0, 0, 0, 1), .Dim = c(3L, 3L)),
                                          structure(c(0, 0, 1, 1, 0, 0, 0, 1, 0), .Dim = c(3L, 3L)),
                                          structure(c(0, 0, 1, 0, 1, 0, 1, 0, 0), .Dim = c(3L, 3L))),
                         objectives = list(3, 7L, 13L, 15L, 107L))

  expect_equal(matTest, expectedOutput)

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

  matSolLarger <- muRty::get_k_best(matLarger, 70)
  expectedOutput <- 12L

  expect_equal(length(matSolLarger$objectives[matSolLarger$objectives == 29]), expectedOutput)

})

test_that("Murty's algorithm functions as expected with matrices", {

  set.seed(1)

  mat <- matrix(sample.int(15, 10*10, TRUE), 10, 10)

  matTest <- muRty::get_k_best(mat, 35)
  matTest <- length(matTest$objectives[matTest$objectives == 31])

  expectedOutput <- 13L

  expect_equal(matTest, expectedOutput)

})
