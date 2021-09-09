.configuration <- new.env()

#' Retrieves a configuration key.
#'
#' @param key the lookup key
#' @param def the default value if no value with the given key exists
#'
#' @return the configuration value
.cget <- function(key, def = NULL) {
    result <- .configuration[[key]]
    if (is.null(result)) {
        return(def)
    } else {
        return(result)
    }
}

#' Sets a configuration value.
#'
#' @param key the lookup key
#' @param val the new value
.cset <- function(key, val = NULL) {
    .configuration[[key]] <- val
}

