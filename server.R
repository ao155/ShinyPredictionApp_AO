library(shiny)

buildmodel <- function(modelname) {
        
        # load data and set NAs
        setwd("C:/Users/de-85972/Desktop/Coursera/Data")
        training = read.csv("./pml-training.csv", na.strings=c("NA","#DIV/0!",""))
        testing = read.csv("./pml-testing.csv", na.strings=c("NA","#DIV/0!",""))
        
        # filter features
        library(caret)
        nzv <- nearZeroVar(training, saveMetrics=TRUE) # detect near-zero variables
        trainingclean <- training[,nzv$nzv==FALSE] # remove near-zero variables
        testingclean <- testing[,nzv$nzv==FALSE] # remove near-zero variables
        trainingclean <- trainingclean[,-(1:6)] # remove row ID, user names, timestamps and window number
        testingclean <- testingclean[,-(1:6)] # remove row ID, user names, timestamps and window number
        trainingclean <- trainingclean[,!(colSums(is.na(trainingclean)) > length(trainingclean$classe)*0.5)] # remove all variables with more than 50% NA's
        testingclean <- testingclean[,!(colSums(is.na(testingclean)) > length(testingclean$classe)*0.5)] # remove all variables with more than 50% NA's
        
        # impute missing data
        library(RANN)
        preObj <- preProcess(trainingclean, method="knnImpute")
        trainingclean <- predict(preObj, trainingclean)
        testingclean <- predict(preObj, testingclean)
        
        # partition training data
        set.seed(3875)
        inTrain <- createDataPartition(y=trainingclean$classe, p=0.6, list=FALSE)
        traindata <- trainingclean[inTrain,]
        testdata <- trainingclean[-inTrain,]
        
        if (modelname == "rPart") {
                library(rpart)
                rpartmodel <- rpart(classe~., data=traindata, method="class")
                rpartpred <- predict(rpartmodel, testdata, type="class")
                round(confusionMatrix(rpartpred, testdata$classe)$overall['Accuracy'] *100, digits = 2)
        }
        else if (modelname == "Random Forest") {
                library(randomForest)
                rfmodel <- randomForest(classe~., data=traindata, method="rf")
                rfpred <- predict(rfmodel, testdata, type="class")
                round(confusionMatrix(rfpred, testdata$classe)$overall['Accuracy'] *100, digits = 2)
        }
}


shinyServer(
        function(input, output) {
                
                # display the selected model
                output$selectedmodel <- renderText({input$radio})
                
                # run the model
                text1 <- eventReactive(input$buildButton, {
                        testresult <<- buildmodel({input$radio})
                        "The model was built"
                })
                output$buildtext <- renderText({
                        text1()
                })
                
                # display the accuracy
                text2 <- eventReactive(input$testButton, {
                        paste("The accuracy is ", testresult, " %.")
                })
                output$testtext <- renderText({
                        text2()
                })
                
        }
)
