
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")


# Importar pdfs -----------------------------------------------------------

# AGEFLORESTA - Diagnóstico das Plantações Florestais em Mato Grosso - 2007

path_agefloresta_2007 <- "./data-raw/pdf/05-MT/agefloresta_diagnostico_plantacoes_florestais_2007.pdf"

# Extraindo infos da página 1 (pois o tabulizer não consegue achar nada)
agefloresta_2007_pg1 <- tabulizer::extract_text(path_agefloresta_2007,
                                                pages = 1)
    
    
agefloresta_2007_pg1


tabulizer::extract_tables(path_agefloresta_2007,
                          pages = 9,
                          method = "stream")

# pag 2 - ok
# pag 5 - nao pega o nome das cidades direito
# pag 6 - ficou zoado, mas da pra capturar algumas coisas
# pag 9 - nao pegou muita coisa nao




# FEMATO - Diagnóstico de Florestas Plantadas do Mato Grosso - 2013
path_femato_2013 <- "./data-raw/pdf/05-MT/femato_diagnostico_florestas_plantadas_2013.pdf"

# Extraindo tabela
femato_2013 <- tabulizer::extract_tables(path_femato_2013,
                                         method = "stream")

femato_2013



# Faxinar e organizar tabela do pdf - Femato 2013 -------------------------

# Manipular tabela - Página 1
pagina1_muni_2013 <- femato_2013 %>% 
    
    # pegar o item 1
    purrr::pluck(1) %>%

    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>% 
    
    # definir nomes das colunas
    purrr::set_names("regiao", "municipio", "eucalipto", "teca", "total") %>% 
    
    # retirar linhas desnecessárias
    dplyr::slice(-(1:2)) %>% 
    
    # retirar coluna desnecessária
    dplyr::select(-total) %>% 
    
    # ajustar tipo das colunas
    dplyr::mutate(
        
        # remover espaços entre os números
        dplyr::across(.cols = eucalipto:teca,
                      stringr::str_remove_all, pattern = " "),
        
        # transformar em númerico as colunas de áreas
        dplyr::across(.cols = eucalipto:teca,
                      readr::parse_number, locale = loc),
        
        # ajustar nome dos municípios (cada palavra com letra maiúscula)
        municipio = stringr::str_to_title(municipio)
    ) %>%
    
    # pivotar
    tidyr::pivot_longer(cols = eucalipto:teca,
                        names_to = "genero",
                        values_to = "area_ha")
    

# Conferir totais
pagina1_muni_2013 %>% 
    dplyr::group_by(municipio) %>% 
    dplyr::summarise(area = sum(area_ha, na.rm = TRUE)) %>% 
    tibble::view()


# Manipular tabela - Página 2
femato_2013 %>% 
    
    # pgar o item 2
    purrr::pluck(2) %>%  
    
    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>% 
    
    # definir nomes das colunas
    purrr::set_names("regiao", "municipio", "eucalipto", "teca", "total") %>% 
    
    # retirar coluna desnecessária
    dplyr::select(-total) %>% 
    
    # ajustar tipo das colunas
    dplyr::mutate(
        
        # remover espaços entre os números
        dplyr::across(.cols = eucalipto:teca,
                      stringr::str_remove_all, pattern = " "),
        
        # transformar em númerico as colunas de áreas
        dplyr::across(.cols = eucalipto:teca,
                      readr::parse_number, locale = loc),
        
        # ajustar nome dos municípios (cada palavra com letra maiúscula)
        municipio = stringr::str_to_title(municipio)
    ) %>% 
    
    tibble::view()

    # pivotar
    tidyr::pivot_longer(cols = eucalipto:teca,
                        names_to = "genero",
                        values_to = "area_ha")





# Salvar tabela final do pdf ----------------------------------------------
