#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
In this file I cross check diffeerent observations from the data which I understand from results. Please read each insight before moving through the code
Created on Tue Jan  9 10:12:21 2018

@author: haroonr
"""
#%%
import numpy as np
import pandas as pd
np.random.seed(123)
import seaborn as sns
sns.set_context("paper")
import matplotlib.pyplot as plt
#%%
# Insight: The F-score of iawe home with FHMM and oracle is same. Does this mean disaggregation worked perfectly in this home. Let's plot AC data of both cases and understand things

path2 = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
aggregate_result = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"
#%%

homes =  "meter_2.csv"
df = pd.read_csv(path2+homes,index_col='localminute')
df.index = pd.to_datetime(df.index)
high_energy_apps = ['use','air1','refrigerator1','laptop','tv','water_filter'] # for aiwe
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1)# create new aggregate column
#%%
#FOR iawe
train_dset = df_new.truncate(before="2013-07-13", after="2013-07-20 23:59:59")
oracle_dset = df_new.truncate(before="2013-07-21", after="2013-08-04 23:59:59")
#%% Let's read now disaggregatedd FHMM dataset of same home
path= "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/fhmm/"
df2 = pd.read_csv(path+homes,index_col='localminute') # injected anomalies
df2.index = pd.to_datetime(df2.index)
#%%
temp = pd.concat([oracle_dset['air1'],df2['air1']],axis=1)
temp.columns = ["Submetered","Disaggregated"]
temp.plot(subplots=True)
#temp['2013-07-21'].plot(subplots=True)
# Conclusion: After plotting data of several days I found indeed disaggregation has worked very well in this house
#%% now plotting part
p  = temp
p['Timestamp'] = p.index
t = pd.melt(p,id_vars=['Timestamp'],value_vars=["Submetered","Disaggregated"],var_name='Data',value_name='Power (W)')
pal = dict(Submetered="black", Disaggregated="blue")
sobj = sns.FacetGrid(t,row='Data',sharex=True,margin_titles=True,hue='Data',palette=pal)
sobj.map(plt.plot,'Timestamp','Power (W)')

#%% While comparing nomarlized error of AC across homes in paper we find that home 3 (490) has also same error as that of iawe then why Fscore of 490 for ac is lower as compared to iawe
#Read oracle data of 490
path= "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
homes = "490.csv"
df = pd.read_csv(path+homes,index_col='localminute') # INJECTED FILES
df.index = pd.to_datetime(df.index)

res = df.sum(axis=0)
high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1) # create new aggregate column
oracle_dset = df_new.truncate(before="2014-07-01", after="2014-08-30 23:59:59")
#%%
pathxx = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/fhmm/"
df2 = pd.read_csv(pathxx+homes,index_col='localminute') # injected anomalies
df2.index = pd.to_datetime(df2.index)
#%%
temp = pd.concat([oracle_dset['air1'],df2['air1']],axis=1)
temp.columns = ["oracle","disagg"]
temp.plot(subplots=True) # from 2014-07-01 to 2014-08-30
temp['2014-07-21'].plot(subplots=True)
savedir = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/tempres/"
sel_app = ['air1','clotheswasher1','furnace1','dishwasher1','refrigerator1']
#%%
mydate =  '2014-07-04'
df2[mydate][sel_app].plot(subplots=True)
plt.savefig(savedir+mydate+"_disagg.pdf")
oracle_dset[mydate][sel_app].plot(subplots=True)
plt.savefig(savedir+mydate+"_orac.pdf")
# I found that this home has clotheswasher and furance and at time the AC usage gets wrongly distriubuted in these appliances as a result the net energy consumed by AC decreases. Therefore these cases are not flagged as anomalies. This means when we have more similar energy consuming appliances then anomaly detection is even harder.