

##  ########  Plot lake levels scraped from USACE for Texoma  #######
##
##  Data source is /python_scripts/texoma/csv/*.csv generated
##  by texoma_month.py
##
##
##  ##########################################################
##

library(tidyverse)
library(lubridate)
library(ggplot2)
library(magrittr)
# 2017-07-04 15:47:16 ------------------------------mdp
# 2017-07-08 19:51:09 ------------------------------mdp
# 2017-07-09 21:36:58 ------------------------------mdp
# 2017-07-11 19:15:38 ------------------------------mdp
# 2017-07-15 19:22:25 ------------------------------mdp
# 2017-07-16 16:54:43 ------------------------------mdp
# 2017-07-30 14:41:54 ------------------------------mdp
# 2017-09-29 19:20:42 ------------------------------mdp
# 2017-10-14 17:27:57 ------------------------------mdp
# 2017-12-09 13:56:33 ------------------------------mdp


##  Load archived data  ---- Change this when updating  ----------------
may_sep_2017 <- read_csv("H:/git_R/tex/archived/may_sep_2017.csv")

# Load all csv files in working dir and rbind them into one df

csvpath = "H:/git_R/tex/csv/"
path = "H:/git_R/tex/"
setwd(csvpath)
multi_files <- dir(pattern = "\\.csv")

multi.df <- lapply(multi_files,
                   read.csv,
                   header = FALSE,
                   stringsAsFactors = FALSE)
Temp.df <- do.call(rbind, multi.df)
setwd(path)


texoma <- Temp.df

texoma <- texoma %>%
  mutate(paste0(year = "2017/", V1," ", V2)) ##  Create a year column


##  rename some columns - delete others
names(texoma)[3] <- "Elevation"
names(texoma)[6] <- "Time"
names(texoma)[4] <- "Inflow"
names(texoma)[5] <- "Discharge"
texoma <- texoma %>% select(-V1, -V2)
##
texoma <- texoma %>%
  transform("Time" = ymd_hm(Time,truncated = 3))  ##  truncated deals with 00:00:00

##  convert from factor to numeric -- there is likely to be some NAs
texoma$Elevation <- as.numeric(as.character(texoma$Elevation))
texoma$Inflow <- as.integer(texoma$Inflow)
texoma$Discharge <- as.integer(texoma$Discharge)


##  Change invalid values to NA
texoma[ , 2 ][ texoma[ , 2 ] == -901] <- NA
texoma[ , 3 ][ texoma[ , 3 ] == -901] <- NA


# #  Write out full months to archive file
# sept <- texoma %>% filter(Time < as.Date("2017-10-01 00:00:00"))
# sept <-sept[order(as.Date(sept$Time)),]
# write_csv(sept, "csv/sept_2017.csv")


#  Combine previous and current data together  -- Change file name on updates
texoma <- rbind(may_sep_2017, texoma)

texoma <-texoma[order(as.Date(texoma$Time)),]

write_csv(texoma, "csv/may_nov_2017.csv")  ##  Change ending month here******


##  Used for ggtitle and filenames
min.date <- as.POSIXct(min(texoma$Time))
max.date <- as.POSIXct(max(texoma$Time))
print.date <- format(max.date, format = "%Y%m%d") ## Use this for file name


retick <- seq(613.00, 622.00, 0.5)

elev <- ggplot(texoma, aes(Time,Elevation), color = 'Elevation', rm.na = TRUE) +
  geom_line(color = "blue", size = 1.0) +
  scale_x_datetime(date_breaks = "4 day",
                   date_labels = "%b %d") +
  scale_y_continuous(breaks = retick) +
  theme(axis.text.x = element_text(colour = "blue", angle = 90))  +
  theme(panel.background = element_rect(fill = 'grey75')) +
  ggtitle(paste0("Lake Texoma Lake Levels  - ",min.date, " - ", max.date))
print(elev )




#  ################    Not enough data to even plot
flow <- ggplot(texoma, aes(Time,Inflow), rm.na = TRUE) +
  geom_line(color = "blue") +
  geom_line(aes(y = Discharge), color = "green") +
  scale_x_datetime(date_breaks = "4 day",
                   date_labels = "%b %d") +

  theme(axis.text.x = element_text(colour = "blue", angle = 90))  +
  theme(panel.background = element_rect(fill = 'grey75'))
print(flow)
