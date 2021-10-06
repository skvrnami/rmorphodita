#' Morphodita Python binding
morphodita <- NULL

#' Load ufal.morphodita python package
#'
#' @param libname Library name
#' @param pkgname Package name
.onLoad <- function(libname, pkgname) {
    morphodita <<- reticulate::import("ufal.morphodita", delay_load = TRUE)
}

#' Install ufal.morphodita package
#'
#' @param method Installation method. By default, "auto" automatically finds a
#' method that will work in the local environment. Change the default to force
#' a specific installation method. Note that the "virtualenv" method is not
#' available on Windows.
#' @param conda The path to a conda executable.
#' Use "auto" to allow reticulate to automatically find an appropriate conda binary.
#' @param pip Boolean; use pip for package installation? This is only relevant when
#' Conda environments are used, as otherwise packages will be installed from
#' the Conda repositories.
#' @export
install_morphodita <- function(method = "auto", conda = "auto", pip = TRUE) {
    reticulate::py_install("ufal.morphodita", method = method, conda = conda, pip = pip)
}

#' Remove zip suffix from file name
#'
#' @param x File name
remove_zip_suffix <- function(x){
    stringr::str_remove(x, "\\.zip$")
}

#' Download language models from LINDAT repository
#'
#' @param lang Language of the model ("CZ" for Czech, "SK" for Slovak and "EN" for English)
#' @param dest_folder Destination folder where the language models should be downloaded to
#' @return Vector with paths to available models (taggers and morphological dictionaries)
#' @export
download_models <- function(lang = "CZ",
                           dest_folder = ""){

    if(!dir.exists(dest_folder) & dest_folder != ""){
        dir.create(dest_folder)
    }

    if(lang == "CZ"){
        utils::download.file("https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-1836/czech-morfflex-pdt-161115.zip",
                      destfile = here::here(dest_folder, "czech-morfflex-pdt-161115.zip"))
        utils::unzip(here::here(dest_folder, "czech-morfflex-pdt-161115.zip"),
                     exdir = dest_folder)
        list.files(here::here(dest_folder, remove_zip_suffix("czech-morfflex-pdt-161115.zip")),
                   full.names = TRUE,
                   pattern = "\\.tagger|\\.dict")
    }else if(lang == "SK"){
        utils::download.file("https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-3278/slovak-morfflex-pdt-170914.zip",
                      destfile = here::here(dest_folder, "slovak-morfflex-pdt-170914.zip"))
        utils::unzip(here::here(dest_folder, "slovak-morfflex-pdt-170914.zip"),
                     exdir = dest_folder)
        list.files(here::here(dest_folder, remove_zip_suffix("slovak-morfflex-pdt-170914.zip")),
                   full.names = TRUE,
                   pattern = "\\.tagger|\\.dict")
    }else if(lang == "EN"){
        utils::download.file("https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11858/00-097C-0000-0023-68D9-0/english-morphium-wsj-140407.zip",
                      destfile = here::here(dest_folder, "english-morphium-wsj-140407.zip"))
        utils::unzip(here::here(dest_folder, "english-morphium-wsj-140407.zip"),
                     exdir = dest_folder)
        list.files(here::here(dest_folder, remove_zip_suffix("english-morphium-wsj-140407.zip")),
                   full.names = TRUE,
                   pattern = "\\.tagger|\\.dict")
    }else{
        usethis::ui_stop("The language needs to be one of the following: 'CZ', 'SK', or 'EN'")
    }
}
