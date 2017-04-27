# this file differes from localize_main file only in the perspective that context is added
import warnings
warnings.filterwarnings("ignore")
import fhmm_support as fhm
import numpy as np
import pandas as pd
np.random.seed(123)
import matplotlib.pyplot as plt
from collections import OrderedDict
from hmmlearn import hmm
from IPython import embed
import time

# List all houses in a directory
dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default_3months/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/localize_fhmm")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/localize_appliance_support")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plot_functions.py")

houses = [f for f in os.listdir(dir)]
df = pd.read_csv(dir+houses[6],index_col='localminute') # USE HOUSE (6,115) 
df.index = pd.to_datetime(df.index)

df = df["2014-06-01":"2014-08-30"]
res = df.sum(axis=0)
high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few applainces
df_new = df[high_energy_apps]
del df_new['use']# drop stale aggregate column
df_new['use'] = df_new.sum(axis=1) # create new aggregate column

train_dset = df_new.truncate(before="2014-06-01", after="2014-06-20 23:59:59")
test_dset = df_new.truncate(before="2014-06-21", after="2014-06-24 23:59:59")
# keep tab on context option - creates day and night divison
train_result = compute_appliance_statistic(train_dset,context=True) # training, using day and night context


# NORMAL CASE WHEN ANAOMLALIES ARE NOT INSERTED
fhmm_result  =  fhmm_decoding(train_dset,test_dset) # dissagreation
plot_actual_vs_decoded(fhmm_result)
sel_appliances = ["air1","refrigerator1"]
localize_anomalous_appliance(fhmm_result['decoded_power'][sel_appliances],train_result) # appliance anomaly detection

# CASE WHEN ANAOMLALIES ARE INSERTED IN SELECTED APP
anomalies = {
 1:generate_synthetic_timeseries_anomaly(timestart = '2014-06-21',hours = 7, upper_mag = 1100, frequency = 1/4, dutycycle = 0.7),
 2:generate_synthetic_timeseries_anomaly(timestart = '2014-06-22',hours = 8, upper_mag = 1100, frequency = 1/6, dutycycle = 0.7),
 3:generate_synthetic_timeseries_anomaly(timestart = '2014-06-23',hours = 9, upper_mag = 1100, frequency = 1/8, dutycycle = 0.7),
 4:generate_synthetic_timeseries_anomaly(timestart = '2014-06-24',hours = 15, upper_mag = 1100, frequency =  20, dutycycle = 0.4)
}
test_dset_anomalous = insert_anomaly_in_testframe(test_dset,anomalies,appliance_name="air1")
fhmm_result  =  fhmm_decoding(train_dset,test_dset_anomalous) # dissagreation
plot_actual_vs_decoded(fhmm_result)
sel_appliances = ["air1","refrigerator1"]
localize_anomalous_appliance(fhmm_result['decoded_power'][sel_appliances],train_result,appliance_count=100) # appliance anomaly detection

# check at applaince level
appliance ="air1"
anomalous_appliance = insert_anomaly_in_appliance(test_dset,anomalies,appliance_name=appliance)
localize_anomalous_appliance(anomalous_appliance,train_result[appliance],appliance_count=1) # appliance anomaly detection





