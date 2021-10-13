library(tidyverse)
library(lubridate)
library(zoo)
source("src/data/pre processing/utility.R")

# pest <- read.csv("src/data/raw/pest.csv")
#pest <-pdf_data("src/data/pra/Mold Report HDAE 2021.pdf")
setwd("C:\\nexus\\data-gh\\pestAndMold")
pest <- read.csv("src/data/pra/Pest Control Report HDAE 2021.csv")

str(pest)

dim(pest)
head(pest)

pest$Task.Description %>% tail()
unique(as.yearmon(lubridate::ymd_hms(pest.data$date)))

pest.data <- pest %>%
    filter(
        Building.Name != ""
    ) %>%
    mutate(
        date=parse_date_time(
            Request.Date, 
            "%m-%d-%Y %h-%M"
        ),
        desc=Task.Description,
        req=format.white.space(Request),
        building=strip.names(format.building.name(Building.Name))
    ) %>%
    mutate(
        ants=str_detect(req, regex("au?nts?", ignore_case=T)), # some people mispell
        flies=str_detect(req, regex("flies|fly|fleas?", ignore_case=T)),
        spiders=str_detect(req, regex("spiders?|black widow", ignore_case=T)), # separate out
        roaches=str_detect(req, regex("roach(es)?", ignore_case=T)),
        termites=str_detect(req, regex("termites?|wood", ignore_case=T)),
        bedbugs=str_detect(req, regex("bed ?bugs?", ignore_case=T)),
        wasps=str_detect(req, regex("wasps?|yellow jackets?", ignore_case=T)),
        bees=str_detect(req, regex("bees?", ignore_case=T)),
        bugs=str_detect(req, regex("bugs?", ignore_case=T)),
        pests=str_detect(req, regex("pests?", ignore_case=T)),
        kitchen=str_detect(req, regex("kitchens?", ignore_case=T)),
        bathroom=str_detect(req, regex("bath ?rooms?|shower|restroom|tub|sink|toilets|refridgerator|refrigerator", ignore_case=T)),  # mispell
        mattress=str_detect(req, regex("matt?ress", ignore_case=T)), # mispell
        crickets=str_detect(req, regex("crickets?", ignore_case=T)),
        silverfish=str_detect(req, regex("silverfish", ignore_case=T)),
        rodents=str_detect(req, regex("rodents?", ignore_case=T)),
        mouse=str_detect(req, regex("mouse|mice", ignore_case=T)), # rats too ??
        # bedroom
        # balcony
        # spray, traps, bait
        # colony
        # exterminator
        # window
        # garbage
        # bites / bit
        # mosquitos
        # REMOVE OUT CANCELLED / move out
        # hive, nest
        # swarming, EMERGENCY, "THEY ARE EVERYWHERE", "PLEASE HELP"
        # "beam where small bebree falls on the bed"??
    ) %>%
    select(
        order=ï..Work.Order..,
        building,
        name=Building.Name,
        date,
        desc,
        req,
        ants,
        flies,
        spiders,
        roaches,
        termites,
        bedbugs,
        wasps,
        bees,
        pests, 
        kitchen, 
        bathroom, 
        bugs, 
        mattress, 
        crickets
    ) %>%
    mutate(
        building = ifelse(building %in% c("The Club-Grounds", "De La Guerra-Grounds") , str_replace(building, "-Grounds", ""), str_replace(building, "-Grounds", " Hall"))
    ) %>%
    filter(
        year(date) >= 2016
    )


pest.data

%>%
    filter(
        !ants & !flies & !termites & !roaches & !spiders & !wasps & !bedbugs & !bees & !bugs & !pests & !kitchen & !bathroom & !mattress & !crickets
    )

pest.data$req
unique(as.yearmon(lubridate::ymd_hms(pest.data$date)))

# ughhhhhhhhhhhhhhhhhhhh might be overlap
pests.ts <- pest.data %>%
    select(building, date, ants:crickets) %>%
    gather("which", "yes", -c(building, date)) %>%
    filter(yes) %>%
    mutate(
        days = as.yearmon(lubridate::ymd_hms(date))
    ) 

pests.ts %>%
    filter(building == "De La Guerra") %>%
    group_by(which) %>%
    count() %>%
    ungroup() %>%
    mutate(total = sum(n))%>%
    mutate(pct = n / sum(n))

pest.data %>%
    filter(!is.na(str_match(building, "(Portola|De La Guerra|Carrillo|Ortega)"))) %>%
    group_by(building) %>%
    count()

pests.ts %>%
    filter(!is.na(str_match(building, "De La Guerra"))) %>%
    group_by(which) %>%
    count()

pest.data %>%
    group_by(building) %>%
    count() %>%
    ungroup() %>%
    arrange(desc(n))

dim(pest.data)

pests.ts %>%
    filter(which == "bedbugs") %>%
#    filter(year(date) >= 2015) %>%
    group_by(building) %>%
    count() %>%
    ungroup() %>%
    arrange(desc(n)) %>%
    mutate(total = sum(n))

pests.ts %>%
    group_by(which) %>%
    count() %>%
    arrange(desc(n))

#
# ts plot of pest names
#
top.cats <- pests.ts %>%
    group_by(which) %>%
    count() %>%
    ungroup() %>%
    arrange(desc(n)) %>%
    filter(which %in% c("ants", "roaches", "bedbugs")) %>%
    pull(which)

pests.ts %>%
    pull(which) %>%
    unique()

g <- pests.ts %>%
    filter(!(which %in% c("bathroom", "kitchen"))) %>%
    mutate(
        top3 = which %in% top.cats
    ) %>%
    mutate(
        which = factor(
            ifelse(top3, str_to_title(which), "Other"),
            levels=c("Ants", "Bedbugs", "Roaches", "Other")
        )
    ) %>%
    group_by(which, days, .groups="drop") %>%
    summarise(n = n()) %>%
    ungroup() %>% 
    ggplot() +
    geom_bar(aes(x = days, y = n, fill = which), stat="identity") +
    theme_light() +
    scale_y_continuous(expand=c(0, 0.25)) +
    theme(
        panel.border = element_blank(),
        panel.grid.major.y = element_line(color="#d3d3d3", size=0.5),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
       # legend.position = "none",
        title = element_text(size=12),
        axis.text = element_text(size = 12),
        #plot.title = element_text(hjust=0.5)
    ) +
    labs(
        x="",
        y="# of reports", 
        title="Ants Make Up 45% of All Pest Removal Requests Since 2016",
        fill="Top requests"
    ) +
    scale_fill_manual(values=c("#4e79a7bb", "#D96942", "#59a14fbb", "#d3d3d3")) 
    geom_text(
        aes(x=x, y=y, label=label), 
        data.frame(x=as.Date("2019-8-01"), y=50, label="Daily administered tests"), 
        size=5
    )

+
    geom_curve(
        aes(x = x1, y = y1, xend = x2, yend = y2),
        data = data.frame(x1 = as.Date('2021-9-24'), x2 = as.Date("2021-9-22"), y1 = 8.65, y2 = 8.65),
        arrow = arrow(length = unit(0.0175, "npc"), type="closed")
    )
g


ggsave("pests.png", g, width=8, height=5, dpi=300)

pests.ts %>%
    group_by(which) %>%
    count() %>%
    ungroup() %>%
    arrange(desc(n)) %>%
    mutate(tot = sum(n))


pest.data %>%
    group_by(date) %>%
    summarise(n = n()) %>%
    mutate(sept = month(date) == 9 | month(date) == 10) %>%
    group_by(sept) %>%
    summarise(n = sum(n)) %>%
    group_by(1) %>%
    summarise(n = n/sum(n))

#
# Top Tests over time
#
pests.ts %>%
    group_by(which) %>%
    summarise(n = n()) %>%
    arrange(desc(n))

pests.ts %>%
    filter(which == "ants") %>%
    group_by(days) %>%
    summarise(n = n()) %>%
    View()

%>%
    ggplot(aes(x = days, y =n)) +
    geom_line()

pest.buildings <- pest.data %>%
    select(building, date, ants:crickets) %>%
    gather("which", "yes", -c(building, date)) %>%
    filter(yes) %>%
    mutate(
        days = as.yearmon(lubridate::ymd_hms(date))
    ) %>%
    group_by(building, days) %>%
    summarise(n = n()) %>%
    mutate(
        building = strip.names(building)
    ) 

# top pest locations
pest.data %>%
    group_by(building) %>%
    summarise(n = n()) %>%
    arrange(desc(n)) 

pest.data %>%
    filter(building == "De La Guerra") %>%
    count()

pest.buildings %>%
    ggplot(aes(x = days, y = n, fill = building)) +
    geom_bar(stat="identity")

pest.data %>%
    ggplot(aes(x = n, y = building)) +
    geom_bar(stat="identity")
