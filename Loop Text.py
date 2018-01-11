import pandas as pd
import numpy as np

d = pd.read_csv('//cifs2/homedir$/Office/Projects/Report Inventory/TextTest.txt', sep=" ", header=None)
d.columns = ["Site", "Date", "Nothing"]


d['SiteEXTRA'] = d['Site'].map({'LW': 0, 'SS': 1})
d['SiteLag'] = d['SiteEXTRA'].shift(1)
d['SiteControl'] = 0
 d['SiteCom'] = np.where(d['SiteLag'] != d['SiteEXTRA'])

# for index, row in d.iterrows():
#     if d['SiteEXTRA'] d['SiteLag']:
#         d['SiteControl'] = d['SiteControl'] + 1
#     print(row['Site'], row['SiteEXTRA'])

print(d)