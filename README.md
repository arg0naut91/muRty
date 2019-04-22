muRty
================

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version-last-release/muRty)](https://cran.r-project.org/package=muRty)
[![Development
version](https://img.shields.io/badge/devel%20version-0.2-brightgreen.svg)](https://github.com/arg0naut91/muRty)
[![Travis build
status](https://travis-ci.org/arg0naut91/muRty.svg?branch=master)](https://travis-ci.org/arg0naut91/muRty)
[![codecov](https://codecov.io/gh/arg0naut91/muRty/branch/master/graph/badge.svg)](https://codecov.io/gh/arg0naut91/muRty)

The package enables users to obtain multiple best solutions to the
assignment problem (up to `!n`).

It implements Murty’s algorithm as outlined in \[1\]. It is mostly
written in `base`; for solving the assignment it uses `lpSolve`.

You can install it from CRAN by `install.packages("muRty")`.

Development version can be installed *via*
`devtools::install_github("arg0naut91/muRty")`.

## Examples

The input matrix has to be a square matrix (`N x N`).

In terms of classes, if you pass anything else it attempts to convert it
to matrix. Usually this should work for common formats (`data frame`,
`data.table` or `tibble`).

Let’s take for example a small matrix used for demonstration of Murty’s
algorithm in \[2\]:

``` 
     V1 V2 V3
[1,]  0  5 99
[2,]  6  1  3
[3,]  7  4  2
```

To execute Murty’s algorithm, you need to call the `get_k_best`
function.

Usually you will only need to specify `mat` (matrix) and `k_best`
(desired number of best scenarios) arguments.

It returns a list containing two additional lists: `solutions` (matrices
of 0s and 1s as solutions) and `costs` (the costs of corresponding
solutions).

``` r
library(muRty)

get_k_best(mat, 6)
```

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

In the latter case it also happened that there were partitions that
could not be further partitioned.

This has been tested and in such case the implementation jumps to
another branch.

The maximum number of possible solutions in the above example is exactly
6 (`!3 = 6`). If you would have specified a higher `k_best`, it would
output a warning but still produce all possible solutions.

### Ranked solutions

By default, the function outputs as many solutions and costs as
specified in `k_best` argument.

This means that if your matrix can be solved in 5 different ways with 5
equal costs, and you specified you want 3 best solutions, the function
will output only 3 of the possible ways.

You can change this behaviour by setting the `by_rank` argument to
`TRUE`. In this context, `rank` is similar to `dense rank` in `SQL`
(meaning no ranks are skipped).

Consider the following matrix:

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
```

Exactly three solutions are returned if we keep the `by_rank` argument
untouched (i.e. `FALSE` as it is by default):

``` r
get_k_best(mat = mat, k_best = 3)
```

    $solutions
    $solutions[[1]]
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
    
    $solutions[[2]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    0    0    0    0    0    0    0    0     1
     [2,]    0    1    0    0    0    0    0    0    0     0
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    1    0    0    0    0    0    0     0
     [5,]    0    0    0    0    0    1    0    0    0     0
     [6,]    0    0    0    0    0    0    0    0    1     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    1    0    0    0    0    0     0
     [9,]    0    0    0    0    0    0    1    0    0     0
    [10,]    1    0    0    0    0    0    0    0    0     0
    
    $solutions[[3]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    1    0    0    0    0    0    0    0     0
     [2,]    0    0    0    0    0    0    0    0    0     1
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    0    1    0    0    0    0    0     0
     [5,]    0    0    1    0    0    0    0    0    0     0
     [6,]    0    0    0    0    0    1    0    0    0     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    0    0    0    0    0    1     0
     [9,]    0    0    0    0    0    0    1    0    0     0
    [10,]    1    0    0    0    0    0    0    0    0     0
    
    
    $costs
    $costs[[1]]
    [1] 25
    
    $costs[[2]]
    [1] 27
    
    $costs[[3]]
    [1] 27

On the other hand, changing this argument to `TRUE` will return 6
solutions, as 4 of them actually have the same cost (and are thus stored
together in a sublist):

``` r
get_k_best(mat = mat, k_best = 3, by_rank = TRUE)
```

    $solutions
    $solutions[[1]]
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
    
    $solutions[[2]]
    $solutions[[2]][[1]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    0    0    0    0    0    0    0    0     1
     [2,]    0    1    0    0    0    0    0    0    0     0
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    1    0    0    0    0    0    0     0
     [5,]    0    0    0    0    0    1    0    0    0     0
     [6,]    0    0    0    0    0    0    0    0    1     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    1    0    0    0    0    0     0
     [9,]    0    0    0    0    0    0    1    0    0     0
    [10,]    1    0    0    0    0    0    0    0    0     0
    
    $solutions[[2]][[2]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    1    0    0    0    0    0    0    0     0
     [2,]    0    0    0    0    0    0    0    0    0     1
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    0    1    0    0    0    0    0     0
     [5,]    0    0    1    0    0    0    0    0    0     0
     [6,]    0    0    0    0    0    1    0    0    0     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    0    0    0    0    0    1     0
     [9,]    0    0    0    0    0    0    1    0    0     0
    [10,]    1    0    0    0    0    0    0    0    0     0
    
    $solutions[[2]][[3]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    1    0    0    0    0    0    0    0     0
     [2,]    0    0    0    0    0    0    0    0    0     1
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    1    0    0    0    0    0    0     0
     [5,]    1    0    0    0    0    0    0    0    0     0
     [6,]    0    0    0    0    0    1    0    0    0     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    1    0    0    0    0    0     0
     [9,]    0    0    0    0    0    0    1    0    0     0
    [10,]    0    0    0    0    0    0    0    0    1     0
    
    $solutions[[2]][[4]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    1    0    0    0    0    0    0    0     0
     [2,]    0    0    0    0    0    0    0    0    0     1
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    1    0    0    0    0    0    0     0
     [5,]    0    0    0    0    0    1    0    0    0     0
     [6,]    0    0    0    0    0    0    1    0    0     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    1    0    0    0    0    0     0
     [9,]    0    0    0    0    0    0    0    0    1     0
    [10,]    1    0    0    0    0    0    0    0    0     0
    
    
    $solutions[[3]]
          [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
     [1,]    0    1    0    0    0    0    0    0    0     0
     [2,]    0    0    0    0    0    0    0    0    0     1
     [3,]    0    0    0    0    0    0    0    1    0     0
     [4,]    0    0    0    1    0    0    0    0    0     0
     [5,]    0    0    0    0    0    1    0    0    0     0
     [6,]    0    0    1    0    0    0    0    0    0     0
     [7,]    0    0    0    0    1    0    0    0    0     0
     [8,]    0    0    0    0    0    0    0    0    1     0
     [9,]    0    0    0    0    0    0    1    0    0     0
    [10,]    1    0    0    0    0    0    0    0    0     0
    
    
    $costs
    $costs[[1]]
    [1] 25
    
    $costs[[2]]
    [1] 27 27 27 27
    
    $costs[[3]]
    [1] 28

Note that in the case of multiple solutions with equal cost, you can
retrieve individual solutions by double brackets (`[[`) as they are
stored in a sublist, and individual costs by single brackets (`[`) as
they are actually vectors.

For example, you would extract the fourth solution with the cost of 27
with `solvedlist$solutions[[2]][[4]]` and the corresponding cost by
`solvedlist$costs[[2]][4]` (provided that you have stored the output
from `get_k_best` in a list called `solvedlist`).

### Changing the objective

By default - and as foreseen in \[1\] -, the function tries to minimize
the total cost of each assignment and outputs a list of *k* assignments
with lowest costs.

You can reverse this behaviour by changing the parameter `objective` to
`max`, like below (`mat` here is the same as in the initial example
above):

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

In case you work with weights that are relatively close to that (also
considering the matrix size), you should modify it properly *via* the
`proxy_Inf` argument.

There is no need to modify the `proxy_Inf` argument if the `objective`
is changed to `max`; the reversal of the sign is done automatically.

## References

\[1\] Murty, K. (1968). An Algorithm for Ranking all the Assignments in
Order of Increasing Cost. *Operations Research, 16*(3), 682-687.
Retrieved from <http://www.jstor.org/stable/168595>

\[2\] Burkard, R., Dell’Amico, M., Martello, S. (2009). *Assignment
Problems*. Philadelphia, PA: Society for Industrial and Applied
Mathematics, 160-61.
