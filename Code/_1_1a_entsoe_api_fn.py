import pandas as pd
from entsoe import EntsoePandasClient
import os
import traceback
import time


client = EntsoePandasClient(api_key= '833a1055-1404-4b16-b04f-01b104f73f61')

client.retry_count = 100
client.retry_delay = 10

"""
Code takes too long to run. df_all commented out - do later
Switch the appending for files to melt too

"""

# https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html#_areas
# Will have to use section A.10 to redo domain mappings for which places we want
# ^ Done in CONTROL_AREAS and MERGED_MAPPINGS
DOMAIN_MAPPINGS = {
     'AL': '10YAL-KESH-----5',
    'AT': '10YAT-APG------L',
    'AX': '10Y1001A1001A46L',  # for price only; Åland has SE-SE3 area price
    'BA': '10YBA-JPCC-----D',
    'BE': '10YBE----------2',
    'BG': '10YCA-BULGARIA-R',
    'BY': '10Y1001A1001A51S',
    'CH': '10YCH-SWISSGRIDZ',
    'CZ': '10YCZ-CEPS-----N',
   # 'DE': '10Y1001A1001A83F',
    'DE': '10Y1001A1001A63L',
    'DE-LU': '10Y1001A1001A82H',
    'DK': '10Y1001A1001A65H',
    'DK-DK1': '10YDK-1--------W',
    'DK-DK2': '10YDK-2--------M',
    'EE': '10Y1001A1001A39I',
    'ES': '10YES-REE------0',
    'FI': '10YFI-1--------U',
    'FR': '10YFR-RTE------C',
    'GB': '10YGB----------A',
    'GB-NIR': '10Y1001A1001A016',
    'GR': '10YGR-HTSO-----Y',
    'HR': '10YHR-HEP------M',
    'HU': '10YHU-MAVIR----U',
    'IE': '10YIE-1001A00010',
    'IT': '10YIT-GRTN-----B',
    'IT-BR': '10Y1001A1001A699',
    'IT-CA': '10Y1001C--00096J',
    'IT-CNO': '10Y1001A1001A70O',
    'IT-CSO': '10Y1001A1001A71M',
    'IT-FO': '10Y1001A1001A72K',
    'IT-NO': '10Y1001A1001A73I',
    'IT-PR': '10Y1001A1001A76C',
    'IT-SAR': '10Y1001A1001A74G',
    'IT-SIC': '10Y1001A1001A75E',
    'IT-SO': '10Y1001A1001A788',
    'LT': '10YLT-1001A0008Q',
    'LU': '10YLU-CEGEDEL-NQ',
    'LV': '10YLV-1001A00074',
    'ME': '10YCS-CG-TSO---S',
    'MK': '10YMK-MEPSO----8',
    'MT': '10Y1001A1001A93C',
    'NL': '10YNL----------L',
    'NO': '10YNO-0--------C',
    'NO-NO1': '10YNO-1--------2',
    'NO-NO2': '10YNO-2--------T',
    'NO-NO3': '10YNO-3--------J',
    'NO-NO4': '10YNO-4--------9',
    'NO-NO5': '10Y1001A1001A48H',
    'PL': '10YPL-AREA-----S',
    'PT': '10YPT-REN------W',
    'RO': '10YRO-TEL------P',
    'RS': '10YCS-SERBIATSOV',
    'RU': '10Y1001A1001A49F',
    'RU-KGD': '10Y1001A1001A50U',
    'SE': '10YSE-1--------K',
    'SE-SE1': '10Y1001A1001A44P',
    'SE-SE2': '10Y1001A1001A45N',
    'SE-SE3': '10Y1001A1001A46L',
    'SE-SE4': '10Y1001A1001A47J',
    'SI': '10YSI-ELES-----O',
    'SK': '10YSK-SEPS-----K',
    'TR': '10YTR-TEIAS----W',
    'UA': '10YUA-WEPS-----0'
}
BIDDING_ZONES = DOMAIN_MAPPINGS.copy()
BIDDING_ZONES.update({
    'DE': '10Y1001A1001A63L',  # DE-AT-LU
    'LU': '10Y1001A1001A63L',  # DE-AT-LU
    'IT-NORD': '10Y1001A1001A73I',
    'IT-CNOR': '10Y1001A1001A70O',
    'IT-CSUD': '10Y1001A1001A71M',
    'IT-SUD': '10Y1001A1001A788',
    'IT-FOGN': '10Y1001A1001A72K',
    'IT-ROSN': '10Y1001A1001A77A',
    'IT-BRNN': '10Y1001A1001A699',
    'IT-PRGP': '10Y1001A1001A76C',
    'IT-SARD': '10Y1001A1001A74G',
    'IT-SICI': '10Y1001A1001A75E',
    'NO-1': '10YNO-1--------2',
    'NO-2': '10YNO-2--------T',
    'NO-3': '10YNO-3--------J',
    'NO-4': '10YNO-4--------9',
    'NO-5': '10Y1001A1001A48H',
    'SE-1': '10Y1001A1001A44P',
    'SE-2': '10Y1001A1001A45N',
    'SE-3': '10Y1001A1001A46L',
    'SE-4': '10Y1001A1001A47J',
    'DK-1': '10YDK-1--------W',
    'DK-2': '10YDK-2--------M'
})

CONTROL_AREAS = {
    'AL': '10YAL-KESH-----5',
    'AT': '10YAT-APG------L',
    'BA': '10YBA-JPCC-----D',
    'BE': '10YBE----------2',
    'BG': '10YCA-BULGARIA-R',
    'BY': '10Y1001A1001A51S',
    'CA': '10YHR-HEP------M',
    'CH': '10YCH-SWISSGRIDZ',
    'CY': '10YCY-1001A0003J',
    'CZ_': '10YCZ-CEPS-----N',
    'DE_50Hertz': '10YDE-VE-------2',
    'DE_Amprion': '10YDE-RWENET---I',
    'DE_TenneT': '10YDE-EON------1',
    'DE_TransnetBW': '10YDE-ENBW-----N',
    'DK': '10Y1001A1001A796',
    'DK-DK1': '10Y1001A1001A796',
    'DK-DK2': '10Y1001A1001A796',
    'EE': '10Y1001A1001A39I',
    'ES': '10YES-REE------0',
    'FI': '10YFI-1--------U',
    'FR': '10YFR-RTE------C',
    'GR': '10YGR-HTSO-----Y',
    'HR': '10YHR-HEP------M',
    'HU': '10YHU-MAVIR----U',
    'IE': '10YIE-1001A00010',
    'IT': '10YIT-GRTN-----B',
    'LV': '10YLV-1001A00074',
    'LT': '10YLT-1001A0008Q',
    'LU': '10YLU-CEGEDEL-NQ',
    'MD': '10Y1001A1001A990',
    'ME': '10YCS-CG-TSO---S',
    'MK': '10YMK-MEPSO----8',
    'MT': '10Y1001A1001A93C',
    'NL': '10YNL----------L',
    'NO': '10YNO-0--------C',
    'PL': '10YPL-AREA-----S',
    'PT': '10YPT-REN------W',
    'RO': '10YRO-TEL------P',
    'RU_': '10Y1001A1001A49F',
    'RU_KGD': '10Y1001A1001A50U',
    'RS': '10YCS-SERBIATSOV',
    'SE': '10YSE-1--------K',
    'SK': '10YSK-SEPS-----K',
    'SI': '10YSI-ELES-----O',
    'TR': '10YTR-TEIAS----W',
    'UA_': '10Y1001C--00003F',
    'UA_BEI': '10YUA-WEPS-----0',
    'UA_DOobTPP': '10Y1001A1001A869',
    'UA_IPS': '10Y1001C--000182',
    'UK_GB': '10YGB----------A',
    'UK_NI': '10Y1001A1001A016',
}

# Keep Germnay TSOs, use more fine grained for other areas.
# Note: Cannot mix and match for imports/exports. Suggest using BIDDING_ZONES.
MERGED_MAPPINGS = CONTROL_AREAS.copy()
MERGED_MAPPINGS.update({
    'IT': '10YIT-GRTN-----B',
    'IT-NORD': '10Y1001A1001A73I',
    'IT-CNOR': '10Y1001A1001A70O',
    'IT-CSUD': '10Y1001A1001A71M',
    'IT-SUD': '10Y1001A1001A788',
    'IT-FOGN': '10Y1001A1001A72K',
    'IT-ROSN': '10Y1001A1001A77A',
    'IT-BRNN': '10Y1001A1001A699',
    'IT-PRGP': '10Y1001A1001A76C',
    'IT-SARD': '10Y1001A1001A74G',
    'IT-SICI': '10Y1001A1001A75E',
    'NO-1': '10YNO-1--------2',
    'NO-2': '10YNO-2--------T',
    'NO-3': '10YNO-3--------J',
    'NO-4': '10YNO-4--------9',
    'NO-5': '10Y1001A1001A48H',
    'SE-1': '10Y1001A1001A44P',
    'SE-2': '10Y1001A1001A45N',
    'SE-3': '10Y1001A1001A46L',
    'SE-4': '10Y1001A1001A47J',
    'DK-1': '10YDK-1--------W',
    'DK-2': '10YDK-2--------M'
})
""" Looks like some places only accept control areas and not bidding zones...
for key in ['IT', 'NO', 'SE', 'DK']:
    MERGED_MAPPINGS.pop(key, None)
"""


class get_entsoe:
    """
    Get data from ENTSOE using functions in this class. country_list may need
    work. Start/End in format '20171201' fo 1st Dec 2017
    """

    def __init__(self, country_list, start_date, end_date):
        self.country_list = country_list
        self.start_date = start_date
        self.end_date = end_date
        return

    def generation_per_plant(self, folder_name):
        print("Downloading Generation Data (may take a while):", end=' ', flush=True)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        start = pd.Timestamp(self.start_date, tz='Europe/Brussels')
        end = pd.Timestamp(self.end_date, tz='Europe/Brussels')

        fail_list = "Failed (if any):"

        for country in self.country_list:
            try:
                country_code = MERGED_MAPPINGS[country]  # convert to code

                print(country, end=', ', flush=True)
                #                    print("Downloading generation data (may take a while): " + country)
                t0 = time.time()
                response = client.query_generation_per_plant(start=start,
                                                             end=end, country_code=country_code)  # get data
                t1 = time.time()
                delta = t1 - t0
                #                    print('Time taken: ' + str(delta))

                #                    print("Initial cleaning and saving...")
                t0 = time.time()
                response.index.name = 'time'  # Column title was empty
                response.reset_index(inplace=True)

                # Turn rows of plants into columns and save

                df = response.melt(id_vars=['time'],
                                   var_name=['name', 'type'],
                                   value_name='generation_time')
                df.to_csv(folder_name + "generation_plant_" + country + '.csv', index=False)
                t1 = time.time()
                delta = t1 - t0
            #                    print('Time taken: ' + str(delta))

            except Exception:
                #                    print("Error on " + country)
                                   #traceback.print_exc()
                fail_list = fail_list + " " + country + ", "
        print("Done!")
        print(fail_list)
        print()
        return

    def price(self, folder_name):
        print("Downloading Price Data (may take a while):", end=' ', flush=True)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)
            fail_list = "Failed (if any):"
        start = pd.Timestamp(self.start_date, tz='Europe/Brussels')
        end = pd.Timestamp(self.end_date, tz='Europe/Brussels')
        fail_list = "Failed (if any):"
        for country in self.country_list:
            try:
                country_code = MERGED_MAPPINGS[country]  # convert to code

                print(country, end=', ', flush=True)
                t0 = time.time()
                response = client.query_day_ahead_prices(country_code, start=start, end=end)
                t1 = time.time()
                delta = t1 - t0

                t0 = time.time()
                df = response.to_frame()
                df.reset_index(inplace=True)
                df = df.rename(columns={'index': 'time', 0: 'price'})

                df.to_csv(folder_name + "price_" + country + '.csv', index=False)
                t1 = time.time()
                delta = t1 - t0
            except Exception:
                fail_list = fail_list + " " + country + ", "

        print("Done!")
        print()
        return

    def load(self, folder_name):
        print("Downloading Load Data (may take a while):", end=' ', flush=True)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        start = pd.Timestamp(self.start_date, tz='Europe/Brussels')
        end = pd.Timestamp(self.end_date, tz='Europe/Brussels')
        fail_list = "Failed (if any):"

        for country in self.country_list:
            try:
                country_code = MERGED_MAPPINGS[country]  # convert to code

                print(country, end=', ', flush=True)
                #                    print("Downloading load data (may take a while): " + country)
                t0 = time.time()
                response = client.query_load(start=start,
                                             end=end, country_code=country_code)  # get data
                t1 = time.time()
                delta = t1 - t0
                #                    print('Time taken: ' + str(delta))

                #                    print("Initial cleaning and saving...")
                t0 = time.time()
                df = response.to_frame()
                df.reset_index(inplace=True)
                df = df.rename(columns={'index': 'time', 0: 'load'})

                df.to_csv(folder_name + "load_" + country + '.csv', index=False)
                t1 = time.time()
                delta = t1 - t0
            #                    print('Time taken: ' + str(delta))

            except Exception:
                #                    print("Error on " + country)
                #                    traceback.print_exc()

                fail_list = fail_list + " " + country + ", "
        print("Done!")
        print(fail_list)
        print()
        return

    def generation_type(self, folder_name):
        print("Downloading Generation by Type Data (may take a while):", end=' ', flush=True)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        start = pd.Timestamp(self.start_date, tz='Europe/Brussels')
        end = pd.Timestamp(self.end_date, tz='Europe/Brussels')
        fail_list = "Failed (if any):"

        for country in self.country_list:
            try:
                country_code = MERGED_MAPPINGS[country]  # convert to code

                print(country, end=', ', flush=True)
                #                    print("Downloading generation by type data (may take a while): " + country)
                t0 = time.time()
                response = client.query_generation(start=start,
                                                   end=end, country_code=country_code)  # get data
                t1 = time.time()
                delta = t1 - t0
                #                    print('Time taken: ' + str(delta))

                #                    print("Initial cleaning and saving...")
                t0 = time.time()
                response.index.name = 'time'  # Column title was empty
                response.reset_index(inplace=True)

                # Turn rows of type into columns and save
                df = response.melt(id_vars=['time'],
                                   var_name=['type'],
                                   value_name='type_generation_time')
                df.to_csv(folder_name + "type_generation_" + country + '.csv', index=False)
                t1 = time.time()
                delta = t1 - t0
            #                    print('Time taken: ' + str(delta))
            except Exception:
                print("Error on " + country)
                #                    traceback.print_exc()
                fail_list = fail_list + " " + country + ", "
        print("Done!")
        print(fail_list)
        print()
        return

    def capacity_per_plant(self, folder_name):
        print("Downloading Capacity Data (may take a while):", end=' ', flush=True)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        start = pd.Timestamp(self.start_date, tz='Europe/Brussels')
        end = pd.Timestamp(self.end_date, tz='Europe/Brussels')
        fail_list = "Failed (if any):"

        # Need to do each year seperately...
        for country in self.country_list:
            df_all = pd.DataFrame()
            for yr in range(start.year, end.year + 1):
                s = pd.Timestamp(str(yr), tz='Europe/Brussels')
                e = pd.Timestamp(str(yr + 1), tz='Europe/Brussels')
                try:
                    country_code = MERGED_MAPPINGS[country]  # convert to code
                    print(country + " " + str(yr), end=', ', flush=True)
                    #                        print("Downloading capacity data (may take a while): " + country + ' '+ str(yr))
                    t0 = time.time()
                    response = client.query_installed_generation_capacity_per_unit(start=s, end=e, country_code=country_code)  # get data
                    t1 = time.time()
                    delta=t1-t0
                    #                        print('Time taken: ' + str(delta))
# client.query_installed_generation_capacity_per_unit
                    #                        print("Initial cleaning and saving...")
                    t0 = time.time()
                    response.index.name = 'code'  # Column title was empty
                    response.reset_index(inplace=True)

                    df = response
                    df['Year'] = yr

                    df_all = df_all.append(df)
                    t1 = time.time()
                    delta = t1 - t0
                #                        print('Time taken: ' + str(delta))
                except Exception:
                    print("Error on " + country)
                    #                        traceback.print_exc()
                    fail_list = fail_list + " " + country + " " + str(yr) + ", "
            df_all.to_csv(folder_name + "capacity_plant_" + country + '.csv', index=False)
        print("Done!")
        print(fail_list)
        print("Redo whole country if one year fails.")
        print()
        return



    def capacity(self, folder_name):
        print("Downloading Capacity Data (may take a while):", end=' ', flush=True)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        start = pd.Timestamp(self.start_date, tz='Europe/Brussels')
        end = pd.Timestamp(self.end_date, tz='Europe/Brussels')
        fail_list = "Failed (if any):"

        # Need to do each year seperately...
        for country in self.country_list:
            df_all = pd.DataFrame()
            for yr in range(start.year, end.year + 1):
                s = pd.Timestamp(str(yr), tz='Europe/Brussels')
                e = pd.Timestamp(str(yr + 1), tz='Europe/Brussels')
                try:
                    country_code = MERGED_MAPPINGS[country]  # convert to code
                    print(country + " " + str(yr), end=', ', flush=True)
                    #                        print("Downloading capacity data (may take a while): " + country + ' '+ str(yr))
                    t0 = time.time()
                    response = client.query_installed_generation_capacity(start=s,
                                                                                   end=e,
                                                                                   country_code=country_code)  # get data
                    t1 = time.time()
                    delta = t1 - t0
                    #                        print('Time taken: ' + str(delta))

                    #                        print("Initial cleaning and saving...")
                    t0 = time.time()
                    response.index.name = 'code'  # Column title was empty
                    response.reset_index(inplace=True)

                    df = response
                    df['Year'] = yr

                    df_all = df_all.append(df)
                    t1 = time.time()
                    delta = t1 - t0
                #                        print('Time taken: ' + str(delta))
                except Exception:
                    print("Error on " + country)
                    #                        traceback.print_exc()
                    fail_list = fail_list + " " + country + " " + str(yr) + ", "
            df_all.to_csv(folder_name + "capacity" + country + '.csv', index=False)
        print("Done!")
        print(fail_list)
        print("Redo whole country if one year fails.")
        print()
        return


    def electricity_transfer(self, folder_name):
        print("Downloading Export Data (may take a while): ", end=' ', flush=True)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        start = pd.Timestamp(self.start_date, tz='Europe/Brussels')
        end = pd.Timestamp(self.end_date, tz='Europe/Brussels')
        df_all = pd.DataFrame()
        fail_list = "Failed:"
        success_list = "Succeeded:"

        for country in self.country_list:
            for country_2 in self.country_list:
                if country == country_2:
                    pass
                else:
                    try:
                        country_code = MERGED_MAPPINGS[country]  # convert to code
                        country_code_2 = MERGED_MAPPINGS[country_2]

                        print(country + "-" + country_2, end=', ', flush=True)
                        #                            print("Downloading export data (may take a while): " + country  + ' to ' + country_2)
                        t0 = time.time()
                        response = client.query_crossborder_flows(
                            start=start, end=end,
                            country_code_from=country_code, country_code_to=country_code_2)  # get data
                        t1 = time.time()
                        delta = t1 - t0
                        #                            print('Time taken: ' + str(delta))

                        #                            print("Initial cleaning and saving...")
                        t0 = time.time()
                        df = response.to_frame()
                        df.reset_index(inplace=True)
                        df = df.rename(columns={'index': 'time', 0: 'flow'})
                        df['from'] = country
                        df['to'] = country_2

                        df.to_csv(folder_name + "transfer_" + country + "x" + country_2 + '.csv', index=False)
                        t1 = time.time()
                        delta = t1 - t0
                        #                            print('Time taken: ' + str(delta))
                        success_list = success_list + " " + country + "-" + country_2 + ", "
                    except Exception:
                        #                            print("Error on " + country + " and " + country_2 +
                        #                            ". May not be a border.")
                        #                            traceback.print_exc()
                        fail_list = fail_list + " " + country + "-" + country_2 + ", "
        print("Done!")
        print(success_list)
        print("Please compare to expected boundaries to see if any are missing.")
        return df_all


"""
Dirty test code. Please ignore, may come in handy at some point.

# folder = "C:\\Users\\Taraq\\Google Drive\\Not on HDD\\Research\\EU_Energy\\data\\entsoe\\"
folder = "C:\\Users\\TK\\Desktop\\entsoe_data\\"




start_date = '20171201'
end_date = '20171202'
start = pd.Timestamp(start_date, tz = 'Europe/Brussels')
end = pd.Timestamp(end_date, tz = 'Europe/Brussels')

t0 = time.time()
df = get_entsoe(['UK_GB'],'20171201' , '20171202').generation_per_plant_slow(folder)
t1 = time.time()
delta = t1-t0
print(delta)
df1 = pd.read_csv(folder + 'generation_plant_UK_GB')
df1
t2 = time.time()
df = get_entsoe(['UK_GB'],'20171201' , '20171202').generation_per_plant_fast(folder)
t3 = time.time()
delta = t3-t2
print(delta)
df = pd.read_csv(folder + 'generation_plant_UK_GB')
df

response = client.query_generation_per_plant(start = start, end = end, country_code = CONTROL_AREAS['UK_GB'])

response.index.name = 'time' # Column title was empty
response.reset_index(inplace=True)
response
response.melt(id_vars = ['time'], var_name = ['name', 'type'], value_name = 'generation_hour')
response

df = response.to_frame()
df.reset_index(inplace = True)
df = df.rename(columns = {'index':'time', 0:'flow'})
df['from'] = country
df['to'] = country_2

df
response.unique()
response = client.query_installed_generation_capacity_per_unit(start = start, end = end, country_code = BIDDING_ZONES['GB'])

response.index.name = 'code'
response.reset_index(inplace=True)
response['country'] = country

folder = "C:\\Users\\Taraq\\Google Drive\\Not on HDD\\Research\\EU_Energy\\data\\entsoe\\"
df = get_entsoe(['GB', 'ES'],'20171201' , '20171202').generation_type(folder)
df
response.index.name = 'time'
response.reset_index(inplace=True)
response
mylist = []
for i in list(response):
    for j in response.index:
        mylist.append([response['time'][j],i, response[i][j]])

list(response)
mylist
df = pd.DataFrame(mylist,
columns=['time','fuel_type','generation'])
df = df[len(response):].reset_index()
df['country'] = country
df = df.drop(columns = ['index'])
df
df.to_csv(folder_name + "generation_fuel_" + country, index = False)
df_all = df_all.append(df, )

df.to_csv(folder + "generation_fuel_ALL", index = False)
"""

