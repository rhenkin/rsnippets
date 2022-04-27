# Example of vegawidget with dynamic data and signal
#
# To use shiny_get_signal along with dynamic data (on R side), you have to use
# shiny_set_data as well. This is because the binding of shiny_get_signal breaks
# if you use normal reactive data (see other file in this folder).
#
# shiny_set_data work saround that problem and uses an elegant reactive solution
#
library(shiny)
library(vegawidget)

ui <- fluidPage(
  sliderInput("minimum_mpg",
              "Select minimum mpg",
              min(mtcars$mpg),
              max(mtcars$mpg),min(mtcars$mpg)
  ),
  vegawidgetOutput("scatterplot",width = 200, height = 200),
  textOutput("print_fill_sel")
)

server <- function(input, output, session) {
  
  output$scatterplot <- renderVegawidget({
    list(
      `$schema` = "https://vega.github.io/schema/vega-lite/v5.json",
      params = list(
        list(name = "fill_sel",
             select = list(type = "point",
                           fields = list("cyl"),
                           on = "click",
                           clear = "dblclick",
                           toggle = FALSE),
             bind = "legend")
      ),
      # Note the use of name = "source"
      data = list(name = "source"),
      mark = list(type = "point", filled = TRUE),
      encoding = list(
        x = list(field = "mpg", type = "quantitative"),
        y = list(field = "wt", type = "quantitative"),
        color = list(
          condition = list(
            param = "fill_sel",
            field = "cyl",
            type = "ordinal"
          ),
          value = "#bbbbbb"
        )
      )
    ) %>% as_vegaspec()
  })
  
  # This block is bound to input$minimum_mpg
  df <- reactive({
    df <- mtcars[mtcars$mpg >= input$minimum_mpg,]
  })
  vw_shiny_set_data("scatterplot", "source", df())
  
  # get_fill_sel is reactive
  get_fill_sel <- vw_shiny_get_signal("scatterplot", "fill_sel", "value")
  output$print_fill_sel <- renderPrint({ get_fill_sel() })
  
}

shinyApp(ui, server)