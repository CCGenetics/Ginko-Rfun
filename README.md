# README


## Step 1: Processing raw data and quality check it
Script: [1_Processing_raw_data_quality_test.Rmd](1_Processing_raw_data_quality_test.Rmd)

This step takes as input the output from KoboToolbox in .csv format as downloaded using [these instructions](https://ccgenetics.github.io/guidelines-genetic-diversity-indicators/docs/5_Data_collection/Kobo_toolbox_help.html).

It then looks for common sources of error and flags those records manual revision by the assessors who capture data from each country. Specifically, it:

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
* A .csv file (called ´kobo_output_tocheck.csv´) showing **the records that need manual review or corrections**, if any.
* A .csv file (called ´kobo_output_clean.csv´) with the data after processing (**records flagged in the previous file may or may not be included according to user choice**).

If any entries need corrections, you have to go back to Kobo and correct the relevant entries. Once you are happy with how data looks, you can proceed to step 2. 
