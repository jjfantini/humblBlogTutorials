# 1: Install needed packages
!pip install yfinance
!pip install pandas
!pip install matplotlib
!pip install statsmodels

# 1.1: Load required libraries
import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.seasonal import seasonal_decompose
from statsmodels.tsa.seasonal import STL

# 2: Collect past 5 years of price data for AAPL and save it to an object named 'AAPL_df'
AAPL_df = yf.download('AAPL', start='2017-03-31', end='2022-03-31')

# 2.1: Plot and visualize AAPL price data
AAPL_price = AAPL_df[['Adj Close']].plot(figsize=(12, 6), xlabel='Date', ylabel='Price', title='AAPL Price')

# 2.2: View the plot
plt.show()

# 3: Get the adjusted close prices and convert to pandas series
AAPL_adj_close = AAPL_df["Adj Close"]

# 3.1: Perform time series decomposition using an additive model
ts_decomp_add = seasonal_decompose(AAPL_adj_close, model="additive", period=252)

# 3.2: Plot the decomposition components
ts_decomp_add.plot()
plt.suptitle("Additive Model Decomposition", y=0.99, fontsize=14)
plt.tight_layout()
plt.show()

# 4:  Perform time series decomposition using STL/LOESS method

ts_decomp_loess = STL(AAPL_adj_close, period=252).fit()

# 4.1: Plot the decomposition components
ts_decomp_loess.plot()
plt.suptitle("LOESS Decomposition", y=0.99, fontsize=14)
plt.tight_layout()
plt.show()

# 5: Prepare a grid for combined plot
fig, axes = plt.subplots(3, 2, sharex=True, figsize=(10, 12))
plt.tight_layout()
fig.subplots_adjust(top=0.95)

# 5.1: Additive Model Decomposition components
ts_decomp_add.trend.plot(ax=axes[0, 0], title="Trend")
ts_decomp_add.seasonal.plot(ax=axes[1, 0], title="Seasonality")
ts_decomp_add.resid.plot(ax=axes[2, 0], title="Residuals")
axes[0, 0].set_title("Additive Model Decomposition", fontsize=14, fontweight="bold")

# 5.2: LOESS Decomposition components
ts_decomp_loess.trend.plot(ax=axes[0, 1], title="Trend")
ts_decomp_loess.seasonal.plot(ax=axes[1, 1], title="Seasonality")
ts_decomp_loess.resid.plot(ax=axes[2, 1], title="Residuals")
axes[0, 1].set_title("LOESS Decomposition", fontsize=14, fontweight="bold")

# 5.3: Show the combined plot
plt.show()
