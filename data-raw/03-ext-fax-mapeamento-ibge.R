
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

ibge_hist_2014_2016_fim <- ibge_hist_2014_2016 %>% 
    janitor::clean_names() %>% 
    dplyr::mutate(
        fonte = "IBGE - Dados disponibilizados pelo SNIF",
        mapeamento = "IBGE - Não identificado",
        ano_base = stringr::str_extract(ano_data, "[0-9]{4}$")
    ) %>% 
    
    dplyr::rename(uf = "estado_sigla",
                 genero = "especie_florestal",
                 municipio = "municipio_municipios") %>% 

    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "Eucalipto" ~ "Eucalyptus",
            genero == "Outras espécies" ~ "Outros",
            TRUE ~ genero
        )
    ) %>% 
    
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  municipio,
                  latitude,
                  longitude,
                  genero,
                  area_ha) 

# Conferindo totais
ibge_hist_2014_2016_fim %>% 
    dplyr::group_by(uf) %>% 
    dplyr::summarise(total = sum(area_ha, na.rm = TRUE))

ibge_hist_2014_2016 %>% 
    janitor::clean_names() %>% 
    dplyr::group_by(estado_sigla) %>% 
    dplyr::summarise(total = sum(area_ha, na.rm = TRUE))


# Salvar tabela final do csv ----------------------------------------------
ibge_hist_2014_2016_fim %>% saveRDS("./data/BR_IBGE_SNIF_HISTORICO_MUNICIPIOS_2014_2016.RDS")


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
    
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            genero == "outros" ~ "Outros",
            TRUE ~ genero
        )
    ) %>% 
    
    # organizando colunas
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  genero,
                  area_ha) 

tbl_ibge_2018_fim %>% tibble::view()

# Salvar tabela final do pdf ----------------------------------------------
tbl_ibge_2018_fim %>% saveRDS("./data/BR_IBGE_PEVS_2018.RDS")

