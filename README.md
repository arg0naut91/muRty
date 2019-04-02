muRty
================

The package enables users to obtain multiple solutions to the assignment problem (up to `!n`).

It implements Murty's algorithm as outlined in \[1\]. It is mostly written in `base`; for solving the assignment it uses `lpSolve`.

You can install it *via* `devtools::install_github("arg0naut91/muRty")`.

Examples
--------

The input matrix has to be a square matrix (`N x N`).

In terms of classes, if you pass anything else it attempts to convert it to matrix. Usually this should work for common formats (`data frame`, `data.table` or `tibble`).

``` r
set.seed(1)

mat <- matrix(sample.int(15, 10*10, TRUE), 10, 10)
```

          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    4    4   15    8   13    8   14    6    7     4
     [2,]    6    3    4    9   10   13    5   13   11     1
     [3,]    9   11   10    8   12    7    7    6    6    10
     [4,]   14    6    2    3    9    4    5    6    5    14
     [5,]    4   12    5   13    8    2   10    8   12    12
     [6,]   14    8    6   11   12    2    4   14    4    12
     [7,]   15   11    1   12    1    5    8   13   11     7
     [8,]   10   15    6    2    8    8   12    6    2     7
     [9,]   10    6   14   11   11   10    2   12    4    13
    [10,]    1   12    6    7   11    7   14   15    3    10

Then you need to call the `get_k_best` function.

Usually you will only need to specify `mat` (matrix) and `k_best` (desired number of scenarios) arguments.

It returns a list containing two additional lists: `solutions` (matrices of 0s and 1s as solutions) and `costs` (the costs of corresponding solutions).

``` r
k_best <- get_k_best(mat = mat, k_best = 3)

head(k_best$solutions, 1) # Best solution
```

    [[1]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    1    0    0    0    0    0    0    0     0
     [2,]    0    0    0    0    0    0    0    0    0     1
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    1    0    0    0    0    0    0     0
     [5,]    0    0    0    0    0    1    0    0    0     0
     [6,]    0    0    0    0    0    0    0    0    1     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    1    0    0    0    0    0     0
     [9,]    0    0    0    0    0    0    1    0    0     0
    [10,]    1    0    0    0    0    0    0    0    0     0

``` r
head(k_best$costs, 1) # The cost of best solution
```

    [[1]]
    [1] 25

The solutions and costs are sorted from most optimal to least optimal.

Normally, there should be more possible solutions to your problem than what you have selected in `k_best`. If not, the function outputs a warning.

To show the full output (i.e. structure of the list returned), let's take a small matrix used for demonstration of Murty's algorithm in \[2\]:

         V1 V2 V3
    [1,]  0  5 99
    [2,]  6  1  3
    [3,]  7  4  2

If we specify 10 desired solutions, we get a warning, and all possible solutions are returned (`!3 = 6`):

``` r
get_k_best(mat, 10)
```

    Warning in get_k_best(mat, 10): There are only 6 possible solutions -
    terminating earlier.

    $solutions
    $solutions[[1]]
         [,1] [,2] [,3]
    [1,]    1    0    0
    [2,]    0    1    0
    [3,]    0    0    1

    $solutions[[2]]
         [,1] [,2] [,3]
    [1,]    1    0    0
    [2,]    0    0    1
    [3,]    0    1    0

    $solutions[[3]]
         [,1] [,2] [,3]
    [1,]    0    1    0
    [2,]    1    0    0
    [3,]    0    0    1

    $solutions[[4]]
         [,1] [,2] [,3]
    [1,]    0    1    0
    [2,]    0    0    1
    [3,]    1    0    0

    $solutions[[5]]
         [,1] [,2] [,3]
    [1,]    0    0    1
    [2,]    0    1    0
    [3,]    1    0    0

    $solutions[[6]]
         [,1] [,2] [,3]
    [1,]    0    0    1
    [2,]    1    0    0
    [3,]    0    1    0


    $costs
    $costs[[1]]
    [1] 3

    $costs[[2]]
    [1] 7

    $costs[[3]]
    [1] 13

    $costs[[4]]
    [1] 15

    $costs[[5]]
    [1] 107

    $costs[[6]]
    [1] 109

In the latter case it also happened that there were partitions that could not be further partitioned.

This has been tested and in such case the implementation jumps to another branch.

By default, the function tries to minimize the total cost of assignment.

You can modify that behaviour by changing the parameter `objective` to `max`, like below:

``` r
get_k_best(mat, k_best = 6, objective = 'max')
```

    $solutions
    $solutions[[1]]
         [,1] [,2] [,3]
    [1,]    0    0    1
    [2,]    1    0    0
    [3,]    0    1    0

    $solutions[[2]]
         [,1] [,2] [,3]
    [1,]    0    0    1
    [2,]    0    1    0
    [3,]    1    0    0

    $solutions[[3]]
         [,1] [,2] [,3]
    [1,]    0    1    0
    [2,]    0    0    1
    [3,]    1    0    0

    $solutions[[4]]
         [,1] [,2] [,3]
    [1,]    0    1    0
    [2,]    1    0    0
    [3,]    0    0    1

    $solutions[[5]]
         [,1] [,2] [,3]
    [1,]    1    0    0
    [2,]    0    0    1
    [3,]    0    1    0

    $solutions[[6]]
         [,1] [,2] [,3]
    [1,]    1    0    0
    [2,]    0    1    0
    [3,]    0    0    1


    $costs
    $costs[[1]]
    [1] 109

    $costs[[2]]
    [1] 107

    $costs[[3]]
    [1] 15

    $costs[[4]]
    [1] 13

    $costs[[5]]
    [1] 7

    $costs[[6]]
    [1] 3

Note that the package uses a proxy for *Inf*: 10e06.

In case you work with weights that are relatively close to that (also considering the matrix size), you should modify it properly *via* the `proxy_Inf` argument.

There is no need to modify the `proxy_Inf` argument if the `objective` is changed to `max`; the reversal of the sign is done automatically.

------------------------------------------------------------------------

\[1\] Murty, K. (1968). An Algorithm for Ranking all the Assignments in Order of Increasing Cost. *Operations Research, 16*(3), 682-687. Retrieved from <http://www.jstor.org/stable/168595>

\[2\] Burkard, R., Dell'Amico, M., Martello, S. (2009). *Assignment Problems*. Philadelphia, PA: Society for Industrial and Applied Mathematics, pp. 160-61.
