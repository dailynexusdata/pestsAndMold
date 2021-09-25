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
    str_replace("(^ +| +$)", "")
}