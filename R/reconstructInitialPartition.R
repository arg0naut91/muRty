################################
#
# reconstructPartition - A function to reconstruct partition after another round of partitioning
#
# It either reconstructs the full matrix (if the current iteration works on partition of full original matrix) -
# or the partitioned matrix (if the current iteration works on partition of partition of full original matrix)
#
# @algoList A list of solutions (assignments) of partitions (or partitioned partitions)
# @idx A truncated list of indices that locate 1s in curr_solution matrix (it excludes the last identified 1)
# @idxStrike a matrix or named integer storing information about rows and columns that were removed
# @curr_solution Solved matrix - either initial full matrix, or partition
# @nextMat If we are solving partitions of original matrix, this equals original matrix, otherwise it equals partition of orig. matrix (the one with minimum cost in iteration)
#
# @return A list of reconstructed solutions of full solutions / partitioned matrix
#
################################

reconstructPartition <- function(algoList, idx, idxStrike, curr_solution, nextMat) {

  # matMemory stores the missing part from the current solution
  
  matMemory <- lapply(1:(nrow(idx) - 1), function(x) curr_solution[1:x,])

  reconstructedPartition <- lapply(1:length(algoList), function(x) {

    assignmSol <- algoList[[x]]$solution

    if (nrow(assignmSol) == nrow(nextMat)) {

      assignmFull <- assignmSol

    } else {

      if (nrow(assignmSol) == (nrow(nextMat) - 1)) {
        
        # Fetch the column indices from idxStrike (here idxStrike is a named integer)

        colsToAddPartition <- idxStrike[[ncol(nextMat) - ncol(assignmSol)]][2]

      }

      else {
        
        # Fetch the column indices - here idxStrike is a matrix

        colsToAddPartition <- idxStrike[[ncol(nextMat) - ncol(assignmSol)]][, 2]

      }
      
      # Initialize empty matrix with 0s

      emptyMat <- matrix(0L, nrow = nrow(assignmSol), ncol = length(colsToAddPartition))
      
      # Complete the columns: bind together the partitioned assignment and empty matrix with columns in order that insert idxStrike columns where they belong

      assignmFull <- cbind(assignmSol, emptyMat)[, order(c(1:ncol(assignmSol), sort(colsToAddPartition) - seq_along(colsToAddPartition))) ]
      
      # Complete the rows: bind together with the missing part

      assignmFull <- rbind(matMemory[[ncol(nextMat) - ncol(assignmSol)]], assignmFull)

    }

  })
  
  return(reconstructedPartition)

}

################################
#
# reconstructInitial - A function to reconstruct partition to full dimensions of initial matrix
#
# It reconstructs the full matrix. Used to complement the reconstructPartition function
#
# @reconstructedPartition Output from reconstructPartition
# @colsToAdd Columns that are missing from column names of partition
# @full_solution Full solution that corresponds to partitioned matrix currently in use in the iteration
#
# @return A list of reconstructed full solutions
#
################################

reconstructInitial <- function(reconstructedPartition, colsToAdd, full_solution) {

  if (length(colsToAdd) > 1) {

    matMemory <- full_solution[1:length(colsToAdd),]

    reconstructedInitial <- lapply(1:length(reconstructedPartition), function(x) {

      assignmSol <- reconstructedPartition[[x]]

      emptyMat <- matrix(0L, nrow = nrow(assignmSol), ncol = length(colsToAdd))

      assignmFull <- cbind(assignmSol, emptyMat)[, order(c(1:ncol(assignmSol), sort(colsToAdd) - seq_along(colsToAdd))) ]

      assignmFull <- rbind(matMemory, assignmFull)

    }

    )

  } else {

    matMemory <- full_solution[1,]

    reconstructedInitial <- lapply(1:length(reconstructedPartition), function(x) {

      assignmSol <- reconstructedPartition[[x]]

      emptyMat <- matrix(0L, nrow = nrow(assignmSol), ncol = length(colsToAdd))

      assignmFull <- cbind(assignmSol, emptyMat)[, order(c(1:ncol(assignmSol), sort(colsToAdd) - seq_along(colsToAdd))) ]

      assignmFull <- rbind(matMemory, assignmFull)

    }

    )

  }
  
  return(reconstructedInitial)

}