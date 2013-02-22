
## packages needed for shapefiles:
require(rgdal)

## needed for colour mapping - not on CRAN:
## http://r-forge.r-project.org/projects/colourscheme/
## try:
##install.packages("colourschemes", repos="http://R-Forge.R-project.org")
require(colourschemes)

## pretty colours:
require(RColorBrewer)

## read the share of shelf data:
sos <- read.delim("S:\\ResearchGRP\\00 Business Science\\01 Clients\\00 Scotts\\01 Data\\18 Share of Shelf\\Share of Shelf by Retailer, Year, and Store.txt",
header = TRUE)

## extract DMA number from DMA variable
sos$DMA = substr(sos$DMA,1,3)

## remove unwanted vars
sos <- sos[-c(3:5,9,11,13,15,17,19)]

## change any zeroes to NA since we'll be averaging
sos[sos==0]<-NA


#remove R03 and R05 DMA
sos <- sos[-which(substr(sos$DMA,1,1)=="R"),] 


#aggregate so there is one obs per DMA
sos2 <- aggregate(sos, by = list(group.1 = sos$Retailer,group.2 = sos$DMA,group.3 = sos$Year), FUN = mean, na.rm=TRUE)


##get info on .shp file
ogrInfo(dsn="S:\\ResearchGRP\\00 Business Science\\01 Clients\\00 Scotts\\11 Data Visualization\\00 Shapefiles",layer="nielsen_dma")

#read the DMA data:
DMA <- readOGR(dsn="S:\\ResearchGRP\\00 Business Science\\01 Clients\\00 Scotts\\11 Data Visualization\\00 Shapefiles",layer="nielsen_dma")

## Create a key to match the DMA codes
m = match(DMA$dma,sos2$DMA)

## add the SOS data to the county map:
DMA$MGPFSOS = sos2$MGPFSOS[m]

## fix a couple of missing data:
DMA$MGPFSOS[is.na(DMA$MGPFSOS)]

## use the purple-red palette:
colours = brewer.pal(6,"Green")

## make a colour scheme:
sd = data.frame(col=colours,values=c(0.35,0.40,0.45,0.50,0.55,0.65))
sc = nearestScheme(sd)

## set the plot region to the lower 48:
## the aspect ratio may not be right. Meh. This is a
## quick exercise! If I was doing this for real I'd find
## a better shapefile!

#Plot lower 48
plot(c(-129,-61),c(21,53),type="n",axes=FALSE,xlab="",ylab="")

## add the counties
plot(DMA,col=sc(DMA$MGPFSOS),add=TRUE,border="white",lwd=0.2)
title(main="Plant Food Share of Shelf HD 2012",font.main=4)
legend("bottomleft",c('sc'), cex=0.8, fill=colours) 


