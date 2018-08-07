# You should create one R script called run_analysis.R that does the following.
# 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the 
# average of each variable for each activity and each subject.

#Answer
#Load packages and get the data
library(data.table)
library(reshape2)
filePath <- getwd()
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, file.path(filePath, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

#Load activity labels and features
activityLabels <- fread(file.path(filePath,"UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("Labels", "Activity"))
features <- fread(file.path(filePath, "UCI HAR Dataset/features.txt")
                            , col.names = c("Index", "Measurement"))
#Grab only mean and standard deviation from features
measurementsWanted <- grep ("(mean|std)\\(\\)", features[,Measurement])
measurements <- features[measurementsWanted, Measurement]
#Remove the parentheses from the measurements
measurements <- gsub(pattern = "[()]", replacement = "", x = measurements)

#Load train dataset
train <- fread(file.path(filePath, "UCI HAR Dataset/train/X_train.txt"))[,measurementsWanted, with=FALSE]
#head(train)
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(filePath, "UCI HAR Dataset/train/y_train.txt")
                         , col.names = c("Activity"))

trainSubjects <- fread(file.path(filePath, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectId"))

train <- cbind(trainSubjects, trainActivities, train) 

#Load test dataset
test <- fread(file.path(filePath, "UCI HAR Dataset/test/X_test.txt"))[,measurementsWanted, with=FALSE]
#head(test)
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(filePath, "UCI HAR Dataset/test/y_test.txt")
                         , col.names = c("Activity"))

testSubjects <- fread(file.path(filePath, "UCI HAR Dataset/test/subject_test.txt")
                       , col.names = c("SubjectId"))

test <- cbind(testSubjects, testActivities, test) 

#Merge the training and the test sets to create one data set.
combinedDs <- rbind(train, test)

#Convert Labels to Activity names
combinedDs[["Activity"]] <- factor(x = combinedDs[, Activity]
                                   , levels = activityLabels[["Labels"]]
                                   , labels = activityLabels[["Activity"]])
combinedDs[["SubjectId"]] <- as.factor(combinedDs[,SubjectId])

combinedDs <- reshape2::melt(data = combinedDs, id = c("SubjectId", "Activity"))
#head(combinedDs)
combinedDs <- reshape2::dcast(data = combinedDs, formula = SubjectId + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combinedDs, file = "myTidyData.txt", quote = FALSE)
