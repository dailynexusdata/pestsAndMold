library(tidyverse)
library(lubridate)
source("src/data/pre processing/utility.R")

mold <- read.csv("src/data/raw/mold.csv")

mold.data <- mold %>%
    filter(
        Building.Name != ""
    ) %>%
    mutate(
        date=parse_date_time(
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

unique(mold.data$building)

mold.data %>%
    write.csv("src/data/mold_processed.csv", row.names=F)
