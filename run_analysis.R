run_analysis <- function(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){
  ##Purpose: 
  #Merge the training and the test sets to create one data set.
  #Extract mean and standard deviation measurements. 
  #Give descriptive names to the activities in the data set.
  #Appropriately labels the data set with descriptive variable names. 
  #Create a 2nd tidy data set with the avg of each variable for each activity and subject
  ##Input: the url for the desired data
  
  ##Assumes dplyr package is installed
  
  ##Download the file and place into the working directory
  download(url, dest="UCIHAR.zip", mode="wb") 
  unzip ("UCIHAR.zip", exdir = "./")
  
  ##Reading the extracted data into R
  #Reading test data
  test_subj <- read.table("UCI HAR Dataset/test/subject_test.txt")
  test_set <- read.table("UCI HAR Dataset/test/X_test.txt")
  test_labels <- read.table("UCI HAR Dataset/test/Y_test.txt")
  
  #Reading training data
  training_subj <- read.table("UCI HAR Dataset/train/subject_train.txt")
  training_set <- read.table("UCI HAR Dataset/train/X_train.txt")
  training_labels <- read.table("UCI HAR Dataset/train/Y_train.txt")
  
  ##Renaming the labels to be more descriptive
  #First, rename them in the test set
  for (i in 1:dim(test_labels)[[1]]){ #there are 6 total activities
    if(test_labels[i,1] == 1){
      test_labels[i,1] <- "walking"
    } else if(test_labels[i,1]==2){
      test_labels[i,1] <- "walking_upstairs"
    } else if(test_labels[i,1]==3){
      test_labels[i,1] <- "walking_downstairs"
    } else if(test_labels[i,1]==4){
      test_labels[i,1] <-  "sitting"
    } else if(test_labels[i,1]==5){
      test_labels[i,1] <- "standing"
    } else if(test_labels[i,1]==6){
      test_labels[i,1] <- "laying"
    }
  }
  
  #Now to rename the labels on the training data set
  for (i in 1:dim(training_labels)[[1]]){ #same activities as before
    if(training_labels[i,1] == 1){
      training_labels[i,1] <- "walking"
    } else if(training_labels[i,1]==2){
      training_labels[i,1] <- "walking_upstairs"
    } else if(training_labels[i,1]==3){
      training_labels[i,1] <- "walking_downstairs"
    } else if(training_labels[i,1]==4){
      training_labels[i,1] <-  "sitting"
    } else if(training_labels[i,1]==5){
      training_labels[i,1] <- "standing"
    } else if(training_labels[i,1]==6){
      training_labels[i,1] <- "laying"
    }
  }
  
  ##Pulling out only mean or std columns from the full data sets
  #First, load list of features
  feat <- read.table("UCI HAR Dataset/features.txt")
  
  #pull out features with "mean()"
  m <- feat[grep("mean()",feat$V2),]
  #pull out features with "std()"
  s <- feat[grep("std()",feat$V2),]
  #Not going to use features where angle() signals were averages
  #over a window sample as that is separately processed analysis
  
  #combining and chronologically sorting the mean and std indexes in 
  #the features list so that they are in the correct order
  mean_or_std <- rbind(m,s)
  mean_or_std_index <- mean_or_std[order(mean_or_std[,1]),]
  
  ##Combining test data into big data set: 
  #first add the test subjects and test labels
  test_full <- cbind(test_subj,test_labels)
  
  #then add the test set columns of interest
  for (i in mean_or_std_index[,1]){
    test_full <- cbind(test_full,test_set[,i])
  }
  
  #Combining train data into big data set: 
  #first add the train subjects and test labels
  train_full <- cbind(training_subj,training_labels)
  
  #then add the train set columns of interest
  for (i in mean_or_std_index[,1]){
    train_full <- cbind(train_full,training_set[,i])
  }
  
  #Generating column names. Derived from features list
  culled <- as.character(mean_or_std_index$V2)
  colNames <- c("subject","activity",culled)
  
  #Assigning the names to the data frames
  names(train_full) <- colNames
  names(test_full) <- colNames
  
  ##Creating the second data set
  #Extract subject number assignment for each data set
  test_subjs <- unique(test_subj)
  train_subjs <- unique(training_subj)
  
  #Create the null data frame for the second tidy data set
  UCI_HAR_means <- NULL
  
  #Populate the data frame with averages for test subject by activity and measurement
  #make a filter for each test subject
  for(i in 1:dim(test_subjs)[[1]]){
    #make a filter for each activity
    for(j in c("walking","walking_upstairs","walking_downstairs","sitting","standing","laying")){
      
      #separate each subject & activity combination
      per_subj_per_act <- filter(test_full, subject==test_subjs[[1]][[i]] & activity==j)
      #Summarize each column in the subject and activity filtered data frame
      per_subj_per_act <- summarise_each(per_subj_per_act,funs(mean))
      per_subj_per_act[[1]] <- test_subjs[[1]][[i]]
      per_subj_per_act[[2]] <- j
      UCI_HAR_means <- rbind(UCI_HAR_means,per_subj_per_act)
    }
  }
  
  #Continue to populate data frame with training set, avg ofeach subj,act,meas combo
  #Same as above but for training data
  for(i in 1:dim(train_subjs)[[1]]){
    #make a filter for each activity
    for(j in c("walking","walking_upstairs","walking_downstairs","sitting","standing","laying")){
      
      #separate each subject & activity combination
      per_subj_per_act <- filter(train_full, subject==train_subjs[[1]][[i]] & activity==j)
      #Summarize each column in the subject and activity filtered data frame
      per_subj_per_act <- summarise_each(per_subj_per_act,funs(mean))
      per_subj_per_act[[1]] <- train_subjs[[1]][[i]]
      per_subj_per_act[[2]] <- j
      UCI_HAR_means <- rbind(UCI_HAR_means,per_subj_per_act)
    }
  }
  
  ##Because test data set was processed first, then train data set, the subjects
  ##are out of order. Here we reorder the data frame by subject in ascending order.
  UCI_HAR_means <- arrange(UCI_HAR_means,subject)
  
  ##Write the final data frame into a .txt file
  write.table(UCI_HAR_means,file="UCI_HAR-means-std.txt",row.names=FALSE)
  
}