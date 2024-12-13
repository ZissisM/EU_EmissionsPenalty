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

 * Figure1.do: Generates Figure 1 (B, C, D, E) using the main dataset. Fig 1A uses Fig1A.xlsx in *Other datasets*.

 * Figure2.do [^1]: Generates Figure 2.
  
 * Figure 3.do: Generates Figure 3-- 3 panels of 6 country case studies. Uses the main dataset.
  
 * Figure 4.do: Generates Figure 4. Uses *Excess_scat* dataset.
 
 * Figure 5.do: Generates Figure 5.
 
 **Extended Data and SI Figures**

 *SI.do: 

 *CarbonLevy_equivalent.do:

 
 ### Figures 

 Each figure is provided, along with each individual panel for each figure, in high-resolution .svg and .pdf format. 
 
### Data Collection
 * Entso-e Pandas Client was used to download the electricity generation and wholesale price data. Example documentation can be found [here](https://github.com/EnergieID/entsoe-py).
 * _1_a_enstoe_api_fn.py & _1_1b_enstoe_api_fn.py: Used for this purpose to collect the desired data for each country. Anaconda Python Client is used.
 
[^1]: The website tool [Datawrapper.de](https://datawrapper.dwcdn.net/Wi1uA/1/) was used for the construction of maps for Figure 2 (A, B, E) with our estimated results (from main dataset). Example [link](https://www.datawrapper.de/_/3KERv/) to Fig2A map. Powerpoint was used for visual modification and merging of images to create certain figures (i.e., Figure 2).
