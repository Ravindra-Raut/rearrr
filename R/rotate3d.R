


#   __________________ #< e3dcc976d88c1f44e868b048aaf7d875 ># __________________
#   Rotate 3d                                                               ####


#' @title Rotate the values around an origin in 3 dimensions
#' @description
#'  \Sexpr[results=rd, stage=render]{lifecycle::badge("experimental")}
#'
#'  The values are rotated counterclockwise around a specified origin.
#'
#'  The origin can be supplied as coordinates or as a function that returns coordinates. The
#'  latter can be useful when supplying a grouped \code{data.frame} and rotating around e.g. the centroid
#'  of each group.
#' @author Ludvig Renbo Olsen, \email{r-pkgs@@ludvigolsen.dk}
#' @param x_deg,y_deg,z_deg Degrees to rotate values around the x/y/z-axis counterclockwise. In \code{[-360, 360]}.
#'  Can be \code{vector}s with multiple degrees.
#'
#'  \code{`x_deg`} is \emph{roll}. \code{`y_deg`} is \emph{pitch}. \code{`z_deg`} is \emph{yaw}.
#' @param x_col,y_col,z_col Name of x/y/z column in \code{`data`}. All must be specified.
#' @param origin Coordinates of the origin to rotate around. Must be a \code{vector} with 3 elements (i.e. origin_x, origin_y, origin_z).
#'  Ignored when \code{`origin_fn`} is not \code{NULL}.
#' @param origin_fn Function for finding the origin coordinates to rotate the values around.
#'  Each column will be passed as a \code{vector} (i.e. a \code{vector} with x-values,
#'  a \code{vector} with y-values, and a \code{vector} with z-values).
#'  It should return a \code{vector} with one constant per dimension (i.e. origin_x, origin_y, origin_z).
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
#' @param degrees_col_name Name of new column with the degrees. If \code{NULL}, no column is added.
#'
#'  Also adds a string version with the same name + \code{"_str"}, making it easier to group by the degrees
#'  when plotting multiple rotations.
#' @param origin_col_name Name of new column with the origin coordinates. If \code{NULL}, no column is added.
#' @export
#' @return \code{data.frame} (\code{tibble}) with six new columns containing
#'  the rotated x-,y- and z-values and the degrees and origin coordinates.
#' @details
#'  Applies the following rotation matrix:
#'
#'  | [ \eqn{cos \alpha cos \beta} |, \eqn{cos \alpha sin \beta sin \gamma - sin \alpha cos \gamma} |, \eqn{cos \alpha sin \beta cos \gamma + sin \alpha sin \gamma} | ] |
#'  | :--- | :--- | :--- | :--- |
#'  | [ \eqn{sin \alpha cos \beta} |, \eqn{sin \alpha sin \beta sin \gamma + cos \alpha cos \gamma} |, \eqn{sin \alpha sin \beta cos \gamma - cos \alpha sin \gamma} | ] |
#'  | [ \eqn{-sin \beta} |, \eqn{cos \beta sin \gamma } |, \eqn{cos \beta cos \gamma} | ]|
#'
#'  Where \eqn{\alpha =} \code{`z_deg`} in radians, \eqn{\beta =} \code{`y_deg`} in radians, \eqn{\gamma =} \code{`x_deg`} in radians.
#'
#'  As specified at [Wikipedia/Rotation_matrix](https://en.wikipedia.org/wiki/Rotation_matrix).
#' @family mutate functions
#' @family rotation functions
#' @inheritParams multi_mutator
#' @examples
#' \donttest{
#' # Attach packages
#' library(rearrr)
#' library(dplyr)
#' library(ggplot2)
#'
#' # Set seed
#' set.seed(3)
#'
#' # Create a data frame
#' df <- data.frame(
#'   "x" = 1:12,
#'   "y" = c(1, 2, 3, 4, 9, 10, 11,
#'           12, 15, 16, 17, 18),
#'   "z" = runif(12),
#'   "g" = c(1, 1, 1, 1, 2, 2,
#'           2, 2, 3, 3, 3, 3)
#' )
#'
#' # Rotate values 45 degrees around x-axis
#' rotate_3d(df, x_col = "x", y_col = "y", z_col = "z", x_deg = 45)
#'
#' # Rotate all axes around the centroid
#' df_rotated <- df %>%
#'   rotate_3d(x_col = "x",
#'            y_col = "y",
#'            z_col = "z",
#'            x_deg = c(0, 72, 144, 216, 288),
#'            y_deg = c(0, 72, 144, 216, 288),
#'            z_deg = c(0, 72, 144, 216, 288),
#'            origin_fn = centroid)
#' df_rotated
#'
#' # Plot rotations
#' ggplot(df_rotated, aes(x = x_rotated, y = y_rotated, color = .degrees_str, alpha = z_rotated)) +
#'   geom_vline(xintercept = mean(df$x), size = 0.2, alpha = .4, linetype="dashed") +
#'   geom_hline(yintercept = mean(df$y), size = 0.2, alpha = .4, linetype="dashed") +
#'   geom_line(alpha = .4) +
#'   geom_point() +
#'   theme_minimal() +
#'   labs(x = "x", y="y", color="degrees", alpha="z (opacity)")
#'
#' # Plot 3d with plotly
#' plotly::plot_ly(
#'   x=df_rotated$x_rotated,
#'   y=df_rotated$y_rotated,
#'   z=df_rotated$z_rotated,
#'   type="scatter3d",
#'   mode="markers",
#'   color=df_rotated$.degrees_str
#' )
#'
#' # Rotate randomly around all axes
#' df_rotated <- df %>%
#'   rotate_3d(x_col = "x",
#'            y_col = "y",
#'            z_col = "z",
#'            x_deg = round(runif(10, min = 0, max = 360)),
#'            y_deg = round(runif(10, min = 0, max = 360)),
#'            z_deg = round(runif(10, min = 0, max = 360)),
#'            origin_fn = centroid)
#' df_rotated
#'
#' # Plot rotations
#' ggplot(df_rotated, aes(x = x_rotated, y = y_rotated, color = .degrees_str, alpha = z_rotated)) +
#'   geom_vline(xintercept = mean(df$x), size = 0.2, alpha = .4, linetype="dashed") +
#'   geom_hline(yintercept = mean(df$y), size = 0.2, alpha = .4, linetype="dashed") +
#'   geom_line(alpha = .4) +
#'   geom_point() +
#'   theme_minimal() +
#'   labs(x = "x", y="y", color="degrees", alpha="z (opacity)")
#'
#' # Plot 3d with plotly
#' plotly::plot_ly(
#'   x=df_rotated$x_rotated,
#'   y=df_rotated$y_rotated,
#'   z=df_rotated$z_rotated,
#'   type="scatter3d",
#'   mode="markers",
#'   color=df_rotated$.degrees_str
#' )
#'
#' # Rotate around group centroids
#' df_grouped <- df %>%
#'   dplyr::group_by(g) %>%
#'   rotate_3d(x_col = "x",
#'            y_col = "y",
#'            z_col = "z",
#'            x_deg = c(0, 72, 144, 216, 288),
#'            y_deg = c(0, 72, 144, 216, 288),
#'            z_deg = c(0, 72, 144, 216, 288),
#'            origin_fn = centroid)
#'
#' # Plot A and A rotated around group centroids
#' ggplot(df_grouped, aes(x = x_rotated, y = y_rotated, color = .degrees_str, alpha = z_rotated)) +
#'   geom_point() +
#'   theme_minimal() +
#'   labs(x = "x", y="y", color="degrees", alpha="z (opacity)")
#'
#' # Plot 3d with plotly
#' plotly::plot_ly(
#'   x=df_grouped$x_rotated,
#'   y=df_grouped$y_rotated,
#'   z=df_grouped$z_rotated,
#'   type="scatter3d",
#'   mode="markers",
#'   color=df_grouped$.degrees_str
#' )
#'
#' }
rotate_3d <- function(data,
                     x_col,
                     y_col,
                     z_col,
                     x_deg = 0,
                     y_deg = 0,
                     z_deg = 0,
                     suffix = "_rotated",
                     origin = c(0, 0, 0),
                     origin_fn = NULL,
                     keep_original = TRUE,
                     degrees_col_name = ".degrees",
                     origin_col_name = ".origin") {
  # Check arguments ####
  assert_collection <- checkmate::makeAssertCollection()
  checkmate::assert_data_frame(data, min.cols = 3, add = assert_collection)
  checkmate::assert_numeric(
    x_deg,
    lower = -360,
    upper = 360,
    any.missing = FALSE,
    min.len = 1,
    add = assert_collection
  )
  checkmate::assert_numeric(
    y_deg,
    lower = -360,
    upper = 360,
    any.missing = FALSE,
    min.len = 1,
    add = assert_collection
  )
  checkmate::assert_numeric(
    z_deg,
    lower = -360,
    upper = 360,
    any.missing = FALSE,
    min.len = 1,
    add = assert_collection
  )
  checkmate::assert_string(x_col, add = assert_collection)
  checkmate::assert_string(y_col, add = assert_collection)
  checkmate::assert_string(z_col, add = assert_collection)
  checkmate::assert_string(suffix, add = assert_collection)
  checkmate::assert_string(degrees_col_name, null.ok = TRUE, add = assert_collection)
  checkmate::assert_string(origin_col_name, null.ok = TRUE, add = assert_collection)
  checkmate::assert_numeric(origin,
                            len = 3,
                            any.missing = FALSE,
                            add = assert_collection)
  checkmate::assert_function(origin_fn, null.ok = TRUE, add = assert_collection)
  checkmate::reportAssertions(assert_collection)
  checkmate::assert_character(
    c(x_col, y_col, z_col),
    min.chars = 1,
    any.missing = FALSE,
    len = 3,
    unique = TRUE,
    add = assert_collection
  )
  if (!all(length(x_deg) == c(length(y_deg), length(z_deg)))) {
    assert_collection$push(
      paste0(
        "'x_deg', 'y_deg', and 'z_deg' must all have the same length but had lengths: ",
        paste0(c(
          length(x_deg), length(y_deg), length(z_deg)
        ), collapse = ", "),
        "."
      )
    )
  }

  checkmate::reportAssertions(assert_collection)
  # End of argument checks ####

  # Mutate for each degree
  output <- purrr::map_dfr(
    .x = purrr::transpose(list(x_deg, y_deg, z_deg)) %>%
      purrr::simplify_all(),
    .f = function(degrees) {
      out <- multi_mutator(
        data = data,
        mutate_fn = rotate_3d_mutator_method,
        check_fn = NULL,
        force_df = TRUE,
        min_dims = 3,
        keep_original = keep_original,
        cols = c(x_col, y_col, z_col),
        x_deg = degrees[[1]],
        y_deg = degrees[[2]],
        z_deg = degrees[[3]],
        suffix = suffix,
        origin = origin,
        origin_fn = origin_fn,
        origin_col_name = origin_col_name
      )

      if (!is.null(degrees_col_name)) {
        out[[degrees_col_name]] <-
          list_coordinates(degrees, names = c(x_col, y_col, z_col))
      }

      out
    }
  )

  if (!is.null(degrees_col_name)) {
    output <- paste_coordinates_column(output, degrees_col_name)
  }

  output

}


rotate_3d_mutator_method <- function(data,
                                    cols,
                                    x_deg,
                                    y_deg,
                                    z_deg,
                                    suffix,
                                    origin,
                                    origin_fn,
                                    origin_col_name) {
  # Extract columns
  x_col <- cols[[1]]
  y_col <- cols[[2]]
  z_col <- cols[[3]]

  # Create rotation matrix
  rotation_matrix <- create_rotation_matrix3d(x_deg = x_deg,
                                              y_deg = y_deg,
                                              z_deg = z_deg)

  # Extract x and y values
  x <- data[[x_col]]
  y <- data[[y_col]]
  z <- data[[z_col]]

  # Find origin if specified
  origin <- apply_coordinate_fn(
    dim_vectors = list(x, y, z),
    coordinates = origin,
    fn = origin_fn,
    num_dims = length(cols),
    coordinate_name = "origin",
    fn_name = "origin_fn",
    dim_var_name = "cols",
    allow_len_one = FALSE
  )

  # Move origin
  x <- x - origin[[1]]
  y <- y - origin[[2]]
  z <- z - origin[[3]]

  # Convert to matrix
  xyz_matrix <- rbind(x, y, z)

  # Apply rotation matrix
  xyz_matrix <- rotation_matrix %*% xyz_matrix

  # Extract x and y
  x <- xyz_matrix[1,]
  y <- xyz_matrix[2,]
  z <- xyz_matrix[3,]

  # Move origin
  x <- x + origin[[1]]
  y <- y + origin[[2]]
  z <- z + origin[[3]]

  # Add rotated columns to data
  data[[paste0(x_col, suffix)]] <- x
  data[[paste0(y_col, suffix)]] <- y
  data[[paste0(z_col, suffix)]] <- z

  # Add info columns
  if (!is.null(origin_col_name)) {
    data[[origin_col_name]] <- list_coordinates(origin, names = cols)
  }

  data

}
