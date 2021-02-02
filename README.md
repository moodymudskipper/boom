
<!-- README.md is generated from README.Rmd. Please edit that file -->

# boom <img src='man/figures/logo.png' align="right" height="139" />

*{boom}* is a one function package that lets you inspect the results of
the intermediate results of a call. It “explodes” the call into its
parts hence the name. It is useful for debugging and teaching operation
precedence.

Just provide any call to `boom()` or pipe to `boom()` at the end of a
*{magrittr}* pipe chain.

## Installation

Install with:

``` r
remotes::install_github("moodymudskipper/boom")
```

## Examples

``` r
library(boom)
boom(1 + !1 * 2)
#> 1 * 2
#> [1] 2
#> !1 * 2
#> [1] FALSE
#> 1 + !1 * 2
#> [1] 1

boom(subset(head(mtcars, 2), qsec > 17))
#> head(mtcars, 2)
#>               mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4      21   6  160 110  3.9 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag  21   6  160 110  3.9 2.875 17.02  0  1    4    4
#> qsec > 17
#> [1] FALSE  TRUE
#> subset(head(mtcars, 2), qsec > 17)
#>               mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4 Wag  21   6  160 110  3.9 2.875 17.02  0  1    4    4

library(magrittr)
mtcars %>%
  head(2) %>%
  subset(qsec > 17) %>%
  boom()
#> head(., 2)
#>               mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4      21   6  160 110  3.9 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag  21   6  160 110  3.9 2.875 17.02  0  1    4    4
#> qsec > 17
#> [1] FALSE  TRUE
#> subset(., qsec > 17)
#>               mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4 Wag  21   6  160 110  3.9 2.875 17.02  0  1    4    4
#> mtcars %>% head(2) %>% subset(qsec > 17)
#>               mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4 Wag  21   6  160 110  3.9 2.875 17.02  0  1    4    4
```

## Addin

If you don’t want to type `boom()` you can use the provided addin, named
*“Explode a call”*, just attribute a key combination to it (I use
ctrl+shift+alt+B on windows), select the call you’d like to explode and
fire away\!

## Notes

*{boom}* prints intermediate steps as they are executed, and thus
doesn’t say anything about what isn’t executed, it is in constrast
with functions like `lobstr::ast()` which return the parse tree.

This will be noticable with some uses of non standard evaluation.

``` r
lobstr::ast(deparse(quote(1+2+3+4)))
#> o-deparse 
#> \-o-quote 
#>   \-o-`+` 
#>     +-o-`+` 
#>     | +-o-`+` 
#>     | | +-1 
#>     | | \-2 
#>     | \-3 
#>     \-4

boom(deparse(quote(1+2+3+4)))
#> quote(1 + 2 + 3 + 4)
#> 1 + 2 + 3 + 4
#> deparse(quote(1 + 2 + 3 + 4))
#> [1] "1 + 2 + 3 + 4"

# standard evaluation
boom(1+2+3+4)
#> 1 + 2
#> [1] 3
#> 1 + 2 + 3
#> [1] 6
#> 1 + 2 + 3 + 4
#> [1] 10
```
