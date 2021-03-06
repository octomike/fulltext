context("ft_search")

test_that("ft_search returns...", {
  skip_on_cran()
  
  aa <- ft_search(query = 'ecology', from = 'plos')
  flds <- c('id','author','eissn','journal','counter_total_all','alm_twitterCount')
  bb <- ft_search(query = 'climate change', from = 'plos', plosopts = list(fl = flds))
  Sys.sleep(1)
  cc <- ft_search(query = 'ecology', from = 'crossref')
  dd <- ft_search(query = 'owls', from = 'biorxiv')
  
  # correct classes
  expect_is(aa, "ft")
  expect_is(bb, "ft")
  expect_is(cc, "ft")
  expect_is(dd, "ft")
  
  expect_is(aa$plos, "ft_ind")
  expect_is(aa$bmc, "ft_ind")
  expect_is(bb$plos, "ft_ind")
  expect_is(cc$crossref, "ft_ind")
  expect_is(dd$biorxiv, "ft_ind")
  
  expect_is(aa$plos$found, "integer")
  expect_is(aa$plos$license, "list")
  expect_is(aa$plos$opts, "list")
  expect_is(aa$plos$data, "data.frame")
  expect_is(aa$plos$data$id, "character")
  
  expect_equal(
    sort(names(bb$plos$data)),
    sort(c("id", "alm_twitterCount", "counter_total_all", "journal", "eissn", "author")))
  
  expect_is(cc$crossref$data, "data.frame")
  expect_true(cc$crossref$opts$filter[[1]])
  
  expect_is(dd$biorxiv$data, "data.frame")
  expect_match(dd$biorxiv$data$url[1], "http")
})

test_that("ft_search works with scopus", {
  skip_on_cran()
  
  aa <- ft_search(query = 'ecology', from = 'scopus')
  
  expect_is(aa, "ft")
  expect_is(aa$scopus, "ft_ind")
  expect_is(aa$scopus$opts, "list")
  expect_equal(aa$scopus$source, "scopus")
  expect_type(aa$scopus$found, "double")
  expect_is(aa$scopus$data, "data.frame")
  
  ## no results
  res <- ft_search(query = '[TITLE-ABS-KEY (("Chen caeculescens atlantica") AND (demograph* OR model OR population) AND (climate OR "climatic factor" OR "climatic driver" OR precipitation OR rain OR temperature))]', from = 'scopus')
  expect_is(res, "ft")
  expect_equal(NROW(res$scopus$data), 0)
})

test_that("ft_search works for larger requests", {
  skip_on_cran()
  skip_on_travis()
  
  res_entrez <- ft_search(query = 'ecology', from = 'entrez', limit = 200)
  expect_is(res_entrez, "ft")
  expect_is(res_entrez$entrez, "ft_ind")
  expect_equal(NROW(res_entrez$entrez$data), 200)
  
  res_plos <- ft_search(query = 'ecology', from = 'plos', limit = 200)
  expect_is(res_plos, "ft")
  expect_is(res_plos$plos, "ft_ind")
  expect_equal(NROW(res_plos$plos$data), 200)
  
  res_cr <- ft_search(query = 'ecology', from = 'crossref', limit = 200)
  expect_is(res_cr, "ft")
  expect_is(res_cr$crossref, "ft_ind")
  expect_equal(NROW(res_cr$crossref$data), 200)
})


test_that("ft_search fails well", {
  skip_on_cran()
  
  expect_error(ft_search(query = 'ecology', from = 'entrez', limit = 2000), 
               "HTTP failure 414, the request is too large")
  ## FIXME - add catches for plos, other sources
  expect_error(ft_search(query = 'ecology', from = 'crossref', limit = 2000), 
               "limit parameter must be 1000 or less")

  # no query given
  expect_error(ft_search(from = 'plos'), "argument \"query\" is missing")
  # bad source
  expect_error(ft_search("foobar", from = 'stuff'), "'arg' should be one of")
  # no data found, not error, but no data
  expect_equal(NROW(ft_search(5, from = 'plos')$plos$data), 0)
  expect_equal(suppressMessages(ft_search(5, from = 'plos')$plos$found), 0)
  
  expect_error(biorxiv_search("asdfasdfasdfasfasfd"), 
               "no results found in Biorxiv")
})

test_that("ft_search curl options work", {
  skip_on_cran()
  
  # plos
  expect_error(
    ft_search(query='ecology', from='plos', timeout_ms = 1),
    "[Tt]ime")

  # bmc
  expect_error(
    ft_search(query='ecology', from='bmc', timeout_ms = 1),
    "[Tt]ime")

  # crossref
  expect_error(
    ft_search(query='ecology', from='crossref', timeout_ms = 1),
    "[Tt]ime")

  # entrez - dont include, httr not in suggests
  # expect_error(
  #   ft_search(query='ecology', from='entrez', config = httr::timeout(0.1)),
  #   "time")

  # biorxiv
  expect_error(
    ft_search(query='ecology', from='biorxiv', timeout_ms = 1),
    "[Tt]ime")

  # europe pmc
  expect_error(
    ft_search(query='ecology', from='europmc', timeout_ms = 1),
    "[Tt]ime")

  # scopus
  expect_error(
    ft_search(query='ecology', from='scopus', timeout_ms = 1),
    "[Tt]ime")

  # microsoft academic
  expect_error(
    ft_search("Y='19'...", from='microsoft',
      maopts = list(key = Sys.getenv("MICROSOFT_ACADEMIC_KEY")),
      timeout_ms = 1),
    "[Tt]ime")
})
