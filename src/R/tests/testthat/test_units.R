context("Unit tests.")

expect_equal_deep_compare <- function(x, y, expect = TRUE, name = "custom") {
    xyy.result <- rprdcbl:::.deep.equality.test(
        x, y, y, .latest.type = "initial", .name = name)
    xyn.result <- rprdcbl:::.deep.equality.test(
        x, y, NULL, .latest.type = "initial", .name = name)
    xny.result <- rprdcbl:::.deep.equality.test(
        x, NULL, y, .latest.type = "initial", .name = name)

    expect_equal(length(xyn.result), length(xny.result))
    if (expect) {
        expect_length(xyy.result, 0L)
    } else {
        expect_true(length(xyy.result) > 0L)
    }
}

test_that("Comparison tests across possible data structures (largely internal)", {
    rprdcbl:::.reset.all.for.testing.only()

    cds.orig <- list(
        data = list(
            a = 1,
            b = "b",
            c = seq(1, 4),
            d = data.frame(X = 1, Y = 2),
            e = list(),
            f = NULL,
            g = 1L,
            h = matrix(c(1, 2, 3, 4), nrow = 2)
        )
    )
    cds <- cds.orig
    expect_equal_deep_compare(cds, NULL)
    expect_equal_deep_compare(cds, cds.orig)

    cds <- cds.orig
    cds$data$a <- "a"
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data$b <- "B"
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data$d[2, ] <- list(3, 4)
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data$d[2, ] <- list(5, 6)
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data$e <- list(TRUE)
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data$f <- 0L
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data["g"] <- list(NULL)
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data$h[1, 1] <- -1
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)

    cds <- cds.orig
    cds$data$h <- rbind(cds$data$h, cds$data$h)
    expect_equal_deep_compare(cds, cds.orig, expect = FALSE)
})

