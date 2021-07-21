

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

tbl_apre_2020 <- apre_est_set_2020 %>% 
    
    # selecionar o item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>% 
    
    # deletar as colunas desnecessárias
    dplyr::select(-c(5:7)) %>% 
    
    # nomear as colunas restantes
    purrr::set_names(c("regiao", "nucleo_regional", "corte", "eucalipto_pinus")) %>% 
    
    # deletar as linhas iniciais
    dplyr::slice(-c(1:3)) %>% 
    
    # substituir em branco por NA
    dplyr::mutate(dplyr::across(dplyr::everything(),
                                dplyr::na_if, "")) %>%
    
    # preencher região baseado no item acima de cada linha
    tidyr::fill(regiao) %>% 
    
    # retirar total e subtotal
    dplyr::filter(!nucleo_regional %in% c("TOTAL", "Subtotal")) %>% 
    
    # separar colunas de euc e pin
    tidyr::separate(col = eucalipto_pinus,
                    into = c("eucalipto", "pinus"),
                    sep = " ") %>% 
    
    # corrigir tipo das colunas
    dplyr::mutate(
        dplyr::across(.cols = corte:pinus,
                      readr::parse_number,locale = loc)
        ) %>% 
    
    # pivotar
    tidyr::pivot_longer(cols = corte:pinus,
                        names_to = "genero",
                        values_to = "area_ha") %>% 
    
    # corrigir nome dos gêneros
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "corte" ~ "Corte",
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            TRUE ~ genero
        )
    ) %>% 
    
    # adicionar colunas extras
    dplyr::mutate(
        fonte = "UFPR e APRE",
        mapeamento = "APRE - Estudo Setorial 2020",
        ano_base = "2019",
        uf = "PR",
        estado = "Paraná"
    ) %>% 
    
    
    # padronizar a ordem
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
    ) 


# Conferindo totais por região
tbl_apre_2020 %>% 
    dplyr::group_by(regiao) %>% 
    dplyr::summarise(total = sum(area_ha, na.rm = TRUE))
    


# Salvar tabela final do pdf ----------------------------------------------
tbl_apre_2020 %>%  saveRDS("./data/PR_APRE_UFPR_2020.RDS")
