################################
#
# PartitionAndInsertInf - A function to 1) create partitions of matrix and 2) insert proxies of infinity (as defined in proxy_Inf) 
#
# @idx A truncated list of indices that locate 1s in curr_solution matrix (it excludes the last identified 1)
# @nextMat If we are solving partitions of original matrix, this equals original matrix, 
# otherwise it equals partition of orig. matrix (the one with minimum cost in iteration)
# @idxmaxSubs A list of elements of matrix (cells) that need to be overwritten with proxy_Inf per each nextMat
# @proxy_Inf Proxy for infinity (defaults to 10e06)
#
# @return A list of partitions where relevant cells are overwritten with proxy_Inf
#
################################

PartitionAndInsertInf <- function(idx, nextMat, idxmaxSubs, proxy_Inf) {

  if (!is.null(nrow(idx))) {
    
    # Create a list of matrices equaling the initial one

    matSub <- replicate(nrow(idx), nextMat, simplify = FALSE)
    
    # Extract the relevant indices to be replaced by proxy_Inf and replace them

    matSub <- lapply(1:length(matSub),
                     function(x) {

                       tmpMat <- matSub[[x]]
                       tmpidxMax <- idxmaxSubs[[x]]

                       tmpMat[tmpidxMax[1], tmpidxMax[2]] <- proxy_Inf

                       return(tmpMat)

                     }
    )

  } else {
    
    # This is used in case of first partition where there is nothing to be removed
    #
    # There is just the named integer indicating the cell where we need to insert proxy_Inf

    matSub <- nextMat
    tmpidxMax <- idxmaxSubs

    matSub[tmpidxMax[1], tmpidxMax[2]] <- proxy_Inf

  }
  
  return(matSub)

}

################################
#
# strikeRwsCols - A function to remove columns and rows per each partition
#
# @matSub Output from PartitionAndInsertInf
# @idxStrike a matrix or named integer storing information about rows and columns that were removed
#
# @return A list of partitions where relevant rows and columns have been removed
#
################################

strikeRwsCols <- function(matSub, idxStrike) {
  
  # Removing both rows and columns indicated in idxStrike per each element of list (each partition)
  #
  # If we're dealing with 3rd partition or more, this will involve 2 or more rows and columns to be removed
  #
  # If we're dealing with 2nd partition, this will involve exactly 1 row and 1 column
  #
  # If we're dealing with 1st partition, nothing needs to be removed
  #
  # This involves different ways of subsetting idxStrike (if at all), therefore the if / else if / else procedure

  if (is.list(matSub)) {

    matSub <- lapply(1:length(matSub),
                     function(x) {

                       if (x >= 3) {

                         tmpMat <- matSub[[x]]

                         rowsToRem <- idxStrike[[x - 1]][, 1]
                         colsToRem <- idxStrike[[x - 1]][, 2]

                         tmpMat <- tmpMat[-rowsToRem,]
                         tmpMat <- tmpMat[, -colsToRem]

                         return(tmpMat)

                       } else if (x == 2) {

                         tmpMat <- matSub[[x]]

                         rowsToRem <- idxStrike[[x - 1]][1]
                         colsToRem <- idxStrike[[x - 1]][2]

                         tmpMat <- tmpMat[-rowsToRem,]
                         tmpMat <- tmpMat[, -colsToRem]

                         return(tmpMat)

                       }

                       else {

                         return(matSub[[x]])

                       }

                     }
    )

  } else {

    matSub <- list(matSub)

  }
  
  return(matSub)

}
