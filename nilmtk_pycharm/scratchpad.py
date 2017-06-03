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
df = pd.read_csv(path2+"3538.csv",index_col='localminute') # injected anomalies
#df = pd.read_csv(dir+file1,index_col='localminute')
df.index = pd.to_datetime(df.index)

#sel_dates = pd.read_csv(aggregate_result+file1)['Index'].tolist()#VALUES CALCUALTED IN RSTUDIO...main_function_offline.R

df = df["2014-06-01":"2014-08-30 23:59:59"]
res = df.sum(axis=0)
high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1)# create new aggregate column

train_dset = df_new.truncate(before="2014-06-01", after="2014-06-30 23:59:59")
test_dset = df_new.truncate(before="2014-07-01 00:00:00", after="2014-08-30 23:59:59")
# keep tab on context option - creates day and night divison
sel_appliances = ["air1","refrigerator1"]
train_result = compute_appliance_statistic(train_dset[sel_appliances], context=True) # training, using day and night context

#sel_dates=['2014-07-04','2014-07-11','2014-07-19','2014-07-27','2014-07-29']
#test_dset = test_dset.query('@test_dset.index.normalize()in @sel_dates')
sel_appliances = ["air1","refrigerator1"]
orac_results= localize_anomalous_appliance(test_dset[sel_appliances], train_result, appliance_count=100, take_context=True)# appliance anomaly detect
#save_path = aggregate_result + "oracle/"
#orac_results.to_csv(save_path + homes[i])
#orac_results

orac_results[orac_results['air1']==1]
orac_results[orac_results['refrigerator1']==1]