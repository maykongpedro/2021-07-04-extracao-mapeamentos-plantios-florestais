
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar pdfs -----------------------------------------------------------

# AGEFLOR - A Indústria de Base Florestal no RS - 2017
# Nesse relatório as tabelas estão como imagens
path_ageflor_2017 <- "./data-raw/pdf/04-RS/ageflor_setor_florestal_2017.pdf"

# Extraindo infos
ageflor_2017 <- pdftools::pdf_ocr_text(path_ageflor_2017)
cat(ageflor_2017)


# AGEFLOR - A Indústria de Base Florestal no RS - 2020
path_ageflor_2020 <- "./data-raw/pdf/04-RS/ageflor_setor_florestal_2020.pdf"

# Extraindo tabela
ageflor_2020 <- tabulizer::extract_tables(path_ageflor_2020,
                                          method = "lattice")
ageflor_2020



# Faxinar e organizar tabela do pdf - 2017 --------------------------------

# Manipular tabela
# Para resolver essas faxinas com stringr recorri à ajuda no fórum da curso R:
# https://discourse.curso-r.com/t/acesso-ao-curso-deploy-com-r/1413
tbl_geral_ageflor_2017 <- ageflor_2017 %>% 
    
    purrr::pluck(1) %>% 
    
    # dotall para permitir que o ponto capture qualquer coisa, inclusiva o \n
    stringr::str_extract(stringr::regex("Tabela [0-9.]+.+", dotall = TRUE)) %>% 
    
    # separar cada linha gerando uma lista
    stringr::str_split("\n") %>% 
    
    # pegar o item da lista
    purrr::pluck(1) %>% 
    
    # substituir ponto por vírgula por conta do total em 2012 que atrapalha o regex
    purrr::map(stringr::str_replace, "\\.", ",") %>% 
    
    # substituir o "colchentes" em 2014 por 1 para não atraplhar o regex e corrigir  o número
    purrr::map(stringr::str_replace, "\\]", "1") %>% 
    
    # capturar apenas os números
    # ^ -> Match at the beginning of a line.
    # + -> Match 1 or more times. Match as many times as possible.
    # ^[0-9,]+ -> tudo que começa com número e os números que vem depois
    # [0-9, ]+$ -> tudo o que termina com número e os números que vem depois
    stringr::str_subset("^[0-9,]+ [0-9, ]+$") %>% 
    
    # separar cada item por espaço, para gerar as colunas
    purrr::map(stringr::str_split, " ") %>% 
    
    # pegar cada sub-item gerado
    purrr::map(purrr::pluck, 1) %>% 
    
    # substituir vírgula por ponto
    purrr::map(stringr::str_replace, ",", ".") %>% 
    
    # transpor cada item em uma nova lista
    purrr::transpose() %>% 
    
    # formatar tudo como número
    purrr::map(as.numeric) %>%
    
    # definir nomes das colunas
    purrr::set_names("ano", "eucalipto", "pinus", "acacia", "total") %>% 
    
    # transformar em tibble
    dplyr::as_tibble() %>% 
    
    # ajustar o ano de 2008 manualmente (número veio errado)
    dplyr::mutate(
        eucalipto = dplyr::case_when(ano == 2008 ~ 277.3,
                                     TRUE ~ eucalipto)
    ) %>% 
        
    # retirar coluna de total
    dplyr::select(-total) %>% 
    
    # pivotar
    tidyr::pivot_longer(cols = eucalipto:acacia,
                        names_to = "genero",
                        values_to = "area_ha") %>% 
    
    # multiplicar por mil para ficar em hectares únicos
    dplyr::mutate(area_ha = area_ha*1000)

tbl_geral_ageflor_2017


# Conferir totais
tbl_geral_ageflor_2017 %>% 
    dplyr::group_by(ano) %>% 
    dplyr::summarise(total = sum(area_ha))



# Faxinar e organizar tabela do pdf - 2020 --------------------------------

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")



# Salvar tabela final do pdf ----------------------------------------------
