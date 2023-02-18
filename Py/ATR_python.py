# STEP 1: Download necessary libraries:
!pip install pandas
!pip install yfinance
!pip install matplotlib
!pip install TA-Lib


# Import the necessary libraries:
import pandas as pd
import yfinance as yf
import matplotlib.pyplot as plt
import talib

#Collect TSLA data using the yfinance library:
TSLA_df = yf.Ticker("TSLA").history(period="5y")

#Calculate the average true range (ATR) using the talib library:
TSLA_df['ATR'] = talib.ATR(TSLA_df['High'], TSLA_df['Low'], TSLA_df['Close'], timeperiod=14)

#Use a custom function
def average_true_range(high, low, close, n):
    true_range = pd.Series(index=close.index)
    for i in range(len(close)):
        if i == 0:
            true_range[i] = high[i] - low[i]
        else:
            true_range[i] = max(high[i] - low[i], abs(high[i] - close[i-1]), abs(low[i] - close[i-1]))
    return true_range.rolling(n).mean()

TSLA_df['ATR'] = average_true_range(TSLA_df['High'], TSLA_df_df['Low'], TSLA_df['Close'], 14)

#Plot the TSLA price and the ATR values on seperate axis:

fig, ax1 = plt.subplots(figsize=(16,8))
ax2 = ax1.twinx()

ax1.plot(TSLA_df['Close'], label='TSLA_df Close Price', color='blue')
ax2.plot(TSLA_df['ATR'], label='Average True Range', color='red')

ax1.set_xlabel('Date')
ax1.set_ylabel('TSLA_df Close Price', color='blue')
ax2.set_ylabel('Average True Range', color='red')

plt.legend(loc='best')
plt.show()
