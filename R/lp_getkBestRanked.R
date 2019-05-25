############################################################################
#
# get_k_best variant for ranked algorithm based on the LP
#
############################################################################

getkBestRankedLP <- function(matR, k_bestR = NULL, objectiveR = 'min', proxy_InfR = proxy_Inf) {
  
  if (!any(class(matR) %in% "matrix")) {
    
    warning("You haven't provided an object of class matrix. Attempting to convert to matrix ..")
    
    matR <- as.matrix(matR)
    
  }
  
  if (dim(matR)[1] != dim(matR)[2]) {
    
    stop("Number of rows and number of columns are not equal. You need to provide a square matrix (N x N).")
    
  }
  
  if (nrow(matR) < 2) {
    
    stop("Have you provided an empty set or matrix with only a single value? Your matrix should have at least 2 rows and 2 columns.")
    
  }
  
  if (k_bestR < 1) { stop("You have provided an invalid value for k_bestR.") }
  
  # Stripping the dimension names - column names need to be V1, V2, V3 .. in order to reconstruct the full matrix
  
  attr(matR, "dimnames") <- NULL
  colnames(matR) <- paste0("V", 1:ncol(matR))
  
  # Initializing the first solution and all the lists needed
  
  i = 1
  
  # If the cost should be maximized, reverse the sign of Inf proxy; reverse also if there is a negative Inf in 'min'
  
  if (
    
    (objectiveR == 'max' & proxy_InfR > 0) | (objectiveR == 'min' & proxy_InfR < 0)
    
  ) {
    
    proxy_InfR <- -proxy_InfR
    
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
  
  matR <- as.matrix(matR)
  
  # Number of all possible solutions is the factorial
  
  n_possible <- factorial(nrow(matR))
  
  nextMat <- matR
  
  # First assignment with lpSolve and storage in all_solutions (solved matrix) and all_objectives (cost)
  
  assignm <- lpSolve::lp.assign(matR, direction = objectiveR)
  
  all_solutions[[i]] <- assignm$solution
  
  all_objectives[[i]] <- round(assignm$objval, 5)
  
  curr_solution <- assignm$solution
  full_solution <- curr_solution
  
  # While loop which stops as soon we reach the iteration that is equal to desired number of best scenarios or as soon we reach the n_possible
  
  while (i <= k_bestR & k_bestR > 1) {
    
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
    # We always assign the proxy_InfR to last element, and strike the rows and columns of matches before
    
    matSub <- PartitionAndInsertInf(idx, nextMat, idxmaxSubs, proxy_InfR)
    matSub <- strikeRwsCols(matSub, idxStrike)
    
    # Just a check if the solution would make sense at all (there can be only 1 proxy_InfR per row and column)
    
    matCheck <- c(
      which(lapply(matSub, function(x) any(rowSums(x == proxy_InfR) == ncol(x))) == TRUE),
      which(lapply(matSub, function(x) any(colSums(x == proxy_InfR) == nrow(x))) == TRUE)
    )
    
    if (length(matCheck) > 0) {
      
      matSub <- matSub[-matCheck]
      
    }
    
    # If there is at least one partition left, execute
    
    if (length(matSub) > 0) {
      
      partitionsAll <- c(partitionsAll, matSub)
      
      # Solve each of the partitions and store in a list
      
      algoList <- lapply(matSub, lpSolve::lp.assign, direction = objectiveR)
      
      partialSols <- c(partialSols, lapply(1:length(algoList), function(x) algoList[[x]]$solution))
      
      # Check which columns are missing from the partitions, store in a list for each one
      
      colsToAddAll <- c(
        colsToAddAll,
        lapply(1:length(matSub),
               function(x) setdiff(c(1:ncol(matR)), substr(colnames(matSub[[x]]), 2, nchar(colnames(matSub[[x]])))
               )
        )
      )
      
      # Reconstruct partition and/or full matrix if partition != full matrix
      #
      # See the related functions in reconstructInitialPartition.R
      
      reconstructedPartition <- reconstructPartition(algoList, idx, idxStrike, curr_solution, nextMat)
      
      if (nrow(reconstructedPartition[[1]]) != nrow(matR)) {
        
        reconstructedPartition <- reconstructInitial(reconstructedPartition, colsToAdd, full_solution)
        
      }
      
      # For each reconstructed full matrix, check the objective value by comparing to initial matrix (matR)
      
      fullObjsTmp <- lapply(1:length(reconstructedPartition), function(x) {
        
        objval <- round(sum(matR[which(reconstructedPartition[[x]] > 0, arr.ind = T)]), 5)
        
      })
      
      # Store in lists
      
      fullMats <- c(fullMats, reconstructedPartition)
      fullObjs <- c(fullObjs, fullObjsTmp)
      
    }
    
    # Check fullObjs for the (remaining) optimal (minimum/maximum) cost, the next iteration uses it as starting basis
    
    if (objectiveR == 'min') {
      
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
    
    # This returns a solution where k_bestR equals number of unique unlisted costs (duplicates count as 1)
    
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
      
      if (i > k_bestR) { break }
      
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
      
      (length(unlist(all_objectives)) == n_possible) & (length(all_solutions) < k_bestR)
      
    ) {
      
      warning(
        paste0(
          "There are ", n_possible, " possible solutions. Final solution has been found at rank number ",
          length(all_solutions), " which is lower than the k_bestR specified; terminating here."
        )
      )
      
      break
      
    } else if (
      
      ( (length(all_solutions) == n_possible) | (length(unlist(all_objectives)) == n_possible) ) & (k_bestR > n_possible) 
      
    ) {
      
      warning(
        paste0(
          "There are only ", n_possible, " possible solutions; terminating earlier, stopping at rank ", length(all_solutions), "."
        )
      )
      
      break
      
    } else if (
      
      (length(unlist(all_objectives)) == n_possible)
      
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