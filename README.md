# README


## Step 1: Quality check
R Note book: [1_Processing_raw_data_quality_test.Rmd](1_Processing_raw_data_quality_test.Rmd)

This step takes as input the output from KoboToolbox in .csv format as downloaded using [these instructions](https://ccgenetics.github.io/guidelines-genetic-diversity-indicators/docs/5_Data_collection/Kobo_toolbox_help.html). 

To run this notebook you have to specify the following two variables at the start of the script:

1) `kobo_file` Output from KoboToolbox in .csv format. For example:

```
kobo_file="International_Genetic_Indicator_testing_V_4.0_-_latest_version_-_False_-_2023-11-02-08-23-26.csv"
```

2) `keep_to_check` to specify if records that need manual review and potentially correction be removed or kept in the exported “clean” data. True to keep, false to filter them. For example:

```
keep_to_check=FALSE #true to keep, false to filter them. Defaults to FALSE
```

The notebook looks for common sources of error and flags those records manual revision by the assessors who capture data from each country. Specifically, it:

1. Filters out records which were marked as "not_approved" in the manual Kobo validation interface (this means country assessors determined the is something wrong with that particular record).
2. Filters out any data entries with the word "test", as they are not real data.
3. Checks for common data capture errors regarding the number of populations:
   * Are 0 correct?
   * should 999 be -999? (missing data label)
   * are extant/extint confused?
5. Check GBIF ID codes to have the right number of digits
6. Check genus, species and subspecies should be a single word.
7. Flags the records that need manual review and potentially correction.
8. Asks the user if she/he wants to keep the taxa flagged in the previous step, or if they should be filtered out.

The output are:
* a report of the quality check
* A .csv file (called `kobo_output_tocheck.csv`) showing **the records that need manual review or corrections**, if any.
* A .csv file (called `kobo_output_clean.csv`) with the data after processing (**records flagged in the previous file may or may not be included according to user choice**).

If any entries need corrections, you have to go back to Kobo and correct the relevant entries. Once you are happy with how data looks, you can proceed to step 2. 

## Step 2: Processing clean data to extract indicator data

R Note book: [2_Processing_clean_extract_indicators_data.Rmd](2_Processing_clean_extract_indicators_data.Rmd)

This notebook performs the following:

1) it re-formats the data as outputed by Kobo to the shape needed to calculate each of the genetic diversity indicators. For example, in the Kobo output each species assessment is a single row, with population data in different columns, but to estimate the Ne indicator it is needed to have data of each population as a row. This script does that format transformation for you.

2) and transforms Nc to Ne based on a custom Nc:Ne ratio.

Notice that at this stage the **indicator values are not calculated**. This script only re-formats the data from the kobo-output so that you can use these data to estimate the indicators by yourself outside R (e.g. in Excel or other software), or continue to step 3 if you want to use the R functions and standard analyses of this repository.

The input is the "clean kobo output" that was first cleaned in step 1. The output are the indicators data ready to be used to estimate the indicators.

* `indNe_data.csv` file: data needed to estimate the Ne 500 indicator.  Each population is a row and the population size data (either Ne or Nc) is provided in different columns. 

* `indPM_data.csv` file: data needed to estimate the PM indicator. Each row is a taxon of a single assessment, and the number of extant and extinct populations are provided.

* `indDNAbased_data` file: data needed to estimate the genetic monitoring indicator (number of species in which genetic diversity has been or is being monitored using DNA-based methods). Each row is a taxon.

* `metadata.csv` file: metadata for taxa and indicators, in some cases creating new useful variables, like taxon name (joining Genus, species, etc) and if the taxon was assessed only a single time or multiple times

### Important note on transforming Nc to Ne data:

In the Kobo form, Ne and Nc data are collected as follows: 

* **Ne (effective population size) from genetic analyses**, ie by software like NeEstimator or Gone. The estimate and its lower an upper limits are stored as numbers in the columns `Ne`, `NeLower`, `NeUpper`. These columns are not modified during processing.

* **Nc (number of mature individuals) from point estimates**, that is quantitative data with or without confidence intervals. The estimate and its lower an upper limits, if available, are stored as numbers in the columns `NcPoint`, `NcLower`, `NcUpper`.

* **Nc (number of mature individuals) from quantitative range or qualitative data**, these are the ranges that in the kobo form show options like "<5,000 by much" or "< 5,000 but not by much (tens or a few hundred less)". The estimate is stored as text in the column `NcRange`. 

This steps uses the function `transform_to_Ne()` to transform Nc estimates and their lower an upper estimates to Ne based on the Nc:Ne ratio the user decides.

For `NcPoint`, `NcLower`, `NcUpper` columns (Nc from point estimates) Nc is transformed to Ne done by multiplying them for the desired ratio. 

For `NcRange`columns (Nc from quantitative range or qualitative data) the range options (text) are first translated to numbers following this rule:

* "more_5000_bymuch" to 10000
* "more_5000" to 5500
* "less_5000_bymuch" to 500
* "less_5000" to 4050
* "range_includes_5000" to 5001

This is stored in the new column `Nc_from_range`. And then, to transform Nc to Ne it is multiplied for the desired ratio.

Regardless if the Nc data was NcPoint or NcRange, after transforming it to Ne it is stored in the column `Ne_from_Nc`. Notice that the column `NcType` (part of the Koboform original variables) states if Nc data came from NcPoint or NcRange. If the type as NcPoint and there were lower and upper intervals, they are also transformed to Ne and stored in the columns `NeLower_from_Nc`, `NeUpper_from_Nc`.

Finally, a new column `Ne_combined` is created combining data from Ne genetic estimates, with the Ne from transforming Nc using the ratio. For this, if both Ne from genetic data and from transforming Nc exist, the Ne from genetic data is given preference. 

For transparency, the column `Ne_calculated_from` specifies for each population were the data to estimate Ne came from. Options are:  "genetic data", "NcPoint ratio", and "NcRange ratio", as explained above.
