#' Collects variable names of the global environment
#'
#' @return a character array of names
.collect.globals <- function() {
    ls(envir = .GlobalEnv, all.names = TRUE, sorted = TRUE)
}

#' Collects R version information.
#'
#' @return a list of version elements
.collect.version <- function() {
    list(major = R.version$major, minor = R.version$minor, revision = R.version$"svn rev")
}

#' Collects platform architecture information.
#'
#' @return the short name of the platform (architecture)
.collect.platform <- function() {
    R.version$arch
}

#' Collects operating system information
#'
#' @return the operating system identifier
.collect.os <- function() {
    sessionInfo()$running
}

#' Extracts package name and version from sessionInfo()-like output.
#'
#' @param x an individual package description
#'
#' @return a data frame of package information
.name.version.extraction <- function(x) {
    if (is.character(x)) {
        pkgs <- x
        versions <- sapply(pkgs, function(p) {
            as.character(packageVersion(p))
        })
    } else {
        pkgs <- names(x)
        versions <- sapply(pkgs, function(p) {
            x[[p]]$Version
        })
    }
    data.frame(Package = pkgs, Version = versions, stringsAsFactors = FALSE)
}


#' Collects package information (name and version).
#'
#' @return a data frame of package information
#'
#' @importFrom utils packageVersion
#' @importFrom utils sessionInfo
.collect.packages <- function() {
    loaded.packages <- lapply(sessionInfo()[c("loadedOnly", "basePkgs", "otherPkgs")],
        .name.version.extraction)
    loaded.packages <- rbind(loaded.packages$basePkgs, loaded.packages$loadedOnly,
        loaded.packages$otherPkgs)
    colnames(loaded.packages) <- c("package", "version")
    rownames(loaded.packages) <- loaded.packages$package
    return(lapply(setNames(split(loaded.packages, seq(nrow(loaded.packages))),
        rownames(loaded.packages)), as.list))
}

#' Collects LAPACK library information, currently the version only.
#'
#' @return a list of LAPACK-specific information
.collect.lib.lapack <- function() {
    list(version = La_version())
}

#' Collects PRNG state information (complete). This is for the global seed only.
#'
#' @return a copy of the random seed
.collect.prng <- function() {
    value <- mget(".Random.seed", envir = .GlobalEnv, ifnotfound = list(.Random.seed = NULL))$.Random.seed
    if (is.null(value)) {
        return(NULL)
    } else {
        return(value)
    }
}


#' Collects PRNG state information (complete). This is for the global seed only.
#'
#' @return a copy of the random seed
.collect.locale <- function() {
    value <- list()
    for (k in names(Sys.getenv())) {
        if (k == "LANG" || k == "LANGUAGE" || grepl("^LC_[A-Z]*$", k)) {
            value[k] <- Sys.getenv(k)
        }
    }
    return(value)  # an empty environment is also a setting
}

#' Returns all default collectors (excluding the custom collector if any).
#'
#' @return a list of collectors
.default.collectors <- function() {
    list(environment = function() {
        return("R")
    }, variant = function() {
        return(NULL)
    }, version = .collect.version, platform = .collect.platform, os = .collect.os,
        packages = .collect.packages, LAPACK = .collect.lib.lapack, PRNG = .collect.prng,
        locale = .collect.locale, global_names = .collect.globals)
}

