
# Apply function to groups
run_by_group <- function(data, fn, ...){

  # Check arguments ####
  assert_collection <- checkmate::makeAssertCollection()
  checkmate::assert_data_frame(data, min.rows = 1, add = assert_collection)
  checkmate::assert_function(fn, add = assert_collection)
  checkmate::reportAssertions(assert_collection)
  # End of argument checks ####

  purrr::map_dfr(.x = split(x = data, f = dplyr::group_indices(data)),
                 .f = fn, ...)
}
