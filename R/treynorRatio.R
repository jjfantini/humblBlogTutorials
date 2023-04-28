# 1: Setup:=========================================================================================
install.packages("tidyquant")
install.packages("ggplot2")
install.packages("zoo")
install.packages("PerformanceAnalytics")

# 1.1: Load required libraries
library(tidyquant)
library(ggplot2)
library(zoo)
library(PerformanceAnalytics)

# 2: Collect price data for JNJ and SPY=============================================================

# 2.1: Data collection
JNJ_data <- tq_get("JNJ", from = "2018-03-31", to = "2023-03-31")
SPY_data <- tq_get("SPY", from = "2018-03-31", to = "2023-03-31")

# 2.2: Create xts objects for daily adjusted close prices
JNJ_adj_close_xts <- xts(JNJ_data$adjusted, order.by = as.Date(JNJ_data$date))
SPY_adj_close_xts <- xts(SPY_data$adjusted, order.by = as.Date(SPY_data$date))

# 3: Calculate daily returns for JNJ and SPY========================================================
JNJ_returns <- dailyReturn(JNJ_adj_close_xts)
SPY_returns <- dailyReturn(SPY_adj_close_xts)

# 4: Calculate the Treynor Ratio for JNJ============================================================

# 4.1: Calculate rolling beta (volatility)
rolling_window <- 21
JNJ_rolling_beta <- rollapply(
        cbind(JNJ_returns, SPY_returns),
        width = rolling_window,
        function(x) {
                cov(x[, 1], x[, 2]) / var(x[, 2])
        },
        by.column = FALSE,
        align = "right")

# 4.2: Calculate the excess return
JNJ_excess_return <- JNJ_returns - SPY_returns

# 4.3: Calculate the Treynor Ratio for JNJ using rolling beta
JNJ_Treynor <- JNJ_excess_return / as.numeric(JNJ_rolling_beta)


# 5: Plot the Treynor Ratio=========================================================================

# 5.1: Clean DF for plotting
JNJ_rolling_Treynor_df <- data.frame(Date = index(JNJ_Treynor), JNJ_Treynor$daily.returns)
colnames(JNJ_rolling_Treynor_df)[2] <- "Treynor"
JNJ_rolling_Treynor_df <- na.omit(JNJ_rolling_Treynor_df)

# 5.2: Plot the df
JNJ_plot <- ggplot(data = JNJ_rolling_Treynor_df, aes(x = Date, y = Treynor)) +
        geom_line() +
        labs(title = "JNJ 21-Day Rolling Treynor Ratio", x = "Date", y = "Treynor Ratio") +
        theme_minimal()
# 5.3: View the plot
JNJ_plot


# TIDYERSE VERSION: ================================================================================
# 1: Setup:=========================================================================================
install.packages(c("tidyquant", "ggplot2", "zoo", "PerformanceAnalytics", "tidyverse"))

# 1.1: Load required libraries
library(tidyquant)
library(ggplot2)
library(zoo)
library(PerformanceAnalytics)
library(tidyverse)

# 2: Collect price data for JNJ and SPY=============================================================
tickers <- c("JNJ", "SPY")
start_date <- "2018-03-31"
end_date <- "2023-03-31"

price_data <- lapply(tickers, function(ticker) {
        tq_get(ticker, from = start_date, to = end_date) %>%
                mutate(Date = as.Date(date), symbol = ticker) %>%
                select(Date, symbol, adjusted)
}) %>% bind_rows()

price_data <- price_data %>%
        pivot_wider(names_from = symbol, values_from = adjusted)

# 3: Calculate daily returns for JNJ and SPY========================================================
returns_data <- price_data %>%
        mutate(JNJ_returns = (JNJ / lag(JNJ)) - 1,
               SPY_returns = (SPY / lag(SPY)) - 1) %>%
        select(Date, JNJ_returns, SPY_returns)
# 3.1: Remove the first row with NAs
returns_data <- na.omit(returns_data)

# 4: Calculate the Treynor Ratio for JNJ============================================================

# 4.1: Calculate rolling beta
rolling_window <- 21

JNJ_rolling_beta <- returns_data %>%
        mutate(JNJ_beta = c(rep(NA, rolling_window - 1),
                            rollapply(cbind(JNJ_returns, SPY_returns),
                                      width = rolling_window,
                                      FUN = function(x) cov(x[,1], x[,2]) / var(x[,2]),
                                      by.column = FALSE,
                                      align = "right"))) %>%
        select(Date, JNJ_beta)

# 4.2: Calculate the excess return
JNJ_excess_return <- returns_data %>%
        mutate(JNJ_excess_return = JNJ_returns - SPY_returns) %>%
        select(Date, JNJ_excess_return)

# 4.3: Calculate the Treynor Ratio for JNJ using rolling beta
JNJ_Treynor_custom <- JNJ_excess_return %>%
        left_join(JNJ_rolling_beta, by = "Date") %>%
        mutate(Treynor = JNJ_excess_return / JNJ_beta) %>%
        na.omit()

# 5: Plot the Treynor Ratio=========================================================================
JNJ_plot <- ggplot(data = JNJ_Treynor_custom, aes(x = Date, y = Treynor)) +
        geom_line() +
        labs(title = "JNJ Rolling Treynor Ratio", x = "Date", y = "Treynor Ratio") +
        theme_minimal()

JNJ_plot
