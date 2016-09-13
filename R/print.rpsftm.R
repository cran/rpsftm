#'Function used to print of the underlying test object at the point estimate of a rpsftm object
#'
#'@export
#'@title Print Method
#'@name print.rpsftm
#' @param x an object returned from the \code{\link{rpsftm}} function.
#' @param ... further arguments passed to or from other methods.
#' @return a print of the underlying test object at the point estimate.
#' @author Simon Bond
#' 


print.rpsftm <- function(x,...) {
  obj <- x$regression
  # remove the call object without this it will print the entire data set
  obj$call <- NULL
  print(x$call)
  print(obj)
  cat("\npsi:", x$psi)
  cat("\nexp(psi):", exp(x$psi))
  invisible(x)
}


