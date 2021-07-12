

# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, readr tabulizer, purrr, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar pdfs -----------------------------------------------------------

# Obter caminho do pdf
filepath_iba_relatorio_2020 <- "data-raw/pdf/01-Brasil/01-IBA/relatorio_iba_2020.pdf"


# Extrair tableas das páginas
iba_relatorio_2020  <- tabulizer::extract_tables(filepath_iba_relatorio_2020,
                                                 method = "stream")


# Faxinar e organizar tabela - Eucalipto ----------------------------------

# exibir números sem notação científica
options(scipen = 999)

# variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")


tbl_iba_eucalito <- iba_relatorio_2020 %>% 
    
    # obter apenas o primeiro item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>% 
    
    # deletar as duas colunas iniciais
    dplyr::select(-c(1,2)) %>% 
    
    # deletar a primeira linha
    dplyr::slice(-1) %>% 
    
    # transformar a primeira linha em nome da coluna
    janitor::row_to_names(row_number = 1) %>% 
    
    # ajustar nomes das colunas
    janitor::clean_names() %>% 

    # ajustar primeira coluna
    dplyr::mutate(

        # extrair somente os números de 2009
        x2009 = stringr::str_remove_all(state_2009, "[:alpha:]"),
        
        # deixar somente as letras na coluna
        state_2009 = stringr::str_remove_all(state_2009, "[0-9]|\\."),
        
        # ajustar nome dos estados
        state_2009 = dplyr::case_when(
            state_2009 == "Mato Grosso  " ~ "Mato Grosso do Sul",
            state_2009 == "Rio Grande  " ~ "Rio Grande do Sul",
            state_2009 == " Santo" ~ "Espiríto Santo",
            state_2009 == " Santo" ~ "Espiríto Santo",
            TRUE ~ state_2009),
        
        # retirar nomes sem sentido
        state_2009 = dplyr::case_when(
            state_2009 == "do Sul" ~ NA_character_,
            state_2009 == "Espírito" ~ NA_character_,
            state_2009 == "Santa" ~ NA_character_,
            state_2009 == "Catarina" ~ NA_character_,
            state_2009 == "Outros*" ~ NA_character_,
            state_2009 == "Other*" ~ NA_character_,
            TRUE ~ state_2009),
        
        # cria um identificador para cada linha
        id = dplyr::row_number(),
        
        # ajusta estado da linha 18 e 22
        state_2009 = dplyr::case_when(
            id == 18 ~ "Santa Catarina",
            id == 22 ~ "Outros",
            TRUE ~ state_2009
        )
        
    ) %>% 
        
    # substituir o que é vazio por NA
    dplyr::mutate(dplyr::across(dplyr::everything(),
                                dplyr::na_if, "")) %>% 
    
    # substitui o NA do Paraná em 2019 para não perder a linha
    dplyr::mutate(
        x2019 = dplyr::case_when(
            state_2009 == "Paraná" ~ "266.473",
            TRUE ~ x2019)
        ) %>% 
    
    # retirar as linhas com NA
    tidyr::drop_na() %>% 
    
    # remover coluna de id
    dplyr::select(-id) %>% 
    
    # transpor base para ajustar linha 1
    t() %>%
    
    # converter novamente em tibble
    tibble::as_tibble(rownames = "nome_colunas") %>%
    
    # separar coluna que representa a linha 1
    tidyr::separate(col = 2,
                    into = c("mg", "sp"),
                    sep = " ") %>% 
    
    # transpor novamente
    t() %>% 
    
    # converter em tibble
    tibble::as_tibble() %>% 
    
    # ajustar nome das colunas
    janitor::row_to_names(row_number = 1) %>% 

    # ajustar nomes dos estados
    dplyr::mutate(
        state_2009 = dplyr::case_when(
            state_2009 == "Minas" ~ "Minas Gerais",
            state_2009 == "Gerais" ~ "São Paulo",
            TRUE ~ state_2009),
        
        state_2009 = stringr::str_squish(state_2009)
    ) %>% 
    
    # re-organizar ordem das colunas
    dplyr::relocate(x2009, .before = "x2010") %>% 
    
    # ajustar tipos das colunas
    dplyr::mutate(
        dplyr::across(.cols = x2009:x2019,
                      readr::parse_number, locale = loc)
    ) %>% 
    
    # preencher manualmente o que se perdeu na extração
    dplyr::mutate(
        x2009 = dplyr::case_when(
            state_2009 == "Minas Gerais" ~ 1300000,
            state_2009 == "São Paulo" ~ 1029670,
            TRUE ~ x2009
        ),
        
        x2019 = dplyr::case_when(
            state_2009 == "Minas Gerais" ~ 1920329,
            state_2009 == "São Paulo" ~ 1215901,
            TRUE ~ x2019
        )
    ) %>% 

    # retirar linha de total
    dplyr::filter(state_2009 != "Total") %>% 
    
    # renomear coluna de estado
    dplyr::rename(estado = "state_2009") %>% 
    
    # pivotar base
    tidyr::pivot_longer(cols = x2009:x2019,
                        names_to = "anos",
                        values_to = "area_ha") %>% 
    
    # retirar o "x" dos anos
    dplyr::mutate(
        anos = stringr::str_remove_all(anos, "x"),
        anos = as.double(anos)
        ) %>% 
    
    # adicionar coluna identificadora de gênero
    dplyr::mutate(genero = "Eucalyptus")


# Conferir o somatório dos anos
tbl_iba_eucalito %>% 
    dplyr::group_by(anos) %>% 
    dplyr::summarise(area_total = sum(area_ha))



# Faxinar e organizar tabela - Pinus --------------------------------------

tbl_iba_pinus<- iba_relatorio_2020 %>% 
    
    # obter apenas o segundo item da lista
    purrr::pluck(2) %>% 
    
    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>%
    
    # selecionar as colunas que são da tabela de pinus
    dplyr::select(1:9, 11) %>% 
    
    # transformar a primeira linha em nome da coluna
    janitor::row_to_names(row_number = 1) %>% 
    
    # ajustar nomes das colunas
    janitor::clean_names() %>% 
    
    # selecionar apenas as linhas correspondentes à tabela
    dplyr::slice(1:12) %>% 
    
    # substituir o que é vazio por NA
    dplyr::mutate(dplyr::across(dplyr::everything(),
                                dplyr::na_if, "")) %>% 
    
    # retirar as linhas com NA
    tidyr::drop_na() %>%
    
    # renomear coluna de estado
    dplyr::rename(estado = "estado_state_2009") %>% 
    
    # separar coluna do estado
    dplyr::mutate(
        x2009 = stringr::str_remove_all(estado, "[:alpha:]|\\*|\\|"),
        estado = stringr::str_remove_all(estado, "[0-9]|\\.")
    ) %>% 
    
    # separar coluna de 2011 e 2012
    tidyr::separate(col = "x2011_2012",
                    into = c("x2011", "x2012"),
                    sep = " ") %>% 
    
    # re-organizar ordem das colunas
    dplyr::relocate(x2009, .before = "x2010") %>% 
    
    # ajustar nome de outros
    dplyr::mutate(
        estado = dplyr::case_when(
            estado == "Outros* | Other* " ~ "Outros",
            TRUE ~ estado
        )
    ) %>% 
    
    # ajustar tipos das colunas
    dplyr::mutate(
        dplyr::across(.cols = x2009:x2019,
                      readr::parse_number, locale = loc)
    ) %>% 
    
    # pivotar base
    tidyr::pivot_longer(cols = x2009:x2019,
                        names_to = "anos",
                        values_to = "area_ha") %>% 
    
    # retirar o "x" dos anos
    dplyr::mutate(
        anos = stringr::str_remove_all(anos, "x"),
        anos = as.double(anos)
    ) %>% 

    # adicionar coluna identificadora de gênero
    dplyr::mutate(genero = "Pinus")


# Conferir o somatório dos anos
tbl_iba_pinus %>% 
    dplyr::group_by(anos) %>% 
    dplyr::summarise(area_total = sum(area_ha))



# Faxinar e organizar tabela - Outros -------------------------------------

#tbl_iba_outros<-
    iba_relatorio_2020 %>% 
    
    # obter apenas o terceiro item da lista
    purrr::pluck(3) 

