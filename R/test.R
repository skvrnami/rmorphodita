# library(reticulate)
# library(rmorphodita)
# install_morphodita(pip = TRUE)
#
# tagger <- load_tagger("src/czech-morfflex-pdt-161115.tagger")
# tagger_no_dia <- load_tagger("src/czech-morfflex-pdt-161115-no_dia.tagger")
#
# test_text <- "
# V jaké společnosti se ocitl premiér Babiš? Pandora Papers zmiňují také krále, prezidenty nebo Shakiru
# Aféra Pandora Papers rozhýbala světové dění. Zjištění skupiny investigativních novinářů dopadají na desítky státníků po celém světě, kteří v minulosti využívali offshorové společnosti a nyní se kvůli tomu dostávají do problémů. Kromě světových lídrů jsou mezi dotčenými také další významné osobnosti včetně celebrit, jako je popová zpěvačka Shakira.
# „Pro bývalého oligarchu, který při vstupu do politiky sliboval boj proti korupci, je (odhalení) posledním ztrapňujícím obratem,“ komentuje britský deník The Guardian zjištění investigativních novinářů, podle kterých si český premiér Andrej Babiš (ANO) v roce 2009 pořídil například luxusní vilu na jihu Francie prostřednictvím složité sítě offshorových firem.
# Premiér pochybení v pondělí odmítl s tím, že v době transakce nebyl aktivní v politice. „Nevlastním a nikdy jsem nevlastnil nemovitost ve Francii,“ uvedl Babiš. Opakovaně tvrdí, že za celou akcí je snaha ovlivnit blížící se sněmovní volby.
# "
#
# purrr::map_df(0:7, function(x) {
#     tibble::tibble(
#         lemma = lemmas[x]$lemma,
#         tag = lemmas[x]$tag,
#         start = tokens[x]$start,
#         length = tokens[x]$length
#     )
# })
# tokenizer$setText(test_text)
# tagger$tag(forms, lemmas)
