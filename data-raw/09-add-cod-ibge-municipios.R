
# 00 - Carregar e instalar pacotes ----------------------------------------
# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, geobr)

# Carregar pipe
'%>%' <- magrittr::`%>%`
    

# Importando bases organizadas --------------------------------------------

base_ibge <- readr::read_rds("./data/BR_IBGE_SNIF_HISTORICO_MUNICIPIOS_2014_2016.RDS")
base_famato_2013 <- readr::read_rds("data/MT_FAMATO_MUNICIPIOS_2013.RDS")
base_ageflor_2017 <- readr::read_rds("data/RS_AGEFLOR_MUNICIPIOS_2017.RDS")
base_ageflor_2020 <- readr::read_rds("data/RS_AGEFLOR_MUNICIPIOS_2020.RDS")


# Importando base do IBGE -------------------------------------------------
base_muni <- geobr::read_municipality()

base_muni_rs_mg <- base_muni %>% 
    tibble::tibble() %>% 
    dplyr::select(-geom) %>% 
    dplyr::rename(uf = "abbrev_state",
                  municipio = "name_muni") %>% 
    dplyr::filter(uf %in% c("RS", "MT")) 

base_muni_rs_mg



# Adicionando código município - Mapeamento IBGE - 2014 até 2016 ----------
# Fazer join
famato_2013 <- mapeamentos_municipios %>% 
    purrr::pluck(1) %>% 
    dplyr::left_join(base_muni_rs_mg) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

# Verificar itens não encontrados
famato_2013 %>% 
    dplyr::filter(is.na(code_muni)) 



# Adicionando código município - Mapeamento FAMATO - 2013  ---------------
# Fazer join
famato_2013 <- mapeamentos_municipios %>% 
    purrr::pluck(1) %>% 
    dplyr::left_join(base_muni_rs_mg) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

# Verificar itens não encontrados
famato_2013 %>% 
    dplyr::filter(is.na(code_muni)) 



# Adicionando código município - Mapeamento AGEFLOR - 2017  ---------------
# Fazer join
ageflor_2017 <- mapeamentos_municipios %>% 
    purrr::pluck(2) %>% 
    dplyr::mutate(municipio = stringr::str_to_title(municipio)) %>% 
    dplyr::left_join(base_muni_rs_mg) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

ageflor_2017


# Verificar itens não encontrados
ageflor_2017 %>% 
    dplyr::filter(is.na(code_muni))



# Adicionando código município - Mapeamento AGEFLOR - 2020  ---------------
# Fazer join
ageflor_2020 <- mapeamentos_municipios %>% 
    purrr::pluck(3) %>% 
    dplyr::mutate(municipio = stringr::str_to_title(municipio)) %>% 
    dplyr::left_join(base_muni_rs_mg) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

ageflor_2020


# Verificar itens não encontrados
ageflor_2017 %>% 
    dplyr::filter(is.na(code_muni))



# Salvar bases ------------------------------------------------------------

famato_2013 %>% saveRDS("./data/MT_FAMATO_MUNICIPIOS_2013_COD-IBGE.RDS")
ageflor_2017 %>% saveRDS("./data/RS_AGEFLOR_MUNICIPIOS_2017_COD-IBGE.RDS")
ageflor_2020 %>% saveRDS("./data/RS_AGEFLOR_MUNICIPIOS_2020_COD-IBGE.RDS")

