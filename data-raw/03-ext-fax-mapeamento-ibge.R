
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar csv ------------------------------------------------------------

ibge_hist_2014_2016 <- readr::read_csv2("./data-raw/csv/ibge_florestas_plantadas_2014-2016.csv")

ibge_hist_2014_2016


# Importar pdfs -----------------------------------------------------------

# Relatório do SFB, que compilou dados do PEVS/IBGE de 2018 (ano-base 2017)
sfb_florestas_brasil_resumo_2019 <- "./data-raw/pdf/01-Brasil/02-IBGE/snif_2019_dados_estaduais_ibge.pdf"

# Extrair tabelas das páginas
ibge_2018 <- tabulizer::extract_tables(sfb_florestas_brasil_resumo_2019,
                                       method = "stream")

ibge_2018


# Organizar tabela do csv -------------------------------------------------

ibge_hist_2014_2016 
    


# Faxinar e organizar tabela do pdf ---------------------------------------

# variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")

tbl_ibge_2018 <- ibge_2018 %>% 
    # obter apenas o primeiro item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>% 
    
    # deletar as primeiras linhas
    dplyr::slice(-c(1:4)) %>% 
    
    # ajustar espaços
    dplyr::mutate(...1 = stringr::str_squish(...1)) %>% 
    
    # separar colunas
    tidyr::separate(col = 1, 
                    into = c("uf", "eucalipto", "pinus", "outros", "total"),
                    sep = " ") %>% 
    
    # substituir traços por NA
    dplyr::mutate(dplyr::across(dplyr::everything(),
                                dplyr::na_if, "-")) %>% 
    
    # retirar "total"
    dplyr::filter(uf != "Total") %>% 
    dplyr::select(-total) %>% 
    
    # ajustar tipos das colunas
    dplyr::mutate(
        dplyr::across(.cols = eucalipto:outros,
                      readr::parse_number, locale = loc)) %>% 
    
    # pivotar base
    tidyr::pivot_longer(cols = eucalipto:outros,
                        names_to = "genero",
                        values_to = "area_ha") %>% 
    
    # add fonte de dados
    dplyr::mutate(
        fonte = "PEVS/IBGE",
        mapeamento = "IBGE e PEVS - 2018",
        ano_base = "2017"
    ) 
    

# Trazer os nomes dos estados  

# abrir base de estados + ufs
uf_estados <- readr::read_rds("data/AUX_IBGE_UF_ESTADOS.RDS")


# colocar na base
tbl_ibge_2018_fim <- tbl_ibge_2018 %>% 
    dplyr::left_join(uf_estados) %>% 
    
    # organizando colunas
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  genero,
                  area_ha) 



# Salvar tabela final do pdf ----------------------------------------------
tbl_ibge_2018_fim %>% saveRDS("./data/BR_IBGE_PEVS_2018.RDS")

