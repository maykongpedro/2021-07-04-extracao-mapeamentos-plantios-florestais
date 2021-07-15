

# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar pdfs -----------------------------------------------------------

# Estudo Setorial 2017-2018
# É a mesma tabela contida na base já organizada do SFB/IFPR, contida na pasta
# 'data': "./data/PR_IFPR_SFB_2015.rds"


# Estudo Setorial 2020
path_estudo_setorial_2020 <- "./data-raw/pdf/02-PR/01-APRE/apre_estudo_setorial_2020.pdf"

# Extraindo tabela
apre_est_set_2020 <- tabulizer::extract_tables(path_estudo_setorial_2020,
                                               method = "stream")

apre_est_set_2020

# Faxinar e organizar tabela do pdf ---------------------------------------

# variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")

apre_est_set_2020 %>% 
    purrr::pluck(1) %>% 
    tibble::as_tibble(.name_repair = "unique") %>% 
    dplyr::select(-c(5:7)) %>% 
    purrr::set_names(c("regiao", "nucleo_regional", "corte", "eucalipto_pinus")) %>% 
    dplyr::slice(-c(1:3)) %>% 
    dplyr::mutate(dplyr::across(dplyr::everything(),
                                dplyr::na_if, "")) %>%
    tidyr::fill(regiao) %>% 
    dplyr::filter(!nucleo_regional %in% c("TOTAL", "Subtotal")) %>% 
    tidyr::separate(col = eucalipto_pinus,
                    into = c("eucalipto", "pinus"),
                    sep = " ") %>% 
    dplyr::mutate(
        dplyr::across(.cols = corte:pinus,
                      readr::parse_number,locale = loc)
        ) %>% 
    tidyr::pivot_longer(cols = corte:pinus,
                        names_to = "genero",
                        values_to = "area_ha") %>% 
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "corte" ~ "Corte",
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            TRUE ~ genero
        )
    ) %>% 
    dplyr::mutate(
        fonte = "UFPR e APRE",
        mapeamento = "APRE - Estudo Setorial 2020",
        ano_base = "2019",
        uf = "PR",
        estado = "Paraná"
    ) %>% 
    
    dplyr::select(
        mapeamento,
        fonte,
        ano_base,
        uf,
        estado,
        regiao,
        nucleo_regional,
        genero,
        area_ha
    ) %>% 
    
    tibble::view()


    
    


# Salvar tabela final do pdf ----------------------------------------------

