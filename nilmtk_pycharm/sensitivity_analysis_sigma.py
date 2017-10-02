# using this script we do the sensitivity analysis of sigma
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd
np.random.seed(123)
import os

# List all houses in a directory
#dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default_3months/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")

path2 = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
aggregate_result = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"

#homes = ["115.csv","434.csv","490.csv","1463.csv","3538.csv"]
#file1 ="115.csv"
#houses = [f for f in os.listdir(dir)]
#df = pd.read_csv(dir+houses[6],index_col='localminute') # USE HOUSE (6,115)
#for i in range(len(homes)):
home = "115.csv"
df = pd.read_csv(path2+home,index_col='localminute') # injected anomalies
df.index = pd.to_datetime(df.index)

df = df["2014-06-01":"2014-08-30 23:59:59"]
res = df.sum(axis=0)
high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1)# create new aggregate column

train_dset = df_new.truncate(before="2014-06-01", after="2014-06-30 23:59:59")
test_dset  = df_new.truncate(before="2014-07-01 00:00:00", after="2014-08-30 23:59:59")
# keep tab on context option - creates day and night divison
sel_appliances = ["air1","refrigerator1"]
train_result = compute_appliance_statistic(train_dset[sel_appliances], context=True) # training, using day and night context

sel_appliances = ["air1","refrigerator1"]
sigma_group = [0.5,1.0,1.5,2.0,2.5]
print home
for i in range(len(sigma_group)):
    orac_results = sensitivity_localize_anomalous_appliance(test_dset[sel_appliances], train_result, appliance_count=100, take_context=True,sigma=sigma_group[i])# appliance anomaly detect
    save_path = aggregate_result + "oracle_sensitivity/"
    orac_results.to_csv(save_path + home.split('.')[0]+'_sigma_'+str(sigma_group[i])+'.csv')
    #orac_results

#orac_results[orac_results['air1']==1]
#orac_results[orac_results['refrigerator1']==1]