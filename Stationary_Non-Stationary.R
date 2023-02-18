library(tseries) # analysis methods
library(tidyquant) # quant data
library(ggplot2) # to plot
library(cowplot) # to merge plots
library(dfa) # for DFA
library(mgcv) # for spline regression

# Step 1: Get AMZN price data-------------
start_date <- as.Date("2017-01-01")
end_date <- as.Date("2023-02-09")

amzn_prices <- tq_get("AMZN", from = start_date, to = end_date)



# Step 2: Check if data is stationary or non-stationary with URT (unit root tests)-------------

# 2.1 Apply ADF test
adf_test <- adf.test(amzn_prices$adjusted)

# 2.2 Apply PP test
pp_test <- pp.test(amzn_prices$adjusted)

# Null Hypothesis: Non-stationary
# Alt hypothesis: Stationary
# If p-value > 0.05, accept null / reject alt
# If p-value < 0.05, reject null / accept alt

# 2.3 Apply KPSS test
kpss_test <- kpss.test(amzn_prices$adjusted)

# Null Hypothesis: Stationary
# Alt hypothesis: Non-stationary
# If p-value > 0.05, accept null / reject alt
# If p-value < 0.05, reject null / accept alt


# Step 3: Detrending Methods-------------

# 3.1 Detrended fluctuation analysis (DFA)
amzn_dfa_detrended <- DFA(amzn_prices$adjusted) %>%
        as.data.frame()

# 3.2 Spline regression
amzn_spline <- gam(adjusted ~ date, data = amzn_prices)
amzn_spline_detrended <- residuals(amzn_spline) %>%
        as.data.frame() %>%
        cbind(as.Date(amzn_prices$date))
colnames(amzn_spline_detrended) <- c("adjusted_residuals", "date")

# 3.3 Differencing
amzn_diff <- diff(amzn_prices$adjusted) %>%
        as.data.frame()


amzn_diff <- cbind(amzn_prices$date[2:nrow(amzn_prices)], amzn_diff)
colnames(amzn_diff) <- c("date", "adjusted_diff")

# Step 4: Transformation Methods-------------

# 4.1 Square root transformation
amzn_sqrt <- sqrt(amzn_prices$adjusted) %>%
        as.data.frame() %>%
        cbind(amzn_prices$date)
colnames(amzn_sqrt) <- c("adjusted_sqrt", "date")

# 4.2 Log Transformation
amzn_log <- log(amzn_prices$adjusted) %>%
        as.data.frame() %>%
        cbind(amzn_prices$date)
colnames(amzn_log) <- c("adjusted_log", "date")

# Step 5: Plot the time series + analysis to visualize-----------

# 5.1 Plot Original AMZN prices
plot_amzn <- amzn_prices %>%
        ggplot(aes(x = date, y = adjusted)) +
        geom_line() +
        theme_classic() +
        labs(title = "AMZN 5yr price chart") +
        xlab("Year") +
        ylab("Price")

# 5.2 Plot DFA slope

plot_amzn_dfa <- as.data.frame(amzn_dfa_detrended) %>%
        ggplot(aes(x = boxe, y = DFA)) +
        geom_point() +
        geom_smooth(method = "lm", se = FALSE) +
        theme_classic() +
        labs(title = "AMZN Detrended Fluctuation Analysis Results (slope 0.48)") +
        xlab("Window Size") +
        ylab("Detrended Fluctuation")
slope_dfa <- coef(lm(boxe ~ DFA, data = amzn_dfa_detrended))[2]
# Please check out this DFA post to learn how to interpret the slope and the results

#5.3 Plot spline regression residuals
plot_amzn_spline <- amzn_spline_detrended %>%
        ggplot(aes(x = date, y = adjusted_residuals)) +
        geom_line() +
        theme_classic() +
        labs(title = "AMZN Spline Regression Analysis Results") +
        xlab("Date") +
        ylab("Spline Residuals")

# 5.4 Plot the differenced time series
plot_amzn_diff <- amzn_diff %>%
        ggplot(aes(x = date, y = adjusted_diff)) +
        geom_line() +
        theme_classic() +
        labs(title = "AMZN Differenced Detrended Results") +
        xlab("Date") +
        ylab("Detrended Fluctuation")

# 5.5 Plot sqrt Transformation
plot_amzn_sqrt <- amzn_sqrt %>%
        ggplot(aes(x = date, y = adjusted_sqrt)) +
        geom_line() +
        theme_classic() +
        labs(title = "AMZN SQRT Transformation Results") +
        xlab("Date") +
        ylab("Sqrt Transform")

# 5.6 Plot Log Transformation
plot_amzn_log <-amzn_log %>%
        ggplot(aes(x = date, y = adjusted_log)) +
        geom_line() +
        theme_classic() +
        labs(title = "AMZN LOG Transformation Analysis Results") +
        xlab("Date") +
        ylab("Log Transform")


amzn_overlay <- plot_grid(plot_amzn, plot_amzn_diff, plot_amzn_sqrt,plot_amzn_log, plot_amzn_dfa, ncol = 2)
