# Example of vegawidget with signal
#
# Using a signal to set dynamic encodings avoids triggering rendering the chart
# again, which you may not want when displaying big datasets
#
# The other file in this folder has an example of dynamic data, that is,
# data that is transformed using a reactive expression in R.
#
library(shiny)
library(vegawidget)

ui <- fluidPage(
  textInput("new_title", "Insert new title:", value = "initial title"),
  vegawidgetOutput("scatterplot", width = 200, height = 200)
)

server <- function(input, output, session) {
  
  output$scatterplot <- renderVegawidget({
    list(
      `$schema` = "https://vega.github.io/schema/vega-lite/v5.json",
      params = list(
        list(name = "chart_title", value = "placeholder title not visible")
      ),
      # Note the use of values = mtcars
      data = list(values = mtcars),
      title = list(text = list(expr = "chart_title")),
      mark = list(type = "point"),
      encoding = list(
        x = list(field = "mpg", type = "quantitative"),
        y = list(field = "wt", type = "quantitative")
      )
    ) %>% as_vegaspec()
  })
  
  # We don't need to observe any event, as set signal will create the binding
  vw_shiny_set_signal("scatterplot", "chart_title", input$new_title)
  
}

shinyApp(ui, server)