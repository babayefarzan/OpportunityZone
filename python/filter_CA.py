import geopandas as gpd
data = gpd.read_file('../GAMA/OpportunityZone/includes/Tract_2010Census_DP1/Tract_2010Census_DP1.shp')
states = gpd.read_file('../GAMA/OpportunityZone/includes/cb_2016_us_state_500k/cb_2016_us_state_500k.shp')
california_geo = states[states['STUSPS']=='CA']['geometry'].values[0]
data['CA_Area'] = data.geometry.intersection(california_geo).area
data['Area'] = data.geometry.area
data['CA_share'] = data['CA_Area']/data['Area']
CA = data[data['CA_share']==1]
CA = CA.drop(['CA_Area','Area','CA_share'],1)
CA = gpd.GeoDataFrame(CA.drop('geometry',1),geometry=CA['geometry'])
CA.to_file('../GAMA/OpportunityZone/includes/Tract_2010Census_DP1_CA/Tract_2010Census_DP1_CA.shp')