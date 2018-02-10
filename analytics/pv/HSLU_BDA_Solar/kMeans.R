# HSLU Demo of the k-Means clustering using the Iris dataset

head(iris)

library(ggplot2)
ggplot(iris, aes(Petal.Length, Petal.Width, color = Species)) + geom_point()

# Show the docu for kmeans
?kmeans

set.seed(418)
# Build  the k means model. Note that the cluster number k is predefined
irisCluster <- kmeans(iris[, 3:4], centers=3, nstart = 200)
# Show the model summary
irisCluster

# Results in table format
table(irisCluster$cluster, iris$Species)
irisCluster$centers

iris$cluster <- as.factor(irisCluster$cluster)
ggplot(iris, aes(x = Petal.Length, y = Petal.Width, color = iris$cluster)) + geom_point()
