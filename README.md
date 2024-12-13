# "Emergency Response Mechanisms for addressing challenges with high gas prices in international energy markets" Replication Package
### Antonio Bento, Nicolas Koch, and Zissis Marmarelis

#### The following repository contains all of the curated datasets and code used to generate each figure and result in the paper "Emergency Response Mechanisms for addressing challenges with high gas prices in international energy markets". The model output was generated in STATA 16.1. You can find the code for the analysis and each figure below, along with the corresponding dataset that is used. Any questions with the code or data please contact zmarmare@usc.edu

## Datasets 

 * *Main dataset* includes the data collected and used for each country for our sample period (April 1 2021-June 30 2022). This includs the , as described in the Methods. Here, it is in the form of a compressed zip file.

 * *Excess_scat* includes a cross-sectional dataset of all countries, except Ireland (as noted in the Methods) used to generate Figure 4 and Supplementary Figures using scatter plots.

 * *Fig5_new* includes data used to generate Figure 5, after calculating the counterfactuals and estimated consequences from the two different policies: cabron levy and natural gas price cap. 
  
 * *Other datasets* include datasets used to calculate the substitution effect-equivelent carbon levy for 2022, Figure 1A natural gas timeseries, and data on historic emisisons.

## Code

**Main Text Figures** 

 * Figure1.do: Generates Figure 1 (B, C, D, E) using *main* dataset. Fig 1A uses Fig1A.xlsx in *Other datasets*.

 * Figure2.do: Generates Figure 2. Calculates main regression estimation of coal repsonsiveness and marginal effects for each country, and uses it to calculate excess coal generation and emissions (Fig 2 A and B), which data is used to create the map[^1]. Also used to calculate Supp. Fig. XX & XX robustness check of excess coal calculation with different reference baseline. Excess emissions are calculated based on standard emission factor for coal and lignite, depending on each country's composition. Calculates excess wholesale electricity price per country (Panel E) compared to same period baseline as excess coal. Panel C,D,G,F generated. Uses *main dataset* and *excess_scat* dataset (Panel C and F).
  
 * Figure 3.do: Generates Figure 3-- 3 panels of 6 country case studies. Uses the main dataset. Also generates the same 3 panels for the remainder of countries, as seen in Supp. Fig. XX-XX. Uses *main* dataset. Estimation takes ~20 minutes per panel.
  
 * Figure 4.do: Generates Figure 4. Uses *excess_scat* dataset. Coalp.csv in *Other* stores 24-hour estimates for each repsonsiveness (coal or price pass-through) per country. Correlation between each 24-hour estimates (coal and price) per country are shown in the excel sheet, and imported as *correl* in the dataset. 
 
 * Figure 5.do: Generates Figure 5. Calculates the counterfactual relative price under the gas cap and resulting substitution effect emissions (which is the same for the carbon levy by definition), using *main dataset*. Calculates resulting change in wholesale electricity price under each policy and resulting output effect. Uses *Fig5_new* dataset to generate the panels A,B,C,D. Also used to generate Supp. Fig. XX of relative (compared to pre-crisis baseline) wholesale electricity price change, Supp. Fig. XX relative substition effect, Supp. Fig. XX substitution effect, and Supp. Fig. XX relative output effect.
 
 **Extended Data and SI Figures**

 *EDF.do: Generates all Extended Data Figure panels (uses *excess_scat* dataset) and tables (uses *main* dataset).

 *SI.do: Generates all Supplementary Figure panels and tables (besides the ones mentioned above). Each dataset used is specified above each panel (either *main* or excess_scat*).

 *CarbonLevy_equivalent.do: Uses *prices_2022* dataset to iteratively find the carbon price that would result in the same average relative price as the natural gas cap would yield during the same time period.

 
 ### Figures 

 Each figure is provided, along with each individual panel for each figure, in high-resolution .svg and .pdf format, in the Figures folder. 
 
### Data Collection
 * Entso-e Pandas Client was used to download the electricity generation and wholesale price data. Example documentation can be found [here](https://github.com/EnergieID/entsoe-py).
 * _1_a_enstoe_api_fn.py & _1_1b_enstoe_api_fn.py: Used for this purpose to collect the desired data for each country, editing time period and data type as needed. Anaconda Python Client is used.
 
[^1]: The website tool [Datawrapper.de](https://datawrapper.dwcdn.net/Wi1uA/1/) was used for the construction of maps for Figure 2 (A, B, E) with our estimated results (from main dataset). Example [link](https://www.datawrapper.de/_/3KERv/) to Fig2A map, [link](https://www.datawrapper.de/_/vwC3I/) to Fig2E map, [link](https://www.datawrapper.de/_/GBMrw/) to Fig2B map. Powerpoint was used for visual modification and merging of images to create certain figures (i.e., Figure 2).
