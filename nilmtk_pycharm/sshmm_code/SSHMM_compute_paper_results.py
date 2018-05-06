#!/usr/bin/env python2
# -*- coding: utf-8 -*-


"""
Created on Sat May  5 12:42:46 2018

@author: haroonr

IN this I compute metrics like ANE for the paper using disagg data obtained from SSHMM method.
"""

import pickle,sys
sys.path.append('/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/')
import localize_appliance_support as las
#%%
filepath = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/sshmm/"
house = "redd_home_6.pkl"  # meter_2.pkl, redd_home_6.pkl
pickle_in = open(filepath + house,"rb")
dict_data = pickle.load(pickle_in)
actual_power = dict_data['actual_power']
train_power = dict_data['train_power']
decoded_power = dict_data['decoded_power']


#%%

norm_sshmss = las.accuracy_metric_norm_error(dict_data)
norm_sshmss