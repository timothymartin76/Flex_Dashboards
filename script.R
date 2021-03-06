library(scales)
library(ggplot2)
library(reshape2)
library(lubridate)
library(tidyr)
library(plotly)
library(dplyr)
library(leaflet)
library(flexdashboard)
library(shiny)
library(DT) 


mydata<-read.csv("https://raw.githubusercontent.com/NYCDOB/flexdashboard_test/gh-pages/complaints.csv", header=T, sep=',')
names(mydata)<- c("Complaint.Date", "Inspection.Date", "Complaint.Type", "Complaint.Number", "Complaint.Category", "Complaint.Description", "Community.Board", "Borough", "BIN", "Count.Inspected", "with.Access", "No.Access", "with.Violations", "No.Violations", "Count.Complaints", "Inspection.Sequence", "Latitude", "Longitude", "House.Number", "Street.Name","Disposition.Code", "Dispostion.Description")
mydata$Address <- paste(mydata$House.Number," ",mydata$Street.Name)
IC <- subset(mydata, Complaint.Type == c('Illegal Conversion'))
IC_borough<-IC
Top.Address.VC<- IC
Avg.Monthly.Complaints<- IC
Avg.Daily.Complaints<- IC
IC_complaint.map<-IC
## Overall total count of complaints for scorecard
Total.Complaints.VC<- NROW(IC)


Avg.Daily.Complaints$Complaint.Date <- mdy(Avg.Daily.Complaints$Complaint.Date)
Avg.Daily.Complaints<- aggregate(Count.Complaints ~ Complaint.Date, Avg.Daily.Complaints, sum)
Avg.Daily.Complaints<- mean(Avg.Daily.Complaints$Count.Complaints)
Avg.Daily.Complaints<- round(Avg.Daily.Complaints, 1)


Avg.Monthly.Complaints$Complaint.Date <- mdy(Avg.Monthly.Complaints$Complaint.Date)
Avg.Monthly.Complaints$Complaint.Date<- floor_date(Avg.Monthly.Complaints$Complaint.Date, "month")
Avg.Monthly.Complaints<- aggregate(Count.Complaints ~ Complaint.Date, Avg.Monthly.Complaints, sum)
Avg.Monthly.Complaints<- mean(Avg.Monthly.Complaints$Count.Complaints)
Avg.Monthly.Complaints<- round(Avg.Monthly.Complaints, 1)


Top.Address.VC<- IC
Top.Address.VC$Complaint.Date <- mdy(Top.Address.VC$Complaint.Date)
Top.Address.VC2<- Top.Address.VC %>% filter(Top.Address.VC$Complaint.Date  >= today() - days(30))
levels(Top.Address.VC2$Borough)
levels(Top.Address.VC2$Borough) = c("Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island", "BX", "BK", "MN", "QN", "SI")
Top.Address.VC2$Borough <- replace(Top.Address.VC2$Borough, Top.Address.VC2$Borough=="Bronx", "BX")
Top.Address.VC2$Borough <- replace(Top.Address.VC2$Borough, Top.Address.VC2$Borough=="Brooklyn", "BK")
Top.Address.VC2$Borough <- replace(Top.Address.VC2$Borough, Top.Address.VC2$Borough=="Manhattan", "MN")
Top.Address.VC2$Borough <- replace(Top.Address.VC2$Borough, Top.Address.VC2$Borough=="Queens", "QN")
Top.Address.VC2$Borough <- replace(Top.Address.VC2$Borough, Top.Address.VC2$Borough=="Staten Island", "SI")
Top.Address.VC2$Top.VC <- paste(Top.Address.VC2$Address,",",Top.Address.VC2$Borough)
Top.Address.VC2<- dcast(Top.Address.VC2, Top.VC ~ .)
names(Top.Address.VC2)<- c("Address", "count")
Top.Address.VC2<- Top.Address.VC2[with(Top.Address.VC2,order(-count)),]
Top.Address.VC2<- Top.Address.VC2[1:1,]
Top.Address.VC2$Most.Complaints <- paste(Top.Address.VC2$Address,":",Top.Address.VC2$count)
Most.Complaints.VC<- Top.Address.VC2$Most.Complaints


mydata2<-read.csv("https://raw.githubusercontent.com/NYCDOB/flexdashboard_test/gh-pages/inspections.csv", header=T, sep=',')
names(mydata2)<- c("Complaint.Date", "Inspection.Date", "Complaint.Type", "Complaint.Number", "Complaint.Category", "Complaint.Description", "Community.Board", "Borough", "BIN", "Count.Inspected", "with.Access", "No.Access", "with.Violations", "No.Violations", "Count.Complaints", "Inspection.Sequence", "Latitude", "Longitude", "House.Number", "Street.Name", "Disposition.Code", "Dispostion.Description")
mydata2$Address <- paste(mydata2$House.Number," ",mydata2$Street.Name)
IC2 <- subset(mydata2, Complaint.Type == c('Illegal Conversion'))  ##Error on this but OK
IC2$Inspection.Date<-as.Date(as.character(IC2$Inspection.Date),format="%Y%m%d")
IC3<-IC2
BIN.Most.Vios<-IC2
Inspection.map<- IC2
## No Access Rate 
Access.Rate.VC<- percent(sum(IC2$No.Access) / sum(IC2$Count.Inspected))
## % Violations Issued on Accessed Complaints
Violation.Rate.VC<- percent(sum(IC2$with.Violations)/ sum(IC2$with.Access))


## BIN with most vios
BIN.Most.Vios<-BIN.Most.Vios <- subset(BIN.Most.Vios, with.Violations == "1")
BIN.Most.Vios<- BIN.Most.Vios %>% filter(BIN.Most.Vios$Inspection.Date  >= today() - days(30))
levels(BIN.Most.Vios$Borough)
levels(BIN.Most.Vios$Borough) = c("Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island", "BX", "BK", "MN", "QN", "SI")
BIN.Most.Vios$Borough <- replace(BIN.Most.Vios$Borough, BIN.Most.Vios$Borough=="Bronx", "BX")
BIN.Most.Vios$Borough <- replace(BIN.Most.Vios$Borough, BIN.Most.Vios$Borough=="Brooklyn", "BK")
BIN.Most.Vios$Borough <- replace(BIN.Most.Vios$Borough, BIN.Most.Vios$Borough=="Manhattan", "MN")
BIN.Most.Vios$Borough <- replace(BIN.Most.Vios$Borough, BIN.Most.Vios$Borough=="Queens", "QN")
BIN.Most.Vios$Borough <- replace(BIN.Most.Vios$Borough, BIN.Most.Vios$Borough=="Staten Island", "SI")
BIN.Most.Vios$Top.Vio <- paste(BIN.Most.Vios$Address,",",BIN.Most.Vios$Borough)
BIN.Most.Vios<- dcast(BIN.Most.Vios, Top.Vio ~ .)
names(BIN.Most.Vios)<- c("Address", "count")
BIN.Most.Vios<- BIN.Most.Vios[with(BIN.Most.Vios,order(-count)),]
BIN.Most.Vios<- BIN.Most.Vios[1:1,]
BIN.Most.Vios$Most.Violations <- paste(BIN.Most.Vios$Address,":",BIN.Most.Vios$count)
Most.Violations.VC<- BIN.Most.Vios$Most.Violations


### Response Time
mydata3<-read.csv("https://raw.githubusercontent.com/NYCDOB/flexdashboard_test/gh-pages/response.csv", header=T, sep=',')
names(mydata3)<- c("Borough", "Response.Time", "Inspection.Date", "Date2", "Complaint.Number", "Priority.Code", "Unit", "Community.Board", "Complaint.Category")
mydata3$Inspection.Date <- mdy_hm(mydata3$Inspection.Date)
Overall.Response.Time<- mean(mydata3$Response.Time)
Overall.Response.Time<- round(Overall.Response.Time, 1)
mydata3$Inspection.Date<- floor_date(mydata3$Inspection.Date, "month")
ICR<- aggregate(Response.Time ~ Inspection.Date, mydata3, FUN=mean)
ICR$Response.Time<- round(ICR$Response.Time, 2)


### Total Complaints by Month
####### Total complaints chart below
IC$Complaint.Date <- mdy(IC$Complaint.Date)
IC$Complaint.Date<- floor_date(IC$Complaint.Date, "month")
IC_Complaints<- aggregate(Count.Complaints ~ Complaint.Date, IC, sum)
x <- list(title = "")
y <- list(title = "")
p <- plot_ly(IC_Complaints, x = ~Complaint.Date, y = ~Count.Complaints, type = 'bar', opacity=0.8, hoverinfo='text', text = ~paste('Date:', format(Complaint.Date, '%b-%y'),'<br>Total:', Count.Complaints))  %>%  layout(xaxis = x, yaxis = y, showlegend = FALSE)  %>% config(displayModeBar = F)
p



### Total Complaints by Borough
## Borough Graph
IC_borough$Complaint.Date <- mdy(IC_borough$Complaint.Date)
IC_borough$Complaint.Date<- floor_date(IC_borough$Complaint.Date, "month")
IC_borough<- dcast(IC_borough, Complaint.Date ~ Borough)
names(IC_borough)<- c("Complaint.Date", "Bronx", "Brooklyn", "Manhattan", "Queens", "Staten.Island")
x <- list(title = "")
y <- list(title = "")
p_borough <- plot_ly(IC_borough, x = ~Complaint.Date, y = ~Manhattan, type="bar", opacity=0.8, name = "A", visible = T) %>%
config(displayModeBar = F)%>%
layout(
  title = "",
  xaxis = x,
  yaxis = y,
  updatemenus = list(
    list(
      y = 0.7,
      buttons = list(
        list(method = "restyle",
             args = list("y", list(IC_borough$Manhattan)),  # put it in a list
             label = "Manhattan"),
        list(method = "restyle",
             args = list("y", list(IC_borough$Bronx)),  # put it in a list
             label = "Bronx"),
		list(method = "restyle",
             args = list("y", list(IC_borough$Brooklyn)),  # put it in a list
             label = "Brooklyn"),
		list(method = "restyle",
             args = list("y", list(IC_borough$Queens)),  # put it in a list
             label = "Queens"),
		list(method = "restyle",
             args = list("y", list(IC_borough$Staten.Island)),  # put it in a list
             label = "Staten Island"))))) 
p_borough



### Top 10 Community Boards
## Community Board Graph
## convert Community Board numbers to factors
IC$Community.Board <- as.factor(IC$Community.Board)
IC_CMBD<- aggregate(Count.Complaints ~ Community.Board, IC, sum)
IC_CMBD<- IC_CMBD[with(IC_CMBD,order(-Count.Complaints)),]
IC_CMBD<- IC_CMBD[1:10,]
IC_CMBD$Community.Board <- factor(IC_CMBD$Community.Board, levels = unique(IC_CMBD$Community.Board), ordered = TRUE)
x <- list(title = "Community Board")
IC_CMBD_Graph<- plot_ly(IC_CMBD, x = ~Community.Board, y = ~Count.Complaints, type = 'bar', opacity=0.8, hoverinfo='text', text= ~paste('CB:', Community.Board, '<br>Total:', Count.Complaints)) %>%  layout(xaxis = x, yaxis = y, showlegend = FALSE) %>% config(displayModeBar = F)
IC_CMBD_Graph


### Complaints: Past 7 days
#### Complaint Map
IC_complaint.map$Complaint.Date <- mdy(IC_complaint.map$Complaint.Date)
complaint.map<- IC_complaint.map %>% filter(IC_complaint.map$Complaint.Date  >= today() - days(7))
pal <- colorFactor(c("#1695A3"),
domain = unique(complaint.map$Complaint.Type))

unique_markers_map1 <- leaflet(complaint.map) %>%
   setView(lng = -73.936176, lat = 40.694526, zoom = 11) %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Carto Postiron")  %>% 
  addProviderTiles(providers$CartoDB.DarkMatter, group = "Carto Dark") %>%  
  addProviderTiles(providers$Stamen.Toner, group = "Stamen Toner") %>%  
  addCircleMarkers(
    color = ~pal(Complaint.Type),
    stroke = FALSE, fillOpacity = 0.6,
    lng = ~Longitude, lat = ~Latitude,
    label = ~as.character(Address),
	popup = paste("Complaint Type:", complaint.map$Complaint.Type, "<br>",
                           "Address:", complaint.map$Address, "<br>",
						   "Borough:", complaint.map$Borough, "<br>",
                           "Complaint Date:", complaint.map$Complaint.Date)
  )  %>%
  
   addLayersControl(
    baseGroups = c("Carto Postiron", "Carto Dark", "Stamen Toner"),
    options = layersControlOptions(collapsed = FALSE)
  )  %>%
  
  addLegend("bottomright", pal = pal, values = ~Complaint.Type,
    title = "Complaint Type",
    opacity = 1
  )
  
unique_markers_map1


### Inspections and Access
### Inspection attempts and no access rate
IC2 <- subset(IC2, Count.Inspected == "1")
IC2<- IC2[,c("Inspection.Date", "No.Access", "with.Access")]
IC2$Inspection.Date<- floor_date(IC2$Inspection.Date, "month")
IC2 <- aggregate(x = IC2[c("No.Access","with.Access")], FUN = sum, by = list(group.Date = IC2$Inspection.Date))
names(IC2)<- c("Inspection.Date", "No.Access", "with.Access")
IC2$Inspection.Date<- as.Date(IC2$Inspection.Date)
x <- list(title = "")
IC2<- plot_ly(IC2, x = ~Inspection.Date, y = ~with.Access, type = 'bar', opacity=0.8,name = 'with Access', hoverinfo='text', text = ~paste('Date:', format(Inspection.Date, '%b-%y'),'<br>with Access:', with.Access, '<br>No Access:', No.Access))    %>% add_trace(y = ~No.Access, name = 'No Access')     %>%  layout(xaxis = x, yaxis = y, showlegend = TRUE, barmode='stack', legend = list(orientation = 'h')) %>% config(displayModeBar = F) 
IC2




### Violations Issued
### Graph Access complaints with violations
## Subset by only Accessed inspections
IC3 <- subset(IC3, with.Access == "1")
IC3<- IC3[,c("Inspection.Date", "with.Violations", "No.Violations")]
IC3$Inspection.Date<- floor_date(IC3$Inspection.Date, "month")
IC3 <- aggregate(x = IC3[c("with.Violations","No.Violations")], FUN = sum, by = list(group.Date = IC3$Inspection.Date))
names(IC3)<- c("Inspection.Date", "with.Violations", "No.Violations")
IC3$Inspection.Date<- as.Date(IC3$Inspection.Date)
IC3<- plot_ly(IC3, x = ~Inspection.Date, y = ~No.Violations, type = 'bar', opacity=0.8, name = 'No Violations', hoverinfo='text', text = ~paste('Date:', format(Inspection.Date, '%b-%y'),'<br>No Violations:', No.Violations, '<br>with Violations:', with.Violations))    %>% add_trace(y = ~with.Violations, name = 'with Violations') %>%  layout(xaxis = x, yaxis = y, showlegend = TRUE, barmode='stack', legend = list(orientation = 'h'))  %>% config(displayModeBar = F)
IC3



### Response Time
## Response Timex <- list(title = "")
y <- list(title = "Avg. Response Time (days)")
ICR_Graph <- plot_ly(ICR, x = ~Inspection.Date, y = ~Response.Time, type="scatter", mode= "lines+markers", hoverinfo='text', text = ~paste('Month:', format(Inspection.Date, '%b-%y'),'<br>Response Time:', Response.Time))  %>%  layout(xaxis = x, yaxis = y, showlegend = FALSE) %>% config(displayModeBar = F)
ICR_Graph


### Inspections: Past 7 days
#### Inspection map
Inspection.map$No.Access[Inspection.map$No.Access == 0 & is.numeric(Inspection.map$No.Access)] <- NA
Inspection.map$No.Access[Inspection.map$No.Access == 1 & is.numeric(Inspection.map$No.Access)] <- "No Access"
Inspection.map$with.Violations[Inspection.map$with.Violations == 0 & is.numeric(Inspection.map$with.Violations)] <- NA
Inspection.map$with.Violations[Inspection.map$with.Violations == 1 & is.numeric(Inspection.map$with.Violations)] <- "with Violations"
Inspection.map$No.Violations[Inspection.map$No.Violations == 0 & is.numeric(Inspection.map$No.Violations)] <- NA
Inspection.map$No.Violations[Inspection.map$No.Violations == 1 & is.numeric(Inspection.map$No.Violations)] <- "No Violations"
Inspection.map["INSPECTIONS"] <- NA
Inspection.map <- subset(Inspection.map, Count.Inspected == "1")
Inspection.map$INSPECTIONS = Inspection.map$No.Access  # your new merged column start with x
Inspection.map$INSPECTIONS[!is.na(Inspection.map$with.Violations)] = Inspection.map$with.Violations[!is.na(Inspection.map$with.Violations)]  # merge with y
Inspection.map$INSPECTIONS[!is.na(Inspection.map$No.Violations)] = Inspection.map$No.Violations[!is.na(Inspection.map$No.Violations)]  


map2<- Inspection.map %>% filter(Inspection.map$Inspection.Date  >= today() - days(7))							
pal <- colorFactor(c("orange", "green", "red"),
domain = unique(map2$INSPECTIONS))


unique_markers_map2 <- leaflet(map2) %>%
  setView(lng = -73.936176, lat = 40.694526, zoom = 11) %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Carto Postiron")  %>% 
  addProviderTiles(providers$CartoDB.DarkMatter, group = "Carto Dark") %>%  
  addProviderTiles(providers$Stamen.Toner, group = "Stamen Toner") %>%  
  addCircleMarkers(
    color = ~pal(INSPECTIONS),
    stroke = FALSE, fillOpacity = 0.6,
    lng = ~Longitude, lat = ~Latitude,
    label = ~as.character(Address),
	popup = paste("Status:", map2$INSPECTIONS, "<br>",
                           "Address:", map2$Address, "<br>",
						   "Borough:", map2$Borough, "<br>",
                           "Inspection Date:", map2$Inspection.Date, "<br>",
                           "Disposition:", map2$Disposition.Code)
  )  %>%
  
   addLayersControl(
    baseGroups = c("Carto Postiron", "Carto Dark", "Stamen Toner"),
    options = layersControlOptions(collapsed = FALSE)
  )  %>%
  
  addLegend("bottomright", pal = pal, values = ~INSPECTIONS,
    title = "Inspection Status",
    opacity = 1
  )
  
unique_markers_map2





