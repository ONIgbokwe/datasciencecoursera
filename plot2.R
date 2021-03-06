library(data.table)

filePath <- getwd()
fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
download.file(fileUrl, file.path(filePath, "ElectricPowerCons.zip"))
unzip(zipfile = "ElectricPowerCons.zip")

#Read in data
epc <- fread(file.path(filePath, "household_power_consumption.txt")
             , header = TRUE
             , na.strings = "?")

#To prevent printing in scientific notation:
epc[,Global_active_power := lapply(.SD, as.numeric), .SDcols = c("Global_active_power")]


#Make date as POSIXct to enable plotting by time of day
epc[, dateTime := as.POSIXct(paste(Date, Time), format = "%d/%m/%Y %H:%M:%S")]

#Filter dates from 2007-02-01 to 2007-02-02
epc <- epc[(dateTime >= "2007-02-01") & (dateTime < "2007-02-03")]



#Construct the plot and save it to a PNG file 
#with a width of 480 pixels and a height of 480 pixels

#Plot 2
png(filename = "plot2.png", width = 480, height = 480)

plot(x = epc[, dateTime], y = epc[,Global_active_power], type = "l", xlab = ""
     , ylab = "Global Active Power (kilowatts)" )
dev.off()
