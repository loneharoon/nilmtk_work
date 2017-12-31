#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This file only computes disagregation error using LBM technique for iawe and redd dataset.
It is a replica of LBM_disaggregation_error for iawe and redd secondly datasets
Created on Fri Dec 29 20:29:23 2017

@author: haroonr
"""

#%%
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd
np.random.seed(42)
import pickle
from latent_Bayesian_melding import LatentBayesianMelding
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")
#%% Read one home at a time
dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
savedir = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/lbm_disaggregation_puredata/"
savedir_error = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/disagg_results/"

hos = "redd_home_6.csv" #"meter_2.csv"  
pklobject = "redd_home_6.pkl"  # "meter_2.pkl"
model_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/lbm_population_models/"
#%%
population_parameters = model_path + pklobject
df = pd.read_csv(dir + hos, index_col='localminute')  
df.index = pd.to_datetime(df.index)
#%%
res = df.sum(axis=0)
high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1).values # create new aggregate column
#%%
#meterdata = df_new.truncate(before="2013-07-21", after="2013-08-04 23:59:59") #for iawe
meterdata = df_new.truncate(before="2011-05-30", after="2011-06-13 23:59:58") #for redd home
#%%
# experiments show that we should provide day level chunks intead of allday once. and changing sample_seconds does not affect accuracy
#lbm_result = lbm_decoder(meterdata, population_parameters, main_meter = "use", filetype = "pkl")
main_meter = 'use'
filetype = 'pkl'
mains = meterdata[main_meter]
meterlist = meterdata.columns.tolist()
meterlist.remove(main_meter)
lbm = LatentBayesianMelding()
individual_model = lbm.import_model(meterlist, population_parameters,filetype)
#%%
mains_group = mains.groupby(mains.index.date)
res = []
for key,val in mains_group:
    print(key)
    results = lbm.disaggregate_chunk(val)
    infApplianceReading = results['inferred appliance energy']
    res.append(infApplianceReading)
infApplianceReading = pd.concat(res)
#%%
infApplianceReading.to_csv("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/lbm_dissag_results/pure_data/" + hos) # save diss_data for furthe processing
#%%
#infApplianceReading.to_csv(savedir+"115.csv")
#%% TEMPORARY CELL
gt = meterdata[meterlist]
lbm_result = {'actaul_power':gt,'decoded_power':infApplianceReading}
norm_lbm = accuracy_metric_norm_error(lbm_result)
print (norm_lbm)


#%%
gt = meterdata[meterlist] # drops aggregate column internally
lbm_rmse = compute_rmse(gt,infApplianceReading)
lbm_rmse = pd.DataFrame.from_dict(lbm_rmse)
lbm_rmse.to_csv(savedir_error+"lbm_rmse_"+hos)

#prepare DS as according to metric input
aggregate = sum(meterdata['use'])
lbm_result = {'actaul_power':gt,'decoded_power':infApplianceReading}
lbm_kotler = diss_accu_metric_kotler_1(lbm_result,aggregate)
norm_lbm = accuracy_metric_norm_error(lbm_result)
norm_lbm.to_csv(savedir_error + "lbm_norm_rmse"+hos)

res_frame = pd.DataFrame(data={'algo':['lbm_acc'],'accuracy':[lbm_kotler]})
res_frame = res_frame.round(2)
res_frame.to_csv(savedir_error+"lbm_accuracy_kolter_"+hos,index=False)
