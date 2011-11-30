library(ggplot2)
args <- commandArgs(trailingOnly = TRUE)
f=args[1]

elements <- read.table(f,header=F,sep=" ")
strwr <- function(str) gsub(" ", "\n", str)

names(elements)<- c("type","name","start","end","elapsed")

elements$id <- seq_along(elements$start)
#elements$id <-rev(elements$id)
elements <- elements[,c(6,1,2,3,4,5)]
m <- min(elements$start)
elements$start <- (elements$start-m)
elements$end <- (elements$end-m)


p0<-ggplot(elements, aes(y=id,fill = type)) + geom_rect(aes(y = id, ymin=id-0.45,ymax=id+0.45,xmin=start,xmax=end))+
 scale_x_continuous("time in ms", formatter = "comma",expand = c(0, 0)) +
 scale_y_reverse("",minor_breaks=NA,breaks=elements$id, labels = elements$name,expand = c(0, 0)) +
 opts(axis.text.y = theme_text(colour="black",hjust=1), panel.grid.major = theme_line(colour = "grey90", size = 0.2) , panel.background = theme_blank())
# opts( axis.text.y = theme_text(size = 8 , hjust=1), panel.grid.major = theme_line(colour = "grey90", size = 0.2) , panel.background = theme_blank())
pngName=gsub(".txt",".png",f)
ggsave(p0, filename=pngName,scale=2)
