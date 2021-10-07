
test_that("Download model", {
    setwd(here::here())
    cz_models <- download_models("CZ", "tmp")
    expect_gt(length(cz_models), 4)
})

test_that("Tagging text", {
    cz_taggers <- list.files(path = here::here("tmp", "czech-morfflex-pdt-161115"),
                            pattern = "\\.tagger", full.names = TRUE)
    tagger <- load_tagger(cz_taggers[4])
    out <- morpho_tag(tagger, "Paní Ester, proč jsou lidi tak zlí?")

    expect_equal(nrow(out), 9)
    expect_true(all(colnames(out) %in% c("lemma", "tag", "start", "length", "word",
                                         "sentence")))
})

test_that("Analyzing lemma", {
    cz_taggers <- list.files(path = here::here("tmp", "czech-morfflex-pdt-161115"),
                             pattern = "\\.tagger", full.names = TRUE)
    tagger <- load_tagger(cz_taggers[4])
    out <- morpho_analyze(tagger, "kout")

    expect_equal(nrow(out), 3)
    expect_true(all(colnames(out) %in% c("lemma", "tag")))
})

test_that("Generate text", {
    cz_taggers <- list.files(path = here::here("tmp", "czech-morfflex-pdt-161115"),
                             pattern = "\\.tagger", full.names = TRUE)
    tagger <- load_tagger(cz_taggers[4])
    out <- morpho_generate(tagger, "Karel", "N?")

    # There are 7 cases x 2 numbers (singular, plural) for every noun
    expect_gte(nrow(out), 14)
})

unlink("tmp", recursive = TRUE)
