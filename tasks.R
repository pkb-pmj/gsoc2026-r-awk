library(data.table)
library(ggplot2)

# setwd("~/Downloads/")

# Easy --------------------------------------------------------------------

# Setup
fwrite(x = diamonds[1:5,], file = "diamonds.csv")

# Command 1
fread(cmd = "awk -F ',' '{print}' 'diamonds.csv'")

# Command 2
fread(cmd = "awk -F ',' '{if(NR > 1) print $1, $2, $7/$1}' 'diamonds.csv'", fill = T)

# Medium ------------------------------------------------------------------

# Setup
filename = "diamonds2.csv"
fwrite(x = diamonds, file = filename)
awk <- function(command, files = filename) {
  files <- paste(sapply(files, function(x) paste0("'", x, "'")), collapse = " ")
  fread(cmd = paste0("awk -F ',' '", command, "' ", files))
}

# Task 1
# Read in all of the rows of data that have a color of 'E'
# and a price greater than 1500.
# Show the output and then count the rows.
rows <- awk("{if(NR == 1 || (FNR > 1 && ($3 == \"E\" && $7 > 1500))) print}")
print(rows)
cat("row count:", nrow(rows))

# Task 2
# Provide a modified AWK command that can count the rows
# for the previous command without first reading the data.
awk("BEGIN {count = 0} {if(FNR > 1 && ($3 == \"E\" && $7 > 1500)) count++} END {print(count)}")

# Task 3
# Read in the diamonds data 3 times in a single AWK command.
# Include only the rows with all of the following characteristics:
#   a) carat at least 1,
#   b) a cut of Ideal or Premium,
#   c) color 'E' or 'F', and
#   d) price at least 1000.
# Show the data and then count the rows.
rows <- awk(
  "{if(NR == 1 || (FNR > 1 && ($1 >= 1 && ($2 == \"Ideal\" || $2 == \"Premium\") && ($3 == \"E\" || $3 == \"F\") && $7 > 1500))) print; count++}",
  rep(filename, times = 3)
)
print(rows)
cat("row count:", nrow(rows))

# Hard --------------------------------------------------------------------

# Write a function that translates R code to an AWK statement.
# Make sure that it works properly on the diamonds data for the following test cases:
#   1. "price >= 1000"
#   2. "carat <= 1 and color == 'E'"
#   3. "cut %in% c('Premium', 'Ideal')"
# Show the output of your translation function.
# Then run fread() while feeding in the translated AWK command.
# Show the resulting data.

r2awkCondition <- function (x, columns) {
  x <- gsub("\\band\\b", "&&", x)
  x <- gsub("\\bor\\b", "||", x)
  
  for (i in seq_along(columns)) {
    x <- gsub(paste0("\\b", columns[i], "\\b"), paste0("$", i), x)
  }
  
  expandInOperator <- function (x) {
    parts <- trimws(strsplit(x, "%in%")[[1]])
    column <- parts[1]
    valuesStr <- gsub("^c\\(|\\)$", "", parts[2])
    valuesList <- trimws(strsplit(valuesStr, ",")[[1]])
    expandedOr <- paste0("(", column, " == ", valuesList, ")", collapse = " || ")
    paste0("(", expandedOr, ")")
  }
  
  m <- gregexpr("\\$\\d+\\s*%in%\\s*c\\((.*?)\\)", x)
  replacements <- lapply(regmatches(x, m), function (x) sapply(x, expandInOperator))
  regmatches(x, m) <- replacements
  
  x <- gsub("\'", "\"", x)
  x
}

r2awk <- function(x, files) {
  files <- paste(sapply(files, function(x) paste0("'", x, "'")), collapse = " ")
  columnsTable <- fread(cmd = paste0("awk -F ',' '", "NR == 1 {print; exit}", "' ", files))
  condition <- r2awkCondition(x, colnames(columnsTable))
  command <- paste0("awk -F ',' '(NR == 1 || (", condition, ")) {print}' ", files)
  command
}

columns <- c("carat", "cut", "color", "clarity", "depth", "table", "price", "x", "y", "z")
r2awkCondition("price >= 1000", columns)
r2awkCondition("carat <= 1 and color == 'E'", columns)
r2awkCondition("cut %in% c('Premium', 'Ideal')", columns)
r2awkCondition("carat <= 2 and (color == 'E' or $1 %in% c('Premium', 'Ideal')) and $2 %in% c('E', 'F')", columns)

files <- "diamonds2.csv"

# awk("{if($7 >= 1000) print}", files)
(cmd <- r2awk("price >= 1000", files))
fread(cmd = cmd)

# awk("{if($1 <= 1 && $3 == \"E\") print}", files)
(cmd <- r2awk("carat <= 1 and color == 'E'", files))
fread(cmd = cmd)

# awk("{if($2 == \"Premium\" || $2 == \"Ideal\") print}", files)
(cmd <- r2awk("cut %in% c('Premium', 'Ideal')", files))
fread(cmd = cmd)

r2awk("carat <= 2 and (color == 'E' or $1 %in% c('Premium', 'Ideal')) and $2 %in% c('E', 'F')", files)
