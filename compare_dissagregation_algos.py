import warnings
warnings.filterwarnings("ignore")
import fhmm_support as fhm
import numpy as np
import pandas as pd
np.random.seed(123)
#import matplotlib.pyplot as plt
from collections import OrderedDict
from hmmlearn import hmm
#from IPython import embed
import time

# List all houses in a directory
dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default_3months/"
savedir = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/disagg_results/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/localize_fhmm")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/localize_appliance_support")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plot_functions.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/cluster_file.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/utils.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/co.py")

def run_dissaggreation_algos():
    houses = [f for f in os.listdir(dir)]
    for hos in houses:
        df = pd.read_csv(dir+hos,index_col='localminute') # USE HOUSE (6,115) 
        df.index = pd.to_datetime(df.index)
        df = df["2014-06-01":"2014-08-30"]
        res = df.sum(axis=0)
        high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few applainces
        df_new = df[high_energy_apps]
        del df_new['use']# drop stale aggregate column
        df_new['use'] = df_new.sum(axis=1) # create new aggregate column
        
        train_dset = df_new.truncate(before="2014-06-01", after="2014-06-30 23:59:59")
        test_dset = df_new.truncate(before="2014-07-1", after="2014-07-15 23:59:59")
        # keep tab on context option - creates day and night divison
        #train_result = compute_appliance_statistic(train_dset,context=True) # training, using day and night context
        
        fhmm_result  =  fhmm_decoding(train_dset,test_dset) # dissagreation
        co_result = co_decoding(train_dset,test_dset)
        #plot_actual_vs_decoded(co_result)
        fhmm_rmse = compute_rmse(fhmm_result['actaul_power'],fhmm_result['decoded_power'])
        co_rmse = compute_rmse(co_result['actaul_power'],co_result['decoded_power'])
        fhmm_rmse = pd.DataFrame.from_dict(fhmm_rmse)
        co_rmse = pd.DataFrame.from_dict(co_rmse)
        fhmm_rmse.to_csv(savedir+"fhmm_rmse_"+hos)
        co_rmse.to_csv(savedir+"co_rmse_"+hos)
        
        aggregate = sum(test_dset['use'])
        fhmm_accu = diss_accu_metric_kotler_1(fhmm_result,aggregate)
        co_accu = diss_accu_metric_kotler_1(co_result,aggregate)
        res_frame = pd.DataFrame(data={'algo':['fhmm_acc','co_acc'],'accuracy':[fhmm_accu,co_accu]})
        res_frame.to_csv(savedir+"accuracy_"+hos,index=False)
        

