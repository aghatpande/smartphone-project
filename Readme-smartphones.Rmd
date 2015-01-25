---
title: "Samsung smartphone data project"
author: "A Ghatpande"
date: "January 19, 2015"
output: html_document
---

Getting data from the Web

```{r Importing the zip archive,eval=FALSE}
fileurl="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile="smartphonedata.zip"
download.file(fileurl,destfile,method="curl")
```

#### The idea, raw signals and processed measurements
The idea is to continously monitor locomotor actvity of human volunteers and develop a method / software to classify this activity into 6 distinct activities : WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING & LAYING. 

**Core Idea** 

Each distinct activity (e.g. walking versus laying down) will have its own unique combination / signature of linear acceleration (movement of that subject's smartphone in X-Y-Z directions) and angular velocity (movement of the smartphone in a sphere of a certain radius). The idea is to continously collect these signals from the built-in accelerometer and gyroscope of the smartphone. Using these raw data, they (project designers) calculate a vector (a signature) which should allow their software program to accurately identify which of the 6 distinct activities the subject / volunteer is performing at any given instant. The program's classification was visually cross-checked for accuracy by simultaneously recording video of the subject.

The original designers of this project came up with a 561-feature vector calculated from the 2 raw signals, for this classification.  
There were 30 volunteers aged 19-48 yrs and data is divided into training set (21 volunteers 70%), and test set (9 volunteers, 30%).
Raw data was two signals recorded simultaneously : 3-axis linear acceleration and 3-axis angular velocity. Sampling is at 50 Hz (20ms intervals between consecutive rows / samples).

This raw data was pre-processed:

1. Noise was filtered out, the signals were chunked as 2560 ms windows / segments (i.e. 128 points per segment based on a 20ms interval). Each segment shares half its data with the preceding and following segment (overlap of 64 data points between each consecutive segment).
2. The acceleration signal has two components: gravitational acceleration & body acceleration. The gravitational component was assumed to have only low frequency and was isolated by passing signal through low-pass Butterworth at 0.3 Hz cutoff.
3. Frequencies higher than 0.3 Hz are assumed to come from body acceleration.

#### Course project tasks

You should create one R script called run_analysis.R that does the following. 

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

I unzipped the zip archive in Coursera/getxplordata/smartphone-project/; this created a directory and various subdirectories.
The following files should be in the working directory in which run_analysis.R is executed, for it to work:

1. X_test.txt : this contains actual data for testing the program after it 'learns' how to classify
2. X_train.txt : this contains actual data for training the program to identify the 6 distinct activities.
3. subject_test.txt: this file contains subject identity (ID number between 1:30) for the test data
4. subject_train.txt : this contains subject ID for the training data
5. y_test.txt: this contains activity label codes: a number between 1 to 6 for each of the 6 distinct activities for each test observation / row
6. y_train.txt : this contains activity label codes: a number between 1 to 6 for each of the 6 distinct activities for each training observation / row
7. features.txt: this is a file containing column names: they correspond to one of 561 'features' i.e. parameters calculated from the raw signal data 
8. activity_labels.txt: this file contains the key for activity codes; a descriptive label for each activity and its corresponding numerical code
        
The training & test data files are : X_train.txt & X_test.txt. These are very large files and we can cache them to avoid re-reading them for input into R multiple times when this Rmd file is run.

##### Reading in the data

```{r reading in data files,cache=TRUE}
testdata<-read.table("X_test.txt")
traindata<-read.table("X_train.txt")
```

```{r reading in subject IDs, activity codes+labels & feature / column names}
testSubjectIds<-read.table("subject_test.txt")
trainSubjectIds<-read.table("subject_train.txt")
test_labels<-read.table("y_test.txt")
train_labels<-read.table("y_train.txt")
column_names<-readLines("features.txt")
activities<-readLines("activity_labels.txt")
```

##### Task # 1 
Joining subject IDs and activity codes with the respective datasets; the 'merged_data' data frame created in the code chunk below results in a merged dataset as directed in task # 1 of the assignment. The attached activity codes and subject IDs will help in achieving other tasks of the assignment. 

```{r joining subject IDs and activity codes to data and then merging the datasets}
test_IDs_actcodes<-cbind(testSubjectIds,test_labels,testdata)
train_IDs_actcodes<-cbind(trainSubjectIds,train_labels,traindata)
merged_data<-rbind(train_IDs_actcodes,test_IDs_actcodes)
```

##### Task #4

```{r generating list of column names and adding column names to merged_data}
column_names<-as.list(column_names)
feature_names<- c("subjectId","activity_label",column_names)
colnames(merged_data)<-c(feature_names)
```

##### Task #3

Next, we substitute activity codes with descriptive labels of each activity; this is done by using a vectorized "if else loop" that looks for a specific activity code and substitutes the appropriate descriptive activity label.

```{r substituting activity codes with descriptive activity labels}
library(dplyr)
merge<-tbl_df(merged_data)
merge<-merge %>% mutate(activity_label=ifelse(activity_label==1,"WALKING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==2,"WALKING_UPSTAIRS",activity_label)) %>% mutate(activity_label=ifelse(activity_label==3,"WALKING_DOWNSTAIRS",activity_label)) %>% mutate(activity_label=ifelse(activity_label==4,"SITTING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==5,"STANDING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==6,"LAYING",activity_label))
```

Labeling each column with the appropriate name acheives task #4 of the assignment; substituting activity codes with descriptive labels achieves task #3.

##### Task #2

To extract parameters / calculated variables / measurements that represent means and standard deviations of various parameters, we *assume* that any parameter that contains either the word 'mean' or the abbreviation 'std' is a mean or standard deviation parameter. This achieves task #2 of the assignment.

```{r extracting features that contain mean and standard deviations of various calculated parameters / measurements}
mean_std<-merge %>% select(subjectId,activity_label,contains("mean"),contains("std"))
```

##### Task #5

Next, we create a dataset that groups the mean / std-dev parameters by each subject and then within each subject's data it groups each parameter according to the activity it has been calculated for. Thus, the final tidy dataset will contain average values of each mean / std-dev parameter with the corresponding activity label for each subject / volunteer.
Given that there are 30 volunteers each performing 6 distinct activities, there will be 180 rows in the dataset and 86 parameters for each activity of each subject.
Hence, the final tidy dataset has the foll: dimensions: *180 x 88* accounting for two additional columns, one for the activity label and another for subject ID.

```{r creating a tidy dataset with subjectIds, and averages (means) of each parameter of the tidy dataset created above}
av_groupedby<-mean_std %>% group_by(subjectId, activity_label) %>% summarise_each(funs(mean),3:88)
write.table(av_groupedby,file="smartphone-tidydata.txt",row.names=FALSE)
```