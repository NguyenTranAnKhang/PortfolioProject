#!/usr/bin/env python
# coding: utf-8

# In[101]:


# Import Libraries
import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8) # Adjust the configuration of the plots we will create

# Read in the data

df = pd.read_csv(r'E:\Working\Portfolio\Project\Alex The Analyst\Movie Industry\movies.csv')


# In[7]:


# Let's look at the Data
df.head()


# In[48]:


# Let's see if there any missing Data
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, round(pct_missing*100)))


# In[49]:


# Clear data missing
df = df.dropna()
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, round(pct_missing*100)))


# In[50]:


# Data types for our columns 
print(df.dtypes)


# In[51]:


# Change data type of columns
df['budget'] = df['budget'].astype('int64')
df['gross'] = df['gross'].astype('int64')


# In[32]:


print(df.dtypes)


# In[53]:


# Are there any Outliers?

df.boxplot(column=['gross'])


# In[56]:


pd.set_option('display.max_rows', None)


# In[58]:


# Drop any duplicates 
df['company'].drop_duplicates().sort_values(ascending=False)


# In[103]:


# Order our Data a little bit to see

df = df.sort_values(by=['gross'], inplace=False, ascending=False)


# In[67]:


# Scatter plot with budget vs gross

plt.scatter(x=df['budget'],y=df['gross'])

plt.title('Budget vs Gross Earning')

plt.xlabel('Gross Earning')

plt.ylabel('Budget for Film')

plt.show()


# In[66]:


df.head()


# In[81]:


# Plot budget vs gross using Seaborn

sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color": "purple"}, line_kws={"color":"blue"})


# In[82]:


# Looking at Correlation


# In[87]:


df.corr(method = 'pearson')


# In[88]:


# High correlation between budget vs gross


# In[91]:


correlation_matrix = df.corr(method = 'pearson')

sns.heatmap(correlation_matrix, annot=True)

plt.title("Correlation matrix for Numeric Features")

plt.xlabel("Movie features")

plt.ylabel("Movie features")

plt.show()


# In[92]:


# Look at company
df.head()


# In[96]:


df_numerized = df

for col_name in df_numerized.columns:
    if (df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes
df_numerized


# In[104]:


df


# In[105]:


correlation_matrix = df_numerized.corr(method='pearson')

sns.heatmap(correlation_matrix, annot = True)

plt.title("Correlation matrix for Numeric Features")

plt.xlabel("Movie features")

plt.ylabel("Movie features")

plt.show()


# In[107]:


correlation_mat = df_numerized.corr()

corr_pairs = correlation_mat.unstack()

corr_pairs


# In[109]:


sorted_pairs = corr_pairs.sort_values()

sorted_pairs


# In[111]:


high_corr = sorted_pairs[(sorted_pairs)> 0.5]
high_corr


# In[112]:


# Votes and Budget have the highest correlation to Gross Earnings

# Company has low correlation

