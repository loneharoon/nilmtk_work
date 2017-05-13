
def co_training(train_dset):
    model = []
    num_states_dict = {}
    l= train_dset.columns
    num_meters = len(l)
    if num_meters > 12:
        max_num_clusters = 2
    else:
        max_num_clusters = 3
    for i in range(len(l)):
        #print("Training model for submeter '{}'".format(meter))
        #power_series = meter.power_series(**load_kwargs)
        chunk = train_dset[l[i]]
        meter = l[i]
        #chunk = next(power_series)
        num_total_states = num_states_dict.get(meter)
        if num_total_states is not None:
            num_on_states = num_total_states - 1
        else:
            num_on_states = None
        train_on_chunk(chunk, meter, max_num_clusters, num_on_states,model)
    return model
    
def train_on_chunk(chunk, meter, max_num_clusters, num_on_states,model):
    states = cluster(chunk, max_num_clusters, num_on_states)
    model.append({
        'states': states,
        'meter': meter})
model = co_training(train_dset)
        
def set_state_combinations_if_necessary(state_combinations, model):
    """Get centroids"""
    # If we import sklearn at the top of the file then auto doc fails.
    if (state_combinations is None or state_combinations.shape[1] != len(model)):
        from sklearn.utils.extmath import cartesian
        centroids = [model['states'] for model in model]
        state_combinations = cartesian(centroids)
        return (state_combinations)

state_combinations = None
mains = test_dset['use']

appliance_powers = disaggregate_chunk(state_combinations,mains,model)

def disaggregate_chunk(state_combinations,mains,model):
    import warnings
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    state_combinations = set_state_combinations_if_necessary(state_combinations,model)
    summed_power_of_each_combination = np.sum(state_combinations, axis=1)
    indices_of_state_combinations, residual_power = find_nearest(summed_power_of_each_combination, mains.values)
    
    appliance_powers_dict = {}
    for i, mod in enumerate(model):
        print("Estimating power demand for '{}'".format(mod['meter']))
        predicted_power = state_combinations[indices_of_state_combinations, i].flatten()
        column = pd.Series(predicted_power, index=mains.index, name=i)
        appliance_powers_dict[model[i]['meter']] = column
        
    appliance_powers = pd.DataFrame(appliance_powers_dict, dtype='float32')
    return appliance_powers

