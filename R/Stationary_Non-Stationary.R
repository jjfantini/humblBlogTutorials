library(tseries)
library(tidyquant)
library(pracma) # for DFA
library(mgcv) # for spline regression

# Step 1: Get AMZN price data-------------
start_date <- as.Date("2017-01-01")
end_date <- as.Date("2022-01-01")

amzn_prices <- tq_get("AMZN", from = start_date, to = end_date)

# Step 2: Check if data is stationary or non-stationary with URT (unit root tests)-------------

# Apply ADF test
adf_test <- adf.test(amzn_prices$close)

# Apply KPSS test
kpss_test <- kpss.test(amzn_prices$close)

# Apply PP test
pp_test <- pp.test(amzn_prices$close)

# Step 3: Detrending Methods-------------

# Detrended fluctuation analysis (DFA)
amzn_dfa <- dfa(amzn_prices$close)
amzn_dfa_detrended <- detrend(amzn_prices$close, method="dfa")

# Spline regression
amzn_spline <- gam(close ~ s(date, k = 5), data = amzn_prices)
amzn_spline_detrended <- residuals(amzn_spline)

# Differencing
amzn_diff <- diff(amzn_prices$close)

# Step 4: Transformation Methods-------------

# Square root transformation
amzn_sqrt <- sqrt(amzn_prices$close)

# Log transformation
amzn_log <- log(amzn_prices$close)
