library(tidyverse)

#
# for request
#
format.white.space <- function(str) {
    rm.newline <- str_replace_all(str, "\\n", "")
    # str_replace_all(rm.newline, "\\W+", " ")
    str_replace(rm.newline, "\".*\"", "")
}

#
# rm _ Cluster, _ Tower etc
#
format.building.name <- function(str) {    
    str_replace(str, "(Q|-)?(\\d|[eE]nding).*$", "") %>%
    str_replace("(^ +| +$)", "") %>%
    str_replace("^SCH", "Santa Catalina Hall") %>%
    str_replace("^SY", "Santa Ynez") %>%
    str_replace(" -$", "") %>%
    str_replace(" Residence Hall", " Hall") %>%
    str_replace("(t|r)s$", "\\1") %>%
    str_replace("Village Apartment$", "Apt") %>%
    str_replace("(Apartme|Apar)$", "Apt") %>%
    str_replace("Apartment$", "Apt") %>%
    str_replace(" Building", "") %>%
    str_replace("SCV", "San Clemente Village")
}

#
#
#
strip.names <- function(name) {
    str_replace(name, "(Q|-)?(\\d|[eE]nding).*$", "") %>%
    str_replace("West Campus.*$", "West Campus") %>%
    str_replace("Santa Catalina.*$", "Santa Catalina")  %>%
    str_replace("Sierra Madre.*$", "Sierra Madre")  %>%
    str_replace("San Joaquin.*$", "San Joaquin")  %>%
    str_replace("Santa Ynez.*$", "Santa Ynez") %>%
    str_replace("San Rafael.*$", "San Rafael") %>%
    str_replace("San Clemente.*$", "San Clemente") %>%
    str_replace("Fineta House.*$", "Fineta House")  %>%
    str_replace("El Dorado.*$", "El Dorado")  %>%
    str_replace("Anacapa.*$", "Anacapa") %>%
    str_replace("San Miguel.*$", "San Miguel")  %>%
    str_replace("Del Mar Cottage.*$", "West Campus")  %>%
    str_replace("Storke.*$", "Storke") %>%
    str_replace("Manzanita .*$", "Manzanita") %>%
    str_replace("KITP .*", "KITP") %>%
    str_replace("DLG", "De La Guerra") %>%
    str_replace("De La Guerra .*", "De La Guerra") %>%
    str_replace("The Club.*", "The Club")
}