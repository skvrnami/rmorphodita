#' Morphodita Python binding
morphodita <- NULL

.onLoad <- function(libname, pkgname) {
    # use superassignment to update global reference to scipy
    morphodita <<- reticulate::import("ufal.morphodita", delay_load = TRUE)
}

install_morphodita <- function(method = "auto", conda = "auto", pip = TRUE) {
    reticulate::py_install("ufal.morphodita", method = method, conda = conda, pip = pip)
}

# download_model <- function(lang = "CZ"){
#     download.file("https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-1836/czech-morfflex-pdt-161115.zip")
# }
