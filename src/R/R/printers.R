#' Format the boundary information for easy reading.
#'
#' @param boundary a list with boundary information
#'
#' @return a character array with all boundary-related information
.formatter.pretty <- function(boundary) {
    if (is.null(boundary) || length(boundary) < 1L || !hasName(boundary,
        "results") || length(boundary$results) == 0L) {
        return(invisible(NULL))
    }
    sprintf("Boundary \"%s\" (#%d): %s", boundary$label, boundary$number,
        sapply(boundary$results, function(x) {
            sprintf("  %s\n", x)
        }))
}

#' Format the boundary information for parsing.
#'
#' @param boundary a list with boundary information
#'
#' @return a character array with all boundary-related information
#'
#' @importFrom utils hasName
.formatter.parsable <- function(boundary) {
    if (is.null(boundary) || length(boundary) < 1L || !hasName(boundary,
        "results") || length(boundary$results) == 0L) {
        return(invisible(NULL))
    }
    sapply(boundary$results, function(x) {
        sprintf("E: B=%d L=\"%s\" C=\"%s\"\n", boundary$number, boundary$label,
            gsub("\"", "\\\"", gsub("\n", "\\n", x, fixed = TRUE), fixed = TRUE))
    })
}

#' Prints a report about the given boundaries.
#'
#' @param b the boundary index or an array of boundary indices to print
#' @param boundaries the list of boundary information
#' @param mode indicates the formatting (\code{'pretty'} or \code{'parsable'})
#'
#' @note If the mode argument is incorrect, parsable output will be used
#'       without warning.
.print.report <- function(b = NULL, boundaries = .data[["boundaries"]], mode = "pretty") {
    if (is.null(b)) {
        b <- length(boundaries)
    }
    formatter <- if (mode == "pretty") {
        .formatter.pretty
    } else {
        .formatter.parsable
    }
    items <- sapply(b, function(x) {
        formatter(boundaries[[x]])
    })
    items <- items[!sapply(items, is.null)]
    cat(unlist(items), sep = "")
}
