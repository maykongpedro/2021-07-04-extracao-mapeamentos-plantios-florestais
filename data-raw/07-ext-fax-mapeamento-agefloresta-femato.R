
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")


# Importar pdfs -----------------------------------------------------------

# Famato - Diagnóstico de Florestas Plantadas do Mato Grosso - 2013
path_famato_2013 <- "./data-raw/pdf/05-MT/famato_diagnostico_florestas_plantadas_2013.pdf"


# Extraindo tabela
famato_2013 <- tabulizer::extract_tables(path_famato_2013,
                                         method = "stream")

famato_2013

# Página 3 só funciona capturando o texto
famato_2013_pag3 <- tabulizer::extract_text(path_famato_2013,
                                            pages = 3)


# Faxinar e organizar tabela do pdf - Famato 2013 - Pag1 ------------------

# Manipular tabela - Página 1
pagina1_muni_2013 <- famato_2013 %>% 
    
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



# Faxinar e organizar tabela do pdf - Famato 2013 - Pag2 ------------------

# Manipular tabela - Página 2
pagina2_muni_2013 <- famato_2013 %>% 
    
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
    
    # retirar linha que ficou com erro
    dplyr::filter(regiao != "") %>% 
    
    # corrigir esse município
    dplyr::mutate(
        municipio = dplyr::case_when(
            municipio == "Livramento" ~ "Nossa Senhora Do Livramento",
            TRUE ~ municipio)
    ) %>% 

    # pivotar
    tidyr::pivot_longer(cols = eucalipto:teca,
                        names_to = "genero",
                        values_to = "area_ha")


# Conferir totais
pagina2_muni_2013 %>% 
    dplyr::group_by(municipio) %>% 
    dplyr::summarise(area = sum(area_ha, na.rm = TRUE)) %>% 
    tibble::view()


# Faxinar e organizar tabela do pdf - Famato 2013 - Pag3 ------------------

# Manipular tabela - Página 3
pagina3_muni_2013 <- famato_2013_pag3 %>% 
    
    purrr::pluck(1) %>% 
    
    # retirar cada "\r"
    stringr::str_remove_all("\\\r") %>% 
    
    # separar cada linha gerando uma lista
    stringr::str_split("\n") %>% 
    
    # pegar o item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    dplyr::as_tibble(.name_repair = "unique") %>% 
    
    # retirar primeiras linhas
    dplyr::slice(-(1:5)) %>% 
    
    # renomear coluna
    dplyr::rename(muni_valores = "value") %>% 
    
    # separar nomes e números
    dplyr::mutate(
        
        # remover letras
        areas = stringr::str_remove_all(muni_valores, "[:alpha:]"),
        
        # retirar espaços desnecessários
        areas = stringr::str_squish(areas),
        
        # remover números
        regioes_muni = stringr::str_remove_all(muni_valores, "[0-9,.]"),
        
        # retirar espaços desnecessários
        regioes_muni = stringr::str_squish(regioes_muni),
        
        # extrair somente os municípios
        municipio = stringr::str_extract(regioes_muni, "[A-Z\u00C0-\u00DD ]+$"),
        
        # remover os municípios para obter somente as regiões
        regiao = stringr::str_remove(regioes_muni, municipio),
        
        # deixar apenas com a primeira letra da palavra em caixa alta
        municipio = stringr::str_to_title(municipio),
        
        # limpar espaços desnecessários
        municipio = stringr::str_squish(municipio),
        
        # substituir vazio por NA
        dplyr::across(dplyr::everything(),
                      dplyr::na_if,  ""
        )
            
        
    ) %>% 
    
    # retirar colunas auxiliares
    dplyr::select(-muni_valores,-regioes_muni) %>% 
    
    # separar números
    tidyr::separate(col = "areas",
                    into = c("eucalipto", "teca", "total"),
                    sep = " ") %>% 
    
    # realocar
    dplyr::select(regiao,
                  municipio,
                  eucalipto,
                  teca,
                  total) %>% 
    
    # remover linhas completamente vazias
    janitor::remove_empty("rows") %>% 
    
    # ajustes manuais
    dplyr::mutate(
        
        # ajustar nome dos municípios com quebra de linha na tab. original
        municipio = dplyr::case_when(
            municipio == "Leverger" ~ "Santo Antônio Do Lerverger",
            municipio == "Marcos" ~ "Sao José Dos Quatro Marcos",
            municipio == "Trindade" ~ "Vila Bela Da Santíssima Trindade",
            TRUE ~ municipio
        ),
        
        # ajustar regiões faltantes
        regiao = dplyr::case_when(
            municipio == "Santo Antônio Do Lerverger" ~ "Centro-Sul",
            municipio == "Sao José Dos Quatro Marcos" ~ "Oeste",
            municipio == "Vila Bela Da Santíssima Trindade" ~ "Oeste",
            TRUE ~ regiao
        ),

        # ajustar números do eucalipto
        eucalipto = dplyr::case_when(
            is.na(teca) ~ eucalipto,
            eucalipto == teca ~ eucalipto,
            eucalipto == "-" ~ teca,
            TRUE ~ eucalipto
        ),
        
        # ajustar números da teca
        teca = dplyr::case_when(
            teca == eucalipto ~ NA_character_,
            TRUE ~ teca
        ),
        
        # preencher números faltantes da teca
        teca = dplyr::case_when(
            is.na(teca) ~ total,
            TRUE ~ teca
        )
    
    ) %>% 
    
    # retirar linhas com NA
    dplyr::filter(!is.na(regiao)) %>% 
    
    # retirar coluna de total
    dplyr::select(-total) %>% 
    
    # pivotar
    tidyr::pivot_longer(cols = eucalipto:teca,
                        names_to = "genero",
                        values_to = "area_ha") %>% 
    
    # corrigir tipo das colunas
    dplyr::mutate(
        area_ha = readr::parse_number(area_ha, locale = loc)
    ) 


# Conferir totais
pagina3_muni_2013 %>% 
    dplyr::group_by(municipio) %>% 
    dplyr::summarise(area = sum(area_ha, na.rm = TRUE)) %>% 
    tibble::view()



# Unir tabelas de municípios - Famato 2013 --------------------------------

# Empilhar dados
tab_muni_2013_completa <- pagina1_muni_2013 %>% 
    dplyr::bind_rows(pagina2_muni_2013) %>% 
    dplyr::bind_rows(pagina3_muni_2013) 


# Adicionar infoss complementares
tab_muni_2013_fim <- tab_muni_2013_completa %>% 
    dplyr::mutate(
        fonte = "Imea",
        mapeamento = "Famato - Diagnóstico de florestas plantadas do Estado de Mato Grosso - 2013",
        ano_base = "2012",
        uf = "MT",
        estado = "Mato Grosso"
    ) %>% 
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "teca" ~ "Tectona",
            TRUE ~ genero
        )
    ) %>% 
    
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  municipio,
                  genero,
                  area_ha) 

# Conferir totais
tab_muni_2013_fim %>% 
    dplyr::group_by(genero) %>% 
    dplyr::summarise(area = sum(area_ha, na.rm = TRUE)) %>% 
    tibble::view()


# Salvar tabela final do pdf ----------------------------------------------
tab_muni_2013_fim %>% saveRDS("./data/MT_FAMATO_MUNICIPIOS_2013.RDS")


