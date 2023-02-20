# Step 1: Install or load packages
install.packages("tidyquant")
install.packages("pracma")
install.packages("ggplot2")

library(tidyquant)
library(ggplot2)
library(pracma)

# Step 2: Collect stock information
WMT <- tq_get("WMT")

# 2.1: Plot your WMT price
plot_WMT <- ggplot(WMT, aes(x = date, y = adjusted)) +
        geom_line() +
        labs(title = "Walmart Inc. (WMT) Adjusted Closing Prices", x = "Date", y = "Closing Price")

# Step 3: Conduct R/S analysis to detect LRD
# 3.1 Calculate log returns
WMT_log_returns <- diff(log(WMT$adjusted))

# 3.2 Calculate the Hurst exponent using R/S analysis
rs_analysis <- pracma::hurstexp(WMT_log_returns)

# Step 4: Conduct ACF to detect LRD
# 4.1 ACF raw price calculation
WMT_acf <- acf(WMT$adjusted, lag.max = 1000)

# is the ACF (y-axis) is “decaying”, or decreasing, very slowly, and remains well above the significance range
# (dotted blue lines). This is indicative of a non-stationary series

# 4.2 Return calculation
WMT_acf <- acf(WMT_log_returns, lag.max = 200)
# is ACF shows exponential decay. (rapid decline after 0) This is indicative of a stationary series.
