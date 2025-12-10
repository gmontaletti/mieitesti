# 1. test function existence -----

test_that("scraping functions exist and are callable", {
  expect_true(is.function(sussidiario))
  expect_true(is.function(leggi_pagina))
  expect_true(is.function(pag_as_frame))
})

test_that("istat functions exist and are callable", {
  expect_true(is.function(sintesi))
  expect_true(is.function(istat_feeds))
})

# 2. test istat_feeds returns expected URLs -----

test_that("istat_feeds returns character vector", {
  feeds <- istat_feeds()
  expect_type(feeds, "character")
  expect_gt(length(feeds), 0)
})

test_that("istat_feeds contains valid URLs", {
  feeds <- istat_feeds()
  expect_true(all(grepl("^https://", feeds)))
  expect_true(all(grepl("istat\\.it", feeds)))
})

# 3. test pag_as_frame structure -----

test_that("pag_as_frame creates correct data.table structure", {
  mock_list <- list(
    list("2024-01-01", "Title 1", "Text 1", "http://example.com/1"),
    list("2024-01-02", "Title 2", "Text 2", "http://example.com/2")
  )

  result <- pag_as_frame(mock_list)

  expect_s3_class(result, "data.table")
  expect_equal(names(result), c("data", "titolo", "text", "item_link"))
  expect_equal(nrow(result), 2)
})
