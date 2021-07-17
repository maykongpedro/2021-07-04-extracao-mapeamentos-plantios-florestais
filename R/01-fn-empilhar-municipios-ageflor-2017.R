#' empilhar_muni_ageflor_2017
#'
#' Descrição da função
#' Função utilizada para faxinar as tabelas de municípios do mapeamento da 
#' AGEFLOR - 2017.
#' 
#' @param tabela_municipios tabela dos municípios com duas colunas de muni e área
#' 
#' @return retorna uma tibble com os municípios empilhados em apenas uma coluna e
#' com uma só coluna de área

empilhar_muni_ageflor_2017 <-function(tabela_municipios){
    
    # separar as colunas de municípios entre diferentes bases
    muni_1 <- tabela_municipios %>% 
        dplyr::select(muni_1,area_1 )
    
    muni_2 <- tabela_municipios %>% 
        dplyr::select(muni_2, area_2) %>% 
        dplyr::rename(muni_1 = "muni_2",
                     area_1 = "area_2")
    
    # empilhar as duas bases de muni
    tab_final <- dplyr::bind_rows(muni_1, muni_2)
  
    # ajustar nomes
    tab_final %>% 
      dplyr::rename(area_ha = "area_1",
                    municipio = "muni_1")
  
}
