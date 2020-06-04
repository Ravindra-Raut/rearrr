% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mutators.R
\name{multi_mutator}
\alias{multi_mutator}
\title{Wrapper for running multicolumn mutator methods}
\usage{
multi_mutator(
  data,
  mutate_fn,
  check_fn,
  cols = NULL,
  suffix = "_mutated",
  force_df = TRUE,
  keep_original = TRUE,
  ...
)
}
\arguments{
\item{data}{\code{data.frame} or \code{vector}.}

\item{mutate_fn}{Mutator to apply.}

\item{check_fn}{Function with checks post-preparation of \code{data} and \code{cols}.
Should not return anything.}

\item{cols}{Columns to mutate values of. Must be specified when \code{data} is a \code{data frame}.}

\item{suffix}{Suffix to add to the names of the generated columns.}

\item{force_df}{Whether to return a \code{data.frame} when \code{data} is a \code{vector}.}

\item{...}{Named arguments for the \code{mutate_fn}.}
}
\value{
The mutated \code{data.frame}.
}
\description{
Wrapper for running multicolumn mutator methods
}
\keyword{internal}