#SCHOOL SCRAPING USAGE
#####updated September 5, 2015
#####Leila Hofer and Robert Krabek

###About
   The two functional files in this repository are 
    1. get_school_urls.rb which grabs the links to the individual school pages from the schoolguide website
    2. final_scrape.rb which accesses the individual school pages and grabs contact information from each page  

###Code to run:
    1. run the following code in the terminal below to start the scrape: 
        $ ruby get_school_urls.rb
        
        ... once complete run ...
        
        $ ruby final_scrape.rb
    2. Right click on school_scraping.csv and click download each time the script is run this file will be written over.
    3. note: together, this scrape can take up to 24 hours to run in total
            
###Potential errors that will cause the scrape to be halted and have to be restarted::
    *If the internet cuts out
    *If computer falls asleep (sometimes)