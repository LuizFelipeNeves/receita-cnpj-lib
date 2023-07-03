#' Busca um CNPJ no site da Receita Federal
#'
#' Realiza uma busca de um CNPJ na Receita Federal e salva resultados em arquivo.
#'
#' @param cnpj número do CNPJ, com ou sem os caracteres especiais.
#' @param output tipo de output: "df" retorna uma \code{tibble}, "html" salva um arquivo HTML, "both" retorna a \code{tibble} e salva um aquivo HTML.
#' @param dir pasta onde o arquivo html será salvo. Default diretório atual.
#' @param qsa logical indicando se deseja baixar o QSA ou não. Default \code{FALSE}.
#'
#' @return Se \code{output} for "df" ou "both", retorna uma \code{tibble} com resultados após scraping.
#'   Se \code{qsa} for TRUE, retorna uma lista com três \code{tibble}s: \code{dados_cnpj} com as informações da página principal,
#'   \code{infos_basicas} com as informações básicas da empresa na página do QSA e
#'   \code{qsa} informações do quadro social.
#'
#' @export
buscar_cnpj <- function(cnpj, output = 'both', dir = '.', qsa = FALSE) {
  cnpj <- check_cnpj(cnpj)
  arq_html <- sprintf('%s/%s.html', dir, cnpj)
  tentativas <- 0
  while ((!file.exists(arq_html) || file.size(arq_html) == 8391) && tentativas < 10) {
    tentativas <- tentativas + 1
    if (tentativas > 1) cat(sprintf('Tentativa %02d...\n', tentativas))
    try({
      r <- baixar_um(cnpj, dir, arq_html)
      if (qsa) {
        arq_qsa <- sprintf('%s/%s_qsa.html', dir, cnpj)
        baixar_qsa(r, arq_qsa)
      }
    })
    Sys.sleep(1)
  }
  if (output %in% c('both', 'df')) {
    txt <- readr::read_file(arq_html, locale = readr::locale(encoding = 'latin1'))
    d <- scrape_cnpj(txt)
    if (qsa) {
      txt_qsa <- readr::read_file(arq_qsa, locale = readr::locale(encoding = 'latin1'))
      d_qsa <- scrape_qsa(txt_qsa)
      d <- list(dados_cnpj = d,
                infos_basicas = d_qsa$infos_basicas,
                qsa = d_qsa$qsa)
    }
    if(output == 'df') {
      file.remove(arq_html)
      if (qsa) file.remove(arq_qsa)
    }
    return(d)
  }
  return(invisible(TRUE))
}

#' Verifica conexão
#'
#' Verifica se é possível acessar a página de busca de CNPJ da Receita.
#'
#' @return TRUE se acessa o site da Receita, FALSE caso contrário.
#'
#' @export
has_conn <- function() {
  r <- try({httr::GET(u_check(), httr::timeout(3))}, silent = TRUE)
  !is.null(r) && (class(r) == 'response') && (r[['status_code']] == 200)
}

baixar_qsa <- function(r, arq_qsa) {
  cookie <- httr::set_cookies("flag" = '1', .cookies = unlist(httr::cookies(r)))
  httr::GET(u_qsa(), cookie, httr::timeout(3),
            httr::write_disk(arq_qsa, overwrite = TRUE))
}

baixar_um <- function(cnpj, dir, arq_html) {
  to <- httr::timeout(3)
  u_consulta <- u_receita(cnpj)
  httr::handle_reset(u_consulta)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  url_gera_captcha <- u_captcha_img()
  url_audio <- u_captcha_audio()
  solicitacao <- httr::GET(u_consulta)
  data_hora <- stringr::str_replace_all(lubridate::now(), "[^0-9]", "")
  if (is.null(dir)) dir <- tempdir()
  arq <- tempfile(pattern = data_hora, tmpdir = dir)
  wd_aud <- httr::write_disk(paste0(arq, ".wav"), overwrite = TRUE)
  wd_img <- httr::write_disk(paste0(arq, ".png"), overwrite = TRUE)
  imagem <- httr::GET(url_gera_captcha, wd_img, to)
  audio <- httr::GET(url_audio, wd_aud, to)
  while (as.numeric(audio$headers[["content-length"]]) < 1) {
    sl <- 3
    msg <- sprintf("Aconteceu algum problema. Tentando novamente em %d segundos...", sl)
    message(msg)
    Sys.sleep(sl)
    imagem <- httr::GET(url_gera_captcha, wd_img, to)
    audio <- httr::GET(url_audio, wd_aud, to)
  }

  captcha <- captchaReceitaAudio::predizer(paste0(arq, ".wav"))
  file.remove(paste0(arq, ".wav"))
  file.remove(paste0(arq, ".png"))
  dados <- form_data(cnpj, captcha)
  u_valid <- u_validacao()
  httr::POST(u_valid, body = dados, to,
             httr::set_cookies("flag" = '1', .cookies = unlist(httr::cookies(solicitacao))),
             encode = 'form', httr::write_disk(arq_html, overwrite = TRUE))
}

check_cnpj <- function(cnpj) {
  cnpj <- gsub('[^0-9]', '', cnpj)
  if (nchar(cnpj) != 14) stop('CNPJ Invalido.')
  cnpj
}

form_data <- function(cnpj, captcha) {
  dados <- list(origem = 'comprovante',
                cnpj = cnpj,
                txtTexto_captcha_serpro_gov_br = captcha,
                submit1 = 'Consultar',
                search_type = 'cnpj')
}
