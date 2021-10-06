#' Load tagger
#'
#' @param src Path to the Tagger file
#' @export
#' @examples
#' \dontrun{
#' load_tagger("src/czech-morfflex-161115.tagger")
#' }
load_tagger <- function(src){
    morphodita$Tagger$load(src)
}

#' Load Morphological dictionary
#'
#' @param src Path to the morphological dictionary
#' @export
#' @examples
#' \dontrun{
#' load_morpho("src/czech-morfflex-161115.dict")
#' }
load_morpho <- function(src){
    morphodita$Morpho$load(src)
}

#' Tag text
#'
#' @param tagger Morphodita Tagger
#' @param text Text to be tagger
#' @param converters Tag converter
#' @export
#' @importFrom rlang .data
morpho_tag <- function(tagger, text, converters = NULL){
    tokenizer <- tagger$newTokenizer()
    forms <- morphodita$Forms()
    lemmas <- morphodita$TaggedLemmas()
    tokens <- morphodita$TokenRanges()

    tokenizer$setText(text)
    out <- tibble::tibble()
    sentence <- 1
    while(tokenizer$nextSentence(forms, tokens)){
        tagger$tag(forms, lemmas)
        lemmas_it <- reticulate::iterate(lemmas)

        if("conll2009" %in% converters){
            converter <- morphodita$TagsetConverter$newPdtToConll2009Converter()
            purrr::walk(lemmas_it, function(x) converter$convert(x))
        }

        if("strip_lemma_comment" %in% converters){
            morpho <- tagger$getMorpho()
            converter <- morphodita$TagsetConverter$newStripLemmaCommentConverter(morpho)
            purrr::walk(lemmas_it, function(x) converter$convert(x))
        }

        if("strip_lemma_id" %in% converters){
            morpho <- tagger$getMorpho()
            converter <- morphodita$TagsetConverter$newStripLemmaIdConverter(morpho)
            purrr::walk(lemmas_it, function(x) converter$convert(x))
        }

        tokens_it <- reticulate::iterate(tokens)
        words <- reticulate::iterate(forms)

        out <- purrr::map2_df(lemmas_it, tokens_it, function(l, t) {
            list(
                lemma = l[["lemma"]],
                tag = l[["tag"]],
                start = t[["start"]],
                length = t[["length"]]
            )
        }) %>%
            dplyr::mutate(word = words,
                          sentence = sentence) %>%
            dplyr::bind_rows(out)

        sentence <- sentence + 1
    }
    out
}


#' Analyze morphology of a word
#'
#' @param tagger Morphodita tagger
#' @param x a word to analyze
#' @export
morpho_analyze <- function(tagger, x){
    morpho <- tagger$getMorpho()
    tlf <- morphodita$TaggedLemmas()

    morpho$analyze(x, morpho$GUESSER, tlf)
    tlf_it <- reticulate::iterate(tlf)

    purrr::map_df(tlf_it, function(i) {
        list(lemma = i$lemma,
             tag = i$tag)
    })
}

#' Extract form and tag from form object
#'
#' @param form Form
get_forms_tibble <- function(form){
    f <- reticulate::iterate(form$forms)
    purrr::map_df(f, function(x) {
        list(form = x$form,
             tag = x$tag)
    })
}

#' Generate forms of a given lemma
#'
#' @param tagger morphological tagger
#' @param lemma a lemma from which forms should be generated
#' @param tag_wildcard specification of a form that should be generated
#' @export
morpho_generate <- function(tagger, lemma, tag_wildcard = NULL){
    morpho <- tagger$getMorpho()
    tlf <- morphodita$TaggedLemmasForms()

    morpho$generate(lemma, tag_wildcard, morpho$GUESSER, tlf)
    t_forms <- reticulate::iterate(tlf)
    purrr::map_df(t_forms, function(x) {
        get_forms_tibble(x) %>%
            dplyr::mutate(lemma = x$lemma)
    })
}

#' Split CONLL tags into separate columns
#'
#' @param df Data.frame containing column `tag` with morphological tags
#' @export
#' @seealso https://ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html
#' @importFrom rlang .data
extract_conll_tags <- function(df){
    df %>%
        dplyr::mutate(
            pos = stringr::str_extract(.data$tag, "(?<=POS=)[A-Z0-9]{1}"),
            pos_detail = stringr::str_extract(.data$tag, "(?<=SubPOS=)[A-Za-z0-9.!#,:;?@^}~]{1}"),
            gender = stringr::str_extract(.data$tag, "(?<=Gen=)[FHIMNQTXYZ]{1}"),
            number = stringr::str_extract(.data$tag, "(?<=Num=)[A-Za-z0-9.!#,:;?@^}~]{1}"),
            case = stringr::str_extract(.data$tag, "(?<=Cas=)[1-7X]{1}"),
            poss_gender = NA_character_,
            poss_number = stringr::str_extract(.data$tag, "(?<=PNu=)[PS]{1}"),
            person = stringr::str_extract(.data$tag, "(?<=Per=)[A-Za-z0-9.!#,:;?@^}~]{1}"),
            tense = stringr::str_extract(.data$tag, "(?<=Ten=)[A-Za-z0-9.!#,:;?@^}~]{1}"),
            grade = stringr::str_extract(.data$tag, "(?<=Gra=)[A-Za-z0-9.!#,:;?@^}~]{1}"),
            negation = stringr::str_extract(.data$tag, "(?<=Neg=)[A-Za-z0-9.!#,:;?@^}~]{1}"),
            voice = stringr::str_extract(.data$tag, "(?<=Voi=)[AP]{1}"),
            reserve1 = NA_character_,
            reserve2 = NA_character_,
            variant = stringr::str_extract(.data$tag, "(?<=Var=)[1-9]{1}")
        ) %>%
        dplyr::select(-c(.data$reserve1, .data$reserve2))
}

#' Split HM tags into separate columns
#'
#' @param df Data.frame containing column `tag` with morphological tags
#' @export
#' @seealso https://ufal.mff.cuni.cz/pdt/Morphology_and_Tagging/Doc/hmptagqr.html
#' @importFrom rlang .data
extract_hm_tags <- function(df){
    df %>%
        dplyr::mutate(tag = purrr::map_chr(.data$tag,
                                           function(x) paste0(unlist(strsplit(x, "")),
                                                              collapse = "|"))) %>%
        tidyr::separate(col = .data$tag, into = c("pos",
                                         "pos_detail",
                                         "gender",
                                         "number",
                                         "case",
                                         "poss_gender",
                                         "poss_number",
                                         "person",
                                         "tense",
                                         "grade",
                                         "negation",
                                         "voice",
                                         "reserve1",
                                         "reserve2",
                                         "variant"), sep = "[|]") %>%
        dplyr::select(-c(.data$reserve1, .data$reserve2))
}

#' Recode tag to factor
#'
#' @param x tag to be recoded
#' @param tags_df List of Data.frames with values and descriptions of morphological tags
#' @param tag_type Abbreviation of a morphological tag
recode_tag <- function(x, tags_df, tag_type){
    factor(x, levels = tags_df[[tag_type]]$Value,
           labels = tags_df[[tag_type]]$Description)
}

#' Recode morphological tags
#'
#' @param df Data.frame with extracted tags
#' @param tags_df List of data.frames with values and descriptions of morphological tags
#' @export
#' @importFrom rlang .data
recode_tags <- function(df, tags_df){
    df %>%
        dplyr::mutate(pos = recode_tag(.data$pos, tags_df, "POS"),
               pos_detail = recode_tag(.data$pos_detail, tags_df, "SUBPOS"),
               gender = recode_tag(.data$gender, tags_df, "GENDER"),
               number = recode_tag(.data$number, tags_df, "NUMBER"),
               case = recode_tag(.data$case, tags_df, "CASE"),
               poss_gender = recode_tag(.data$poss_gender, tags_df, "POSSGENDER"),
               poss_number = recode_tag(.data$poss_number, tags_df, "POSSNUMBER"),
               person = recode_tag(.data$person, tags_df, "PERSON"),
               tense = recode_tag(.data$tense, tags_df, "TENSE"),
               grade = recode_tag(.data$grade, tags_df, "GRADE"),
               negation = recode_tag(.data$negation, tags_df, "NEGATION"),
               voice = recode_tag(.data$voice, tags_df, "VOICE"),
               variant = recode_tag(.data$variant, tags_df, "VAR"))
}
