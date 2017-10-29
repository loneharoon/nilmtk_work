from copy import deepcopy
import pandas as pd
import numpy as np
from matplotlib import interactive

# in this script, I take a home and insert anomalies in one of the appliance and perform necessary changes in aggregate consumption.Later we save
# all changes as a separate csv file.

file = "meter_2.csv"
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/iawe/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")

df = pd.read_csv(path+file,index_col='localminute')ß
df.index =  pd.to_datetime(df.index)
df_ref = deepcopy(df['2013-07-13':'2013-08-04 23:59:59'])


 ac_anomalies = {
    # first two correspond to elongated and last two with frequent anomalies
 1:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-07-21 21:00:00', hours = 4,  upper_mag = 1800,  frequency = 4., dutycycle = 0.5),
 2:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-07-25 22:00:00', hours = 6,  upper_mag = 1800,  frequency = 2., dutycycle = 0.7),
 3:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-07-29 21:00:00', hours = 6,  upper_mag = 1800, frequency =  2.,  dutycycle = 0.9),
 4:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-07-30 22:00:00', hours = 4,  upper_mag = 1800,  frequency = 30., dutycycle = 0.5),
 5:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-08-02 22:00:00', hours = 6,  upper_mag = 1800,  frequency = 60.,   dutycycle = 0.6)
}


anomalous_df = insert_anomaly_in_testframe(df_ref,ac_anomalies,appliance_name="ac2")


fridge_anomalies = {
    # first two correspond to elongated and last two with frequent anomalies
 1:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-07-22 06:00:00', hours = 10, upper_mag = 110, frequency = 4.,  dutycycle = 0.6),
 2:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-07-27 18:00:00', hours = 6,  upper_mag = 110, frequency = 2.,  dutycycle = 0.8 ),
 3:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-07-28 07:00:00', hours = 8,  upper_mag = 110, frequency = 60., dutycycle = 0.5),
 4:generate_synthetic_seconds_timeseries_anomaly(timestart = '2013-08-03 00:00:00', hours = 6,  upper_mag = 110, frequency = 60., dutycycle = 0.2)
 }

anomalous_df2 = insert_anomaly_in_testframe(anomalous_df,fridge_anomalies,appliance_name="fridge")

store_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
  anomalous_df2.to_csv(store_path+file)



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


  p = generate_synthetic_seconds_timeseries_anomaly(timestart = '2014-07-25 06:00:00', hours = 1, upper_mag = 90, frequency = 60., dutycycle = 0.8)
  p.plot()