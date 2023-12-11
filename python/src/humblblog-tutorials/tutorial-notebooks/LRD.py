!pip install hurst



import yfinance as yf
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import acf
from hurst import compute_Hc


# Step 2: Get AMZN price data-------------
start_date = "2013-01-01"
end_date = "2023-02-19"

WMT = yf.download("WMT", start=start_date, end=end_date)

# 2.1: Plot your WMT price
plt.figure(figsize=(16, 8))
plt.plot(WMT['Adj Close'])
plt.title('Walmart Inc. (WMT) Adjusted Closing Prices')
plt.xlabel('Date')
plt.ylabel('Closing Price')
plt.show()

# Step 3: Conduct R/S analysis to detect LRD
# 3.1 Calculate log returns
WMT['log_returns'] = np.log(WMT['Adj Close']).diff()

# 3.2 Calculate the Hurst exponent using R/S analysis
H, c, data = compute_Hc(WMT['log_returns'].dropna(), simplified=True)

print("Hurst exponent: ", H)

# Step 4: Conduct ACF to detect LRD
# 4.1 ACF raw price calculation
lag_max = 1000
WMT_acf = acf(WMT['Adj Close'], nlags=lag_max, fft=False)

# if the ACF (y-axis) is “decaying”, or decreasing, very slowly, and remains well above the significance range
# (dotted blue lines). This is indicative of a non-stationary series

plt.figure(figsize=(16, 8))
plt.plot(WMT_acf)
plt.axhline(y=0, linestyle='--', color='gray')
plt.axhline(y=-1.96/np.sqrt(len(WMT)), linestyle='--', color='gray')
plt.axhline(y=1.96/np.sqrt(len(WMT)), linestyle='--', color='gray')
plt.title('Autocorrelation Function - Raw Prices')
plt.xlabel('Lag')
plt.ylabel('ACF')
plt.show()

# 4.2 Return calculation
WMT_acf = acf(WMT['log_returns'].dropna(), nlags=lag_max, fft=False)
# if ACF shows exponential decay. (rapid decline after 0) This is indicative of a stationary series.
plt.figure(figsize=(16, 8))
plt.plot(WMT_acf)
plt.axhline(y=0, linestyle='--', color='gray')
plt.axhline(y=-1.96/np.sqrt(len(WMT)), linestyle='--', color='gray')
plt.axhline(y=1.96/np.sqrt(len(WMT)), linestyle='--', color='gray')
plt.title('Autocorrelation Function - Log Returns')
plt.xlabel('Lag')
plt.ylabel('ACF')
plt.show()

##############

