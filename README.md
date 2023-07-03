[![Travis-CI Build Status](https://travis-ci.org/jtrecenti/cnpjReceita.svg?branch=master)](https://travis-ci.org/jtrecenti/cnpjReceita)

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jtrecenti/cnpjReceita?branch=master&svg=true)](https://ci.appveyor.com/project/jtrecenti/cnpjReceita)

# cnpjReceita

Webscraper que realiza consulta de CNPJ na Receita Federal.

## Instalação

```r
if (!require(devtools)) install.packages('devtools')
devtools::install_github('LuizFelipeNeves/receita-cnpj-lib')
```

## Modo de uso

```r
library(cnpjReceita)
cnpj <- '00.000.000/0001-91'
```

Se quiser apenas salvar o HTML resultante da pesquisa na pasta `dir`, rode

```r
buscar_cnpj(cnpj, dir = './', output = 'html')
```

Se quiser somente um `data.frame` organizado com os resultados, rode

```r
d_result <- buscar_cnpj(cnpj, output = 'df')
d_result
```

Se quiser retornar o `data.frame` e salvar o HTML, use `output='both'`.

## QSA

Se quiser baixar também o QSA, use a opção `qsa = TRUE`

```r
d_result <- buscar_cnpj(cnpj, output = 'df', qsa = TRUE)
d_result
```

Note que nesse caso, o resultado é uma lista com três `tibble`s: 

- `dados_cnpj` com as informações da página principal (mesma `tibble` retornada quando `qsa = FALSE`);
- `infos_basicas` com as informações básicas da empresa na página do QSA; e
- `qsa` informações do quadro social.

## TODO

- Buscar vetor de CNPJs.
- Buscar em paralelo.
- Mais checks.

## Agradecimentos

Turminha da página [decryptr](https://github.com/decryptr).

## License

MIT
