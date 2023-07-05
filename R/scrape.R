fix_html <- function (x, arq_html) {
  txts <- xml2::read_html(x) |>
  stringr::str_replace(
    pattern = "images/brasao2.gif", 
    replace = "http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/images/brasao2.gif") |>
  writeLines(con = arq_html)
  x
}

scrape_cnpj <- function(x) {
  txts <- x %>%
    xml2::read_html() %>%
    rvest::html_nodes(xpath = '//td[contains(@style, "BORDER-RIGHT")]') %>%
    arrumar_node()
  txts <- txts[txts != '']
  dados <- txts %>%
    stringr::str_split_fixed(' \n', 2) %>%
    tibble::as_tibble() %>%
    purrr::set_names(c('key', 'value'))
  return(dados)
}

scrape_qsa <- function(x) {
  txts <- xml2::read_html(x)
  fs <- txts %>%
    rvest::html_nodes('fieldset') %>%
    arrumar_node() %>%
    stringr::str_split_fixed(' \n', 4) %>%
    tibble::as_tibble() %>%
    purrr::set_names(c('nm_key', 'nm', 'qual_key', 'qualif')) %>%
    dplyr::select(nm, qualif)
  xp <- '//div[@id="principal"]//table[2]//table//tr'
  kv <- txts %>%
    rvest::html_nodes(xpath = xp) %>%
    arrumar_node() %>%
    stringr::str_split_fixed(' \n', 2) %>%
    tibble::as_tibble() %>%
    purrr::set_names(c('key', 'value')) %>%
    dplyr::mutate(key = stringr::str_replace(key, ':$', ''))
  return(list(infos_basicas = kv, qsa = fs))
}

arrumar_node <- function(x) {
  x %>%
    rvest::html_text() %>%
    stringr::str_replace_all('[\t \r]+', ' ') %>%
    stringr::str_replace_all('(\n )+', '\n') %>%
    stringr::str_trim()
}
