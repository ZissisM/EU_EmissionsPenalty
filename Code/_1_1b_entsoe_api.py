from _1_1a_entsoe_api_fn import get_entsoe

"""
NOTES:

Country list in api file needs fixing - do we want country level data or TSO?
TSO list seems correct: Only Germany has more than one:
https://www.next-kraftwerke.com/knowledge/european-tsos-list

Data is not necessarily in hourly format, some might be half hour. Need to sum.
Done in next file.

Some foriegn characters aren't showing properly (e.g. spanish plant name).
Could just be display, should still be able to match.

Generation Fuel type data has different column names for different countries
e.g. "Biomass" vs "('Biomass', 'Actual Aggregated')"

Decommissioning Date - can't find in API, may need to get manually.
On a yearly level so not too difficult.

Electricity Transfers - question on if we need it if we're looking at whole EU

installed capacity doesn't have year...what data is it getting? Capacity at beginning of year.
It's only getting one year of data - need to redo code so it gets all - Done.
Also, e.g. DRAXX rather than DRAXX-2, so need to be aware of this when merging datasets

COUNTRIES WITHOUT GENERATION DATA: HR, CY, LU, MT
MOSTLY MISSING GENERATION DATA: NO
Germany within country exports between TSOs is missing

"""
# country_list = ['FR']

# country_list = ['AT', 'BE', 'BG', 'CH', 'CZ', 'DE_50Hertz', 'DE_Amprion', 'DE_TenneT', 'DE_TransnetBW', 'DK', 'EE']
# cz,'IT-BRNN','IT-CNOR','IT-FOGN','IT-NORD','IT-PRGP','IT-ROSN','IT-SARD','IT-SICI','IT-SUD'
# country_list = ['AL', 'AX', 'BA', 'BY', 'CY', 'RU','DE_50Hertz', 'DE_Amprion', 'DE_TenneT', 'DE_TransnetBW', 'CZ_DE_SK','DE_LU','DE_AT_LU','DK','DK_CA', 'IE', 'MK', 'IS', 'IE_SEM', 'IE', 'GB', 'GB-NIR','DE','AT','BE','BG','CH','CZ_','EE','ES','FI','GR','HR','HU','LV','LT','NL','PL','RO','PT','RS','SI','SK','UK_GB','FR','ME','NO','NO-1','NO-2','NO-3','NO-4','NO-5','MT', 'LU', 'RU','IT', 'RU_KGD', 'SE','SE-1','SE-2','SE-3','SE-4','TR','UA','UK_NI']
# failed for price : AL, AX, BA, BY, CY, CZ_DE_SK,DE,DE_LU,DE_AT_LU,DK,DK_CA, IE, MK, IS, IE_SEM, IE, GB, GB-NIR, AT is quarterly
# ME,MT, LU, RU, RU_KGD, SE,SE1-4,TR,UA,UK_NI
# failed for load(from price list above): RU,
# failed for capacity data: HR, RU, SI(2015-2016),SK(2015)
# DE 4 TSOs work for these 2 above
# worked: 'DE','AT','BE','BG','CH','CZ_','EE','ES','FI','GR','HR','HU','LV','LT','NL','PL','RO','PT','RS','SI','SK','UK_GB'
# gen_byplant failed: NO#, HU,
# PL from 2018, DK up to 2021, IT from 2019
# gen type failed:
# uk up to 2020

#country_list = ['AT', 'BE', 'BG', 'CH', 'CZ_', 'DE_50Hertz', 'DE_Amprion', 'DE_TenneT', 'DE_TransnetBW', 'DK', 'EE','ES', 'FI', 'FR', 'GR', 'HR', 'HU', 'IT', 'LT', 'NL', 'NO', 'PL', 'RO', 'PT', 'RS', 'SI', 'SK']
#country_list = ['IT-SICI', 'IT-NORD', 'IT-CNOR' ,'IT-CSUD', 'IT-SUD', 'IT-FOGN', 'IT-ROSN', 'IT-BRNN', 'IT-PRGP', 'IT-SARD']
#country_list=['DE_50Hertz']

#country_list = ['BE', 'BG', 'CH', 'DK', 'ES', 'FR', 'GR', 'LT', 'RO', 'PT', 'RS', 'SI', 'SK', 'UK']
country_list=['FR']
start = '20160101'
end = '20201201'

# switch to whatever folder you're downloading data to
# folder = "C:\\Users\\Taraq\\Google Drive\\Not on HDD\\Research\\EU_Energy\\data\\entsoe\\"
#folder = "C:\\Users\\ZMarmarelis\\Desktop\\entsoe_data\\"
folder = "C:\\Users\\ZMarmarelis\\Downloads\\entsoe_data\\"

"""Download data and save each country seperately"""
# df = get_entsoe(country_list, start, end).generation_per_plant(folder)
df = get_entsoe(country_list, start, end).load(folder)
# df = get_entsoe(country_list, start, end).generation_type(folder)
#df = get_entsoe(country_list, start, end).capacity_per_plant(folder)
#df = get_entsoe(country_list, start, end).price(folder)
# df = get_entsoe(country_list, start, end).contracted_reserve_amount(folder)
# df = get_entsoe(country_list, start, end).electricity_transfer(folder)
#df = get_entsoe(country_list, start, end).capacity(folder)

"""Decommissioning date"""
# Do manually - Yearly so not too much of an issue.
