library(data.table)

filePath <- getwd()
fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
download.file(fileUrl, file.path(filePath, "ElectricPowerCons.zip"))
unzip(zipfile = "ElectricPowerCons.zip")

#Read in data
epc <- fread(file.path(filePath, "household_power_consumption.txt")
             , header = TRUE
             , na.strings = "?")

#To prevent histogram from printing in scientific notation:
epc[,Global_active_power := lapply(.SD, as.numeric), .SDcols = c("Global_active_power")]

#Change Date to class Date
epc[, Date := lapply(.SD, as.Date, "%d/%m/%Y"), .SDcols =c("Date")]

#Change Time to class Time
epc[, Time := lapply(.SD, strptime, "%H:%M:%S"), .SDcols = c("Time")]

#Filter dates from 2007-02-01 to 2007-02-02
epc <- epc[(Date >= "2007-02-01") & (Date <= "2007-02-02")]

#Construct the plot and save it to a PNG file 
#with a width of 480 pixels and a height of 480 pixels

#Plot 1
png(filename = "plot1.png", width = 480, height = 480)

hist(epc$Global_active_power, xlab = "Global Active Power (kilowatts)"
     , ylab = "Frequency", col = "Red", main = "Global Active Power")
dev.off()
