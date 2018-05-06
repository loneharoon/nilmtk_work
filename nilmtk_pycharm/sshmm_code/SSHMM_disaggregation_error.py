#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sat May  5 10:09:16 2018

@author: haroonr
"""

"""
This file explicitly computes dissaggregation error metrics on minutes level data and second level data. Data used is dataport, iawe and redd and approaches tested is SSHMM.
Created on 

@author: haroonr
"""
#%%
import warnings
import sys,pickle
sys.path.append('/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/')
sys.path.append('/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/sshmm_code/')
import makonin_support as mks
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd

np.random.seed(123)

# List all houses in a directory
dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
savedir = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/disagg_results/"
#%%
def run_dissaggreation_algos():
    #sel_homes = [1169, 130, 1314, 1463, 2075, 2864, 3039, 3538, 936, 2366]# FOUND IN FIRST 200 HOMES
    #sel_homes = [3864,3893,410,434,4514,4641,4703,4864,4874,490,4927] # FOUND BETWEEN 200-300 HOMES
    sel_homes = ["115.csv","490.csv","1463.csv","3538.csv"]
    
    #houses = map(lambda x: str(x) + ".csv", sel_homes)
    #houses = [f for f in os.listdir(dir)]
    for hos in sel_homes:
        #df = pd.read_csv(dir+houses[0],index_col='localminute') # USE HOUSE (6,115)
        hos = "redd_home_6.csv" # "meter_2.csv"  # 
        df = pd.read_csv(dir + hos, index_col='localminute')  # USE HOUSE (6,115)
        df.index = pd.to_datetime(df.index)
        #df = df["2014-06-01":"2014-08-29 23:59:59"]
        res = df.sum(axis=0)
        high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
        df_new = df[high_energy_apps]
        del df_new['use']# drop stale aggregate column
        df_new['use'] = df_new.sum(axis=1) # create new aggregate column

        train_dset = df_new.truncate(before="2014-06-01", after="2014-06-30 23:59:59")
        test_dset = df_new.truncate(before="2014-07-01", after="2014-08-29 23:59:59")
#%% for iawe and redd data only this cell
        hos = "redd_home_6.csv" # 
        # or
        hos = "meter_2.csv"  # 
        df = pd.read_csv(dir + hos, index_col='localminute')  # USE HOUSE (6,115)
        df.index = pd.to_datetime(df.index)
        res = df.sum(axis=0)
        high_energy_apps = ['use','air1','refrigerator1','laptop','tv','water_filter'] # for aiwe
        #high_energy_apps = ['use','air1','refrigerator1','electric_heat','stove','bathroom_gfi'] # for redd_home
        df_new = df[high_energy_apps]
        del df_new['use']# drop stale aggregate column
        df_new['use'] = df_new.sum(axis=1).values # create new aggregate column
        df_new = df_new.dropna()
        
        # for iawe
        train_dset = df_new.truncate(before="2013-07-13", after="2013-07-20 23:59:59")
        test_dset = df_new.truncate(before="2013-07-21", after="2013-08-04 23:59:59")
        # for redd
      
        train_dset = df_new.truncate(before="2011-05-24", after = "2011-05-27 23:59:59")
        test_dset = df_new.truncate(before="2011-05-28", after="2011-06-13 23:59:59")
#%%
        
        ids = train_dset.columns.values.tolist()
        ids.remove('use')
        
        train_times = []
        max_states = 4 # makonin set 4
        precision = 1 
        # this defines max aggregate power value as confirmed by Makonin
        max_obs = np.ceil(max(df_new['use'].values)) + 1
        max_obs = float(max_obs)
        max_states = int(max_states)
        #%
        sshmms = mks.create_train_model(train_dset, ids, max_states, max_obs, precision)
        
        labels = sshmms[0].labels
        
        precision = 1
        algo_name = 'SparseViterbi'
        limit ="all"
        print('Testing %s algorithm load disagg...' % algo_name)
        disagg_algo = getattr(__import__('algo_' + algo_name, fromlist = ['disagg_algo']), 'disagg_algo')
        sshmms_result = mks.perform_testing(test_dset, sshmms, labels, disagg_algo, limit)
        sshmms_result['train_power'] = train_dset # required during anomaly detection logic
        #%
        savepath = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/sshmm/"

        #TODO : set me to correct directory
        filename = savepath  + hos.split('.')[0] + '.pkl'
        handle = open(filename,'wb')
        pickle.dump(sshmms_result, handle, protocol=2)
        #pickle.dump(your_object, your_file, protocol=2)
        handle.close()
        print('I am done')