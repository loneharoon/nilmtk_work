import seaborn as sns
from copy import deepcopy

def plot_daywise_facet(app_data,ncolumns=5):
    """ this functions plots facet_grid with ncolumns
    input:only one appliance data with index datetime column"""
    l = deepcopy(app_data)
    index = l.index.day
    l = l.to_frame()
    l['index'] = index
    l.columns = ['power','day']
    l['time'] = l.index.time
    g = sns.FacetGrid(l,col="day",col_wrap=ncolumns)
    g.map(sns.tsplot,"power")
    
def plot_pandas(df_sub):
    """plots entire data frame"""
    plt.figure(figsize=(12,4))
    df_sub.plot()

def plot_actual_vs_decoded(fhmm_result):
   """ function used to plot actual appliance vs dissagregated signal""" 
    actual = fhmm_result['actaul_power']
    decoded = fhmm_result['decoded_power']
    appliances = actual.columns
    fig, ax = plt.subplots(nrows = len(appliances), ncols = 2)
    for i in range(len(appliances)):
        ax[i, 0].plot(actual[appliances[i]])
        ax[i, 0].set_title("actual appliance "+ appliances[i])
        ax[i, 1].plot(decoded[appliances[i]])
        ax[i, 1].set_title("decoded appliance " + appliances[i])
    fig.tight_layout()