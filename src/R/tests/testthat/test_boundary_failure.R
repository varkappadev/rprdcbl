context("Boundary pass and failure.")

test_that("Single failure output.", {
    rprdcbl:::.reset.all.for.testing.only()
    expect_silent(pass_initial_boundary(fail = 'never'))
    library(roxygen2)
    expect_silent(pass_boundary())
    expect_output(pass_final_boundary())
    detach("package:roxygen2", unload = TRUE)
})

test_that("Single failure error.", {
    rprdcbl:::.reset.all.for.testing.only()
    expect_silent(pass_initial_boundary(fail = 'late'))
    library(roxygen2)
    expect_silent(pass_boundary())
    expect_output(expect_error(pass_final_boundary()))
    detach("package:roxygen2", unload = TRUE)
})

test_that("Single failure error with parsable output.", {
    rprdcbl:::.reset.all.for.testing.only()
    expect_silent(pass_initial_boundary(output_mode = 'parsable', fail = 'late'))
    expect_silent(pass_boundary())
    library(roxygen2)
    expect_output(expect_error(pass_final_boundary()))
    detach("package:roxygen2", unload = TRUE)
})

