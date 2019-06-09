#########################################################################################
#
# parseClueOutput - A helper function to parse the output from solve_LSAP (clue library)
#
# It is used for initial solution as there are no restricted solutions yet.
#
# @mat: A matrix that can also contain negative values
# @max: Whether we should minimize or maximize the cost
# @addConst: Output from checks if any value is negative (TRUE or FALSE)
# @addedConst: A constant to be added if any value is negative
#
# @return A list of solutions and costs
#
##########################################################################################

parseClueOutput <- function(mat, max = NULL, addConst = checkNegative, addedConst = NULL) {
  
  # If any value in the original matrix is negative, add the constant
  
  if (addConst) {
    
    mat <- mat + addedConst
    
  }
  
  solvedObject <- clue::solve_LSAP(mat, max)
  
  lgth <- length(solvedObject)
  
  parsedMat <- cbind(
    matrix(1:lgth),
    matrix(as.integer(solvedObject))
  )
  
  solvedMat <- matrix(0, nrow = lgth, ncol = lgth)
  solvedMat[parsedMat] <- 1
  
  # If constant has been added, subtract to get the correct costs
  
  if (addConst) {
    
    mat <- mat - addedConst
    
    cost <- sum(mat[parsedMat], na.rm = T)
    
  } else {
    
    cost <- sum(mat[parsedMat], na.rm = T)
    
  }
  
  return(
    list(
      solution = solvedMat,
      objval = cost
    )
  )
  
}

##############################################################################################
#
# parseClueOutputInf - A helper function to parse the output from solve_LSAP (clue library)
#
# It is applied during the partitioning when solutions are restricted.
#
# @mat: A matrix that can also contain negative values
# @max: Whether we should minimize or maximize the cost
# @const: A constant to be added. Corresponds to proxy Inf value and neutralizes the matrix
# @addConst: Output from checks if any value is negative (TRUE or FALSE)
# @addedConst: A constant (usually the minimum of matrix) to be added if any value is negative
#
# @return A list of solutions and costs
#
###############################################################################################

parseClueOutputInf <- function(mat, max = NULL, const = proxyConst, addConst = checkNegative, addedConst = NULL) {
  
  # Different variations of adding the constant
  #
  # They depend on whether the objective is maximum and/or whether there is a negative value in the initial matrix
  
  if (max & !addConst) {
    
    mat <- mat + const
    
  } else if (max & addConst) {
    
    mat <- mat + const + addedConst
      
  } else if (!max & addConst) {
    
    mat <- mat + addedConst
    
  }
  
  solvedObject <- clue::solve_LSAP(mat, max)
  
  lgth <- length(solvedObject)
  
  parsedMat <- cbind(
    matrix(1:lgth),
    matrix(as.integer(solvedObject))
  )
  
  solvedMat <- matrix(0, nrow = lgth, ncol = lgth)
  solvedMat[parsedMat] <- 1
  
  # Depending on the condition, subtract the constant(s) to get correct costs
  
  if (max & !addConst) {
    
    mat <- mat - const
    
  } else if (max & addConst) {
    
    mat <- mat - const - addedConst
    
  } else if (!max & addConst) {
    
    mat <- mat - addedConst
    
  }
  
  cost <- sum(mat[parsedMat], na.rm = T)
  
  return(
    list(
      solution = solvedMat,
      objval = cost
    )
  )
  
}#########################################################################################
#
# parseClueOutput - A helper function to parse the output from solve_LSAP (clue library)
#
# It is used for initial solution as there are no restricted solutions yet.
#
# @mat: A matrix that can also contain negative values
# @max: Whether we should minimize or maximize the cost
# @addConst: Output from checks if any value is negative (TRUE or FALSE)
# @addedConst: A constant to be added if any value is negative
#
# @return A list of solutions and costs
#
##########################################################################################

parseClueOutput <- function(mat, max = NULL, addConst = checkNegative, addedConst = NULL) {
  
  # If any value in the original matrix is negative, add the constant
  
  if (addConst) {
    
    mat <- mat + addedConst
    
  }
  
  solvedObject <- clue::solve_LSAP(mat, max)
  
  lgth <- length(solvedObject)
  
  parsedMat <- cbind(
    matrix(1:lgth),
    matrix(as.integer(solvedObject))
  )
  
  solvedMat <- matrix(0, nrow = lgth, ncol = lgth)
  solvedMat[parsedMat] <- 1
  
  # If constant has been added, subtract to get the correct costs
  
  if (addConst) {
    
    mat <- mat - addedConst
    
    cost <- sum(mat[parsedMat], na.rm = T)
    
  } else {
    
    cost <- sum(mat[parsedMat], na.rm = T)
    
  }
  
  return(
    list(
      solution = solvedMat,
      objval = cost
    )
  )
  
}

##############################################################################################
#
# parseClueOutputInf - A helper function to parse the output from solve_LSAP (clue library)
#
# It is applied during the partitioning when solutions are restricted.
#
# @mat: A matrix that can also contain negative values
# @max: Whether we should minimize or maximize the cost
# @const: A constant to be added. Corresponds to proxy Inf value and neutralizes the matrix
# @addConst: Output from checks if any value is negative (TRUE or FALSE)
# @addedConst: A constant (usually the minimum of matrix) to be added if any value is negative
#
# @return A list of solutions and costs
#
###############################################################################################

parseClueOutputInf <- function(mat, max = NULL, const = proxyConst, addConst = checkNegative, addedConst = NULL) {
  
  # Different variations of adding the constant
  #
  # They depend on whether the objective is maximum and/or whether there is a negative value in the initial matrix
  
  if (max & !addConst) {
    
    mat <- mat + const
    
  } else if (max & addConst) {
    
    mat <- mat + const + addedConst
      
  } else if (!max & addConst) {
    
    mat <- mat + addedConst
    
  }
  
  solvedObject <- clue::solve_LSAP(mat, max)
  
  lgth <- length(solvedObject)
  
  parsedMat <- cbind(
    matrix(1:lgth),
    matrix(as.integer(solvedObject))
  )
  
  solvedMat <- matrix(0, nrow = lgth, ncol = lgth)
  solvedMat[parsedMat] <- 1
  
  # Depending on the condition, subtract the constant(s) to get correct costs
  
  if (max & !addConst) {
    
    mat <- mat - const
    
  } else if (max & addConst) {
    
    mat <- mat - const - addedConst
    
  } else if (!max & addConst) {
    
    mat <- mat - addedConst
    
  }
  
  cost <- sum(mat[parsedMat], na.rm = T)
  
  return(
    list(
      solution = solvedMat,
      objval = cost
    )
  )
  
}