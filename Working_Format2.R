######################################################Required Packages######################################################

#install.packages("dplyr", quiet = TRUE)
#install.packages("doMC")
#install.packages("plyr")
#install.packages("stringr", quiet = TRUE)
#install.packages("qdap")
#install.packages("lsa")
#install.packages("ggplot2")
#install.packages("sentiment")
#install.packages("rJava")
#install.packages("SnowballC")
#install.packages("parallel")
#install.packages("doMC")
library(dplyr)
library(plyr)
library(stringr)
library(qdap)
library(tm)
library(lsa)
library(ggplot2)
library(sentiment)
library(rJava)
library(SnowballC)
library(parallel)
library(doMC)



#################################################Adjusting Sentiment Lexicon################################################

POLKEY <- sentiment_frame(positive.words, negative.words)
POLKEY <- sentiment_frame(c(positive.words, "fleek"), c(positive.words, "yas"),c(positive.words, "bae"), c(positive.words, "slay"),c(positive.words, "fierce"), c(positive.words, "sick"), c(positive.words, "lol"), c(positive.words, "yaas"), c(positive.words, "yaaas"), c(positive.words, "yasss"), c(positive.words, "yaaas"), c(positive.words, "obsessed"))
#################################################User-Defined Functions################################################

tagtovector <- function(k) {
  working_result = unlist(strsplit(k, split = ', '))
  working_result[1] = substr(working_result[1], 2, nchar(working_result[1]))
  working_result[length(working_result)] = substr(working_result[length(working_result)], 1, nchar(working_result[length(working_result)])-1)
  return(sapply(x=working_result, FUN = gsub, "'", ""))
}

numdis <- function(k) {
  return(length(unlist(str_extract_all(k, "([0-9]+)%"))))
}

comAvePol <- function(k) {
  k<-iconv(enc2utf8(k),sub="byte")
  texts <-as.character(k)
  corpus <- Corpus(VectorSource(texts))
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, function(x) removeWords(x, stopwords("english")))
  corpus <- tm_map(corpus, stemDocument, language = "english")
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, PlainTextDocument)
  corpus<- tm_map(corpus, content_transformer(tolower))
  dataframe<-data.frame(text=unlist(sapply(corpus, `[`, "content")), 
                        stringsAsFactors=F)
  qpol <- polarity(asvec, polarity.frame=POLKEY)
  vec = counts(qpol)[, "polarity"]
  return(qpol)
}

comAvePol2 <- function(k) {
  print("wee")
  k<-iconv(enc2utf8(k),sub="byte")
  texts <-as.character(k)
  corpus <- Corpus(VectorSource(texts))
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, function(x) removeWords(x, stopwords("english")))
  corpus <- tm_map(corpus, stemDocument, language = "english")
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, PlainTextDocument)
  corpus<- tm_map(corpus, content_transformer(tolower))
  dataframe<-data.frame(text=unlist(sapply(corpus, `[`, "content")), 
                        stringsAsFactors=F)
  asvec <- unlist(dataframe)
  qpol <- polarity(asvec, polarity.frame=POLKEY)
  vec = counts(qpol)[, "polarity"]
  return(c(qpol$group$total.words, qpol$group$ave.polarity, qpol$group$sd.polarity, qpol$group$stan.mean.polarity))
}


extract <- function(k,i) {
  return(k[i])
}

checkTag <-function(k, tag) {
  return(tag %in% unlist(k))
}

ununemoji <- function(sample) {
  sample = unlist(sample)
  return(unlist(mclapply(sample, FUN=unemoji, mc.cores =6)))
}

unemoji <- function(sample_string) {
  matches = str_detect(sample_string, emoji$emoji)
  for(i in which(matches))
  {
    sample_string = gsub(emoji$emoji[i], paste(" ",emoji$format[i]," "), sample_string)
  }
  
  return(sample_string)
}

numBrands <- function(brand, str1) {
  return(sapply(gregexpr(brand, str1), function(x) sum(x > 0)))
}

getSpecWord<- function(string, word) {
  sample = strsplit(string, " ")
  sample = unlist(sample)[(unlist(sample) %in% word)]
  return(length(sample))
}

#################################################Read Main Data File################################
mydata2 = read.csv("node_sample_data.csv", header = TRUE, stringsAsFactors = FALSE)
#################################################Read in Comments###################################
mydata2$comments = ""
for(i in list.files(path = "~/Comments", full.names = TRUE)) {
  print(i)
  mydata = try(read.table(i, header = FALSE, sep = "\n", stringsAsFactors = FALSE, quote = ""), silent = TRUE)
  v = unlist(str_locate_all(pattern = "/", i))
  samplink = substr(i, start = v[length(v)]+1, stop = nchar(i)-4)
  if (mydata !="") {mydata2$comments[mydata2$link==samplink] = mydata}
  else {mydata2$comments[mydata2$link==samplink] = NA}
}
##################s######################Read in Transcripts######################
for(i in list.files(path = "/Users/lavanyasunder1/Subtitles/TXT", full.names = TRUE)) {
  print(i)
  mydata = read.table(i, header = FALSE, sep = "\n", stringsAsFactors = FALSE, quote = "", fileEncoding = "UTF-8")
  v = unlist(str_locate_all(pattern = "/", i))
  samplink = substr(i, start = v[length(v)]+1, stop = nchar(i)-11)
  if (mydata !="") {mydata2$transcript[mydata2$link==samplink] = mydata}
  else {mydata2$transcript[mydata2$link==samplink] = NA}
}
mydata2$transcript = sapply(mydata2$transcript, function(k) { if(is.null(k)) {return(" ")} else {return(k)}})

###########################Read in Faces################################################
faces = read.csv("/Users/lavanyasunder1/FaceDetect/face_detect_result.csv", header = TRUE)
faces = as.data.frame(faces)
faces = unique(faces)
mydata2 = merge(x = mydata2, y = faces, by.x=mydata2$link, all.x = TRUE)

###################Calculate number of comments###########
mydata2$numcomments = vector()
for(i in seq(1:nrow(mydata2))) {
  if (!is.NA(mydata2$comments[i]))
  {mydata2$numcomments[i] = length(unlist(mydata2$comments[i]))}
  else
  {mydata2$numcomments[i] = NA}
}

###########################Getting Rid Of Emojis################################################

emoji = read.table("emoji_table.txt", header = TRUE, sep = ",", stringsAsFactors = FALSE, quote = "")
result = unlist(lapply(emoji$meaning, FUN = str_extract, pattern = "([a-z]+)"))
emoji$format = result
format_comments=lapply(mydata2$comments, FUN = ununemoji)
mydata2$format_comments = format_comments
format_desc = lapply(mydata2$desbox, FUN = ununemoji)
mydata2$format_desbox = format_desbox
format_title = lapply(mydata2$title, FUN = ununemoji)
mydata2$format_title = format_title
#This step will take a long time##

########################################Adding More Variables##################################
mydata2$tags = lapply(X= mydata2$tags, FUN = tagtovector)
mydata2$day_of_week = weekdays((as.Date(mydata2$pubdate, format = "%d-%B-%y")))
mydata2$year = substr(mydata2$pubdate, nchar(mydata2$pubdate)-1, nchar(mydata2$pubdate))
mydata2$month = substr(mydata2$pubdate, nchar(mydata2$pubdate)-5, nchar(mydata2$pubdate)-3)
mydata2$day = strtoi(substr(mydata2$pubdate, 0, ifelse(nchar(mydata2$pubdate)==9, 2, 1)))

########################################Stuff in Title ##################################
mydata2$desbox = tolower(mydata2$title)
mydata2$grwm_titl = str_detect(mydata2$title,"get ready") | str_detect(mydata2$title,"grwm") 
mydata2$fall_titl = str_detect(mydata2$title,"fall")
mydata2$makeup_titl = str_detect(mydata2$title,"makeup")
mydata2$tutorial_titl = str_detect(mydata2$title,"tutorial")
mydata2$routine_titl = str_detect(mydata2$title,"routine")
mydata2$drugstore_titl = str_detect(mydata2$title,"drugstore")
mydata2$favorite_titl = str_detect(mydata2$title,"favorite")


########################################Certain Things in Desbox##################################

mydata2$desbox = tolower(mydata2$desbox)
mydata2$FTC = str_detect(mydata2$desbox,"FTC") | str_detect(mydata2$desbox,"ftc") 
mydata2$notspon = str_detect(mydata2$desbox,"not sponsored") | str_detect(mydata2$desbox,"NOT sponsored") | str_detect(mydata2$desbox,"not a sponsored") 
mydata2$potspon = str_detect(mydata2$desbox,"provided by") | str_detect(mydata2$desbox,"sponsored by") | str_detect(mydata2$desbox,"sent to me") 
mydata2$affiliate = str_detect(mydata2$desbox,"affiliate") 
mydata2$discountpercent = str_detect(mydata2$desbox, "([0-9]+)%")
mydata2$numdiscountpercent = sapply(mydata2$desbox, FUN = numdis)
mydata2$discountmention = str_detect(mydata2$desbox, "discount") | str_detect(mydata2$desbox, "discount codes") | str_detect(mydata2$desbox, "code")
mydata2$insta = str_detect(mydata2$desbox, "facebook") | str_detect(mydata2$desbox, "F A C E B O O K")
mydata2$fbook =str_detect(mydata2$desbox, "instagram") | str_detect(mydata2$desbox, "I N S T A G R A M")
mydata2$snapchat = str_detect(mydata2$desbox, "snapchat")  | str_detect(mydata2$desbox, "S N A P C H A T")
mydata2$twitter = str_detect(mydata2$desbox, "twitter") | str_detect(mydata2$desbox, "T W I T T E R")
mydata2$thanks = str_detect(mydata2$desbox, "thanks") | str_detect(mydata2$desbox, "thank")
mydata2$deslength = sapply(mydata2$desbox, FUN = nchar, type = "bytes")
mydata2$like = str_detect(mydata2$desbox, "like") 
mydata2$subscribe = str_detect(mydata2$desbox, "subscribe")
mydata2$follow = str_detect(mydata2$desbox, "follow")
mydata2$social = str_detect(mydata2$desbox, "social")

########################################Certain Tags##################################
mydata2$tagtutorial=sapply(mydata2$tag_new, checkTag, tag = "tutorial")
mydata2$tagmakeup=sapply(mydata2$tag_new, checkTag, tag = "makeup")
mydata2$tagbeauty=sapply(mydata2$tag_new, checkTag, tag = "beauty")
mydata2$tagready=sapply(mydata2$tag_new, checkTag, tag = "ready")
mydata2$tagget=sapply(mydata2$tag_new, checkTag, tag = "get")
mydata2$taglipstick=sapply(mydata2$tag_new, checkTag, tag = "lipstick")
mydata2$tagcosmetics=sapply(mydata2$tag_new, checkTag, tag = "cosmetics")
mydata2$tagroutine=sapply(mydata2$tag_new, checkTag, tag = "routine")
mydata2$tageye=sapply(mydata2$tag_new, checkTag, tag = "eye")
mydata2$tageasy=sapply(mydata2$tag_new, checkTag, tag = "easy")
mydata2$tagfoundation=sapply(mydata2$tag_new, checkTag, tag = "foundation")
mydata2$tagsmokey=sapply(mydata2$tag_new, checkTag, tag = "smokey")
mydata2$tagcontour=sapply(mydata2$tag_new, checkTag, tag = "contour")
mydata2$tagglam=sapply(mydata2$tag_new, checkTag, tag = "glam")
mydata2$tagkylie=sapply(mydata2$tag_new, checkTag, tag = "kylie")
mydata2$taggrwm=sapply(mydata2$tag_new, checkTag, tag = "grwm")
mydata2$tagnatural=sapply(mydata2$tag_new, checkTag, tag = "natural")
mydata2$taghaul=sapply(mydata2$tag_new, checkTag, tag = "haul")

########################################Stuff in the Transcript##################################
mydata2$transcript = tolower(mydata2$transcript)
words = sapply(gregexpr("[[:alpha:]]+", mydata2$transcript), function(x) sum(x > 0))
mydata2$wpm = words/(mydata2$length/60)
mydata2$mac_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "mac")
mydata2$nars_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "nars")
mydata2$abh_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "beverly")
mydata2$decay_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "decay")
mydata2$covergirl_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "covergirl")
mydata2$tarte_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "tarte")
mydata2$maybelline_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "maybelline")
mydata2$totalbrand_tran = mydata2$mac + mydata2$nars + mydata2$abh + mydata2$decay + mydata2$covergirl + mydata2$tarte + mydata2$maybelline
mydata2$sponsored_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "sponsored")
mydata2$contour_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "contour")
mydata2$natural_tran = sapply(mydata2$transcript, FUN = getSpecWord, word = "natural")

######################All Sentiment Work #####################################
mydata2$titlelen = nchar(mydata2$title)
mydata2$titlesen = counts(comAvePol(mydata2$title))[,"polarity"]
mydata2$titlelen = nchar(mydata2$desbox)
mydata2$descboxpolarity = counts(comAvePol(mydata2$desbox))[,"polarity"]
mydata2$descboxpolarity[is.nan(mydata2$descboxpolarity)] = NA
mydata2$transen = counts(comAvePol(mydata2$transcript))[,"polarity"]
mydata2$transen[is.nan(mydata2$transen)] = NA
com_pol_result = lapply(mydata2$format_comments, FUN = comAvePol2)
mydata2$words = sapply(com_pol_result, FUN = extract, i = 1)
mydata2$averagepol = sapply(com_pol_result, FUN = extract, i = 2)
mydata2$sdpol = sapply(com_pol_result, FUN = extract, i = 3)
mydata2$stmeanpol = sapply(com_pol_result, FUN = extract, i = 4)

######################Making sure things are NAs that should be
mydata2$numcomments[mydata2$comments==1] = NA





