# this script is used to insert anomalies in iawe and REDD datasets only.
from copy import deepcopy
import pandas as pd
import numpy as np
import os
from matplotlib import interactive

# in this script, I take a home and insert anomalies in one of the appliance and perform necessary changes in aggregate consumption.Later we save
# all changes as a separate csv file.

#file = "meter_2.csv" #iawe
file = "processed_data.csv" # redd
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Redd_dataset/house6/"
#path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/iawe/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")

df = pd.read_csv(path+file,index_col='localminute')
df.index =  pd.to_datetime(df.index)
#df_ref = deepcopy(df['2013-07-13':'2013-08-04 23:59:59']) # iawe
df_ref = deepcopy(df) # redd home # 6

 ac_anomalies = {
    # first two correspond to elongated and last two with frequent anomalies
 0:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-05-28 08:00:00', hours = 7,  upper_mag = 1000,  frequency = 4/5., dutycycle = 0.8),
 1:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-05-29 00:00:00', hours = 6,  upper_mag = 1200,  frequency = 4/5., dutycycle = 0.9),
 2:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-05-29 18:00:00', hours = 6,  upper_mag = 1200,  frequency = 4/5., dutycycle = 0.9),
 3:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-09 18:00:00', hours = 7,  upper_mag = 1200, frequency  =  4.,  dutycycle = 0.2),
 4:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-11 10:00:00', hours = 8,  upper_mag = 1000,  frequency = 12., dutycycle = 0.2),
 5:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-13 17:00:00', hours = 6,  upper_mag = 1200,  frequency = 4.,   dutycycle = 0.4)
}

anomalous_df = insert_anomaly_in_testframe(df_ref,ac_anomalies,appliance_name="air") #for REDD
#anomalous_df = insert_anomaly_in_testframe(df_ref, ac_anomalies, appliance_name="ac2") # for aiwe

fridge_anomalies = {
    # First three  lines are to make training data clean, since some training data was ambigious on these dates.
    # since first two correspond to elongated and last two with frequent anomalies
0: generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-05-24 00:00:00', hours=3, upper_mag=150,frequency=1., dutycycle=0.5),
1: generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-05-24 17:00:00', hours=6, upper_mag=150, frequency=1., dutycycle=0.5),
 2:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-05-25 00:00:00', hours = 6, upper_mag    = 150, frequency = 1., dutycycle=0.5),
 3:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-05-30 06:00:00', hours = 10, upper_mag   = 150, frequency = 4/7.,  dutycycle = 0.85),
 4:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-08 00:00:00', hours = 5,  upper_mag   = 150, frequency = 4/20., dutycycle = 0.95),
 5:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-08 17:00:00', hours = 6,  upper_mag   = 150, frequency = 4/20.,  dutycycle = 0.95),
 6:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-12 06:00:00', hours = 11, upper_mag   = 150, frequency = 6., dutycycle = 0.2),
 7:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-10 00:00:00', hours = 6,  upper_mag   = 150, frequency = 90., dutycycle = 0.9),
 8:generate_synthetic_seconds_timeseries_anomaly(timestart = '2011-06-10 17:00:00', hours = 6,  upper_mag   = 150, frequency = 90., dutycycle = 0.9)
 }

#anomalous_df2 = insert_anomaly_in_testframe(anomalous_df,fridge_anomalies,appliance_name="fridge") # for aiwe
anomalous_df2 = insert_anomaly_in_testframe(anomalous_df,fridge_anomalies,appliance_name="refrigerator") # for redd

# ONLY FOR REDD HOME
anomalous_df2 = anomalous_df2.rename(columns = {'air':'air1','refrigerator':'refrigerator1'})
store_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
file= "redd_home_6.csv" # use this explicitly for redd otherwise default works fine
os.remove("/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/redd_home_6.csv")
anomalous_df2.to_csv(store_path+file)

# ONLY AIWE METER 2
# anomalous_df2 = anomalous_df2.rename(columns = {'ac2':'air1','fridge':'refrigerator1'})
# store_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
# file= "meter_2.csv" # use this explicitly for redd otherwise default works fine
# anomalous_df2.to_csv(store_path+file)


def generate_synthetic_seconds_timeseries_anomaly(timestart,hours, upper_mag=10, frequency = 1, dutycycle = 0.5):
    """ """
    from scipy import signal
    import matplotlib.pyplot as plt
    import random as rnd
    t = np.linspace(0, hours, 60*60*hours, endpoint=False)# generate time sequence
    sig = signal.square(2 * np.pi *frequency* t,duty=dutycycle)
    #sig2 = [np.random.normal(upper_mag,1,1) if a==1 else 0 for a in sig]
    sig2 = [round(rnd.gauss(upper_mag,1),2) if a==1 else 0 for a in sig]
    ind = pd.date_range(timestart, periods=len(sig2),freq='S')
    syn_df = pd.DataFrame(sig2,index=ind)
    return(syn_df)



 #p = generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-08-02 18:00:00', hours = 5, upper_mag = 100, frequency = 1., dutycycle = 0.5)
 #p.plot()