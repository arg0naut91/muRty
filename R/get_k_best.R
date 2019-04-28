#' Murty's algorithm for k-best assignments
#'
#' Find k-best assignments for a given matrix (returns both solved matrices and costs).
#'
#' @param mat Square matrix (N x N) in which values represent the weights
#' @param k_best How many best scenarios should be returned. If by_rank = TRUE, this equals best ranks
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
get_k_best <- function(mat, k_best = NULL, by_rank = FALSE, objective = 'min', proxy_Inf = 10e06L) {

  if (!any(class(mat) %in% "matrix")) {

    warning("You haven't provided an object of class matrix. Attempting to convert to matrix ..")

    mat <- as.matrix(mat)

  }

  if (dim(mat)[1] != dim(mat)[2]) {

    stop("Number of rows and number of columns are not equal. You need to provide a square matrix (N x N).")

  }

  if (nrow(mat) < 2) {

    stop("Have you provided an empty set or matrix with only a single value? Your matrix should have at least 2 rows and 2 columns.")

  }
  
  if (k_best < 1) { stop("You have provided an invalid value for k_best.") }

  # Stripping the dimension names - column names need to be V1, V2, V3 .. in order to reconstruct the full matrix

  attr(mat, "dimnames") <- NULL
  colnames(mat) <- paste0("V", 1:ncol(mat))

  # Initializing the first solution and all the lists needed

  i = 1
  
  # If the cost should be maximized, reverse the sign of Inf proxy; reverse also if there is a negative Inf in 'min'
  
  if (
    
    (objective == 'max' & proxy_Inf > 0) | (objective == 'min' & proxy_Inf < 0)
    
    ) {
    
    proxy_Inf <- -proxy_Inf
    
  }
  
  # Here we store solutions and costs

  all_solutions <- list()
  all_objectives <- list()

  # Here we store all full matrices and objectives that are re-checked at each step for minimum cost matrices

  fullMats <- list()
  fullObjs <- list()

  # Here we store partial solutions for partitions (as well as partitions themselves)

  partialSols <- list()
  partitionsAll <- list()

  # Here we store all the columns needed to add to partitions in order to reconstruct the full matrix

  colsToAddAll <- list()
  colsToAdd <- NA

  mat <- as.matrix(mat)

  # Number of all possible solutions is the factorial

  n_possible <- factorial(nrow(mat))

  nextMat <- mat

  # First assignment with lpSolve and storage in all_solutions (solved matrix) and all_objectives (cost)

  assignm <- lpSolve::lp.assign(mat, direction = objective)

  all_solutions[[i]] <- assignm$solution

  all_objectives[[i]] <- round(assignm$objval, 5)

  curr_solution <- assignm$solution
  full_solution <- curr_solution

  # While loop which stops as soon we reach the iteration that is equal to desired number of best scenarios or as soon we reach the n_possible

  while (i <= k_best) {
    
    if (k_best == 1) { break }

    # Getting indices of rows & columns of initial solution's matches
    #
    # This serves as a basis for partitioning as defined in Murty (1968)

    idx <- which(curr_solution > 0, arr.ind = T)
    idx <- idx[order(idx[, 1]), ]
    idx <- idx[-nrow(idx),]

    if (!is.null(nrow(idx))) {

      idxStrike <- lapply(1:(nrow(idx) - 1), function(x) idx[1:x, ])

      idxmaxSubs <- lapply(1:nrow(idx), function(x) idx[x, ])

    } else {

      idxStrike <- NA
      idxmaxSubs <- idx

    }

    # See the related functions in insertInfStrike.R
    #
    # Basically, we create a list with n - 1 partitions as described in Murty's article
    #
    # We always assign the proxy_Inf to last element, and strike the rows and columns of matches before

    matSub <- PartitionAndInsertInf(idx, nextMat, idxmaxSubs, proxy_Inf)
    matSub <- strikeRwsCols(matSub, idxStrike)

    # Just a check if the solution would make sense at all (there can be only 1 proxy_Inf per row and column)

    matCheck <- c(
      which(lapply(matSub, function(x) any(rowSums(x == proxy_Inf) == ncol(x))) == TRUE),
      which(lapply(matSub, function(x) any(colSums(x == proxy_Inf) == nrow(x))) == TRUE)
    )

    if (length(matCheck) > 0) {

      matSub <- matSub[-matCheck]

    }

    # If there is at least one partition left, execute

    if (length(matSub) > 0) {

      partitionsAll <- c(partitionsAll, matSub)

      # Solve each of the partitions and store in a list

      algoList <- lapply(matSub, lpSolve::lp.assign, direction = objective)

      partialSols <- c(partialSols, lapply(1:length(algoList), function(x) algoList[[x]]$solution))

      # Check which columns are missing from the partitions, store in a list for each one

      colsToAddAll <- c(
        colsToAddAll,
        lapply(1:length(matSub),
               function(x) setdiff(c(1:ncol(mat)), substr(colnames(matSub[[x]]), 2, nchar(colnames(matSub[[x]])))
               )
        )
      )

      # Reconstruct partition and/or full matrix if partition != full matrix
      #
      # See the related functions in reconstructInitialPartition.R

      reconstructedPartition <- reconstructPartition(algoList, idx, idxStrike, curr_solution, nextMat)

      if (nrow(reconstructedPartition[[1]]) != nrow(mat)) {

        reconstructedPartition <- reconstructInitial(reconstructedPartition, colsToAdd, full_solution)

      }

      # For each reconstructed full matrix, check the objective value by comparing to initial matrix (mat)

      fullObjsTmp <- lapply(1:length(reconstructedPartition), function(x) {

        objval <- round(sum(mat[which(reconstructedPartition[[x]] > 0, arr.ind = T)]), 5)

      })

      # Store in lists

      fullMats <- c(fullMats, reconstructedPartition)
      fullObjs <- c(fullObjs, fullObjsTmp)

    }

    # Check fullObjs for the (remaining) optimal (minimum/maximum) cost, the next iteration uses it as starting basis
    
    if (objective == 'min') {
      
      idxOpt <- which.min(fullObjs)
      
    } else {
      
      idxOpt <- which.max(fullObjs)
      
    }

    # Store the corresponding full matrix & related information into variables needed for each iteration

    full_solution <- fullMats[[idxOpt]]
    curr_solution <- partialSols[[idxOpt]]
    nextMat <- partitionsAll[[idxOpt]]
    colsToAdd <- colsToAddAll[[idxOpt]]

    # Final storage in lists
    
    # If rank-oriented solution preferred, execute the block after if (by_rank)
    #
    # It returns a solution where k_best equals number of unique unlisted costs (duplicates count as 1)
    
    if (by_rank) {
      
      sum_dups <- sum(unlist(all_objectives) == fullObjs[[idxOpt]])
      
      if (sum_dups > 0) {
        
        sum_dups <- sum_dups + 1
        
        if (sum_dups == 2) {
          
          tmpFinalSolution <- all_solutions[[i]]
          
          all_solutions[[i]] <- list()
          
          all_solutions[[i]][[1]] <- tmpFinalSolution
          
        }
        
        all_solutions[[i]][[sum_dups]] <- fullMats[[idxOpt]]
        attr(all_solutions[[i]][[sum_dups]], "dimnames") <- NULL
        all_solutions[[i]][[sum_dups]] <- round(all_solutions[[i]][[sum_dups]])
        
        all_objectives[[i]][sum_dups] <- fullObjs[[idxOpt]]
        
      } else {
        
        i = i + 1
        
        if (i > k_best) { break }
        
        all_solutions[[i]] <- fullMats[[idxOpt]]
        attr(all_solutions[[i]], "dimnames") <- NULL
        all_solutions[[i]] <- round(all_solutions[[i]])
        
        all_objectives[[i]] <- fullObjs[[idxOpt]]
        
      }
      
    } else {
      
      # This is executed if by_rank = FALSE (default), it returns a solution where length of unlisted costs equals k_best
      
      i = i + 1
      
      if (i > k_best) { break }
      
      all_solutions[[i]] <- fullMats[[idxOpt]]
      attr(all_solutions[[i]], "dimnames") <- NULL
      all_solutions[[i]] <- round(all_solutions[[i]])
      
      all_objectives[[i]] <- fullObjs[[idxOpt]]
      
    }
    
    # Remove the chosen solution from lists

    fullMats <- fullMats[-idxOpt]
    fullObjs <- fullObjs[-idxOpt]
    partialSols <- partialSols[-idxOpt]
    partitionsAll <- partitionsAll[-idxOpt]
    colsToAddAll <- colsToAddAll[-idxOpt]
    
    if (
      
      (by_rank) & (length(unlist(all_objectives)) == n_possible) & (length(all_solutions) < k_best)
      
    ) {
      
      warning(
        paste0(
          "There are ", n_possible, " possible solutions. Final solution has been found at rank number ",
          length(all_solutions), " which is lower than the k_best specified; terminating here."
        )
      )
      
      break
      
    } else if (
      
      ( (length(all_solutions) == n_possible) | (length(unlist(all_objectives)) == n_possible) ) & (k_best > n_possible) 
      
    ) {
      
      if (by_rank) {
        
        warning(
          paste0(
            "There are only ", n_possible, " possible solutions; terminating earlier, stopping at rank ", length(all_solutions), "."
          )
        )
          
      } else {
        
        warning(
          paste0(
            "There are only ", n_possible, " possible solutions - terminating earlier."
          )
        )
        
      }
      
      break
      
    } else if (
      
      ( (by_rank) & (length(unlist(all_objectives)) == n_possible) ) | ( (!by_rank) & (length(all_solutions) == n_possible) )
      
    ) {
      
      break
      
    }

  }

  return(
    list(
      solutions = all_solutions,
      costs = all_objectives
    )
  )

}