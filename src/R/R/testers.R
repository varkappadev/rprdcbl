#' Special reproducibility test comparison for the PRNG states.
#'
#' @param a the LHS of the comparison
#' @param b the RHS of the comparison
#' @param .a the name/label of \code{a}
#' @param .b the name/label of \code{b}
#' @param .prefix the field prefix
#'
#' @return the error
.test.PRNG.pair <- function(a, b, .a = "latest", .b = "baseline", .prefix = "PRNG") {
    if (is.null(a) && is.null(b)) {
        return(NULL)
    }
    if (is.null(b) && (.b != "reference")) {
        return(NULL)
    }
    if (is.null(a)) {
        return(sprintf("The %s PRNG state is uninitialized but the %s state is not.",
            .a, .b))
    }
    if (!is.vector(a) || !is.numeric(a)) {
        return(sprintf("The %s PRNG is not a matrix as is expected", .a))
    }
    if (!is.null(b)) {
        if (!is.vector(b) || !is.numeric(b)) {
            return(sprintf("The %s PRNG is not a matrix as is expected",
                .b))
        }
        a.kind <- a[1]
        b.kind <- b[1]
        if (!(a.kind == b.kind)) {
            return(sprintf("PRNG states differ in kind between %s and %s configurations.",
                .a, .b))
        }
        if (.b == "reference" && !is.null(.deep.compare(a, b))) {
            return(sprintf("PRNG states differ between %s and %s configurations.",
                .a, .b))
        }
    }
    return(NULL)
}

#' PRNG comparison wrapper.
#'
#' @param latest the current boundary's value
#' @param previous the previous boundary's value
#' @param reference the reference (previous/baseline run) boundary value
#' @param .latest.type indicates what the \code{latest} parameter represents,
#'        only \code{'default'} and \code{'initial'} are currently supplied
#' @param .name the (short) name of the test
#'
#' @return the pairwise results
.test.PRNG <- function(latest, previous, reference, .latest.type = c("default",
    "initial", "final"), .name = "PRNG") {
    .latest.type <- match.arg(.latest.type)
    if (.latest.type == "default") {
        .latest.type <- "latest"
    }
    c(.test.PRNG.pair(latest, previous, .a = .latest.type, .b = "previous",
        .prefix = .name), .test.PRNG.pair(latest, reference, .a = .latest.type,
        .b = "reference", .prefix = .name))
}

#' Evaluates boundary information pairwise.
#'
#' @param latest the current boundary's value
#' @param previous the previous boundary's value
#' @param reference the reference (previous/baseline run) boundary value
#' @param .latest.type indicates what the \code{latest} parameter represents,
#'        only \code{'default'} and \code{'initial'} are currently supplied
#' @param .name the (short) name of the test
#'
#' @return the pairwise results
.deep.equality.test <- function(latest, previous, reference, .latest.type = c("default",
    "initial", "final"), .name = "") {
    .latest.type <- match.arg(.latest.type)
    if (.latest.type == "default") {
        .latest.type <- "latest"
    }
    c(.deep.compare(latest, previous, .x = .latest.type, .y = "previous",
        .prefix = .name), .deep.compare(latest, reference, .x = .latest.type,
        .y = "reference", .prefix = .name))
}

#' Wrapper around.
#'
#' @keywords internal
#' @seealso \code{.deep.equality.test} for the interface definition
.custom.test.wrapper <- function(latest, previous, reference, .latest.type = c("default",
    "initial", "final"), .name = "", .function = .cget("custom.test")) {
    .latest.type <- match.arg(.latest.type)
    if (.latest.type == "default") {
        .latest.type <- "latest"
    }
    result <- .function(latest, previous, reference)
    if (!is.null(result) && !is.list(result) && !is.character(result)) {
        warning("The custom test function returned an unexpected value.")
        return("Unexpected result of custom collector.")
    }
    return(result)
}

#' Returns all default testers (excluding custom).
#'
#' @return a list of testing functions
.default.testers <- function() {
    testers <- lapply(.default.collectors(), function(...) {
        .deep.equality.test
    })
    testers$PRNG <- .test.PRNG
    return(testers)
}

