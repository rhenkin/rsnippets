# Example of vegawidget with dynamic data and signal
#
# This example uses shiny_set_data and shiny_set_signal to use dynamic data
# and passing a value to a signal from R. 
# Using set_data is required to use set_signal, otherwise the binding is broken
# when the widget is re-rendered using typical reactive expressions.
#
# The problem happens if the renderVegawidget is bound to an input and 
# vw_shiny_set_signal is used. The signal will stop working once the widget
# is rendered again.
#
library(shiny)
library(vegawidget)

ui <- fluidPage(
  sliderInput("minimum_mpg",
              "Select minimum mpg",
              min(mtcars$mpg),
              max(mtcars$mpg),min(mtcars$mpg)
              ),
  vegawidgetOutput("scatterplot",width = 200, height = 200)
)

server <- function(input, output, session) {
  
  output$scatterplot <- renderVegawidget({
    list(
      `$schema` = "https://vega.github.io/schema/vega-lite/v5.json",
      params = list(
        list(name = "chart_title", value = "placeholder title not visible")
      ),
      # Note the use of name = "source"
      data = list(name = "source"),
      # We will set the title dynamically again
      title = list(text = list(expr = "chart_title")),
      mark = list(type = "point"),
      encoding = list(
        x = list(field = "mpg", type = "quantitative"),
        y = list(field = "wt", type = "quantitative")
      )
    ) %>% as_vegaspec()
  })
  
  # This block is bound to input$minimum_mpg
  df <- reactive({
    df <- mtcars[mtcars$mpg >= input$minimum_mpg,]
  })
  vw_shiny_set_data("scatterplot", "source", df())
  
  # This block is bound to df
  new_title <- reactive({
    selected_pct <- nrow(df())/nrow(mtcars)*100
    paste0("Viewing ",selected_pct,"% of rows")
  })
  vw_shiny_set_signal("scatterplot", "chart_title", new_title())
  
}

shinyApp(ui, server)