context("Replication pass and failure.")

test.lock.file <- tempfile()
on.exit(unlink(test.lock.file))


test_that("Replication run.", {
    rprdcbl:::.reset.all.for.testing.only()
    expect_true(!file.exists(test.lock.file))

    expect_silent(pass_initial_boundary(lock_file = test.lock.file, fail = 'never'))
    expect_silent(pass_boundary())
    expect_silent(pass_final_boundary())
    expect_true(file.exists(test.lock.file))

    rprdcbl:::.reset.all.for.testing.only()
    expect_silent(pass_initial_boundary(lock_file = test.lock.file, fail = 'never'))
    expect_silent(pass_boundary())
    expect_silent(pass_final_boundary())
    expect_true(file.exists(test.lock.file))

    rprdcbl:::.reset.all.for.testing.only()
    expect_silent(pass_initial_boundary(lock_file = test.lock.file, fail = 'never'))
    expect_silent(pass_boundary())
    expect_silent(pass_boundary())
    expect_output(pass_final_boundary())
    expect_true(file.exists(test.lock.file))

    unlink(test.lock.file)
})

