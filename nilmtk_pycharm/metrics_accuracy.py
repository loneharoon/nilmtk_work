#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
In this script, I compute all metrics related to disaggregation
Created on Wed Jan 17 11:59:12 2018

@author: haroonr
"""
#%%
import numpy as np
import pandas as pd
np.random.seed(123)
import seaborn as sns
sns.set_context("paper")
import matplotlib.pyplot as plt
from collections import OrderedDict
from __future__ import division
#%%
submetered_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
nilm_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/fhmm/"
#%%

homes =  "490.csv"
df = pd.read_csv(submetered_path+homes,index_col='localminute')
df.index = pd.to_datetime(df.index)
#high_energy_apps = ['use','air1','refrigerator1','laptop','tv','water_filter'] # for aiwe
res = df.sum(axis=0)
high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1)# create new aggregate column
#%%
#FOR iawe
#train_dset = df_new.truncate(before="2013-07-13", after="2013-07-20 23:59:59")
#oracle_dset = df_new.truncate(before="2013-07-21", after="2013-08-04 23:59:59")
# for dataport homes
test_dset = df_new.truncate(before="2014-07-01", after="2014-08-30 23:59:59")
#%% Let's read now disaggregatedd FHMM dataset of same home
predict_df = pd.read_csv(nilm_path+homes,index_col='localminute') 
predict_df.index = pd.to_datetime(predict_df.index)

#%%
on_power_threshold = 10
appliances  = predict_df.columns
results =  OrderedDict()
for app in appliances:
    print (app)
    actual = test_dset[app]
    predict = predict_df[app]
    when_on_actual = actual >= on_power_threshold
    when_on_predict = predict >= on_power_threshold
    #results[app] = precision_recall_fscore_support(when_on_actual,when_on_predict)
    results[app] = compute_confusion_metrics(when_on_actual,when_on_predict)
#%%
def compute_confusion_metrics(actual,predict):
    res = OrderedDict()
    tp = np.sum(np.logical_and(predict.values == True,
                actual.values == True))
    fp = np.sum(np.logical_and(predict.values == True,
                actual.values == False))
    fn = np.sum(np.logical_and(predict.values == False,
                actual.values == True))
    tn = np.sum(np.logical_and(predict.values == False,
                actual.values == False))
    precision = tp/(tp+fp) 
    recall =  tp/(tp+fn)
    fscore =  2*(precision*recall)/(precision+recall)
    res['precision'] = precision 
    res['recall'] = recall
    res['f_score'] = fscore
    return (res)
#%%

