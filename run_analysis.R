# analysis of smartphone data

library(dplyr)

# Reading in the data & row / column names
testdata<-read.table("X_test.txt")
traindata<-read.table("X_train.txt")
test_labels<-read.table("y_test.txt")
train_labels<-read.table("y_train.txt")
column_names<-readLines("features.txt")
activities<-readLines("activity_labels.txt")

# joining row codes to the 2 datasets and then merging them
test_rowcodes<-cbind(test_labels,testdata)
train_rowcodes<-cbind(train_labels,traindata)
merged_data<-rbind(train_rowcodes,test_rowcodes)

# adding the activity label column name for the activity label code that gets appended to the dataset

column_names<-as.list(column_names[,2])
feature_names<- c("activity_label",column_names)

# adding column names to the dataset}
colnames(merged_data)<-c(feature_names)

# adding row names to dataset}
merge<-tbl_df(merged_data)

# changing activity labels to descriptive names

merge<-merge %>% mutate(activity_label=ifelse(activity_label==1,"WALKING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==2,"WALKING_UPSTAIRS",activity_label)) %>% mutate(activity_label=ifelse(activity_label==3,"WALKING_DOWNSTAIRS",activity_label)) %>% mutate(activity_label=ifelse(activity_label==4,"SITTING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==5,"STANDING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==6,"LAYING",activity_label))

# extracting mean and std-dev of measurement}
mean_std<-merge %>% select(contains("mean"),contains("std"))