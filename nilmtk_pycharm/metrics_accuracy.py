#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
In this script, I compute all metrics related to computing precision, recall and f_score of  disaggregation technaques
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
co_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/co/"
lbm_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/lbm/"

#%%
#homes = ["115.csv","490.csv","1463.csv","3538.csv","meter_2.csv",redd_home_6.csv"]
homes =  "redd_home_6.csv"
df = pd.read_csv(submetered_path+homes,index_col='localminute')
df.index = pd.to_datetime(df.index)
res = df.sum(axis=0)
#high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
#high_energy_apps = ['use','air1','refrigerator1','laptop','tv','water_filter'] # for aiwe
high_energy_apps = ['use','air1','refrigerator1','electric_heat','stove','bathroom_gfi'] # for redd_home
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1)# create new aggregate column
#%%

#test_dset = df_new.truncate(before="2013-07-21", after="2013-08-04 23:59:59")#iawe
#test_dset = df_new.truncate(before="2014-07-01", after="2014-08-30 23:59:59") #dataport
test_dset = df_new.truncate(before="2011-05-28", after="2011-06-13 23:59:59") # redd
#%% Let's read now disaggregatedd FHMM dataset of same home
predict_df_fhm = pd.read_csv(nilm_path+homes,index_col='localminute') 
predict_df_fhm.index = pd.to_datetime(predict_df_fhm.index)

predict_df_co = pd.read_csv(co_path+homes,index_col='localminute') 
predict_df_co.index = pd.to_datetime(predict_df_co.index)

predict_df_lbm = pd.read_csv(lbm_path+homes,index_col='localminute') 
predict_df_lbm.index = pd.to_datetime(predict_df_lbm.index)
#%%
compute_accuracy_results(test_dset,predict_df_fhm)
compute_accuracy_results(test_dset,predict_df_co)
#test_dset = test_dset[:"2014-08-29"] # for datport homes 
#test_dset = test_dset["2014-07-02":"2014-08-29"] # for 3538.csv
#drop_keys = ["inferred mains","mains",'microwave1','kitchenapp2'] # for 3538.csv
drop_keys = ["inferred mains","mains"]
predict_df_lbm = predict_df_lbm.drop(drop_keys,axis=1)
compute_accuracy_results(test_dset,predict_df_lbm)

#%%
def compute_accuracy_results(test_dset,predict_df):
    on_power_threshold = 10
    appliances  = predict_df.columns
    results =  OrderedDict()
    for app in appliances:
        actual = test_dset[app]
        predict = predict_df[app]
        when_on_actual = actual >= on_power_threshold
        when_on_predict = predict >= on_power_threshold
        #results[app] = precision_recall_fscore_support(when_on_actual,when_on_predict)
        results[app] = compute_confusion_metrics(when_on_actual,when_on_predict) 
    return(results)
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

