# this file differs from localize_main file only in the perspective that context is added and this script is explicity used for iawe and REDD datasets
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd
import os
np.random.seed(123)
#%%
# List all houses in a directory
#dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default_3months/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_fhmm.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")
#execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plot_functions.py")
path2 = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
aggregate_result = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"
dissagg_result_save= "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/"
#%%
homes =  "meter_2.csv"#, redd_home_6.csv
#file1 ="101.csv"
df = pd.read_csv(path2+homes,index_col='localminute') # INJECTED FILES
df.index = pd.to_datetime(df.index)

res = df.sum(axis=0)
#high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
high_energy_apps = ['use','air1','refrigerator1','laptop','tv','water_filter'] # for aiwe
#high_energy_apps = ['use','air1','refrigerator1','electric_heat','stove','bathroom_gfi'] # for redd_home
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1) # create new aggregate column
#%%
#FOR iawe
 train_dset = df_new.truncate(before="2013-07-13", after="2013-07-20 23:59:59")
 test_dset = df_new.truncate(before="2013-07-21", after="2013-08-04 23:59:59")
# For redd homes
#train_dset = df_new.truncate(before="2011-05-24", after="2011-05-27 23:59:59") # continuous data
#test_dset = df_new.truncate(before="2011-05-28", after="2011-06-13 23:59:59")

# keep tab on context option - creates day and night divison
train_result = compute_appliance_statistic(train_dset,context=True) # training, using day and night context

fhmm_result  =  fhmm_decoding(train_dset,test_dset) #
fhmm_result['decoded_power'].to_csv(dissagg_result_save+"fhmm/"+homes)
#%%
#plot_actual_vs_decoded(fhmm_result)
sel_appliances = ["air1","refrigerator1"] # for iawe dataset
#sel_appliances = ["air","refrigerator"] # for REDD dataset
dis_res = localize_anomalous_appliance(fhmm_result['decoded_power'][sel_appliances],train_result,appliance_count=100,take_context=True) # appliance anomaly detection
#%%
save_path_disresults = aggregate_result + "fhmm/"
dis_res.to_csv(save_path_disresults+homes)