library(tidyverse)
source("src/data/pre processing/utility.R")

pest <- read.csv("src/data/raw/pest.csv")

str(pest)


pest.data <- pest %>%
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
        order=Work.Order..,
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
    filter(
        !ants & !flies & !termites & !roaches & !spiders & !wasps & !bedbugs & !bees & !bugs & !pests & !kitchen & !bathroom & !mattress & !crickets
    )

pest.data$req

str_detect("Ants in the kitchen and roaches in the toilet", regex("ants", ignore_case=T))
