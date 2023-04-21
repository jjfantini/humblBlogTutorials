# 1.Prerequisites and Installing Packages
install.packages("shiny")
install.packages("tidyquant")
install.packages("TTR")
install.packages("shinythemes")

library(shiny)
library(tidyquant)
library(TTR)
library(shinythemes)

# 2: Building the UI for the Shiny App
ui <- fluidPage(
        titlePanel("Market Data Analytics App"),
        # 2.1: Create layout with sidebar and main panel
        sidebarLayout(
                sidebarPanel(
                        selectInput(
                                "ticker", "Select Ticker:",
                                choices = c("AAPL", "AMD", "GOOG", "AMZN", "TSLA")
                        ),
                        selectInput(
                                "date_length", "Select Date Length:",
                                choices = c("1y", "2y", "3y", "4y", "5y")
                        ),
                        selectInput(
                                "analysis_method", "Select Analysis Method:",
                                choices = c("ATR", "Rolling Momentum", "Relative Strength Index")
                        ),
                        actionButton("calculate", "Calculate"),
                        themeSelector()
                ),
                # 2.3: Display plots in main panel
                mainPanel(
                        plotOutput("price_plot"),
                        plotOutput("analysis_output"),
                        class = "custom-main-panel"
                )
        ),
        # 2.4: Custom CSS for main panel positioning
        tags$style(HTML("
            .custom-main-panel {
                margin-top: -60px; /* Adjust this value to move the mainPanel up or down */
            }
        "))
)



# 3: Implementing Analysis Techniques
server <- function(input, output) {
        # 3.1: Apply selected theme to plots
        thematic::thematic_shiny()

        # 3.2: Fetch stock data on button click
        stock_data <- eventReactive(input$calculate, {
                date_range <-  switch(input$date_length,
                                      "1y" = 365,
                                      "2y" = 2 * 365,
                                      "3y" = 3 * 365,
                                      "4y" = 4 * 365,
                                      "5y" = 5 * 365)
                # 3.3: Collect data from tidyquant
                tq_get(input$ticker, from = Sys.Date() - days(date_range), to = Sys.Date()) %>%
                        dplyr::select(date, close, high, low)
        })


        # 3.4: Store selected analysis method on button click
        selected_analysis <- reactiveValues(method = NULL)

        # 3.5: Update selected_analysis on button click
        observeEvent(input$calculate, {
                selected_analysis$method <- input$analysis_method
        })

        # 3.6: Render stock price plot
        output$price_plot <- renderPlot({
                # Ensure the data is available before plotting
                req(stock_data())

                selected_data <- stock_data()

                # Simple Plot
                plot(
                        selected_data$date,
                        selected_data$close,
                        type = "l",
                        main = "Stock Price",
                        xlab = "Date",
                        ylab = "Price")
        })

        # 3.7: Render analysis plot based on method
        output$analysis_output <- renderPlot({
                # Ensure the data and analysis method are available before plotting
                req(stock_data(), selected_analysis$method)

                selected_data <- stock_data()
                selected_xts <- xts::xts(selected_data[, -1], order.by = selected_data$date)

                # 3.8: Analysis code logic
                if (selected_analysis$method == "ATR") {
                        atr <- ATR(HLC = selected_xts[, c("high", "low", "close")], n = 14)

                        # Simple Plot
                        plot(
                                index(selected_xts),
                                atr$atr,
                                type = "l",
                                main = "Average True Range",
                                xlab = "Date",
                                ylab = "ATR")

                }  else if (selected_analysis$method == "Rolling Momentum") {
                        rolling_momentum <- lag(selected_xts$close, 12) / selected_xts$close - 1

                        # Simple Plot
                        plot(
                                index(selected_xts),
                                rolling_momentum,
                                type = "l",
                                main = "Rolling Momentum",
                                xlab = "Date",
                                ylab = "Momentum")

                } else if (selected_analysis$method == "Relative Strength Index") {
                        rsi <- RSI(selected_xts$close, n = 14, maType = "SMA")

                        # Simple Plot
                        plot(
                                index(selected_xts),
                                rsi,
                                type = "l",
                                main = "Relative Strength Index",
                                xlab = "Date",
                                ylab = "RSI")
                }
        })
}

# 4. Run the app
shinyApp(ui = ui, server = server)
