#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun Jan 14 09:06:17 2018

@author: haroonr
"""

#%%
# temp scripts for iawe insights
p  = temp['2013-07-21':'2013-08-05']
p['Timestamp'] = p.index
t = pd.melt(p,id_vars=['Timestamp'],value_vars=["Submetered","Disaggregated"],var_name='Data',value_name='Power (W)')
pal = dict(Submetered="black", Disaggregated="blue")
sobj = sns.FacetGrid(t,row='Data',sharex=True,margin_titles=False,hue='Data',palette=pal)
(sobj.map(plt.plot,'Timestamp','Power (W)').set_xticklabels())
#sobj.savefig("tempo.pdf")
#%%
savepath= "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/eEnergy_2018/plots/"
p['2013-07-25':'2013-08-05'].plot(subplots=True)
plt.xlabel("Timestamp")
plt.ylabel("Power (W)")
plt.tight_layout()
plt.savefig(savepath+"insights_iawe1.pdf")
#%%