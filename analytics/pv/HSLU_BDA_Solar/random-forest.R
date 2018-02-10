# HSLU Demo of the Random Forest method and a wine quality dataset https://www.r-bloggers.com/predicting-wine-quality-using-random-forests/

wine <- read.csv("data/winequality-white.csv", sep=";")
head(wine)

barplot(table(wine$quality))

# Classify into good, bad, and normal wines based on their quality.
wine$taste <- ifelse(wine$quality < 6, 'bad', 'good')
wine$taste[wine$quality == 6] <- 'normal'
wine$taste <- as.factor(wine$taste)

# Summary
table(wine$taste)

# Separate the data into testing (66%) and training (34%) sets.
set.seed(123)
samp <- sample(nrow(wine), 0.66 * nrow(wine))
train <- wine[samp, ]
test <- wine[-samp, ]

# install.packages("randomForest")
# Build the random forest model
library(randomForest)
# set.seed(415)
model <- randomForest(as.factor(taste) ~ . - quality + sulphates, data = train, importance=TRUE)

# Show the model configuration
model

# what variables were important
varImpPlot(model)

# We can use ntree and mtry to specify the total number of trees to build (default = 500), 
# and the number of predictors to randomly sample at each split respectively. See the R Documentation
?randomForest
# With the default values 500 trees were built, and the model randomly sampled 3 predictors at each split. 
# It also shows a matrix containing prediction vs actual, as well as classification error for each class. 

# Testing the model on the test data set
pred <- predict(model, newdata = test)
pred_table <- table(pred, test$taste)

# Accuracy is calculated as follows:
(pred_table[1,1] + pred_table[2,2] + pred_table[3,3]) / nrow(test)

