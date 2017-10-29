from copy import deepcopy
import pandas as pd
from matplotlib import interactive

# in this script, I take a home and insert anomalies in one of the appliance and perform necessary changes in aggregate consumption.Later we save
# all changes as a separate csv file.

file = "490.csv"
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default3/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")

df = pd.read_csv(path+file,index_col='localminute')
df.index =  pd.to_datetime(df.index)
df_ref = deepcopy(df['2014-06-01':'2014-08-30 23:59:59'])


 ac_anomalies = {
    # first two correspond to elongated and last two with frequent anomalies
 1:generate_synthetic_timeseries_anomaly(timestart = '2014-07-30 00:00:00',hours = 9, upper_mag = 4000, frequency = 1/3., dutycycle = 0.9),
 2:generate_synthetic_timeseries_anomaly(timestart = '2014-08-30 18:00:00',hours = 6, upper_mag = 4000, frequency = 1/7., dutycycle = 0.9),
 3:generate_synthetic_timeseries_anomaly(timestart = '2014-07-25 06:00:00',hours = 12, upper_mag = 4000, frequency = 1/4., dutycycle = 0.8),
 4:generate_synthetic_timeseries_anomaly(timestart = '2014-08-25 11:00:00',hours = 9, upper_mag = 4000,frequency = 1/3., dutycycle = 0.8),
 5:generate_synthetic_timeseries_anomaly(timestart = '2014-07-01 00:00:00',hours = 6, upper_mag = 4000, frequency = 3., dutycycle = 0.5),
 6:generate_synthetic_timeseries_anomaly(timestart = '2014-08-01 09:00:00',hours = 8, upper_mag = 4000, frequency = 6., dutycycle = 0.5)
}


anomalous_df = insert_anomaly_in_testframe(df_ref,ac_anomalies,appliance_name="air1")


fridge_anomalies = {
    # first two correspond to elongated and last two with frequent anomalies
 1:generate_synthetic_timeseries_anomaly(timestart = '2014-07-04 06:00:00',hours = 10, upper_mag = 90, frequency = 1/3., dutycycle = 0.9),
 2:generate_synthetic_timeseries_anomaly(timestart = '2014-07-18 18:00:00',hours = 6, upper_mag = 90, frequency = 1/3.,dutycycle = 0.7 ),
 3:generate_synthetic_timeseries_anomaly(timestart = '2014-07-21 07:00:00',hours = 8, upper_mag = 90, frequency = 12., dutycycle = 0.8),
 4:generate_synthetic_timeseries_anomaly(timestart = '2014-07-06 00:00:00',hours = 6, upper_mag = 90, frequency = 10., dutycycle = 0.3)
 }

anomalous_df2 = insert_anomaly_in_testframe(anomalous_df,fridge_anomalies,appliance_name="refrigerator1")

store_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
  anomalous_df2.to_csv(store_path+file)

def generate_synthetic_timeseries_anomaly(timestart,hours, upper_mag=10, frequency = 1, dutycycle = 0.5):
    """ """
    from scipy import signal
    import matplotlib.pyplot as plt
    import random as rnd
    t = np.linspace(0, hours, 60*hours, endpoint=False)# generate time sequence
    sig = signal.square(2 * np.pi *frequency* t,duty=dutycycle)
    #sig2 = [np.random.normal(upper_mag,1,1) if a==1 else 0 for a in sig]
    sig2 = [round(rnd.gauss(upper_mag,1),2) if a==1 else 0 for a in sig]
    ind = pd.date_range(timestart, periods=len(sig2),freq='Min')
    syn_df = pd.DataFrame(sig2,index=ind)
    return(syn_df)


  #p = generate_synthetic_timeseries_anomaly(timestart = '2014-07-25 06:00:00', hours = 1, upper_mag = 90, frequency = 10., dutycycle = 0.3)
  #p.plot()