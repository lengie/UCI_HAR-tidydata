# UCI_HAR-tidydata

This repo contains a script that takes the data generated in the following url and outputs a tidy data set of the mean and standard deviation measurements in both training and test data sets. For each measurement (79 total), the mean is calculated for each combination of subject (30) and activity (6).

url: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
Accessed on: February 16 2015, 5:01PM UTC +7:00

The steps taken in the script are:
*Downloads the .zip file from the URL
*Extracts the folders and data into the working directory
*Reads each individual data set into R: subjects, labels, and data from test and training
*Renames the labels with character objects that are more descriptive
*Extracts test and training measurements that only pertain to mean and standard deviation: mean() and std()
*Combines test set with its subject and activities into one data frame
*Combines training set with subject and activities into one data frame
*Generates column names for the data sets that describe which feature's data is in each column
*Generates a second, independent tidy data set. This takes the previously generated data set and calculates a mean for each combination of subject, activity, and measurement. To do so, it filters out each subject then calculates the mean of every column as split by activity.
*This data set is then written into "UCI_HAR-means-std.txt"