library(shiny)

shinyUI(pageWithSidebar(
        headerPanel("Evaluation of Prediction Model Accuracy"),
        sidebarPanel(
                h3('Instructions'),
                p('This app builds a prediction model based on the Human Activity Recognition training data set (http://groupware.les.inf.puc-rio.br/har) with "classe" as target variable, tests the model using cross validation and provides you with the accuracy of the prediction model.'),
                hr(),
                p("1. Select a prediction algorithm"),
                radioButtons("radio", label = NULL,
                             choices = list("rPart" = "rPart", "Random Forest" = "Random Forest"),
                             selected = character(0)
                             ),
                p('2. Build the prediction model'),
                actionButton("buildButton", "Build prediction model"),
                p('3. Test the prediction model'),
                actionButton("testButton", "Test prediction model")
        ),
        mainPanel(
                h3('Results'),
                p('You selected the prediction model:'),
                textOutput('selectedmodel'),
                hr(),
                textOutput('buildtext'),
                hr(),
                textOutput('testtext')
        )
))