# Project 1

# YOUR NAME HERE
### He Ma 22348372 

load(url("http://www.stat.berkeley.edu/users/nolan/data/weather2011.rda"))

makePlotRegion = function(xlim, ylim, bgcolor, ylabels,
               margins, cityName, xtop = TRUE) {
  par(bg = bgcolor,mai = margins)
  plot(NULL,type="n", xlim=xlim, ylim=ylim, xaxt ="n", yaxt="n",xaxs="i",
       ylab = "", main = "")
  axis(side = 2, las =2, at = ylabels, labels = ylabels, tick = TRUE)  
  if (xtop){
  axis(side = 3, las =1, at =  c(1,32,60,91,121,152,182,213,244,274,305,335)+15,
       labels = c("Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep",
                "Oct", "Nov", "Dec"), tick = FALSE, pos = 108,cex = 0.5)
  }else if (!xtop){
    axis(side = 1, las =1, at =  c(1,32,60,91,121,152,182,213,244,274,305,335)+15,
         labels = c("Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep",
                    "Oct", "Nov", "Dec"), tick = FALSE,cex = 0.5)
  }
}

drawTempRegion = function(day, high, low, col){
  rect(day-0.5, low, day+0.5, high, density =NA, col = col)
}

addGrid = function(location, col, ltype, vertical = TRUE) {
  if (vertical){
    for (i in location){
      abline(v = i, lty = ltype, col = col,lwd = 0.5)
    }
  }else if (!vertical){
    for (i in location){
      abline(h = i, lty = ltype, col = col,lwd = 0.5)
    }
  }
}

monthPrecip = function(day, dailyprecip, normal){
  cumPrecip = cumsum(dailyprecip)
  points(day,cumPrecip, type = "l",col = "blue2",lwd =2)  
  polygon(c(day[1],day,day[1]+length(day)-1),c(0,cumPrecip,0),col="grey50")
  points(day,rep(normal,length(day)),type = "l", col = "blue4",lwd =2)
}

finalPlot = function(temp, precip){
  # The purpose of this function is to create the whole plot
  # Include here all of the set up that you need for
  # calling each of the above functions.
  # temp is the data frame sfoWeather or laxWeather
  # precip is the data frame sfoMonthlyPrecip or laxMonthlyPrecip

  
  # Here are some vectors that you might find handy
  
  monthNames = c("January", "February", "March", "April",
                 "May", "June", "July", "August", "September",
                 "October", "November", "December")
  daysInMonth = c(31, 28, 31, 30, 31, 30, 31, 
                  31, 30, 31, 30, 31)
  cumDays = cumsum(c(1, daysInMonth))
  normPrecip = as.numeric(as.character(precip$normal))
  ### Fill in the various stages with your code
 
  
  ### Add any additional variables that you will need here
  days = c(1:365)
  
  ### Set up the graphics device to plot to pdf and layout
  ### the two plots on one canvas
  pdf("/media/sunnymh/Work/Course_sp13/STAT133/HW1/proj1_pic.pdf", width =9 , height =6 )
  layout(matrix(1:2, 2, 1, byrow = TRUE), height = c(2,1)) 
  
  ### Call makePlotRegion to create the plotting region
  ### for the temperature plot
  makePlotRegion(c(0,365), c(20,110), "grey85",seq(20,110,10), 
                 c(0, 1.1, 0.6, 0.5), "San Francisco", xtop = TRUE)
  ### Call drawTempRegion 3 times to add the rectangles for
  ### the record, normal, and observed temps
  drawTempRegion(days,temp$RecordHigh,temp$RecordLow, "#E41A1C33")
  drawTempRegion(days,temp$NormalHigh,temp$NormalLow,"#377EB833")
  drawTempRegion(days,temp$High,temp$Low,"#FFFF3344")
  ### Call addGrid to add the grid lines to the plot
  addGrid(cumDays[2:12]-0.5,"grey30", 2, TRUE)
  addGrid(seq(20,110,10),"white", 2, FALSE)
  ### Add the markers for the record breaking days
  BreakHigh = temp$High>=temp$RecordHigh
  BreakLow = temp$Low<=temp$RecordLow
  points(days[days[BreakHigh]], temp$High[days[BreakHigh]],cex = 0.2, pch = 19, col = "gray15")
  for (i in days[BreakHigh][-2]){
    text(days[i], temp$High[i], 
       paste(temp$Month[i], ".",temp$Day[i]),
       cex = 0.6, pos = 4, offset = 0.2, col ="gray10")
  }
  text(days[36], temp$High[36], 
       paste(temp$Month[36], ".",temp$Day[36]),
       cex = 0.6, pos = 3, offset = 0.2, col ="gray10")
  points(days[days[BreakLow]], temp$Low[days[BreakLow]],cex = 0.2, pch = 19, col = "gray15")
  for (i in days[BreakLow]){
    text(days[i], temp$Low[i], 
       paste(temp$Month[i], ".",temp$Day[i]),
       cex = 0.6, pos = 4, offset = 0.2, col ="gray10")
  }
  
  ### Add the titles 
  legend( x = 200, y = 35, cex = 0.5,
         legend = c("record temperature", "record temperature", "daily temperature"), 
         fill = c("#E41A1C33","#377EB833","#FFFF3344"))
  title(main ="San Francisco's weather in 2011", ylab = "Temperature, F")
  ### Call makePlotRegion to create the plotting region
  ### for the precipitation plot
  makePlotRegion(c(1,365), c(0,6), "grey85", 0:6, 
                 c(0.5, 1.1, 0, 0.6) , "San Francisco", xtop = FALSE)
  ### Call monthPrecip 12 times to create each months 
  ### cumulative precipitation plot. To do this use 
   sapply(1:12, function(m) {
              a = cumDays[m]
              b = cumDays[m]+daysInMonth[m]-1
               monthPrecip(days[a:b],temp$Precip[a:b],normPrecip[m])
               }) 
  ### the anonymous function calls monthPrecip with the 
  ### appropriate arguments
  
  ### Call addGrid to add the grid lines to the plot
  addGrid(cumDays[2:12]-0.5,"grey30", 2, TRUE)
  addGrid(1:6,"white", 2, FALSE)  
  ### Add the titles
  title(ylab = "precipation")
  dev.off()
  
}

finalPlot(temp = sfoWeather, precip = sfoMonthlyPrecip)


