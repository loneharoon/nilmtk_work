
# df = pd.DataFrame({'a':np.random.normal(50,2,100),'b':np.random.normal(100,2,100),'c':np.random.normal(150,2,100),'d': np.random.normal(60,1,100)})
# df2 = pd.DataFrame({'a':np.random.normal(10,2,100),'b':np.random.normal(80,2,100),'c':np.random.normal(50,2,100),'d': np.random.normal(40,1,100)})
#
# agg = np.sum(df,axis=1)
# agg_sum =  sum(agg)
#
# df_dis = deepcopy(df)
# df_dis['a'] = df_dis['d']
# results  = {}
# results['actaul_power'] =  df
# results['decoded_power'] = df
# diss_accu_metric_kotler_1(results, agg_sum)

def accuracy_metric_gemello(dis_result):
   '''This per appliance accuracy metric is used in Gamello. Paper mentions that it is based on works 1,7 mentioned in gamello paper'''
    ### this fails when there are 0 values in the denominator
    pred = dis_result['decoded_power']
    gt = dis_result['actaul_power']
    per_accu = {}
    for app in gt.columns:
        per_error = (abs(pred[app].values - gt[app].values)/ (gt[app] * 1.0)) * 100
        per_accu[app] = np.mean(per_error)
        # FIXME i am per error and not accuracy
    #print per_accu
    result = pd.DataFrame.from_dict(per_accu, orient='index')
    return result

def accuracy_metric_norm_error(dis_result):
   '''Metric taken from Nipuns NILMTK paper:Normalised error in assigned power'''
    pred = dis_result['decoded_power']
    gt = dis_result['actaul_power']
    error = {}
    for app in gt.columns:
        numerator = sum(abs(pred[app].values - gt[app].values))
        denominator = sum(gt[app]) * 1.0
        error[app] = np.divide(numerator,denominator)
    #print per_accu
    result = pd.DataFrame.from_dict(error, orient='index')
    return result


accuracy_metric_norm_error(fhmm_result)





check2(fhmm_result)

pd.concat([fhmm_result['actaul_power']['air1'],fhmm_result['decoded_power']['air1']],axis=1,ignore_index=True)

def diss_accu_metric_kotler_2_per_app(dis_result,aggregate):
    #dis_result = co_result
    pred = dis_result['decoded_power']
    gt = dis_result['actaul_power']
    error = []
    for app in gt.columns:
        numerator = 0
        numerator = sum(abs(pred[app].values - gt[app].values))
        denominator = sum(gt[app].values)
        print(numerator/denominator)
    #return (1 - (numerator / denominator))

diss_accu_metric_kotler_2_per_app(fhmm_result, sum(test_dset['use']))
