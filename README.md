# Easy Test

## Command 1

```r
fread(cmd = "awk -F ',' '{print}' 'diamonds.csv'")
```

- `-F ','` – sets the field separator, in this case a comma
- `'{print}'` – the AWK program, in this case simply prints every row
- `'diamonds.csv'` – the input file

### Command 2

```r
fread(cmd = "awk -F ',' '{if(NR > 1) print $1, $2, $7/$1}' 'diamonds.csv'", fill = T)
```

- `-F ','` – sets the field separator
- `'{if(NR > 1) print $1, $2, $7/$1}'` – again, the AWK program executed for every row:
    - `if(NR > 1)` – skips the first row, in this case the header, so we don't accidentally try dividing strings; as a side effect, the resulting table doesn't inherit column names
    - `print $1, $2, $7/$1` – prints the 1st and 2nd columns of every row (carat and cut), and 7th divided by 1st (price per carat).
- `fill = T` (R option, not AWK) – if rows have different lenghts, fills in the missing fields

# Medium Test

## Setup

First I wrote the entire dataset to CSV to actually get any results after filtering.
I also made a utility function for better readabiblity and less potential errors (no `'` mess in every command).

```r
filename = "diamonds2.csv"
fwrite(x = diamonds, file = filename)
awk <- function(command, files = filename) {
  files <- paste(sapply(files, function(x) paste0("'", x, "'")), collapse = " ")
  fread(cmd = paste0("awk -F ',' '", command, "' ", files))
}
```

## Task 1

Read in all of the rows of data that have a color of 'E' and a price greater than 1500. Show the output and then count the rows.

```r
rows <- awk("{if(NR == 1 || (FNR > 1 && ($3 == \"E\" && $7 > 1500))) print}")
print(rows)
cat("row count:", nrow(rows))
```

- `NR == 1` – preserve the header so the resulting table has nicely named columns
- `FNR > 1` – ensure all headers in the other files are skipped, even if they don't get filtered out by the following column value filters
- `$3 == \"E\"` – color 'E'
- `$7 > 1500` – price grater than 1500

## Task 2

Provide a modified AWK command that can count the rows for the previous command without first reading the data.

```r
awk("BEGIN {count = 0} {if(FNR > 1 && ($3 == \"E\" && $7 > 1500)) count++} END {print(count)}")
```

- `BEGIN {count = 0}` – set the count to 0 before rows are loaded
- `{if(FNR > 1 && ($3 == \"E\" && $7 > 1500)) count++}` – Increment count on the same filtering conditions as in previous task, but skip all headers, including the first one – we don't want to count it
- `END {print(count)}` – at the end, print count

## Task 3

Read in the diamonds data 3 times in a single AWK command.
Include only the rows with all of the following characteristics:

- carat at least 1 – `$1 >= 1`
- a cut of Ideal or Premium – `($2 == \"Ideal\" || $2 == \"Premium\")`
- color 'E' or 'F' – `($3 == \"E\" || $3 == \"F\")`
- price at least 1000 – `$7 > 1500`

Show the data and then count the rows.

```r
rows <- awk(
  "{if(NR == 1 || (FNR > 1 && ($1 >= 1 && ($2 == \"Ideal\" || $2 == \"Premium\") && ($3 == \"E\" || $3 == \"F\") && $7 > 1500))) print; count++}",
  rep(filename, times = 3)
)
print(rows)
cat("row count:", nrow(rows))
```

This is basically a combination of AWK and R code from two previous tasks, with the same file passed 3x. Here the header skipping starts really doing its job.

# Hard
