#' Load tagger
#'
#' @param src Path to the Tagger file
#' @example load_tagger("src/czech-morfflex-161115.tagger")
load_tagger <- function(src){
    morphodita$Tagger$load(src)
}

#' Load Morpho dictionary
#'
#' @param src
#' @example load_morpho("src/czech-morfflex-161115.dict")
load_morpho <- function(src){
    morphodita$Morpho$load(src)
}

#' Tag text
#'
#' @param tagger Morphodita Tagger
#' @param text Text to be tagger
morpho_tag <- function(tagger, text){
    tokenizer <- tagger$newTokenizer()
    forms <- morphodita$Forms()
    lemmas <- morphodita$TaggedLemmas()
    tokens <- morphodita$TokenRanges()

    tokenizer$setText(text)
    out <- tibble::tibble()
    while(tokenizer$nextSentence(forms, tokens)){
        tagger$tag(forms, lemmas)
        lemmas_it <- iterate(lemmas)
        tokens_it <- iterate(tokens)

        out <- purrr::map2_df(lemmas_it, tokens_it, function(l, t) {
            list(
                lemma = l[["lemma"]],
                tag = l[["tag"]],
                start = t[["start"]],
                length = t[["length"]]
            )
        }) %>% bind_rows(out, .)
    }
    out
}

strip_lemma_comment <- function(morpho, x){
    morpho$rawLemma(x)
}

get_forms_tibble <- function(form){
    f <- iterate(form$forms)
    purrr::map_df(f, function(x) {
        list(form = x$form,
             tag = x$tag)
    })
}

#' Analyze morphology of a word
#'
#' @param tagger
#' @param x a word to analyze
morpho_analyze <- function(tagger, x){
    morpho <- tagger$getMorpho()
    tlf <- morphodita$TaggedLemmas()

    morpho$analyze(x, morpho$GUESSER, tlf)
    tlf_it <- iterate(tlf)

    purrr::map_df(tlf_it, function(i) {
        list(lemma = i$lemma,
             tag = i$tag)
    })
}

#' Generate forms of a given lemma
#'
#' @param tagger
#' @param lemma a lemma from which forms should be generated
#' @param tag_wildcard specification of a form that should be generated
morpho_generate <- function(tagger, lemma, tag_wildcard = NULL){
    morpho <- tagger$getMorpho()
    tlf <- morphodita$TaggedLemmasForms()

    morpho$generate(lemma, tag_wildcard, morpho$GUESSER, tlf)
    t_forms <- reticulate::iterate(tlf)
    purrr::map_df(t_forms, function(x) {
        get_forms_tibble(x) %>%
            mutate(lemma = x$lemma)
    })
}
