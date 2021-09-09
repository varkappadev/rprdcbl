context("Standard workflow tests.")
test_that("Single run works.", {
    rprdcbl:::.reset.all.for.testing.only()
    expect_silent(pass_initial_boundary())
    expect_silent(pass_boundary())
    expect_silent(pass_final_boundary())
    expect_false(is_failing())
    expect_false(is.null(get_state()))
})

test_that("Fail with illegal arguments", {
    rprdcbl:::.reset.all.for.testing.only()
    expect_error(pass_initial_boundary(custom_collect = "string"))

    rprdcbl:::.reset.all.for.testing.only()
    expect_error(pass_initial_boundary(custom_test = "string"))
})

test_that("PRNG", {
    rprdcbl:::.reset.all.for.testing.only()
    RNGkind(kind = "Knuth-TAOCP")
    expect_silent(pass_initial_boundary())
    RNGkind(kind = "Knuth-TAOCP-2002")
    expect_output(pass_final_boundary())
    rm(".Random.seed", envir = .GlobalEnv)
})

test_that("Custom test", {
    rprdcbl:::.reset.all.for.testing.only()
    expect_silent(pass_initial_boundary(
        custom_collect = function() {
            return(TRUE)
        },
        custom_test = function(l, p, r) {
            return(sprintf("(%s, %s, %s)", format(l), format(p), format(r)))
        }
    ))
    expect_output(pass_final_boundary(), "^.*\\(TRUE, NULL, NULL\\).*$")
})

