##  ###############  Scrapes lake levels and parses to csv  #################
##
##  Downloads hourly values for each day
##  Change values in url for particular month
##  http://www.swt-wc.usace.army.mil/webdata/gagedata/DSNT2.insertdatehere.html
##  Writes csv for each day of month - join files in R
##
##  User enters month and days in month @ lines 23-24
##
##  Lots of dependencies for astropy - got working for 3.4 only
##
##  20170715
##  20170716
##  20170730

import requests  ##  Html requests
from bs4 import BeautifulSoup  ##  Parses html
from astropy.io import ascii  #  http://docs.astropy.org/en/stable/index.html
import csv

##  http://www.swt-wc.usace.army.mil/webdata/gagedata/DSNT2.20170501.html  ##  structure of previous day html links

##todo  Enter month name and month number below
month_name = "sep"        ##   Enter month name here
month_num = "09"           ##   Enter month number here - two digits
days = list(range(1, 31))  ##   Change number of days here - one more than you need
base_url = "http://www.swt-wc.usace.army.mil/webdata/gagedata/DSNT2.2017"
extension_url = ".html"
global awol  ##get a count of missing days
awol = 0
for i in days:
    if i <= 9:  ##  column count changes base on single digit days
        usace_url = base_url + str(month_num) + str(0) + str(i) + extension_url
    else:
        usace_url = usace_url = base_url + str(month_num) + str(i) + extension_url

    table = requests.get(usace_url)
    soup = BeautifulSoup(table.content, 'html.parser')

    try:  ##  Deals with the missing data issues on certain days - catches error of empty files
        f = soup.find("pre").contents[0]
    except AttributeError:
        awol = awol + 1
        print("missing data for " + month_name + " " + str(i))
        continue
    else:

        level_data = ascii.read(f, data_start=7,
                                format='fixed_width',
                                col_starts=(0, 6, 35, 66, 71),
                                col_ends=(5, 10, 40, 76, 84))

        fname = "csv/" + month_name + "_" + str(i) + ".csv"
        print(fname)
        writer = csv.writer(open(fname, 'w'), delimiter=",", quoting=csv.QUOTE_MINIMAL)
        for rows in level_data:
            writer.writerow(rows)

print("Attempted retrieval days:  " + str(days))
print(str(awol) + " missing days")
print("Some days are not available - check for missing files")
