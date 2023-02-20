# Step 1: Install or load packages
install.packages("tidyquant")
install.packages("fracdiff")
install.packages("forecast")
install.packages("wavelets")
install.packages("pracma")
install.packages("WaveletComp")

library(tidyquant)
library(fracdiff)
library(forecast)
library(wavelets)
library(ggplot2)
library(pracma)
library(WaveletComp)


# 1.1

WMT <- tq_get("WMT")

# Step 2: Conduct FARIMA modeling to detect LRD
WMT_close <- as.numeric(WMT$close)

fracdiff::fracdiff(WMT_close, nar = 100, dtol = 0.5, h = 0.5)

# Step 4: Conduct spectral analysis to detect LRD
spec.pgram(WMT_close, sp = "modified")

# Step 5: Conduct R/S analysis to detect LRD
# Calculate log returns
WMT_log_returns <- diff(log(WMT$adjusted))

# Create a time series object

# Calculate the Hurst exponent using R/S analysis
rs_analysis <- pracma::hurstexp(WMT_log_returns)

# Step 6: Conduct ACF to detect LRD
acf(WMT_close, lag.max = 5000)

# Step 7: Conduct wavelet transform to detect LRD
WMT_wavelet <- dwt(WMT$adjusted, filter="la8", n.levels=6)


#Step :
plot_WMT <- ggplot(WMT, aes(x = date, y = adjusted)) +
        geom_line() +
        labs(title = "Walmart Inc. (WMT) Adjusted Closing Prices", x = "Date", y = "Closing Price")
