# 1. test miestop data -----

test_that("miestop is a character vector", {
  expect_type(miestop, "character")
  expect_gt(length(miestop), 100)
})

test_that("miestop contains expected Italian stopwords", {
  expect_true("il" %in% miestop)
  expect_true("di" %in% miestop)
  expect_true("che" %in% miestop)
})

test_that("miestop contains domain-specific terms", {
  expect_true("milione" %in% miestop)
  expect_true("trimestre" %in% miestop)
  expect_true("italia" %in% miestop)
})

# 2. test emp_dictionary data -----

test_that("emp_dictionary is a list", {
  expect_type(emp_dictionary, "list")
})

test_that("emp_dictionary has correct structure", {
  expected_names <- c("match", "politica", "pal", "offerta", "domanda")
  expect_true(all(expected_names %in% names(emp_dictionary)))
  expect_equal(length(emp_dictionary), 5)
})

test_that("emp_dictionary elements are character vectors", {
  for (topic in names(emp_dictionary)) {
    expect_type(emp_dictionary[[topic]], "character")
    expect_gt(length(emp_dictionary[[topic]]), 0)
  }
})

test_that("emp_dictionary contains expected patterns", {
  expect_true("salar*" %in% emp_dictionary$match)
  expect_true("govern*" %in% emp_dictionary$politica)
  expect_true("lavor*" %in% emp_dictionary$offerta)
})
