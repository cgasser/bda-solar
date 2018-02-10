# HSLU Demo k Nearest Neighbor (kNN) using the Iris dataset
iris
summary(iris)

# All variables are in near ranges, so we assume normalization on data is not required
str(iris)
# Factor variable is indexed in 5th position
table(iris$Species)
# Percent values
round(prop.table(table(iris$Species)) * 100,digits = 1)

# Random splitting of iris data as 70% train and 30%test datasets
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.7, 0.3))
trainData <- iris[ind==1,]
testData <- iris[ind==2,]

# Removing factor variable from training and test datasets
trainData1 <- trainData[-5]
testData1 <- testData[-5]

# Checking the dimensions of train and test datasets
dim(trainData)
dim(trainData1)
dim(testData)
dim(testData1)

# Storing target variable for testing and training data
iris_train_labels <- trainData$Species 
dim(iris_train_labels)
class(iris_train_labels)

iris_test_labels <- testData$Species
dim(iris_test_labels)
class(iris_test_labels)

# Training a kNN-model on the data
# Install.packages("class") if necessary
library(class)
# knn returns the predicted lables for test data set
iris_test_pred1 <- knn(train = trainData1, test = testData1, cl= iris_train_labels,k = 3,prob=TRUE) 


# Evaluating the model performance
# Install.packages("gmodels") if necessary
library(gmodels)
CrossTable(x = iris_test_labels, y = iris_test_pred1,prop.chisq=FALSE) 

# 
#  
#    Cell Contents
# |-------------------------|
# |                       N |
# |           N / Row Total |
# |           N / Col Total |
# |         N / Table Total |
# |-------------------------|
# 
#  
# Total Observations in Table:  48 
# 
#  
#                  | iris_test_pred1 
# iris_test_labels |     setosa | versicolor |  virginica |  Row Total | 
# -----------------|------------|------------|------------|------------|
#           setosa |         16 |          0 |          0 |         16 | 
#                  |      1.000 |      0.000 |      0.000 |      0.333 | 
#                  |      1.000 |      0.000 |      0.000 |            | 
#                  |      0.333 |      0.000 |      0.000 |            | 
# -----------------|------------|------------|------------|------------|
#       versicolor |          0 |         17 |          2 |         19 | 
#                  |      0.000 |      0.895 |      0.105 |      0.396 | 
#                  |      0.000 |      1.000 |      0.133 |            | 
#                  |      0.000 |      0.354 |      0.042 |            | 
# -----------------|------------|------------|------------|------------|
#        virginica |          0 |          0 |         13 |         13 | 
#                  |      0.000 |      0.000 |      1.000 |      0.271 | 
#                  |      0.000 |      0.000 |      0.867 |            | 
#                  |      0.000 |      0.000 |      0.271 |            | 
# -----------------|------------|------------|------------|------------|
#     Column Total |         16 |         17 |         15 |         48 | 
#                  |      0.333 |      0.354 |      0.312 |            | 
# -----------------|------------|------------|------------|------------|
# 
# 

# The top-left cell indicates the true negative results. 
# The bottom-right cell indicates the true positive results
# The two examples in the lower-left cell are false negative results, which are wrongly predicted
# The top-right cell would contain the false positive results


# A total of 4 out of 51, or 8 percent of Species were incorrectly classified by the kNN classifier
# therefore 92 percent accuracy:
# 92% of accuracy is shown by the model: (17+14+16)/51 = 0.9215686

