# Useful R snippets

This repo contains snippets of R code that I found useful to save as self-contained examples. Many are about Shiny development and overlap with other packages too. Please check each app.R file or others for the required packages.

### Navigation with Shiny

- [navbarPage with URL parameters](navbar_links): example of modular Shiny app where it's possible to navigate between tabs with hyperlinks, and programmatically change inputs in the target modules.
- [JavaScript and updateQueryString test](querystringtest): example of Shiny app where URL in same page is used to set input through JavaScript

### [vegawidget](http://github.com/vegawidget/vegawidget) + Shiny

- [Using vegawidget::shiny_set_signal](vegawidget_shinysetsignal): two examples of Shiny apps setting up a dynamic signal from Shiny to vega-lite: one with non-reactive dataset and one with a reactive dataset. Also includes a file showing a setup that does not work for reactive data.
- [Using vegawidget::shiny_get_signal](vegawidget_shinygetsignal): example of a working Shiny app that combines using reactive data and retrieving a signal from Shiny (e.g. a Vega-based interaction selection). Like above, also includes a file showing what would be a common setup that does not work.
