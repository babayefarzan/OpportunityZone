import geopandas as gpd,numpy as np,pandas as pd
from sklearn.cluster import KMeans

variables = {
	'pop' : {'cols':['DP0010001'],'share':False,'log':True},
	'young' : {'cols':['DP0010006','DP0010007'],'share':True,'log':False},
	'old' : {'cols':['DP0060001'],'share':True,'log':False},
	'male' : {'cols':['DP0010020'],'share':True,'log':False},
	'white' : {'cols':['DP0080003'],'share':True,'log':False},
	'hispanic' : {'cols':['DP0100002'],'share':True,'log':False},
	'households' : {'cols':['DP0130001'],'share':True,'log':False},
	'families' : {'cols':['DP0130002'],'share':True,'log':False},
	'household_size' : {'cols':['DP0160001'],'share':True,'log':False}
	}

data = gpd.read_file('../GAMA/OpportunityZone/includes/Tract_2010Census_DP1_CA/Tract_2010Census_DP1_CA.shp')

# Make a simplified dataframe with the variables for clustering
simplified = data[['GEOID10','geometry']]
for v in variables:
    simplified[v] = data[variables[v]['cols']].sum(1)
simplified = simplified[simplified['pop']!=0]
for v in variables:
    if variables[v]['share']:
        simplified[v]=simplified[v]/simplified['pop']
for v in variables:
    if variables[v]['log']:
        simplified[v]=np.log(simplified[v]+1)
for v in variables:
    simplified[v] = (simplified[v]-simplified[v].mean())/simplified[v].std()
print 'Dropping',len(simplified)-len(simplified.dropna()),'tracts'
simplified = simplified.dropna()

# Cluster the tracts
X = simplified[variables.keys()].as_matrix()
kmeans = KMeans(n_clusters=3)
kmeans = kmeans.fit(X)
labels = kmeans.predict(X)
simplified['cluster_id'] = labels

# Save results
new_data = pd.merge(data,simplified[['GEOID10','cluster_id']])
new_data = gpd.GeoDataFrame(new_data.drop('geometry',1),geometry=new_data['geometry'])
new_data.to_file('../GAMA/OpportunityZone/includes/Tract_2010Census_DP1_CA_kmeans/Tract_2010Census_DP1_CA_kmeans.shp')
