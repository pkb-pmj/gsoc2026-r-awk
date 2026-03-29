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


