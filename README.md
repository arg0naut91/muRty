muRty
================

This is a convenience package with one goal: allow users to obtain multiple solutions to the assignment problem (up to `!n`).

It implements Murty's algorithm as outlined in \[1\]. It is mostly written in `base`; for solving the assignment it uses `lpSolve`.

You can install it via `devtools::install_github("arg0naut91/muRty")`.

Example
-------

The input matrix has to be a square matrix (`N x N`).

If you pass anything else it attempts to convert it to matrix. Usually this should work for common formats (`data frame`, `data.table` or `tibble`).

``` r
set.seed(1)

mat <- matrix(sample.int(15, 10*10, TRUE), 10, 10)
```

    ##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
    ##  [1,]    4    4   15    8   13    8   14    6    7     4
    ##  [2,]    6    3    4    9   10   13    5   13   11     1
    ##  [3,]    9   11   10    8   12    7    7    6    6    10
    ##  [4,]   14    6    2    3    9    4    5    6    5    14
    ##  [5,]    4   12    5   13    8    2   10    8   12    12
    ##  [6,]   14    8    6   11   12    2    4   14    4    12
    ##  [7,]   15   11    1   12    1    5    8   13   11     7
    ##  [8,]   10   15    6    2    8    8   12    6    2     7
    ##  [9,]   10    6   14   11   11   10    2   12    4    13
    ## [10,]    1   12    6    7   11    7   14   15    3    10

Then you need to call the function `get_k_best`. It returns a list with two sublists: `solutions` (which contains matrices of 0s and 1s as solutions) and `objectives` (which contains the costs of involved solutions).

``` r
sols <- get_k_best(mat, 3)

head(sols$solutions, 1)
```

    ## [[1]]
    ##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
    ##  [1,]    0    1    0    0    0    0    0    0    0     0
    ##  [2,]    0    0    0    0    0    0    0    0    0     1
    ##  [3,]    0    0    0    0    0    0    0    1    0     0
    ##  [4,]    0    0    1    0    0    0    0    0    0     0
    ##  [5,]    0    0    0    0    0    1    0    0    0     0
    ##  [6,]    0    0    0    0    0    0    0    0    1     0
    ##  [7,]    0    0    0    0    1    0    0    0    0     0
    ##  [8,]    0    0    0    1    0    0    0    0    0     0
    ##  [9,]    0    0    0    0    0    0    1    0    0     0
    ## [10,]    1    0    0    0    0    0    0    0    0     0

``` r
head(sols$objectives, 1)
```

    ## [[1]]
    ## [1] 25

Note that it uses a proxy for *Inf*: 10e06.

In case you work with weights that are relatively close to that (also considering the matrix size), you should modify it properly via the `proxy_Inf` argument.

In case more solutions are specified as desired than what is actually possible, it returns all possible solutions together with a warning.

Let's take for example a small matrix from \[2\].

    ##      V1 V2 V3
    ## [1,]  0  5 99
    ## [2,]  6  1  3
    ## [3,]  7  4  2

If we specify 10 desired solutions, we get a warning:

``` r
get_k_best(mat, 10)
```

    ## Warning in get_k_best(mat, 10): There are only 6 possible solutions -
    ## terminating earlier.

    ## $solutions
    ## $solutions[[1]]
    ##      [,1] [,2] [,3]
    ## [1,]    1    0    0
    ## [2,]    0    1    0
    ## [3,]    0    0    1
    ## 
    ## $solutions[[2]]
    ##      [,1] [,2] [,3]
    ## [1,]    1    0    0
    ## [2,]    0    0    1
    ## [3,]    0    1    0
    ## 
    ## $solutions[[3]]
    ##      [,1] [,2] [,3]
    ## [1,]    0    1    0
    ## [2,]    1    0    0
    ## [3,]    0    0    1
    ## 
    ## $solutions[[4]]
    ##      [,1] [,2] [,3]
    ## [1,]    0    1    0
    ## [2,]    0    0    1
    ## [3,]    1    0    0
    ## 
    ## $solutions[[5]]
    ##      [,1] [,2] [,3]
    ## [1,]    0    0    1
    ## [2,]    0    1    0
    ## [3,]    1    0    0
    ## 
    ## $solutions[[6]]
    ##      [,1] [,2] [,3]
    ## [1,]    0    0    1
    ## [2,]    1    0    0
    ## [3,]    0    1    0
    ## 
    ## 
    ## $objectives
    ## $objectives[[1]]
    ## [1] 3
    ## 
    ## $objectives[[2]]
    ## [1] 7
    ## 
    ## $objectives[[3]]
    ## [1] 13
    ## 
    ## $objectives[[4]]
    ## [1] 15
    ## 
    ## $objectives[[5]]
    ## [1] 107
    ## 
    ## $objectives[[6]]
    ## [1] 109

\[1\] Murty, K. (1968). An Algorithm for Ranking all the Assignments in Order of Increasing Cost. *Operations Research, 16*(3), 682-687. Retrieved from <http://www.jstor.org/stable/168595>

\[2\] Burkard, R., Dell'Amico, M., Martello, S. (2009). *Assignment Problems*. Philadelphia, PA: Society for Industrial and Applied Mathematics.
