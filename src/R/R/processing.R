.data <- new.env()

#' Initializes tracked data structures.
.reset.data <- function() {
    rm(list = ls(envir = .data, all.names = TRUE), envir = .data)
    .data[["failing"]] <- FALSE
    .data[["boundaries"]] <- list()
    .data[["reference"]] <- NULL
    .data[["finalized"]] <- FALSE
    invisible(NULL)
}

#' Returns a copy of the current tracked state data.
.copy.state <- function() {
    list(boundaries = .data[["boundaries"]], reference = .data[["reference"]],
        failing = .failure.detected(force = FALSE))
}

#' Determines if a failure has been detected.
#'
#' @param force determines if tests should be forced before makeing a
#'    determination of the current state
#' @return \code{TRUE} if failure has been detected, \code{FALSE} otherwise
.failure.detected <- function(force = FALSE) {
    indicator <- .data[["failing"]]
    return(!is.null(indicator) && any(indicator))
}

#' Collects state information.
#'
#' @param label the boundary label
#' @param final indicates if the boundary is the final one
#' @return the summary of the boundary state, in fact a copy of what is stored
#'   internally
.collect <- function(label = NULL, final = FALSE) {
    boundary.number <- length(.data[["boundaries"]]) + 1L
    if (is.null(label)) {
        if (final) {
            label <- "FINAL"
        } else if (boundary.number == 1) {
            label <- "INITIAL"
        } else {
            label <- sprintf("BOUNDARY%d", boundary.number)
        }
    }
    boundary.data <- lapply(.cget("collectors"), function(x) {
        x()
    })
    boundary.summary <- list(label = label, number = boundary.number, final = final,
        data = boundary.data)
    .data[["boundaries"]][[boundary.number]] <- boundary.summary
    return(boundary.summary)
}

#' Executes all testers to compare collected data to previous and reference
#' values.
#'
#' @importFrom stats setNames
#' @importFrom utils hasName
.test <- function() {
    if (is.null(.data[["boundaries"]]) || length(.data[["boundaries"]]) <
        1L) {
        return(invisible(NULL))
    }

    for (b in seq(length(.data[["boundaries"]]))) {
        results <- character()
        latest <- .data[["boundaries"]][[b]]
        if (hasName(latest, "results")) {
            next
        }
        previous <- if (b > 1) {
            .data[["boundaries"]][[b - 1]]
        } else {
            NULL
        }
        if (is.null(.data[["reference"]])) {
            reference <- NULL
        } else if (length(.data[["reference"]]) >= b) {
            reference <- .data[["reference"]][[b]]
        } else {
            results <- c(results, sprintf("The boundary #%d does not have a corresponding boundary in the reference boundary.",
                b))
            reference <- NULL
        }

        if (!is.null(reference) && (latest$label != reference$label)) {
            results <- c(results, sprintf("The label for boundary #%d does not match the reference value ('%s' != '%s').",
                b, latest$label, reference$label))
        }

        # run testers
        for (test in names(.cget("testers"))) {
            test.fun <- .cget("testers")[[test]]
            latest.type <- if (b == 1L) {
                "initial"
            } else {
                "default"
            }
            results <- c(results, test.fun(latest$data[[test]], previous$data[[test]],
                reference$data[[test]], .name = test, .latest.type = latest.type))
        }
        .data[["boundaries"]][[b]]$results <- results
    }
    .data[["failing"]] <- any(sapply(.data[["boundaries"]], function(b) {
        hasName(b, "results") && (length(b$results) > 0L)
    }))
    invisible(NULL)
}

#' Function factory to return a given valid function or a no-op function if it
#' is \code{NULL}.
#'
#' @param fun a valid function, if it is not a function, an error will be raised
#' @param name the name of the function used only in the error message
#' @return \code{fun} or a no-op function
.self.or.noop <- function(fun, name = "`fun`") {
    if (is.null(fun)) {
        return(function(l, p, r) {
            return(NULL)
        })
    } else if (is.function(fun)) {
        return(fun)
    } else {
        stop(name, " must be a function (or NULL).")
    }
}

#' Checks if the package is in a valid state.
#'
#' @param fail indicates if an error should be raised in the event of an invalid
#'   state
#' @return \code{TRUE} if the state is valid, \code{FALSE} oterhwise unless an
#'   error has been raised
.check.state <- function(fail = TRUE) {
    if ("df35e40b-0782-479b-bd6b-68bf3921ab57" == .cget(".MAGIC", "")) {
        return(TRUE)
    } else if (fail) {
        stop("Invalid state or uninitialized package.")
    } else {
        return(FALSE)
    }
}

#' Imports data from the lock file.
.load.lock.file <- function() {
    fname <- .cget("lock.file")
    if (!is.null(fname) && file.exists(fname)) {
        reference.env <- new.env()
        load(fname, envir = reference.env)
        if (exists("boundaries", envir = reference.env)) {
            .data[["reference"]] <- reference.env[["boundaries"]]
        }
    }
    invisible(NULL)
}

#' Exports data to the lock file.
.save.lock.file <- function() {
    if (.failure.detected(force = TRUE)) {
        return(NULL)
    }
    if (!.data[["finalized"]]) {
        stop("The lock file cannot be saved prior to finalization.")
    }
    fname <- .cget("lock.file")
    if (!is.null(fname) && is.null(.data[["reference"]]) && !file.exists(fname)) {
        save(list = c("boundaries"), file = fname, envir = .data)
    }
    invisible(NULL)
}

#' Sets up testing and output parameters.
#'
#' @param output.mode Indicates how messages are to be formatted.
#' @param lock.file The reproducibility lock file to use. It stores
#'        configurations to be checked against.
#' @param failing Indicates whether an error should be produced if failure is
#'        detected. 'late' indicates failure at the final boundary.
#' @param custom.collect A custom collector function to be called for additional
#'        configuration options.
#' @param custom.test A custom testing function to determine failure on the
#'        custom data. It must accept the values (latest, previous, reference)
#'        and return FALSE if failure is detected and TRUE otherwise.
.configure.testing <- function(output.mode = c("pretty", "parsable"), lock.file = NULL,
    failing = c("never", "late", "early"), custom.collect = NULL, custom.test = NULL) {

    output.mode <- match.arg(output.mode)
    failing <- match.arg(failing)
    if (.check.state(fail = FALSE)) {
        stop("Cannot configure pre-configured package. Restart R to run the script again.")
    }

    .reset.data()
    .cset(".MAGIC", "df35e40b-0782-479b-bd6b-68bf3921ab57")
    .cset("output.mode", output.mode)
    .cset("failing", failing)
    .cset("lock.file", lock.file)
    .cset("custom.collect", .self.or.noop(custom.collect, "custom.collect"))
    .cset("custom.test", .self.or.noop(custom.test, "custom.test"))
    .cset("collectors", c(.default.collectors(), list(custom = .cget("custom.collect"))))
    .cset("testers", c(.default.testers(), list(custom = .custom.test.wrapper)))

    .load.lock.file()
    invisible(NULL)
}

#' Triggers all boundary-related functionality
#'
#' @param label the boundary label
#' @param quiet indicates if report output should be suppressed
#' @param final indicates if the boundary is to be considered the final one
.process.boundary <- function(label = NULL, quiet = TRUE, final = TRUE) {
    .check.state()
    if (.data[["finalized"]]) {
        stop("Final boundary already reached.")
    }
    .collect(label = label, final = final)
    .test()
    if (final) {
        .data[["finalized"]] <- TRUE
        .save.lock.file()
    }
    fail.now <- ("early" == .cget("failing")) || (final && ("never" != .cget("failing")))
    if (!quiet) {
        boundary.number <- length(.data[["boundaries"]])
        if (boundary.number < 1L) {
            stop("Unexpected state detected.")
        }
        .print.report(if (final) {
            seq(1, boundary.number)
        } else {
            boundary.number
        }, mode = .cget("output.mode"))
    }
    if (fail.now && .failure.detected(force = TRUE)) {
        stop("A reproducibility error has been detected.")
    }
    invisible(NULL)
}

#' Internal reset command for development and testing only!
.reset.all.for.testing.only <- function() {
    rm(list = ls(envir = .data, all.names = TRUE), envir = .data)
    rm(list = ls(envir = .configuration, all.names = TRUE), envir = .configuration)
}
