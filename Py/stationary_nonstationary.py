!pip install statsmodels
!pip install arch
!pip install scikit-learn


import yfinance as yf
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller, kpss
from arch.unitroot import PhillipsPerron
from sklearn.linear_model import LinearRegression



# Step 1: Get AMZN price data-------------
start_date = "2017-01-01"
end_date = "2023-02-09"

amzn_prices = yf.download("AMZN", start=start_date, end=end_date)

# Step 2: Check if data is stationary or non-stationary with URT (unit root tests)-------------

# 2.1 Apply ADF test
adf_result = adfuller(amzn_prices['Adj Close'], autolag='AIC')
adf_pvalue = adf_result[1]

# Null Hypothesis: Non-stationary
# Alt hypothesis: Stationary
# If p-value > 0.05, accept null / reject alt
# If p-value < 0.05, reject null / accept alt

# 2.2 Apply PP test
pp_result = PhillipsPerron(amzn_prices['Adj Close'])
# Null Hypothesis: Non-stationary
# Alt hypothesis: Stationary
# If p-value > 0.05, accept null / reject alt
# If p-value < 0.05, reject null / accept alt

# 2.3 Apply KPSS test
kpss_result = kpss(amzn_prices['Adj Close'], regression='c')
kpss_pvalue = kpss_result[1]

# Null Hypothesis: Stationary
# Alt hypothesis: Non-stationary
# If p-value > 0.05, accept null / reject alt
# If p-value < 0.05, reject null / accept alt

# Step 3: Detrending Methods-------------

# 3.1 Differencing
amzn_diff = amzn_prices['Adj Close'].diff()[1:]

# 3.2 DFA 
amzn_dfa2 = fathon.DFA(amzn_prices['Adj Close'])

def detrended_fluctuation_analysis(timeseries, max_window_size):
    N = len(timeseries)
    F = np.zeros(N)
    for i in range(N):
        if i < 2 or i > max_window_size:
            continue
        x = timeseries[0:i+1]
        y = np.cumsum(x - np.mean(x))
        z = np.polyfit(range(i+1), y, 1)
        p = np.poly1d(z)
        F[i] = np.sqrt(np.mean((y - p(range(i+1)))**2))
    return F


amzn_adj = amzn_prices['Adj Close'].values
F = detrended_fluctuation_analysis(amzn_adj, 400)
amzn_dfa = pd.DataFrame({'box': range(1, len(F) + 1), 'DFA': F})
# Remove 0's
amzn_dfa = amzn_dfa[amzn_dfa['DFA'] != 0]


# Add linear regression line of best fit
reg = LinearRegression().fit(amzn_dfa[['box']], amzn_dfa[['DFA']])
reg_line = reg.predict(amzn_dfa[['box']])[:, 0]

# Calculate Slope
slope = reg.coef_[0][0]



# Step 4: Transformation Methods-------------

# 4.1 Square root transformation
amzn_sqrt = np.sqrt(amzn_prices['Adj Close'])

# 4.2 Log Transformation
amzn_log = np.log(amzn_prices['Adj Close'])

# Step 5: Plot the time series + analysis to visualize-----------
fig, ax = plt.subplots(3, 2, figsize=(12, 10))

# 5.1 Plot Original AMZN prices
ax[0, 0].plot(amzn_prices.index, amzn_prices['Adj Close'], label='AMZN adjusted close price')
ax[0, 0].set_title("AMZN 5yr price chart")
ax[0, 0].set_xlabel("Year")
ax[0, 0].set_ylabel("Price")

# 5.2 Plot the differenced time series
ax[0, 1].plot(amzn_diff.index, amzn_diff.values)
ax[0, 1].set_title("AMZN Differenced Detrended Results")
ax[0, 1].set_xlabel("Date")
ax[0, 1].set_ylabel("Difference Detrended")

# 5.3 Plot sqrt Transformation
ax[1, 0].plot(amzn_sqrt.index, amzn_sqrt.values)
ax[1, 0].set_title("AMZN SQRT Transformation Results")
ax[1, 0].set_xlabel("Date")
ax[1, 0].set_ylabel("Sqrt Transform")

# 5.4 Plot Log Transformation
ax[1, 1].plot(amzn_log.index, amzn_log.values)
ax[1, 1].set_title("AMZN LOG Transformation Analysis Results")
ax[1, 1].set_xlabel("Date")
ax[1, 1].set_ylabel("Log Transform")

# 5.5 Plot DFA slope
ax[2, 0].scatter(amzn_dfa['box'], amzn_dfa['DFA'], label='DFA values')
ax[2, 0].plot(amzn_dfa['box'], reg_line, 'r', label='Line of best fit')
ax[2, 0].legend()
ax[2, 0].set_xlabel('Box size (number of data points)')
ax[2, 0.set_ylabel('DFA values')
ax[2, 0].set_title('Detrended Fluctuation Analysis of Amazon Stock Price \n Slope: ' + str(slope))


plt.tight_layout()
plt.show()


