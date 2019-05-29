muRty 0.3.0
===========

General changes
---------------

-   Added the `by_rank` argument which allows users to obtain ranked
    results;

-   The `algo` argument has been added together with `clue` as
    dependency, allowing users to take advantage of Hungarian algorithm
    which is usually faster than the LP approach;

-   Note that even though the `solve_LSAP` function from `clue` is used
    for the Hungarian algorithm (which uses the `maximum` argument), the
    `objective` argument has not changed.

muRty 0.1.2
===========

-   First version on CRAN.
