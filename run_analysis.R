# analysis of smartphone data

library(dplyr)

# Reading in the data & row / column names
testdata<-read.table("X_test.txt")
traindata<-read.table("X_train.txt")
testSubjectIds<-read.table("subject_test.txt")
trainSubjectIds<-read.table("subject_train.txt")
test_labels<-read.table("y_test.txt")
train_labels<-read.table("y_train.txt")
column_names<-readLines("features.txt")
activities<-readLines("activity_labels.txt")

# joining subject IDs and row codes to the 2 datasets and then merging them
test_IDs_actcodes<-cbind(testSubjectIds,test_labels,testdata)
train_IDs_actcodes<-cbind(trainSubjectIds,train_labels,traindata)
merged_data<-rbind(train_IDs_actcodes,test_IDs_actcodes)

# adding the activity label column name for the activity label code that gets appended to the dataset

column_names<-as.list(column_names)
feature_names<- c("subjectId","activity_label",column_names)

# adding column names to the dataset}
colnames(merged_data)<-c(feature_names)

# changing activity labels to descriptive names; we convert the dataset to a dplyr format and then use a vectorized 'if else' loop to subsitute activity codes by descriptive labels
merge<-tbl_df(merged_data)
merge<-merge %>% mutate(activity_label=ifelse(activity_label==1,"WALKING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==2,"WALKING_UPSTAIRS",activity_label)) %>% mutate(activity_label=ifelse(activity_label==3,"WALKING_DOWNSTAIRS",activity_label)) %>% mutate(activity_label=ifelse(activity_label==4,"SITTING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==5,"STANDING",activity_label)) %>% mutate(activity_label=ifelse(activity_label==6,"LAYING",activity_label))

# extracting mean and std-dev of measurement}
mean_std<-merge %>% select(subjectId,activity_label,contains("mean"),contains("std"))

# grouping by subjectId and activity_label and computing the mean of each variable in the medn_std data

av_groupedby<-mean_std %>% group_by(subjectId, activity_label) %>% summarise_each(funs(mean),3:88)

# writing the resulting dataset to a text file

write.table(av_groupedby,file="smartphone-tidydata.txt",row.names=FALSE)
