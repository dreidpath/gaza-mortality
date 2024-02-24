#' Replace Zeros with Weighted Average of Next Positive Integer
#'
#' This function takes a numeric vector and replaces each sequence of zeros with
#' the next positive integer divided by the count of zeros plus one in the sequence.
#' The next positive integer following the zeros is also replaced by the same value.
#'
#' @param vec A numeric vector where sequences of zeros are to be replaced.
#'
#' @return A numeric vector with sequences of zeros replaced by the weighted average
#'         of the next positive integer.
#'
#' @examples
#' model_0s(c(1, 2, 3, 0, 0, 0, 4, 0, 5))
#' # Returns: c(1, 2, 3, 1, 1, 1, 1, 2.5, 2.5)
#' model_0s(c(0, 0, 3, 0, 0, 6))
#' # Returns: c(1, 1, 1, 2, 2, 2)
#'
#' @export
model_0s <- function(vec) {
  n <- length(vec) # Length of the vector
  
  i <- 1
  while(i <= n) {
    if(vec[i] == 0) { # When a zero is found
      zeroCount <- 0 # Initialize zero count
      
      # Count the number of consecutive zeros
      while(i + zeroCount <= n && vec[i + zeroCount] == 0) {
        zeroCount <- zeroCount + 1
      }
      
      # Check if the sequence of zeros is followed by a positive integer
      if(i + zeroCount <= n) {
        nextPositive <- vec[i + zeroCount] # The next non-zero (positive) number
        divisionFactor <- zeroCount + 1 # Count of zeros plus one
        
        # Calculate the new value to replace zeros and the next positive number
        newValue <- nextPositive / divisionFactor
        
        # Replace zeros and the next positive number with the new value
        vec[i:(i + zeroCount)] <- rep(newValue, zeroCount + 1)
        
        # Move index to skip over the replaced values
        i <- i + zeroCount
      }
    }
    i <- i + 1 # Move to the next element
  }
  
  return(vec)
}


#' Linear Interpolation Between First and Last Points
#'
#' Generates a linearly spaced sequence between the first and last elements of the input vector,
#' with the sequence having the same number of elements as the input vector.
#' Note that this function does not interpolate between intermediate points of the input vector,
#' but rather only considers the start and end values for sequence generation.
#'
#' @param x A numeric vector. The function will generate a sequence from the first to the last element of this vector.
#' @return A numeric vector that is a linear sequence from the first to the last element of the input vector `x`.
#'         The length of the returned vector is the same as the length of `x`.
#' @examples
#' lininterpol(c(0.2, 0.2, 0.2, 0.3))
#' @export
#' @importFrom stats seq
lininterpol <- function(x){
  # Calculate the length of the input vector
  lenvec <- length(x)
  # Check for null vector
  if(lenvec == 0){
    stop("Input vector 'x' is null. Please provide a non-empty numeric vector.")
  }
  # Check for non-numeric vector
  if(!is.numeric(x)){
    stop("Input vector 'x' is not numeric. Please provide a numeric vector.")
  }
  
  # Generate and return a linearly spaced sequence from the first to the last element of x
  seq(from = x[1], to = x[lenvec], length.out = lenvec)
}


#' Model Missing Proportions
#'
#' This function handles missing data or irregularities in a time series of proportions, such as mortality rates.
#'
#' It identifies runs of consecutive values in a vector and interpolates missing values between them using linear interpolation.
#'
#' @param subpop_deaths A numeric vector representing the number of deaths in a subpopulation over time.
#' @param total_deaths The total number of deaths over the same time period.
#' @return A vector of proportions representing the proportion of deaths in the subpopulation at each time point, with missing values interpolated.
#' @export
model_missing_proportions <- function(subpop_deaths, total_deaths){
  # Initialize local variables
  local_start <- 1  # Start index for the current run
  runs <- list()    # List to store start and end indices of consecutive runs
  
  # Iterate over the vector to identify runs of consecutive values
  for (i in 2:length(subpop_deaths)) {
    # Check if the current value is different from the previous one
    if (subpop_deaths[i] != subpop_deaths[i - 1]) {
      # If different, store the start and end points of the run
      runs[[length(runs) + 1]] <- c(local_start, i - 1)
      # Update the local_start for the next run
      local_start <- i
    }
  }
  
  # Add the last run
  runs[[length(runs) + 1]] <- c(local_start, length(subpop_deaths))
  
  # Calculate proportions of deaths in the subpopulation relative to the total deaths
  proportions <- subpop_deaths/total_deaths
  
  # Interpolate missing proportions within each run
  runs_sublists <- seq_along(runs)
  last_sublist <- tail(seq_along(runs), 1)
  
  for(i in runs_sublists){
    if(i < last_sublist){
      runs_pair_begin <- runs[[i]][[1]]
      runs_pair_end <- runs[[i+1]][[1]]
      # Interpolate missing values using the lininterpol function
      proportions[runs_pair_begin:runs_pair_end] <- lininterpol(proportions[runs_pair_begin:runs_pair_end])
    }
  }
  
  return(proportions)
  
}
