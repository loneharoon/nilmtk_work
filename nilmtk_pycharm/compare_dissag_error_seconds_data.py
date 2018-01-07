#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This file explicitly computes dissaggregation error metrics on seconds level data (ie. iawe and redd)
for approaches CO and FHMM
Created on Sat Dec 30 21:44:23 2017

@author: haroonr
"""
#%%
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd
np.random.seed(123)
#%%
# List all houses in a directory
dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
savedir = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/disagg_results/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_fhmm.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")
#execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plot_functions.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/cluster_file.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/utils.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/co.py")
#%%
hos = "meter_2.csv"# "redd_home_6.csv"#"meter_2.csv"
df = pd.read_csv(dir + hos, index_col='localminute')  
df.index = pd.to_datetime(df.index)
res = df.sum(axis=0)
#high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
#high_energy_apps = ['use','air1','refrigerator1','electric_heat','stove','bathroom_gfi'] # for redd_home
high_energy_apps = ['use','air1','refrigerator1','laptop','tv','water_filter'] # for aiwe
df_new = df[high_energy_apps]
#%%
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1) # create new aggregate column
#%%

#FOR iawe
train_dset = df_new.truncate(before="2013-07-13", after="2013-07-25 23:59:59")
test_dset = df_new.truncate(before="2013-07-26", after="2013-08-04 23:59:59")

# For redd homes
#train_dset = df_new.truncate(before="2011-05-24", after="2011-05-27 23:59:59") # continuous data
#test_dset = df_new.truncate(before="2011-05-28", after="2011-06-13 23:59:59")

if(test_dset.isnull().values.any()): # note I am replacing na values with direct 0
    test_dset = test_dset.fillna(0)

# keep tab on context option - creates day and night divison
#train_result = compute_appliance_statistic(train_dset,context=True) # training, using day and night context

fhmm_result  =  fhmm_decoding(train_dset,test_dset) # dissagreation
co_result = co_decoding(train_dset,test_dset)
#%%

fhmm_rmse = compute_rmse(fhmm_result['actaul_power'],fhmm_result['decoded_power'])
co_rmse = compute_rmse(co_result['actaul_power'],co_result['decoded_power'])
fhmm_rmse = pd.DataFrame.from_dict(fhmm_rmse)
co_rmse = pd.DataFrame.from_dict(co_rmse)

aggregate = sum(test_dset['use'])
fhmm_kotler = diss_accu_metric_kotler_1(fhmm_result,aggregate)
co_kotler = diss_accu_metric_kotler_1(co_result,aggregate)

norm_fhmm = accuracy_metric_norm_error(fhmm_result)
norm_co = accuracy_metric_norm_error(co_result)
#%%
concat_res = pd.concat([fhmm_rmse,co_rmse,norm_fhmm,norm_co],axis=1)
concat_res.columns = ['fhmm_rmse','co_rmse','fhmm_norm','co_norm']
concat_res = concat_res.round(2)
concat_res.to_csv(savedir+"norm_rmse_COFHMM"+hos)

res_frame = pd.DataFrame(data={'algo':['fhmm_acc','co_acc'],'accuracy':[fhmm_kotler,co_kotler]})
res_frame = res_frame.round(2)
res_frame.to_csv(savedir+"accuracy_kolter_COFHMM"+hos,index=False)