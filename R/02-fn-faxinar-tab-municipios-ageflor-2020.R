#' faxinar_ageflor_2020_muni
#'
#' Descrição da função
#' Função utilizada para faxinar as tabelas de municípios (tabeles 4,6, 7 e 8) 
#' do mapeamento da AGEFLOR - 2020.
#' 
#' @param tabelas_extraidas tabela extraida do pdf pela função tabulizer::extract_tables
#' @param nome_tabela nome do tabela que será faxinada
#' 
#' @return retorna uma tibble organizada e faxinada com as informações das tabelas

faxinar_ageflor_2020_muni <-function(tabelas_extraidas, nome_tabela){
    
    loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")
    tab_completa <- tabelas_extraidas %>% 
        purrr::pluck(nome_tabela) %>%
        tibble::as.tibble(.name_repair = "unique") %>%
        janitor::row_to_names(1) %>%
        janitor::clean_names() %>% 
        dplyr::select(-x,- x_2) %>% 
        dplyr::filter(municipio != "Total") %>%
        dplyr::mutate(
            dplyr::across(.cols = c("area_ha", "area_ha_2"),
                          readr::parse_number, locale = loc)
        )
    
    # separar as colunas de municípios entre diferentes bases
    muni_1 <- tab_completa %>% 
        dplyr::select(municipio, area_ha)
    
    muni_2 <- tab_completa %>% 
        dplyr::select(municipio_cont, area_ha_2) %>% 
        dplyr::rename(municipio = "municipio_cont",
                      area_ha = "area_ha_2")
    
    # empilhar as duas bases de muni
    tab_final <- dplyr::bind_rows(muni_1, muni_2)
    
    # adicionar a info da tabela
    tab_final %>% 
        dplyr::mutate(
            genero = nome_tabela,
            genero = stringr::str_remove_all(genero, "muni_")
            )
    
}
