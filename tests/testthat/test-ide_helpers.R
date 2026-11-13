library(testthat)
library(mockery)

test_that("is_ide() detects Positron and RStudio from environment variables", {
  withr::with_envvar(c(POSITRON = "1", RSTUDIO = ""), {
    expect_true(is_ide("positron"))
    expect_false(is_ide("rstudio"))
  })

  withr::with_envvar(c(POSITRON = "", RSTUDIO = "1"), {
    expect_false(is_ide("positron"))
    expect_true(is_ide("rstudio"))
  })

  withr::with_envvar(c(POSITRON = "", RSTUDIO = ""), {
    expect_false(is_ide("positron"))
    expect_false(is_ide("rstudio"))
  })
})

test_that("is_ide() never reports RStudio when running in Positron", {
  withr::with_envvar(c(POSITRON = "1", RSTUDIO = "1"), {
    expect_false(is_ide("rstudio"))
  })
})

test_that("select_folder() uses rstudioapi in RStudio", {
  mock_selectDir <- mock("C:/chosen")
  stub(select_folder, "is_ide", TRUE)
  stub(select_folder, "rstudioapi::isAvailable", TRUE)
  stub(select_folder, "rstudioapi::selectDirectory", mock_selectDir)

  expect_equal(select_folder("Pick"), "C:/chosen")
  expect_called(mock_selectDir, 1)
})

test_that("select_folder() uses svDialogs outside RStudio", {
  stub(select_folder, "is_ide", FALSE)
  stub(select_folder, "svDialogs::dlg_dir", list(res = "C:/chosen"))

  expect_equal(select_folder("Pick"), "C:/chosen")
})

test_that("select_folder() returns NULL when the dialog is cancelled", {
  stub(select_folder, "is_ide", FALSE)
  stub(select_folder, "svDialogs::dlg_dir", list(res = ""))
  expect_null(select_folder("Pick"))

  stub(select_folder, "is_ide", TRUE)
  stub(select_folder, "rstudioapi::isAvailable", TRUE)
  stub(select_folder, "rstudioapi::selectDirectory", NULL)
  expect_null(select_folder("Pick"))
})
