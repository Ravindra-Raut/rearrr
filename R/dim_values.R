

#   __________________ #< 23ce599fd680031f2cba203b7feae4ed ># __________________
#   Dim around                                                              ####


#' @title Dim values of a dimension based on the distance to an n-dimensional origin
#' @description
#'  \Sexpr[results=rd, stage=render]{lifecycle::badge("experimental")}
#'
#'  Dims the values in the dimming dimension (last by default) based on the data point's distance to the origin.
#'
#'  Distance is calculated as:
#'  \deqn{d(P1, P2) = sqrt( (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2 + ... )}
#'
#'  The default \code{`dimming_fn`} multiplies by the inverse-square of
#'  \eqn{1 + distance} and is calculated as:
#'  \deqn{dimming_fn(x, d) = x * (1 / (1 + d) ^ 2)}
#'
#'  Where \eqn{x} is the value in the dimming dimension. The \eqn{+1} is added
#'  to ensure that values are dimmed even when the distance is below \code{1}. The quickest
#'  way to change the exponent or the \eqn{+1} is with
#'  \code{\link[rearrr:create_dimming_fn]{create_dimming_fn()}}.
#'
#'  The origin can be supplied as coordinates or as a function that returns coordinates. The
#'  latter can be useful when supplying a grouped \code{data.frame} and dimming around e.g. the centroid
#'  of each group.
#'
#' @author Ludvig Renbo Olsen, \email{r-pkgs@@ludvigolsen.dk}
#' @param cols Names of columns in \code{`data`}.
#'  The dimming column (\code{`dim_col`}) is dimmed based on all the columns.
#'  Each column is considered a dimension.
#' @param origin Coordinates of the origin to dim around.
#'  Must be either a single constant to use in all dimensions
#'  or a \code{vector} with one constant per dimension.
#'
#'  \strong{N.B.} Ignored when \code{`origin_fn`} is not \code{NULL}.
#' @param origin_fn Function for finding the origin coordinates to dim around.
#'  Each column will be passed as a \code{vector} in the order of \code{`cols`}.
#'  It should return a \code{vector} with one constant per dimension.
#'
#'  Can be created with \code{\link[rearrr:create_origin_fn]{create_origin_fn()}} if you want to apply
#'  the same function to each dimension.
#'
#'  E.g. the \code{\link[rearrr:centroid]{centroid()}} function, which is created with:
#'
#'  \code{create_origin_fn(mean)}
#'
#'  Which returns the following function:
#'
#'  \code{function(...)\{}
#'
#'  \verb{  }\code{list(...) \%>\%}
#'
#'  \verb{    }\code{purrr::map(mean) \%>\%}
#'
#'  \verb{    }\code{unlist(recursive = TRUE,}
#'
#'  \verb{           }\code{use.names = FALSE)}
#'
#'  \code{\}}
#'
#' @param dimming_fn \code{Function} for calculating the dimmed values.
#'  Must take \strong{two} input arguments where the
#'  \emph{first} is a \code{vector} with the values in the dimming dimension,
#'  and the \emph{second} is a \code{vector} with corresponding distances to the origin.
#'
#'  E.g.:
#'
#'  \code{function(x, d)\{}
#'
#'  \verb{  }\code{x * (1 / ((1 + d) ^ 2))}
#'
#'  \code{\}}
#'
#'  This kind of dimming function can be created with
#'  \code{\link[rearrr:create_dimming_fn]{create_dimming_fn()}},
#'  which for instance makes it easy to change the exponent (the \code{2} above).
#'
#' @param dim_col Name of column to dim. Default is the last column in \code{`cols`}. This column must also be in \code{`cols`}.
#' @param origin_col_name Name of new column with the origin coordinates. If \code{NULL}, no column is added.
#' @export
#' @return \code{data.frame} (\code{tibble}) with the dimmed column,
#'  along with the origin coordinates.
#' @details
#'  \itemize{
#'    \item Calculates distances to origin with: \deqn{d(P1, P2) = sqrt( (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2 + ... )}
#'    \item Applies the \code{`dimming_fn`} to the \code{`dim_col`} based on the distances.
#'  }
#' @family mutate functions
#' @inheritParams multi_mutator
#' @examples
#' \donttest{
#' # Attach packages
#' library(rearrr)
#' library(dplyr)
#' library(purrr)
#' library(ggplot2)
#'
#' # Set seed
#' set.seed(7)
#'
#' # Create a data frame with clusters
#' df <- generate_clusters(
#'   num_rows = 70,
#'   num_cols = 3,
#'   num_clusters = 5,
#'   compactness = 1.6
#' ) %>%
#'   dplyr::rename(x = D1, y = D2, z = D3) %>%
#'   dplyr::mutate(o = 1)
#'
#' # Dim the values in the z column
#' dim_values(
#'   data = df,
#'   cols = c("x", "y", "z"),
#'   origin = c(0.5, 0.5, 0.5)
#' )
#'
#' # Dim the values in the `o` column
#' # around the centroid
#' dim_values(
#'   data = df,
#'   cols = c("x", "y", "o"),
#'   origin_fn = centroid
#' )
#'
#' # Specify dimming_fn
#' # around the centroid
#' dim_values(
#'   data = df,
#'   cols = c("x", "y", "o"),
#'   origin_fn = centroid,
#'   dimming_fn = function(x, d){
#'     x * 1 / (2^(1 + d))
#'   }
#' )
#'
#' #
#' # Dim cluster-wise
#' #
#'
#' # Group-wise dimming
#' df_dimmed <- df %>%
#'   dplyr::group_by(.cluster) %>%
#'   dim_values(
#'     cols = c("x", "y", "o"),
#'     origin_fn = centroid
#' )
#'
#' # Plot the dimmed data such that the alpha (opacity) is
#' # controlled by the dimming
#' # (Note: This works because the `o` column is 1 for all values)
#' ggplot(data = df_dimmed,
#'        aes(x = x, y = y, alpha = o_dimmed, color = .cluster)) +
#'   geom_point() +
#'   theme_minimal() +
#'   labs(x = "x", y="y", color="Cluster", alpha = "o_dimmed")
#' }
dim_values <- function(data,
                       cols,
                       dimming_fn = create_dimming_fn(numerator = 1,
                                                      exponent = 2,
                                                      add_to_distance = 1),
                       origin = 0,
                       origin_fn = NULL,
                       dim_col = cols[[length(cols)]],
                       suffix = "_dimmed",
                       keep_original = TRUE,
                       origin_col_name = ".origin") {


  # Check arguments ####
  assert_collection <- checkmate::makeAssertCollection()
  checkmate::assert_string(origin_col_name, null.ok = TRUE, add = assert_collection)
  checkmate::assert_numeric(origin,
                            min.len = 1,
                            any.missing = FALSE,
                            add = assert_collection)
  checkmate::assert_function(origin_fn, null.ok = TRUE, add = assert_collection)
  checkmate::assert_function(dimming_fn, nargs = 2, add = assert_collection)
  checkmate::assert_string(dim_col, min.chars = 1, null.ok = TRUE, add = assert_collection)
  checkmate::reportAssertions(assert_collection)
  if (!is.null(dim_col) && dim_col %ni% cols){
    assert_collection$push("'dim_col' must be in 'cols'.")
  }
  checkmate::reportAssertions(assert_collection)
  # End of argument checks ####

  # Mutate with each multiplier
  multi_mutator(
    data = data,
    mutate_fn = dim_values_mutator_method,
    check_fn = NULL,
    cols = cols,
    suffix = suffix,
    force_df = TRUE,
    keep_original = keep_original,
    min_dims = 2,
    dimming_fn = dimming_fn,
    origin = origin,
    origin_fn = origin_fn,
    dim_col = dim_col,
    origin_col_name = origin_col_name
  )

}

dim_values_mutator_method <- function(data, cols, dimming_fn, origin, origin_fn, dim_col, suffix, origin_col_name){

  # Number of dimensions
  # Each column is a dimension
  num_dims <- length(cols)

  # If cols was originally NULL, dim_col will also be NULL
  if (is.null(dim_col)){
    dim_col <- cols[[length(cols)]]
  }

  # Convert columns to list of vectors
  dim_vectors <- as.list(data[, cols, drop = FALSE])

  # Find origin if specified
  origin <- apply_coordinate_fn(
    dim_vectors = dim_vectors,
    coordinates = origin,
    fn = origin_fn,
    num_dims = length(cols),
    coordinate_name = "origin",
    fn_name = "origin_fn",
    dim_var_name = "cols",
    allow_len_one = TRUE
  )

  # Calculate distances
  # formula: sqrt( (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2 )
  distances <- calculate_distances(dim_vectors = dim_vectors, to = origin)

  # Apply dimmer
  dim_vectors[[dim_col]] <- dimming_fn(dim_vectors[[dim_col]], distances)

  # Add dim_vectors as columns with the suffix
  data <-
    add_dimensions(data = data,
                   new_vectors = setNames(list(dim_vectors[[dim_col]]),
                                          dim_col),
                   suffix = suffix)

  # Add origin coordinates
  if (!is.null(origin_col_name)) {
    data[[origin_col_name]] <- list_coordinates(origin, cols)
  }

  data

}
