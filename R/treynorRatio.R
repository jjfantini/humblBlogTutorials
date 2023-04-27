# 1: Setup:=========================================================================================
install.packages("tidyquant")
install.packages("ggplot2")
install.packages("zoo")

# 1.1: Load required libraries
library(tidyquant)
library(ggplot2)
library(zoo)

# 2: Collect price data for JNJ and SPY=============================================================
JNJ_data <- tq_get("JNJ", from = "2018-03-31", to = "2023-03-31")
SPY_data <- tq_get("SPY", from = "2018-03-31", to = "2023-03-31")

# 2.1: Create xts objects for daily adjusted close prices
JNJ_adj_close_xts <- xts(JNJ_data$adjusted, order.by = as.Date(JNJ_data$date))
SPY_adj_close_xts <- xts(SPY_data$adjusted, order.by = as.Date(SPY_data$date))

# 3: Calculate daily returns for JNJ and SPY========================================================
JNJ_returns <- dailyReturn(JNJ_adj_close_xts)
SPY_returns <- dailyReturn(SPY_adj_close_xts)

# 4: Calculate the Treynor Ratio for JNJ============================================================

# 4.1: Calculate rolling beta
rolling_beta_length <- 21

JNJ_rolling_beta <- rollapply(
        cbind(JNJ_returns, SPY_returns),
        width = rolling_beta_length,
        function(x) {
                cov(x[, 1], x[, 2]) / var(x[, 2])
        },
        by.column = FALSE,
        align = "right")

# 4.2: Calculate the excess return
JNJ_excess_return <- JNJ_returns - SPY_returns

# 4.3: Calculate the Treynor Ratio for JNJ using rolling beta
JNJ_rolling_Treynor <- JNJ_excess_return / as.numeric(JNJ_rolling_beta)

# 5: Plot the Treynor Ratio=========================================================================
JNJ_rolling_Treynor_df <- data.frame(Date = index(JNJ_rolling_Treynor), Treynor = coredata(JNJ_rolling_Treynor))
JNJ_rolling_Treynor_df <- na.omit(JNJ_rolling_Treynor_df)

ggplot(data = JNJ_rolling_Treynor_df, aes(x = Date, y = daily.returns)) +
        geom_line() +
        labs(title = "JNJ Rolling Treynor Ratio", x = "Date", y = "Treynor Ratio") +
        theme_minimal()

# 5.1 Interpret the results
cat("The Treynor Ratio for JNJ is", JNJ_Treynor, ". A good Treynor Ratio indicates better risk-adjusted performance.")



