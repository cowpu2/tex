##  ###############  Scrapes lake levels and parses to csv  #################
##  http://www.swt-wc.usace.army.mil/webdata/gagedata/DSNT2.current.html
##  Parses texoma lake levels and writes to texoma_levels.csv
##
##todo  Still need to scrape previous days and months
##
##  Lots of dependencies for astropy - got working for 3.4 only

import requests  ##  Html requests
from bs4 import BeautifulSoup  ##  Parses html
from astropy.io import ascii  #  http://docs.astropy.org/en/stable/index.html
import csv

##  http://www.swt-wc.usace.army.mil/webdata/gagedata/DSNT2.20170501.html  ##  structure of previous day html links
page = requests.get("http://www.swt-wc.usace.army.mil/webdata/gagedata/DSNT2.current.html")

soup = BeautifulSoup(page.content, 'html.parser')

f = soup.find("pre").contents[0]  ##  pre is the html tag that encloses the ascii table

texoma = ascii.read(f, data_start=7,
                    format='fixed_width',
                    col_starts=(0,6,35),
                    col_ends=(5,10,40))

print(texoma)

writer=csv.writer(open('texoma_levels.csv','w'), delimiter=",",quoting=csv.QUOTE_MINIMAL)
for rows in texoma:
    writer.writerow(rows)
