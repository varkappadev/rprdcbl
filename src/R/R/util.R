#' Compares two objects including recursive comparisons of fields, rows, etc.
#'
#' This function is intended for lists, scalars, and data frames only (no
#' objects in particular).
#'
#' @param x the LHS of a comparison
#' @param y the RHS of a comparison
#' @param .x the name (or label) of `x`
#' @param .y the name (or label) of `y`
#' @param .prefix the logical path to the values (symbolic)
#'
#' @return the messages (if any) explaining differences
#'
#' @section TODO:
#'  handling data frames could be smarter but this may apply
#'  additional assumptions (regarding ordering, duplication, ...).
.deep.compare <- function(x, y, .x = "observed", .y = "expected", .prefix = "") {
    # equality tests apply to all numbers including floating point in
    # this context, this is intentional behavior
    if (is.null(x) && is.null(y)) {
        return(NULL)
    }
    if (is.null(y) && (.y == "reference") && !grepl("$", .prefix, fixed = TRUE)) {
        return(NULL)
    }
    if (is.null(y) && (.x == "initial") && !grepl("$", .prefix, fixed = TRUE)) {
        return(NULL)
    }
    .nnn.message <- "The %s value of '%s' was NULL but the %s value is not."
    if (is.null(y) && !is.null(x)) {
        return(sprintf(.nnn.message, .y, .prefix, .x))
    }
    if (is.null(x)) {
        return(sprintf(.nnn.message, .x, .prefix, .y))
    }
    if (!all(class(x) == class(y))) {
        return(sprintf("Mismatching classes for %s and %s in '%s'.", .x,
            .y, .prefix))
    }
    if (is.atomic(x) && is.atomic(y) && (length(x) == 1L) && (length(y) ==
        1L)) {
        if (x != y) {
            return(sprintf("Values ('%s') do not match %s != %s (%s != %s).",
                .prefix, .x, .y, format(x), format(y)))
        }
    }
    if (is.atomic(x) && is.atomic(y)) {
        if (!all(dim(x) == dim(y)) || !(length(x) == length(y))) {
            return(sprintf("Value matrices in '%s' do not have the same size between %s and %s.",
                .prefix, .x, .y))
        }
        if (!all(x == y)) {
            return(sprintf("Value matrices in '%s' are not equal for %s and %s values.",
                .prefix, .x, .y))
        } else {
            return(invisible(NULL))
        }
    }
    if (is.data.frame(x)) {
        if (!setequal(colnames(x), colnames(y))) {
            return(sprintf("Column names of '%s' differ between %s and %s.",
                .prefix, .x, .y))
        }
        if (NROW(x) != NROW(y)) {
            return(sprintf("Data frames for %s differ in length between %s and %s.",
                .prefix, .x, .y))
        }
        if (!all(apply(as.matrix(x) == as.matrix(y[, colnames(x)]), 1, all))) {
            return(sprintf("Values differ for %s between %s and %s.", .prefix,
                .x, .y))
        }
    }
    if (is.list(x)) {
        messages <- character()
        if (length(x) != length(y)) {
            messages <- c(messages, sprintf("Lists in %s differ in length between %s and %s.",
                .prefix, .x, .y))
        }
        if (!setequal(names(x), names(y))) {
            x.only <- setdiff(names(x), names(y))
            y.only <- setdiff(names(y), names(x))
            if (length(x.only) > 0L) {
                messages <- c(messages, sprintf("Elements in '%s' only contained in the %s list (but not the %s): %s",
                  .prefix, .x, .y, paste(x.only, sep = " ,")))
            }
            if (length(y.only) > 0L) {
                messages <- c(messages, sprintf("Elements in '%s' only contained in the %s list (but not the %s): %s",
                  .prefix, .y, .x, paste(y.only, sep = " ,")))
            }
        }
        common.names <- intersect(names(x), names(y))
        if (!is.null(common.names)) {
            for (n in common.names) {
                messages <- c(messages, .deep.compare(x[[n]], y[[n]], .x,
                  .y, paste(.prefix, n, sep = "$")))
            }
        } else {
            shortest <- min(length(x), length(y))
            if (shortest > 0L) {
                for (n in 1:shortest) {
                  messages <- c(messages, .deep.compare(x[[n]], y[[n]], .x,
                    .y, paste(.prefix, n, sep = "$")))
                }
            }
        }
        return(messages)
    }
    return(sprintf("The collected information for '%s' cannot be compared by the default method.",
        .prefix))
}

