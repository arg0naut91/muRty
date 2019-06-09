###############################################################################################################################################
#
# Murty's algorithm for k-best assignments
#
# This version is executed when no ranking is needed and when LP (Simplex) is used.
#
# @param matNR Square matrix (N x N) in which values represent the weights.
# @param k_bestNR How many best scenarios should be returned. If by_rank = TRUE, this equals best ranks.
# @param objectiveNR Should the cost be minimized ('min') or maximized ('max')? Defaults to 'min'.
# @param proxy_InfNR What should be considered as a proxy for Inf? Defaults to 10e06; if objective = 'max' the sign is automatically reversed.
#
# @return A list with solutions and costs (objective values).
#
###############################################################################################################################################

getkBestNoRankLP <- function(matNR, k_bestNR = NULL, objectiveNR = 'min', proxy_InfNR = proxy_Inf) {
  
  if (!any(class(matNR) %in% "matrix")) {
    
    warning("You haven't provided an object of class matrix. Attempting to convert to matrix ..")
    
    matNR <- as.matrix(matNR)
    
  }
  
  if (dim(matNR)[1] != dim(matNR)[2]) {
    
    stop("Number of rows and number of columns are not equal. You need to provide a square matrix (N x N).")
    
  }
  
  if (nrow(matNR) < 2) {
    
    stop("Have you provided an empty set or matrix with only a single value? Your matrix should have at least 2 rows and 2 columns.")
    
  }
  
  if (k_bestNR < 1) { stop("You have provided an invalid value for k_bestNR.") }
  
  # Stripping the dimension names - column names need to be V1, V2, V3 .. in order to reconstruct the full matrix
  
  attr(matNR, "dimnames") <- NULL
  colnames(matNR) <- paste0("V", 1:ncol(matNR))
  
  # Initializing the first solution and all the lists needed
  
  i = 1
  
  # If the cost should be maximized, reverse the sign of Inf proxy; reverse also if there is a negative Inf in 'min'
  
  if (
    
    (objectiveNR == 'max' & proxy_InfNR > 0) | (objectiveNR == 'min' & proxy_InfNR < 0)
    
  ) {
    
    proxy_InfNR <- -proxy_InfNR
    
  }
  
  # Here we store solutions and costs
  
  all_solutions <- list()
  all_objectives <- list()
  
  # Here we store all full matrices and objectives that are re-checked at each step for minimum cost matrices
  
  fullMats <- list()
  fullObjs <- list()
  
  # Here we store partial solutions for partitions (as well as partitions)
  
  partialSols <- list()
  partitionsAll <- list()
  
  # Here we store all the columns needed to add to partitions in order to reconstruct the full matrix
  
  colsToAddAll <- list()
  colsToAdd <- NA
  
  matNR <- as.matrix(matNR)
  
  # Number of all possible solutions is the factorial
  
  n_possible <- factorial(nrow(matNR))
  
  nextMat <- matNR
  
  # First assignment with lpSolve and storage in all_solutions (solved matrix) and all_objectives (cost)
  
  assignm <- lpSolve::lp.assign(matNR, direction = objectiveNR)
  
  all_solutions[[i]] <- assignm$solution
  
  all_objectives[[i]] <- assignm$objval
  
  curr_solution <- assignm$solution
  full_solution <- curr_solution
  
  # While loop which stops as soon we reach the iteration that is equal to desired number of best scenarios or as soon we reach the n_possible
  
  while (i < k_bestNR) {
    
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
    # We always assign the proxy_InfNR to last element, and strike the rows and columns of matches before
    
    matSub <- PartitionAndInsertInf(idx, nextMat, idxmaxSubs, proxy_InfNR)
    matSub <- strikeRwsCols(matSub, idxStrike)
    
    # Just a check if the solution would make sense at all (there can be only 1 proxy_InfNR per row and column)
    
    matCheck <- c(
      which(lapply(matSub, function(x) any(rowSums(x == proxy_InfNR) == ncol(x))) == TRUE),
      which(lapply(matSub, function(x) any(colSums(x == proxy_InfNR) == nrow(x))) == TRUE)
    )
    
    if (length(matCheck) > 0) {
      
      matSub <- matSub[-matCheck]
      
    }
    
    # If there is at least one partition left, execute
    
    if (length(matSub) > 0) {
      
      partitionsAll <- c(partitionsAll, matSub)
      
      # Solve each of the partitions and store in a list
      
      algoList <- lapply(matSub, lpSolve::lp.assign, direction = objectiveNR)
      
      partialSols <- c(partialSols, lapply(1:length(algoList), function(x) algoList[[x]]$solution))
      
      # Check which columns are missing from the partitions, store in a list for each one
      
      colsToAddAll <- c(
        colsToAddAll,
        lapply(1:length(matSub),
               function(x) setdiff(c(1:ncol(matNR)), substr(colnames(matSub[[x]]), 2, nchar(colnames(matSub[[x]])))
               )
        )
      )
      
      # Reconstruct partition and/or full matrix if partition != full matrix
      #
      # See the related functions in reconstructInitialPartition.R
      
      reconstructedPartition <- reconstructPartition(algoList, idx, idxStrike, curr_solution, nextMat)
      
      if (nrow(reconstructedPartition[[1]]) != nrow(matNR)) {
        
        reconstructedPartition <- reconstructInitial(reconstructedPartition, colsToAdd, full_solution)
        
      }
      
      # For each reconstructed full matrix, check the objective value by comparing to initial matrix (matNR)
      
      fullObjsTmp <- lapply(1:length(reconstructedPartition), function(x) {
        
        objval <- sum(matNR[which(reconstructedPartition[[x]] > 0, arr.ind = T)])
        
      })
      
      # Store in lists
      
      fullMats <- c(fullMats, reconstructedPartition)
      fullObjs <- c(fullObjs, fullObjsTmp)
      
    }
    
    # Check fullObjs for the (remaining) optimal (minimum/maximum) cost, the next iteration uses it as starting basis
    
    idxOpt <- if (objectiveNR == 'min') which.min(fullObjs) else which.max(fullObjs)
    
    # Initialize the next iteration
    
    i = i + 1
    
    # Store the corresponding full matrix & related information into variables needed for each iteration
    
    full_solution <- fullMats[[idxOpt]]
    curr_solution <- partialSols[[idxOpt]]
    nextMat <- partitionsAll[[idxOpt]]
    colsToAdd <- colsToAddAll[[idxOpt]]
    
    # Store in lists returned by the function
    
    all_solutions[[i]] <- fullMats[[idxOpt]]
    attr(all_solutions[[i]], "dimnames") <- NULL
    
    all_objectives[[i]] <- fullObjs[[idxOpt]]
    
    # Remove the chosen solution from lists
    
    fullMats <- fullMats[-idxOpt]
    fullObjs <- fullObjs[-idxOpt]
    partialSols <- partialSols[-idxOpt]
    partitionsAll <- partitionsAll[-idxOpt]
    colsToAddAll <- colsToAddAll[-idxOpt]
    
    if (
      
      (length(all_solutions) == n_possible) & (k_bestNR > n_possible) 
      
    ) {
      
      warning(
        paste0(
          "There are only ", n_possible, " possible solutions - terminating earlier."
        )
      )
      
      break
      
    }
    
  }
  
  return(
    list(
      solutions = lapply(all_solutions, round),
      costs = all_objectives
    )
  )
  
}