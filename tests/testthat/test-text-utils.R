# 1. test apostrofo function -----

test_that("apostrofo normalizes Italian apostrophes", {
  expect_equal(apostrofo("l'articolo"), "l' articolo")
  expect_equal(apostrofo("dell'economia"), "dell' economia")
  expect_equal(apostrofo("l' articolo"), "l' articolo")
  expect_equal(apostrofo("test"), "test")
})

test_that("apostrofo handles curly apostrophes", {
  expect_equal(apostrofo("l\u2019articolo"), "l' articolo")
})

test_that("apostrofo handles multiple apostrophes", {
  expect_equal(apostrofo("l'articolo dell'economia"), "l' articolo dell' economia")
})

# 2. test miostring function -----

test_that("miostring concatenates correctly", {
  expect_equal(mieitesti:::miostring(c("a", "b", "c")), "a b c")
  expect_equal(mieitesti:::miostring("single"), "single")
})

test_that("miostring truncates with width", {
  result <- mieitesti:::miostring(c("this is a long text"), width = 10)
  expect_equal(nchar(result), 10)
  expect_true(grepl("\\.\\.\\.\\.$", result))
})

test_that("miostring handles NULL width", {
  expect_equal(mieitesti:::miostring(c("a", "b"), width = NULL), "a b")
  expect_equal(mieitesti:::miostring(c("a", "b"), width = 0), "a b")
})

test_that("miostring errors on negative width", {
  expect_error(mieitesti:::miostring("test", width = -1), "'width' must be positive")
})
