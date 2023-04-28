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

# 4.1: Calculate rolling beta (volatility)
rolling_window = 21
rolling_cov = JNJ_returns.rolling(window=rolling_window).cov(SPY_returns)
rolling_var = SPY_returns.rolling(window=rolling_window).var()
JNJ_rolling_beta = rolling_cov / rolling_var

# 4.2: Calculate the excess return
JNJ_excess_return = JNJ_returns - SPY_returns

# 4.3: Calculate the Treynor Ratio for JNJ using rolling beta
JNJ_Treynor = JNJ_excess_return / JNJ_rolling_beta

# 5: Plot the Treynor Ratio=========================================================================

# 5.1: Clean DataFrame for plotting
JNJ_rolling_Treynor_df = pd.DataFrame({'Date': JNJ_Treynor.index, 'Treynor': JNJ_Treynor.values})
JNJ_rolling_Treynor_df.dropna(inplace=True)

# 5.2: Plot the DataFrame
plt.figure(figsize=(12, 6))
plt.plot(JNJ_rolling_Treynor_df['Date'], JNJ_rolling_Treynor_df['Treynor'])
plt.title("JNJ Rolling Treynor Ratio")
plt.xlabel("Date")
plt.ylabel("Treynor Ratio")
plt.show()
