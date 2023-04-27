# 1: Load required libraries=========================================================================
!pip install yfinance
!pip install pandas
!pip install numpy
!pip install matplotlib

# 1.1: Import needed functions
import yfinance as yf
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# 2: Collect price data for JNJ and SPY=============================================================
JNJ_data = yf.download('JNJ', start='2018-03-31', end='2023-03-31')
SPY_data = yf.download('SPY', start='2018-03-31', end='2023-03-31')

# 2.1: Calculate daily adjusted close prices
JNJ_adj_close = JNJ_data['Adj Close']
SPY_adj_close = SPY_data['Adj Close']


# 3: Calculate daily returns for JNJ and SPY========================================================
JNJ_returns = JNJ_adj_close.pct_change().dropna()
SPY_returns = SPY_adj_close.pct_change().dropna()


# 4: Calculate the Treynor Ratio for JNJ============================================================
JNJ_beta = np.cov(JNJ_returns, SPY_returns)[0, 1] / np.var(SPY_returns)
JNJ_excess_return = np.mean(JNJ_returns - SPY_returns)
JNJ_Treynor = JNJ_excess_return / JNJ_beta


# 5: Plot the Treynor Ratio=========================================================================
plt.bar(["Treynor Ratio"], [JNJ_Treynor], color="blue")
plt.title("JNJ Treynor Ratio")
plt.xlabel("Treynor Ratio")
plt.ylabel("Value")
plt.show()

# 5.1Interpret the results
print(f"The Treynor Ratio for JNJ is {JNJ_Treynor}. A good Treynor Ratio indicates better risk-adjusted performance.")
