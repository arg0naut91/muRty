#' Murty's algorithm for k-best assignments
#'
#' Find k-best assignments for a given matrix (returns both solved matrices and costs).
#'
#' @param mat Square matrix (N x N) in which values represent the weights.
#' @param k_best How many best scenarios should be returned. If by_rank = TRUE, this equals best ranks.
#' @param algo Algorithm to be used, either 'lp' or 'hungarian'; defaults to 'hungarian'.
#' @param by_rank Should the solutions with same cost be counted as one and stored in a sublist? Defaults to FALSE.
#' @param objective Should the cost be minimized ('min') or maximized ('max')? Defaults to 'min'.
#' @param proxy_Inf What should be considered as a proxy for Inf? Defaults to 10e06; if objective = 'max' the sign is automatically reversed.
#'
#' @return A list with solutions and costs (objective values).
#'
#' @examples
#'
#' set.seed(1)
#' mat <- matrix(sample.int(15, 10*10, TRUE), 10, 10)
#'
#' get_k_best(mat, 3)
#'
#' @export
get_k_best <- function(mat,
                       k_best = NULL,
                       algo = 'hungarian',
                       by_rank = FALSE,
                       objective = 'min',
                       proxy_Inf = 10e06L
                       ) {

  if (!by_rank) {

    if (algo == "lp") {

      solvedMurty <- getkBestNoRankLP(matNR = mat, k_bestNR = k_best, objectiveNR = objective, proxy_InfNR = proxy_Inf)

    } else if (algo == "hungarian") {

      solvedMurty <- getkBestNoRankHung(matNR = mat, k_bestNR = k_best, objectiveNR = objective, proxy_InfNR = proxy_Inf, constantNR = abs(min(mat)))

    }

  } else {

    if (algo == "lp") {

      solvedMurty <- getkBestRankedLP(matR = mat, k_bestR = k_best, objectiveR = objective, proxy_InfR = proxy_Inf)

    } else if (algo == "hungarian") {

      solvedMurty <- getkBestRankedHung(matR = mat, k_bestR = k_best, objectiveR = objective, proxy_InfR = proxy_Inf, constantR = abs(min(mat)))

    }

  }

  return(solvedMurty)

}
