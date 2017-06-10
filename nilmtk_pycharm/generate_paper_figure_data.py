# i used this script to generate data to show how normal consumption  is, how frequent and elongated anomalies look like

def generate_synthetic_timeseries_anomaly(timestart,hours, upper_mag=10, frequency = 1, dutycycle = 0.5):
    """ """
    from scipy import signal
    import matplotlib.pyplot as plt
    import numpy as np
    import pandas as pd
    import random as rnd
    t = np.linspace(0, hours, 60*hours, endpoint=False)# generate time sequence
    sig = signal.square(2 * np.pi *frequency* t,duty=dutycycle)
    #sig2 = [np.random.normal(upper_mag,1,1) if a==1 else 0 for a in sig]
    sig2 = [round(rnd.gauss(upper_mag,1),2) if a==1 else 0 for a in sig]
    ind = pd.date_range(timestart, periods=len(sig2),freq='Min')
    syn_df = pd.DataFrame(sig2,index=ind)
    return(syn_df)

p = generate_synthetic_timeseries_anomaly("2016-06-01 00:00:00",10, 1200,1/2.5,0.6)
#p.plot()

q = generate_synthetic_timeseries_anomaly("2016-06-01 00:00:00",10, 1200,1/5.,0.9)
#q.plot()

r = generate_synthetic_timeseries_anomaly("2016-06-01 00:00:00",10, 1200,3.,0.8)
#r.plot()

df = pd.concat([p,q,r],axis=1)
path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/methodolgy_figdata/"
df.to_csv(path+"three_ac_scenario.csv")