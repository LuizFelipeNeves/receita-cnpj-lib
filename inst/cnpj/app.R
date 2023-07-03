library(shiny)
library(cnpjReceita)

ui <- fluidPage(
   titlePanel("Consulta CNPJ Receita"),
   sidebarLayout(
      sidebarPanel(
         textInput('cnpj', 'Digite o CNPJ'),
         actionButton('go', 'Vai!')
      ),
      mainPanel(
        fluidRow(
          uiOutput('html')
        ),
        tags$hr(),
        fluidRow(
          tableOutput('df')
        )
      )
   )
)

server <- function(input, output) {
  file.remove(dir('.', full.names = TRUE, pattern = '\\.html$|\\.png$'))

  check <- reactive({
    if (!is.null(input$go) && input$go > 0) {
      cn <- isolate(input$cnpj)
      cnpjReceita:::check_cnpj(cn)
    } else {
      ''
    }
  })

  result <- reactive({
    validate(
      need(has_conn(), "Site da Receita fora do ar ou IP bloqueado.")
    )
    cnpj <- check()
    if (cnpj != '') {
      buscar_cnpj(cnpj)
    } else {
      tibble::tibble()
    }
  })

  output$html <- renderUI({
    result()
    f <- sprintf('./%s.html', check())
    if (file.exists(f)) {
      HTML(readr::read_file(f, locale = readr::locale(encoding = 'latin1')))
    } else {
      HTML('')
    }
  })

  output$df <- renderTable({
    result()
  })

}

shinyApp(ui = ui, server = server)
