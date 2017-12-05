import warnings
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd
np.random.seed(123)
import os
# ALT=+ shift + e

# List all houses in a directory
#dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default_3months/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")

path2 = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
aggregate_result = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"

#homes = ["115.csv","434.csv","490.csv","1463.csv","3538.csv"]
homes =  "redd_home_6.csv"    # ["meter_2.csv","redd_home_6.csv"]
#homes =  "meter_2.csv"

df = pd.read_csv(path2+homes,index_col='localminute') # injected anomalies
df.index = pd.to_datetime(df.index)

res = df.sum(axis=0)
high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1)# create new aggregate column

#FOR iawe
#train_dset = df_new.truncate(before="2013-07-13", after="2013-07-20 23:59:59")
#test_dset = df_new.truncate(before="2013-07-21", after="2013-08-04 23:59:59")
#test_dset = df_new.truncate(before="2013-07-30", after="2013-08-02 23:59:59")

# For redd homes
train_dset = df_new.truncate(before="2011-05-24", after="2011-05-27 23:59:59") # continuous data
test_dset = df_new.truncate(before="2011-05-28", after="2011-06-13 23:59:59")
#test_dset = df_new.truncate(before="2011-06-10", after="2011-06-10 23:59:59")
if(test_dset.isnull().values.any()): # note I am replacing na values with direct 0
    test_dset = test_dset.fillna(0)

#test_dset = df_new.truncate(before="2011-05-30", after="2011-05-30 23:59:59")
# keep tab on context option - creates day and night divison
sel_appliances = ["air1","refrigerator1"]
#sel_appliances = ["refrigerator1"]
train_result = compute_appliance_statistic(train_dset[sel_appliances], context=True) # training, using day and night context

#sel_dates=['2014-07-04','2014-07-11','2014-07-19','2014-07-27','2014-07-29']
#test_dset = test_dset.query('@test_dset.indeåx.normalize()in @sel_dates')

orac_results = localize_anomalous_appliance(test_dset[sel_appliances], train_result, appliance_count=100, take_context=True)# appliance anomaly detect
print(orac_results)

#save_path = aggregate_result + "oracle/"
#orac_results.to_csv(save_path + homes)
