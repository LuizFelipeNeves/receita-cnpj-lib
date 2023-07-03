context("output")

cnpj <- '00000000000191'

if (has_conn()) {
  test_that("downloads html when output is html", {
    r <- buscar_cnpj(cnpj, output = 'html')
    f <- paste0(cnpj, '.html')
    expect_true(r)
    expect_true(file.exists(f))
    if (file.exists(f)) file.remove(f)
  })

  test_that("downloads html and returns df when output is both", {
    r <- buscar_cnpj(cnpj, output = 'both')
    f <- paste0(cnpj, '.html')
    expect_true(file.exists(f))
    expect_is(r, 'tbl_df')
    if (file.exists(f)) file.remove(f)
  })

  test_that("returns df when output is df", {
    r <- buscar_cnpj(cnpj, output = 'df')
    f <- paste0(cnpj, '.html')
    expect_false(file.exists(f))
    expect_is(r, 'tbl_df')
    if (file.exists(f)) file.remove(f)
  })

  test_that("downloads html when output is html and QSA is TRUE", {
    r <- buscar_cnpj(cnpj, output = 'html', qsa = TRUE)
    f <- paste0(cnpj, '.html')
    f2 <- paste0(cnpj, '_qsa.html')
    expect_true(r)
    expect_true(file.exists(f))
    expect_true(file.exists(f2))
    if (file.exists(f)) file.remove(f)
    if (file.exists(f2)) file.remove(f2)
  })

  test_that("downloads html and returns df when output is both and QSA is TRUE", {
    r <- buscar_cnpj(cnpj, output = 'both', qsa = TRUE)
    f <- paste0(cnpj, '.html')
    f2 <- paste0(cnpj, '_qsa.html')
    expect_true(file.exists(f))
    expect_true(file.exists(f2))
    expect_is(r, 'list')
    expect_length(r, 3L)
    if (file.exists(f)) file.remove(f)
    if (file.exists(f2)) file.remove(f2)
  })

  test_that("returns list when output is df and QSA is TRUE", {
    r <- buscar_cnpj(cnpj, output = 'df', qsa = TRUE)
    f <- paste0(cnpj, '.html')
    f2 <- paste0(cnpj, '_qsa.html')
    expect_false(file.exists(f))
    expect_false(file.exists(f2))
    expect_is(r, 'list')
    expect_length(r, 3L)
    if (file.exists(f)) file.remove(f)
    if (file.exists(f2)) file.remove(f2)
  })
}


