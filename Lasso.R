#Lasso#
load("data.Rda")
#install.packages("glmnet")
library(glmnet)
library(lme4)
install.packages("mice")
library(mice)
library(dplyr)
#numcomments
#desboxpolarity
#comsentiment
#images
#averagepol
#sdpol
#stmeanpol
#transren
dat = tbl_df(mydata2)
dat = select(dat, -pubdate, -desbox, -tags, -tag_new, -comments, -transcript, -words, -brandmention, -format_comments)
dat = complete.cases(dat)
dat2 = dat[complete.cases(dat),]


#this is the crossv aldition attempt that I need to do i need 10 fold K cross validation ok 
#code code code ;lk

y = mydata2$views
mydata2$author = as.factor(mydata2$author)
mydata2$year  = as.factor(mydata2$year)
mydata2$month  = as.factor(mydata2$month)
mydata2$day  = as.factor(mydata2$day)
mydata2$FTC  = as.factor(mydata2$FTC)
mydata2$notspon  = as.factor(mydata2$notspon)
mydata2$potspon  = as.factor(mydata2$potspon)
mydata2$affiliate  = as.factor(mydata2$affiliate)
mydata2$discountpercent  = as.factor(mydata2$discountpercent)
mydata2$discountmention  = as.factor(mydata2$discountmention)
mydata2$insta  = as.factor(mydata2$insta)
mydata2$fbook  = as.factor(mydata2$fbook)
mydata2$snapchat  = as.factor(mydata2$snapchat)
mydata2$twitter  = as.factor(mydata2$twitter)
mydata2$thanks  = as.factor(mydata2$thanks)
mydata2$tagmakeup  = as.factor(mydata2$tagmakeup)
mydata2$tagtutorial  = as.factor(mydata2$tagtutorial)
mydata2$all_faces = mydata2$img0 + mydata2$img1 + mydata2$img2 + mydata2$img3


attach(mydata2)
#issue with tagmakeup and tagtutorial
xfactors <- model.matrix(y ~ year + month + day + FTC + notspon + potspon + affiliate + discountpercent + discountmention + insta + fbook + snapchat + twitter + thanks)[,-1]
x <- as.matrix(data.frame(mydata2$likes, mydata2$dislikes, mydata2$subs, mydata2$length, mydata2$numcomments, mydata2$numdiscountpercent, mydata2$deslength, mydata2$descboxpolarity, mydata2$comsentiment, mydata2$titlelen, mydata2$titlepolarity, mydata2$img0, mydata2$img1, mydata2$img2, mydata2$img3 + mydata2$all_faces, xfactors))

is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))

is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))

#need to do multiple imputation
  
x[is.nan(x)] <- 0
x[is.na(x)] <-0
fit = glmnet(x,y)
plot(fit, label = TRUE)
cvfit = cv.glmnet(x, y)
plot(cvfit)
coef(cvfit, s = "lambda.min")
coef(cvfit, s="lambda.1se")

lassoResults= cvfit
bestlambda<-cvfit$lambda.min
results<-predict(lassoResults,s=bestlambda,type="coefficients")

choicePred<-rownames(results)[which(results !=0)]


####just what you have 
x <- as.matrix(data.frame(mydata2$subs, mydata2$length, mydata2$numdiscountpercent, mydata2$deslength, mydata2$descboxpolarity, mydata2$titlelen, mydata2$titlepolarity, mydata2$img0, mydata2$img1, mydata2$img2, mydata2$img3 + mydata2$all_faces))



####

