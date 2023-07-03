u_check <- function() {
  'http://servicos.receita.fazenda.gov.br/Servicos/cnpjreva/Cnpjreva_Solicitacao_CS.asp'
}
u_qsa <- function() {
  'https://solucoes.receita.fazenda.gov.br/Servicos/cnpjreva/Cnpjreva_qsa.asp'
}

u_captcha_img <- function() {
  "https://solucoes.receita.fazenda.gov.br/Servicos/cnpjreva/captcha/gerarCaptcha.asp"
}

u_captcha_audio <- function() {
  "https://solucoes.receita.fazenda.gov.br/Servicos/cnpjreva/captcha/gerarSom.asp"
}

u_receita <- function(cnpj = '') {
  u <- 'hhttp://servicos.receita.fazenda.gov.br/Servicos/cnpjreva/Cnpjreva_Solicitacao_CS.asp?cnpj=%s'
  sprintf(u, cnpj)
}

u_validacao <- function() {
  'https://solucoes.receita.fazenda.gov.br/Servicos/cnpjreva/valida.asp'
}

u_result <- function(cnpj) {
  u <- 'https://solucoes.receita.fazenda.gov.br/Servicos/cnpjreva/Cnpjreva_Vstatus.asp?origem=comprovante&cnpj=%s'
  sprintf(u, cnpj)
}
