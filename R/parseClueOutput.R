#####################################################################################
#
# Helper functions to parse the clue output and return a list with solution and cost
#
#####################################################################################

parseClueOutput <- function(mat, max = NULL, addConst = checkNegative, addedConst = NULL) {
  
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

parseClueOutputInf <- function(mat, max = NULL, const = proxyConst, addConst = checkNegative, addedConst = NULL) {
  
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