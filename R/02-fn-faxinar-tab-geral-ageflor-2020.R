#' faxinar_ageflor_2020_geral
#'
#' Descrição da função
#' Função utilizada para faxinar as tabelas gerais (tabela 1 e 2) do mapeamento
#' da AGEFLOR - 2020.
#' 
#' @param tabelas_extraidas tabela extraida do pdf pela função tabulizer::extract_tables
#' @param nome_tabela nome do tabela que será faxinada
#' 
#' @return retorna uma tibble organizada e faxinada com as informações das tabelas

faxinar_ageflor_2020_geral <-function(tabelas_extraidas, nome_tabela){
    
    loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")
    tabelas_extraidas %>% 
        purrr::pluck(nome_tabela) %>% 
        tibble::as_tibble(.name_repair = "unique") %>%
        janitor::row_to_names(1) %>%
        janitor::clean_names() %>%
        dplyr::mutate(dplyr::across(.cols = 2:5,
                                    readr::parse_number, locale = loc))
    
}