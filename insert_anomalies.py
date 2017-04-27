from copy import deepcopy
from matplotlib import interactive

file = "115.csv"
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/localize_appliance_support")

df = pd.read_csv(path+file,index_col='localminute')
df.index =  pd.to_datetime(df.index)
df_ref = deepcopy(df["air1"]['2014-06-01':'2014-07-30'])
df_ref = df_ref.to_frame()
df_ref['synthetic'] = deepcopy(df_ref['air1'].values)

df_ref["2014-06-24"].plot()



# assume I know the place where I need to insert 
# 1. get signal
s_data = generate_synthetic_data(hours=4,upper_mag=1200,frequency=2,dutycycle=0.4)
ind = pd.date_range('06/20/2014',periods=len(s_data),freq='Min')
syn_df = pd.DataFrame(s_data,index=ind)
df_ref['synthetic'].loc[syn_df.index] = syn_df.values
df_ref.loc[syn_df.index].plot()

def inject_anomaly(timestart,hours=4,upper_mag=1200,frequency=2,dutycycle=0.4):
    s_data = generate_synthetic_data(hours=4,upper_mag=1200,frequency=2,dutycycle=0.4)
    ind = pd.date_range(timestart, periods=len(s_data),freq='Min')
    syn_df = pd.DataFrame(s_data,index=ind)
    
    df_ref['synthetic'].loc[syn_df.index] = syn_df.values
    df_ref.loc[syn_df.index].plot()
    

def generate_synthetic_data(hours, upper_mag=10, frequency = 1, dutycycle = 0.5):
    """ Function used to generate synthic data of appliances which run in only two states
    parameters: hours: no. of hours for which we need to generate data, upper_mag: highest consumption
    level, frequency: how often to change state per hour, dutycycle: duration  ratio of on/off cycle"""
    from scipy import signal
    import matplotlib.pyplot as plt
    import random as rnd
    t = np.linspace(0, hours, 60*hours, endpoint=False)# generate time sequence
    sig = signal.square(2 * np.pi *frequency* t,duty=dutycycle)
    #sig2 = [np.random.normal(upper_mag,1,1) if a==1 else 0 for a in sig]
    sig2 = [round(rnd.gauss(upper_mag,1),2) if a==1 else 0 for a in sig]
    plt.plot(t,sig2)
    return sig2

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