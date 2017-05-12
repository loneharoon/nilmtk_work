from copy import deepcopy
from matplotlib import interactive
# in this script, I take a home and insert anomalies in one of the appliance and perform necessary changes in aggregate consumption.Later we save 
# all changes as a separate csv file.
file = "115.csv"
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/localize_appliance_support")

df = pd.read_csv(path+file,index_col='localminute')
df.index =  pd.to_datetime(df.index)
df_ref = deepcopy(df['2014-06-01':'2014-08-30'])

anomalies = {
 1:generate_synthetic_timeseries_anomaly(timestart = '2014-07-04 06:00:00',hours = 7, upper_mag = 1200, frequency = 1/4, dutycycle = 0.7),
 2:generate_synthetic_timeseries_anomaly(timestart = '2014-07-11 06:00:00',hours = 8, upper_mag = 1200, frequency = 1/6, dutycycle = 0.7),
 3:generate_synthetic_timeseries_anomaly(timestart = '2014-07-19 06:00:00',hours = 9, upper_mag = 1100, frequency = 1/8, dutycycle = 0.7),
 4:generate_synthetic_timeseries_anomaly(timestart = '2014-07-27 18:00:00',hours = 8, upper_mag = 1200, frequency = 1/6, dutycycle = 0.7),
 5:generate_synthetic_timeseries_anomaly(timestart = '2014-07-29 18:00:00',hours = 9, upper_mag = 1100, frequency = 1/8, dutycycle = 0.7),
 6:generate_synthetic_timeseries_anomaly(timestart = '2014-07-24 06:00:00',hours = 8, upper_mag = 1100, frequency =  16, dutycycle = 0.4)
}

anomalous_df = insert_anomaly_in_testframe(df_ref,anomalies,appliance_name="air1")
store_path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
anomalous_df.to_csv(store_path+"115.csv")