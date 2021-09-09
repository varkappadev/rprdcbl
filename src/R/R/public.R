#' Indicates the post-configuration (initial) boundary.
#'
#' Allows for configuration of the package in subsequent calls.
#'
#' @param label A label to apply to the boundary or NULL for auto-labelling.
#' @param quiet If TRUE, suppresses output.
#' @param output_mode Indicates how messages are to be formatted.
#' @param lock_file The reproducibility lock file to use. It stores
#'        configurations to be checked against.
#' @param fail Indicates whether an error should be produced if failure is
#'        detected. 'late' indicates failure at the final boundary.
#' @param custom_collect A custom collector function to be called for additional
#'        configuration options.
#' @param custom_test A custom testing function to determine failure on the
#'        custom data. It must accept the values (latest, previous, reference)
#'        and return FALSE if failure is detected and TRUE otherwise.
#' @export
pass_initial_boundary <- function(label = NULL, quiet = TRUE, output_mode = c("pretty",
    "parsable"), lock_file = NULL, fail = c("never", "late", "early"), custom_collect = NULL,
    custom_test = NULL) {

    output_mode <- match.arg(output_mode)
    fail <- match.arg(fail)

    .configure.testing(output_mode, lock_file, fail, custom_collect, custom_test)
    .process.boundary(label = label, quiet = quiet, final = FALSE)
    invisible(NULL)
}

#' Standard .-form alias for \link{pass_initial_boundary}
#'
#' @param label see \link{pass_initial_boundary}
#' @param quiet see \link{pass_initial_boundary}
#' @param output_mode see \link{pass_initial_boundary}
#' @param lock_file see \link{pass_initial_boundary}
#' @param fail see \link{pass_initial_boundary}
#' @param custom_collect see \link{pass_initial_boundary}
#' @param custom_test see \link{pass_initial_boundary}
#' @export
#' @seealso [pass_initial_boundary()]
pass.initial.boundary <- pass_initial_boundary

#' Indicates a staged boundary.
#'
#' @param label A label to apply to the boundary or NULL for auto-labelling.
#' @param quiet If TRUE, suppresses output.
#' @export
pass_boundary <- function(label = NULL, quiet = TRUE) {
    .process.boundary(label = label, quiet = quiet, final = FALSE)
    invisible(NULL)
}

#' Standard .-form alias for \link{pass_boundary}
#'
#' @param label see \link{pass_boundary}
#' @param quiet see \link{pass_boundary}
#' @export
#' @seealso [pass_boundary()]
pass.boundary <- pass_boundary

#' Indicates the pre-exit (final) boundary.
#'
#' @param label A label to apply to the boundary or NULL for auto-labelling.
#' @param quiet If TRUE, suppresses output.
#' @export
pass_final_boundary <- function(label = NULL, quiet = FALSE) {
    .process.boundary(label = label, quiet = quiet, final = TRUE)
    invisible(NULL)
}

#' Standard .-form alias for \link{pass_final_boundary}
#'
#' @param label see \link{pass_final_boundary}
#' @param quiet see \link{pass_final_boundary}
#' @export
#' @seealso [pass_final_boundary()]
pass.final.boundary <- pass_final_boundary

#' Returns complete state information at the time of the call.
#'
#' @return The current state of the reproducibility checks.
#' @export
get_state <- function() {
    invisible(.copy.state())
}

#' Standard .-form alias for \link{get_state}
#'
#' @export
#' @seealso [get_state()]
get.state <- get_state

#' Returns the current failure state.
#'
#' If called before the final boundary, the function may return FALSE even if
#' it will indicate failure subsequently for a reason detected earlier.
#'
#' @return TRUE if a reproducibility failure has been detected,
#'         FALSE otherwise
#' @export
is_failing <- function() {
    invisible(.failure.detected(force = FALSE))
}

#' Standard .-form alias for \link{is_failing}
#'
#' @export
#' @seealso [is_failing()]
is.failing <- is_failing
