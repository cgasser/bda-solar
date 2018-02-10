# HSLU Demo of Principal Component Analysis (PCA) using the Iris dataset

# Load data
data(iris)
head(iris, 3)

# first log transform the data
log.ir <- log(iris[, 1:4])
ir.species <- iris[, 5]

# apply PCA 
# scale. = TRUE is highly advisable, but default is FALSE. 
ir.pca <- prcomp(log.ir,
                 center = TRUE,
                 scale. = TRUE) 
# print method
print(ir.pca)
# plot method
plot(ir.pca, type = "l")
# summary method
summary(ir.pca)

# Predict PCs, assuming the last two raws of the data are new
predict(ir.pca, newdata=tail(log.ir, 2))

# Plot the PC1 and PC2 values
biplot(ir.pca)

# There is a nicer version of this plot on github
# install.packages("devtools")
library(devtools)
install_github("ggbiplot", "vqv")

library(ggbiplot)
g <- ggbiplot(ir.pca, obs.scale = 1, var.scale = 1, 
              groups = ir.species, ellipse = TRUE, 
              circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')
print(g)
