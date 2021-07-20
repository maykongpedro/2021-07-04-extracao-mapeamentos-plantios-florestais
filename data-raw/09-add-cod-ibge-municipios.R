
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

base_muni <- base_muni %>% 
    tibble::tibble() %>% 
    dplyr::select(-geom) %>% 
    dplyr::rename(uf = "abbrev_state",
                  municipio = "name_muni")

base_muni


# Adicionando código município - Mapeamento IBGE - 2014 até 2016 ----------
# Fazer join
ibge_historico <- base_ibge %>% 
    dplyr::mutate(
        municipio = stringr::str_to_title(municipio),
        municipio = stringr::str_remove_all(municipio, "Ro$"),
        municipio = stringr::str_remove_all(municipio, "To$"),
        municipio = stringr::str_remove_all(municipio, "Mg$"),
        municipio = stringr::str_remove_all(municipio, "Rj$"),
        municipio = stringr::str_remove_all(municipio, "Pr$"),
        municipio = stringr::str_remove_all(municipio, "Rs$"),
        municipio = stringr::str_remove_all(municipio, "Ma$"),
        municipio = stringr::str_squish(municipio)
    ) %>% 
    dplyr::left_join(base_muni) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

# Verificar itens não encontrados
ibge_historico %>% 
    dplyr::filter(is.na(code_muni)) %>% 
    dplyr::distinct(uf, municipio) %>% 
    print(n=100)

# Preencher manualmente código dos itens não encontrados
ibge_historico_fim <- ibge_historico %>% 
    dplyr::mutate(
        code_muni = dplyr::case_when(
            municipio == "Serra Caiada" & uf == "RN" ~ 2410306,
            municipio == "Brazópolis" & uf == "MG" ~3108909,
            municipio == "Goiana" & uf == "MG" ~ 3127388,
            municipio == "Passa Vinte" & uf == "MG" ~ 3147808,
            municipio == "Pingo D'água" & uf == "MG" ~ 3150539,
            municipio == "Biritiba Mirim" & uf == "SP" ~ 3506607,
            municipio == "São Luiz Do Paraitinga" & uf == "SP" ~ 3550001,
            municipio == "Mogi Mirim" & uf == "SP" ~ 3530805,
            municipio == "Florínea" & uf == "SP" ~ 3516101,
            municipio == "Arapuá" & uf == "PR" ~ 4101655,
            municipio == "Ipirá" & uf == "SC" ~ 4207601,
            municipio == "Pescaria Brava" & uf == "SC" ~ 4212650,
            municipio == "Balneário Rincão" & uf == "SC" ~ 4220000,
            municipio == "Maraú" & uf == "RS" ~ 4311809,
            municipio == "Pinto Bandeira" & uf == "RS" ~ 4314548,
            municipio == "Paraíso Das Águas" & uf == "MS" ~ 5006275,
            TRUE ~ code_muni
        ),
        
        municipio = dplyr::case_when(
            municipio == "Arapuá" & uf == "PR" ~ "Arapuã",
            TRUE ~ municipio
        )
        
    ) 



# Verificar itens não encontrados (novamente)
ibge_historico_fim %>% 
    dplyr::filter(is.na(code_muni)) 

# Todos precisam ter 9 itens
ibge_historico_fim %>% 
    dplyr::group_by(code_muni, municipio, uf) %>% 
    dplyr::summarise( n= dplyr::n()) %>% 
    dplyr::filter(n != 9)



# Adicionando código município - Mapeamento FAMATO - 2013  ---------------
# Fazer join
famato_2013 <- base_famato_2013 %>% 
    dplyr::left_join(base_muni) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

# Verificar itens não encontrados
famato_2013 %>% 
    dplyr::filter(is.na(code_muni)) 



# Adicionando código município - Mapeamento AGEFLOR - 2017  ---------------
# Fazer join
ageflor_2017 <- base_ageflor_2017 %>% 
    dplyr::mutate(municipio = stringr::str_to_title(municipio)) %>% 
    dplyr::left_join(base_muni) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

ageflor_2017


# Verificar itens não encontrados
ageflor_2017 %>% 
    dplyr::filter(is.na(code_muni))



# Adicionando código município - Mapeamento AGEFLOR - 2020  ---------------
# Fazer join
ageflor_2020 <- base_ageflor_2020 %>% 
    dplyr::mutate(municipio = stringr::str_to_title(municipio)) %>% 
    dplyr::left_join(base_muni) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

ageflor_2020


# Verificar itens não encontrados
ageflor_2017 %>% 
    dplyr::filter(is.na(code_muni))



# Salvar bases ------------------------------------------------------------

ibge_historico_fim %>% saveRDS("./data/BR_IBGE_SNIF_HISTORICO_MUNICIPIOS_2014_2016_COD-IBGE.RDS")
famato_2013 %>% saveRDS("./data/MT_FAMATO_MUNICIPIOS_2013_COD-IBGE.RDS")
ageflor_2017 %>% saveRDS("./data/RS_AGEFLOR_MUNICIPIOS_2017_COD-IBGE.RDS")
ageflor_2020 %>% saveRDS("./data/RS_AGEFLOR_MUNICIPIOS_2020_COD-IBGE.RDS")

