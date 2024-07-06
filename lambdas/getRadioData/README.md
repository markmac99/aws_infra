# getRadiodata

SAM project to create a lambda to be triggered when a file is delivered to s3://mjmm-rawradiodata/

## processRadioData
This function converts the event_log_yyyymm.csv file into a heatmap jpg
It is triggered when a file matching the pattern raw/event_log and ending in .csv is uploaded to the s3 bucket


## processRadioJpgs
This function monitors the raw/ folder for files starting with interesting and ending in .jpg and copies them to s3://mjmm-data/radio where they are used for the website. 