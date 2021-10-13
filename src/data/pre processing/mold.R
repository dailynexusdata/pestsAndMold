library(tidyverse)
library(lubridate)
library(zoo)
source("src/data/pre processing/utility.R")

setwd("C:\\nexus\\data-gh\\pestAndMold")
mold <- read.csv("src/data/raw/mold.csv")

head(mold)

mold.data <- mold %>%
    filter(
        Building.Name != ""
    ) %>%
    mutate(
        date=lubridate::parse_date_time(
            str_extract(Task.Description, "\\d{2}/\\d{2}/\\d{4} \\d{2}:\\d{2}"), 
            "%m-%d-%Y %h-%M"
        ),
        desc=str_match(Task.Description, "\\d{2}/\\d{2}/\\d{4} \\d{2}:\\d{2} (.*)$")[,2],
        req=format.white.space(Request),
        building=format.building.name(Building.Name)
    ) %>%
    select(
        order=Work.Order..,
        building,
        name=Building.Name,
        date,
        desc,
        req
    )

sort(unique(mold.data$building))

mold.data %>%
    write.csv("src/data/mold_processed.csv", row.names=F)

md <- mold.data %>%
    mutate(
        days = as.yearmon(lubridate::ymd_hms(date)),
        building = strip.names(building)
    ) 

md %>%
    mutate(
        black = !is.na(str_match(req, "black")),
        green = !is.na(str_match(req, "green")),
        white = !is.na(str_match(req, "white"))
    ) %>%
    filter(black | green | white) %>%
    filter(black)

md %>%
    group_by(building) %>%
    summarise(n = n()) %>%
    arrange(desc(n)) %>%
    View()

md %>%
    group_by(days, building) %>%
    summarise(n = n()) %>%
    ungroup() %>%
    ggplot(aes(x=n, y=reorder(building, n))) +
    geom_bar(stat="identity")

md %>%
#    filter(year(days) >= 2020) %>%
    group_by(building) %>%
    summarise(n = n()) %>%
#    group_by(1) %>% 
#    count()
    write.csv("dist/data/mold_count.csv", row.names=F)

    ggplot(aes(x = days, y = n, fill=building)) +
    geom_bar(stat="identity")


