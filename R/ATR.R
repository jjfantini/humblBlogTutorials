
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

# Load the required libraries
library(ggplot2)
library(quantmod)
library(cowplot)
library(magrittr)

# Load the financial data from quantmod
getSymbols("TSLA", src = "yahoo", from = "2018-01-01", auto.assign = TRUE)

# Extract the data
TSLA_df <- data.frame(Date = index(TSLA), coredata(TSLA))

# Calculate the ATR using the `ATR()` function from the quantmod library
TSLA_atr <- ATR(HLC(TSLA_df), n=14)

# Bind the ATR values to the stock data
TSLA_df$ATR <- TSLA_atr[,2]

# Plot the stock price time series and ATR values
plot_atr <- TSLA_df %>%
        ggplot(aes(x = Date, y = ATR)) +
        geom_line() +
        theme_classic() +
        labs(title = "TSLA 5yr 2-week rolling chart") +
        xlab("Year") +
        ylab("Average True Range")
plot_atr

plot_TSLA <- TSLA_df %>%
        ggplot(aes(x = Date, y = TSLA.Adjusted)) +
        geom_line() +
        theme_classic() +
        labs(title = "TSLA 5yr price chart") +
        xlab("Year") +
        ylab("Price")
plot_TSLA


# Plot two objects together as one image and then view!
TSLA_overlay <- plot_grid(plot_TSLA, plot_atr, ncol = 1)
TSLA_overlay
