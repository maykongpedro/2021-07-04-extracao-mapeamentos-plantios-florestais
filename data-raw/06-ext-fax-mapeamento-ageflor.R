
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



# Faxinar e organizar tabela do pdf - 2017 - Tabela Geral -----------------

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



# Faxinar e organizar tabela do pdf - 2017 - Tabela Coredes ---------------

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")

tbl_coredes_ageflor_2017 <- ageflor_2017 %>% 
    
    purrr::pluck(2) %>%
    
    # dotall para permitir que o ponto capture qualquer coisa, inclusiva o \n
    stringr::str_extract(stringr::regex("Tabela [0-9.]+.+", dotall = TRUE)) %>% 
    
    # separar cada linha gerando uma lista
    stringr::str_split("\n") %>% 
    
    # pegar o item da lista
    purrr::pluck(1) %>% 
    
    # capturar apenas os números
    stringr::str_subset("[0-9.]+ [0-9. ]+$") %>% 
    
    # pegar cada sub-item gerado
    purrr::map(purrr::pluck, 1) %>% 
    
    # transformar em tibble
    dplyr::as_tibble(.name_repair = "unique") %>% 
    
    # pivotar
    tidyr::pivot_longer(cols = dplyr::everything(), 
                        names_to = "trash",
                        values_to = "colunas") %>% 
    
    # gerar coluna com apenas os números e coredes
    dplyr::mutate(
        areas = stringr::str_remove_all(colunas, "[:alpha:]"),
        areas = stringr::str_squish(areas),
        corede = colunas,
        corede = stringr::str_remove_all(corede, "[0-9]|\\."),
        corede = stringr::str_squish(corede)
        
    ) %>% 
    
    # separar colunas dos números
    tidyr::separate(col = areas,
                   into =  c("eucalipto", "pinus", "acacia", "total"),
                   sep = " ") %>% 
    
    # remover colunas desncessárias
    dplyr::select(-trash,
                 -colunas,
                 -total) %>% 
    
    # ajustando tipo das colunas
    dplyr::mutate(
        dplyr::across(.cols = eucalipto:acacia,
                      readr::parse_number,locale = loc)
    ) %>% 
    
    # muitos valores ficaram zoados por conta da quebra de linha de um corede
    # terei que ajusar manualmente
    dplyr::mutate(
        
        eucalipto = dplyr::case_when(
            corede == "Centro-Sul" ~ 80292,
            corede == "Campanha" ~ 33261,
            corede == "Jaculi-centro" ~ 16000,
            TRUE ~ eucalipto
        ),
        
        pinus = dplyr::case_when(
            corede == "Centro-Sul" ~ 4567,
            corede == "Jaculi-centro" ~ 8825,
            TRUE ~ pinus
        ),
        
        acacia = dplyr::case_when(
            corede == "Centro-Sul" ~ 11032,
            corede == "Jaculi-centro" ~ 658,
            TRUE ~ acacia
        ),
        
        corede = dplyr::case_when(
            corede == "Jaculi-centro" ~ "Jacuí-centro",
            corede == "Vale do Cai -" ~ "Vale do Caí",
            TRUE ~ corede
        )
        
    )


# adicionar coredes faltantes que não foram identificados por conta das quebras
# de linha
coredes_faltantes <- tibble::tribble(
                          ~corede, ~eucalipto, ~pinus, ~acacia,
         "Campos de Cima da Serra",      1024L, 42116L,      NA,
    "Metropolitano Delta do Jacuí",     30533L,  4384L,   7169L
    )

# empilhar
tbl_coredes_ageflor_2017_completa <- tbl_coredes_ageflor_2017 %>% 
    dplyr::relocate(corede, .before = eucalipto) %>% 
    dplyr::bind_rows(coredes_faltantes) %>% 
    tidyr::pivot_longer(cols = eucalipto:acacia,
                       names_to = "genero",
                       values_to = "area_ha")


tbl_coredes_ageflor_2017_completa %>% tibble::view()

# verificar totais
tbl_coredes_ageflor_2017_completa %>% 
    dplyr::group_by(corede) %>% 
    dplyr::summarise(area = sum(area_ha, na.rm = TRUE))


# Faxinar e organizar tabela do pdf - 2020 --------------------------------





# Salvar tabela final do pdf ----------------------------------------------
