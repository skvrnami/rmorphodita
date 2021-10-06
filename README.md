
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rmorphodita

<!-- badges: start -->
<!-- badges: end -->

The goal of rmorphodita is to enable morphological analysis, tagging and
generation using [MorphoDiTa’s](https://github.com/ufal/morphodita)
Python bindings (contained in the [`ufal.morphodita` Python
package](https://pypi.org/project/ufal.morphodita/)).

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("skvrnami/rmorphodita")
```

## Example

First you need to install morphodita by running `install_morphodita()`.

``` r
library(rmorphodita)
```

``` r
install_morphodita()
```

Then you need to download a language model to use for tagging etc. There
are three languages available: Czech (`CZ`), Slovak (`SK`), and English
(`EN`). The `download_models` function downloads a .zip file with models
from [LINDAT/CLARIAH-CZ repository](https://lindat.mff.cuni.cz/) to a
specified directory, unzips them and returns list of files with
morphological taggers and dictionaries.

``` r
cz_models <- download_models(lang = "CZ", dest_folder = "tmp")
cz_models
#> [1] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-161115-no_dia-pos_only.dict"      
#> [2] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-161115-no_dia.dict"               
#> [3] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-161115-pos_only.dict"             
#> [4] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-161115.dict"                      
#> [5] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-pdt-161115-no_dia-pos_only.tagger"
#> [6] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-pdt-161115-no_dia.tagger"         
#> [7] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-pdt-161115-pos_only.tagger"       
#> [8] "/Users/skvrnami/github/rmorphodita/tmp/czech-morfflex-pdt-161115/czech-morfflex-pdt-161115.tagger"
```

Then it is necessary to load tagger:

``` r
cz_tagger <- load_tagger(cz_models[8])
```

``` r
tagged_text <- morpho_tag(cz_tagger, "Já bych všechny ty počítače zakázala.", NULL)
tagged_text
#> # A tibble: 7 × 6
#>   lemma   tag             start length word     sentence
#>   <chr>   <chr>           <int>  <int> <chr>       <dbl>
#> 1 já      PP-S1--1-------     0      2 Já              1
#> 2 být     Vc-S---1-------     3      4 bych            1
#> 3 všechen PLYP4----------     8      7 všechny         1
#> 4 ten     PDIP4----------    16      2 ty              1
#> 5 počítač NNIP4-----A----    19      8 počítače        1
#> 6 zakázat VpQW---XR-AA---    28      8 zakázala        1
#> 7 .       Z:-------------    36      1 .               1
```

Function `morpho_analyze` returns all possible forms of a word.

``` r
morpho_analyze(cz_tagger, "kout")
#> # A tibble: 3 × 2
#>   lemma                         tag            
#>   <chr>                         <chr>          
#> 1 kout_^(např._železo)          Vf--------A----
#> 2 kout_^(př._dát_něco_do_kouta) NNIS1-----A----
#> 3 kout_^(př._dát_něco_do_kouta) NNIS4-----A----
```

And function `morpho_generate` returns all possible forms of a given
lemma that complies with the specified wildcard. In the case below, it
returns all nouns in second case.

``` r
morpho_generate(cz_tagger, "kout", tag_wildcard = "N???2?")
#> # A tibble: 3 × 3
#>   form  tag             lemma                        
#>   <chr> <chr>           <chr>                        
#> 1 koutu NNIS2-----A---1 kout                         
#> 2 kouta NNIS2-----A---- kout_^(př._dát_něco_do_kouta)
#> 3 koutů NNIP2-----A---- kout_^(př._dát_něco_do_kouta)
```

As the tags are quite unintelligible, it is possible to extract and
recode them like this. The `extract_hm_tags` function splits the tag
into columns indicating particular grammatical categories such as part
of speech (`pos`), gender, number, case etc. The `recode_tags` function
then recode the tag marks into factor with a full description of the tag
meaning (using the `TAGS` list which stores the meaning of the tag
values).

``` r
tagged_text %>%
    extract_hm_tags() %>%
    recode_tags(., tags_df = TAGS)
#> # A tibble: 7 × 18
#>   lemma   pos     pos_detail  gender number case  poss_gender poss_number person
#>   <chr>   <fct>   <fct>       <fct>  <fct>  <fct> <fct>       <fct>       <fct> 
#> 1 já      "Prono… "Personal … <NA>   Singu… Nomi… <NA>        <NA>        1     
#> 2 být     "Verb"  "Condition… <NA>   Singu… <NA>  <NA>        <NA>        1     
#> 3 všechen "Prono… "Pronoun i… Mascu… Plural Accu… <NA>        <NA>        <NA>  
#> 4 ten     "Prono… "Pronoun, … Mascu… Plural Accu… <NA>        <NA>        <NA>  
#> 5 počítač "Noun"  "Noun, gen… Mascu… Plural Accu… <NA>        <NA>        <NA>  
#> 6 zakázat "Verb"  "Verb, pas… Femin… Singu… <NA>  <NA>        <NA>        Any   
#> 7 .       "Punct… "Punctuati… <NA>   <NA>   <NA>  <NA>        <NA>        <NA>  
#> # … with 9 more variables: tense <fct>, grade <fct>, negation <fct>,
#> #   voice <fct>, variant <fct>, start <int>, length <int>, word <chr>,
#> #   sentence <dbl>
```
