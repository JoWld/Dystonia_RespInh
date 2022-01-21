#load packages
require(eyelinker)
require(dplyr)
require(ggplot2)
library(scales)
library(tidyr)
library(stringr)
library(naniar)


# change to the folder where the .asc files are located
dir <- paste("/Users/jowld/Downloads/Eye tracking Test")
setwd(dir)

# change to correct filename, subject ID and experiemnt block 
Dateiname1 <- "00001.antisaccades_eeg.20220117_154728.asc"
subject = "Test1"
block = "1"

# select eye, should be "R" whenever right eye was recorded without artefacts
eye = "R"

#load data 
dat <- read.asc(Dateiname1)
raw <- dat$raw
msg<- dat$msg

#remove unnecessary triggers
msg<- filter(msg, msg$text!="Trial_correct")
msg<- filter(msg, msg$text!="BAD_EYE")
msg<- filter(msg, msg$text!="!MODE RECORD CR 500 2 1 LR")
msg<- filter(msg, msg$text!="start recording")
msg$text2 <- msg$text
msg<-replace_with_na_at(msg,.vars = "text2",condition = ~.x != "stop recording")

# calculate correct time of stimulus onset 
for(i in 2:nrow(msg)){
  if(!is.na(msg[(i),4])){
    msg[i,2]= ((msg[i,2]) - 1030)
  }
}
msg$text[msg$text == "stop recording"] <- "startStim"
msg$text2 <- NULL
msg$stime <-msg$time 
raw <-merge (dat$raw,msg, by="time")
raw$stime <- raw$time

# load saccade data 
sac <- dat$sac
sac$amplitude <- sac$exp-sac$sxp
sac <- filter(sac, sac$ampl >5)
sac.R  <- filter(sac, sac$eye==(eye))
sac.R <- merge(sac.R, msg, by="stime", all=TRUE)

sac.R$type=sac.R$text
sac.R$typea=sac.R$text
sac.R$dir=sac.R$text
sac.R$dir2=sac.R$text
sac.R$overlap = sac.R$text
sac.R$gap = sac.R$text
sac.R<-replace_with_na_at(sac.R,.vars = "text",condition = ~.x != "startStim")
sac.R<-replace_with_na_at(sac.R,.vars = "type",condition = ~.x != ("pro"))
sac.R<-replace_with_na_at(sac.R,.vars = "typea",condition = ~.x != ("anti"))
sac.R<-replace_with_na_at(sac.R,.vars = "dir",condition = ~.x != ("right"))
sac.R<-replace_with_na_at(sac.R,.vars = "dir2",condition = ~.x != ("left"))
sac.R<-replace_with_na_at(sac.R,.vars = "overlap",condition = ~.x != ("overlap"))
sac.R<-replace_with_na_at(sac.R,.vars = "gap",condition = ~.x != ("gap"))
sac.R$typ<- sac.R$type
sac.R$typ[!is.na(sac.R$typea)] = sac.R$typea[!is.na(sac.R$typea)] 
sac.R$dir[!is.na(sac.R$dir2)] = sac.R$dir2[!is.na(sac.R$dir2)] 
sac.R$gap[!is.na(sac.R$overlap)] = sac.R$overlap[!is.na(sac.R$overlap)] 
sac.R$type <- NULL
sac.R$typea <- NULL
sac.R$dir2 <- NULL
sac.R$overlap <- NULL
sac.R<-fill(sac.R, typ)
sac.R<-fill(sac.R, dir)
sac.R<-fill(sac.R, gap)
sac.R$dur <- NULL

# calculate latency (rt = response time)
for(i in 2:nrow(sac.R)){
  if(!is.na(sac.R[(i-1),14])){
    sac.R[i,18]= (sac.R[i,1] - sac.R[(i-1),1])
  }
}

sac.R<-sac.R %>% 
  rename(rt=`V18`)
sac.R <- fill(sac.R, block.y)

# remove some stuff
sac.R$block <- NULL
sac.R$syp <- NULL
sac.R$eyp <- NULL
sac.R$eye <- NULL
sac.R$time <-NULL

# remove trials with very high latency (> mean + 2*sd) and express saccades (<90ms)
sac.R <- filter (sac.R, sac.R$rt<(mean(sac.R$rt, na.rm = TRUE)+2*sd(sac.R$rt,na.rm = TRUE)))
sac.R <- filter (sac.R, sac.R$rt>89)

# calculate gain, positive value = prosac / error in antisac trial, negative value = antisac / error in prosac trial 
#cave! 500 just placeholder, gain is not correct! 
for(i in 1:nrow(sac.R)){
  if(sac.R[i,11]=="left"){
    sac.R[i,15]= -500
  }
}
for(i in 1:nrow(sac.R)){
  if(sac.R[i,11]=="right"){
    sac.R[i,15]= 500
  }
}
sac.R$gain <- sac.R$amplitude/sac.R$V15
sac.R$V15 <- NULL
sac.R$block.y <- NULL
sac.R$text <- NULL

# create tables for every trial type
pro.R<-filter(sac.R, sac.R$typ == "pro")
pro<-filter(pro.R, pro.R$gain > 0)
pro_overlap <- filter(pro, pro$gap == "overlap")
pro_gap <-filter(pro, pro$gap == "gap")
as.R<-filter(sac.R, sac.R$typ == "anti")
as<-filter(as.R, as.R$gain < 0)
as_err<-filter(as.R, as.R$gain > 0)
as_overlap <- filter(as.R, as.R$gap == "overlap")
as_gap <-filter(as.R, as.R$gap == "gap")
as_overlap_err <- filter(as_err, as_err$gap == "overlap")
as_gap_err <-filter(as_err, as_err$gap == "gap")

# create block summary 
pro_gap_n = count (pro_gap)
pro_overlap_n = count (pro_overlap)

as_gap_n = count (as_gap)
as_overlap_n = count (as_overlap)
as_gap_err_n = count (as_gap_err)
as_overlap_err_n = count (as_overlap_err)

#latencies
pro_gap_lat=mean(pro_gap$rt)
pro_overlap_lat=mean(pro_overlap$rt)
pro_gap_lat_sd=sd(pro_gap$rt)
pro_overlap_lat_sd=sd(pro_overlap$rt)

as_gap_lat=mean(as_gap$rt)
as_overlap_lat=mean(as_overlap$rt)
as_gap_lat_sd=sd(as_gap$rt)
as_overlap_lat_sd=sd(as_overlap$rt)

as_gap_err_lat=mean(as_gap_err$rt)
as_overlap_err_lat=mean(as_overlap_err$rt)
as_gap_err_lat_sd=sd(as_gap_err$rt)
as_overlap_err_lat_sd=sd(as_overlap_err$rt)

# error rates 
as_gap_ER=count(as_gap_err)/(count(as_gap_err)+count(as_gap))
as_overlap_ER=count(as_overlap_err)/(count(as_overlap_err)+count(as_overlap))

summary <- data.frame(subject, pro_gap_n, pro_overlap_n,as_gap_n, as_overlap_n, as_gap_err_n, as_overlap_err_n,pro_gap_lat, pro_overlap_lat, pro_gap_lat_sd, pro_overlap_lat_sd,
                      as_gap_lat, as_overlap_lat, as_gap_lat_sd, as_overlap_lat_sd,
                      as_gap_err_lat, as_overlap_err_lat, as_gap_err_lat_sd,  as_overlap_err_lat_sd, 
                      as_gap_ER, as_overlap_ER)

# save summary 
Ausgabedatei <- paste(subject, block,"summary.csv", sep ="_")
write.csv(summary,file=Ausgabedatei)
# save prosac / antisac tables with trial-wise data
Ausgabedatei2 <- paste(subject, block, "all_trials.csv", sep="_")
write.csv(sac.R,file=Ausgabedatei2)


