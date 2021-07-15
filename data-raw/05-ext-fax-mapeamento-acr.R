
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar pdfs -----------------------------------------------------------

# ACR - ANUÁRIO ESTATÍSTICO 2019
path_acr_2019 <- "./data-raw/pdf/03-SC/acr_anuario_estatistico_2019.pdf"

# Extraindo tabela
acr_anuario_2019 <- tabulizer::extract_tables(path_acr_2019,
                                              method = "stream")

acr_anuario_2019


# Faxinar e organizar tabela do pdf ---------------------------------------

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")

# Manipular tabela
tbl_acr_anuario_2019 <- acr_anuario_2019 %>%
    
    # selecionar o item da lista
    purrr::pluck(1) %>%
    
    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>%
    
    # deletar as colunas desnecessárias
    dplyr::select(-c(4:5)) %>% 
    
    # nomear as colunas restantes
    purrr::set_names(c("regiao", "pinus", "eucalipto")) %>% 
    
    # deletar as linhas iniciais
    dplyr::slice(-c(1:3)) %>% 
    
    # retirar total
    dplyr::filter(regiao != "TOTAL") %>% 
    
    # corrigir tipo das colunas
    dplyr::mutate(
        dplyr::across(.cols = pinus:eucalipto,
                      readr::parse_number,locale = loc)
    ) %>% 
    
    # pivotar
    tidyr::pivot_longer(cols = pinus:eucalipto,
                        names_to = "genero",
                        values_to = "area_ha") %>% 
    
    # corrigir nome dos gêneros
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            TRUE ~ genero
        )
    ) %>% 
    
    # adicionar colunas extras
    dplyr::mutate(
        fonte = "UDESC-CAV e ACR",
        mapeamento = "ACR - Anuário Estatistico 2019",
        ano_base = "2018",
        uf = "SC",
        estado = "Santa Catarina"
    ) %>% 
    
    # padronizar a ordem
    dplyr::select(
        mapeamento,
        fonte,
        ano_base,
        uf,
        estado,
        regiao,
        genero,
        area_ha
    ) 
    

# Conferir totais
tbl_acr_anuario_2019 %>% 
    dplyr::group_by(genero) %>% 
    dplyr::summarise(total = sum(area_ha))


# Salvar tabela final do pdf ----------------------------------------------
tbl_acr_anuario_2019 %>% saveRDS("./data/SC_ACR_UDESC-CAV_2019.RDS")

