
#' Wrapper for running mutator methods
#'
#' @param data \code{data frame} or \code{vector}.
#' @param col Column to mutate values of. Must be specified when \code{data} is a \code{data frame}.
#' @param mutate_fn Mutator to apply.
#' @param check_fn Function with checks post-preparation of \code{data} and \code{col}.
#'  Should not return anything.
#' @param ... Named arguments for the \code{mutate_fn}.
#' @keywords internal
#' @return
#'  The mutated \code{data frame} / \code{vector}.
mutator <- function(data,
                    mutate_fn,
                    check_fn,
                    col = NULL,
                    ...) {


  # Prepare 'data' and 'col'
  # Includes a set of checks
  prepped <- prepare_input_data(data = data, col = col)
  data <- prepped[["data"]]
  col <- prepped[["col"]]
  was_vector <- prepped[["was_vector"]]

  if (isTRUE(prepped[["use_index"]])){
    stop("When 'data' is a data frame, 'col' must be specified.")
  }

  # Check arguments ####
  assert_collection <- checkmate::makeAssertCollection()
  checkmate::assert_data_frame(data, min.rows = 1, add = assert_collection)
  checkmate::assert_string(col, min.chars = 1, null.ok = TRUE, add = assert_collection)
  checkmate::assert_function(mutate_fn, add = assert_collection)
  checkmate::assert_function(check_fn, null.ok = TRUE, add = assert_collection)
  checkmate::reportAssertions(assert_collection)
  # Extra checks
  # This is for checks we want to perform after preparing 'data' and 'col'
  if (!is.null(check_fn))
    check_fn(data = data, col = col, ...)
  # End of argument checks ####

  # Apply rearrange method
  data <-
    run_by_group(
      data = data,
      fn = mutate_fn,
      col = col,
      ...
    )

  # Clean up output
  data <-
    prepare_output_data(
      data = data,
      col = col,
      use_index = FALSE,
      was_vector = was_vector
    )

  data

}