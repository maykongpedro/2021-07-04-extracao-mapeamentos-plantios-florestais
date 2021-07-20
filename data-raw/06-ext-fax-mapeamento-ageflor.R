
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, tesseract, Rcpp, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`

# Carregar funções
source("./R/01-fn-empilhar-municipios-ageflor-2017.R")
source("./R/02-fn-faxinar-tab-geral-ageflor-2020.R")
source("./R/03-fn-faxinar-tab-municipios-ageflor-2020.R")

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")


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


# adicionar infos complementares
tab_historico_ageflor2017_fim <- tbl_geral_ageflor_2017 %>%
    dplyr::rename(ano_base = "ano") %>% 
    dplyr::mutate(
        fonte = "AFUBRA, AGEFLOR, FEPAM, RDK e SEMA",
        mapeamento = "AGEFLOR - A indústria de base florestal no Rio Grande do Sul 2017",
        uf = "RS",
        estado = "Rio Grande do Sul"
    ) %>% 
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  genero,
                  area_ha) 



# Conferir totais
tab_historico_ageflor2017_fim %>% 
    dplyr::group_by(ano_base) %>% 
    dplyr::summarise(total = sum(area_ha))



# Faxinar e organizar tabela do pdf - 2017 - Tabela Coredes ---------------

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


# adicionar infos complementares
tab_coredes_ageflor2017_fim <- tbl_coredes_ageflor_2017_completa %>% 
    dplyr::mutate(
        fonte = "AFUBRA, AGEFLOR, FEPAM, RDK e SEMA",
        mapeamento = "AGEFLOR - A indústria de base florestal no Rio Grande do Sul 2017",
        ano_base = "2016",
        uf = "RS",
        estado = "Rio Grande do Sul"
    ) %>% 
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  corede,
                  genero,
                  area_ha) 

# visualizar
tab_coredes_ageflor2017_fim %>% tibble::view()

# verificar totais
tab_coredes_ageflor2017_fim %>% 
    dplyr::group_by(corede) %>% 
    dplyr::summarise(area = sum(area_ha, na.rm = TRUE))



# Faxinar e organizar tabela do pdf - 2017 - Tabela Municípios ------------

tbl_muni_geral_2017 <- 
    ageflor_2017 %>% 
    
    purrr::pluck(3) %>%
    
    # dotall para permitir que o ponto capture qualquer coisa, inclusiva o \n
    stringr::str_extract(stringr::regex("AREA +.+", dotall = TRUE)) %>% 
    
    # separar cada linha gerando uma lista
    stringr::str_split("\n") %>% 

    # pegar o item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    dplyr::as_tibble(.name_repair = "unique") %>% 
    
    # retirar primeiras linhas
    dplyr::slice(-c(1:3)) %>% 
    
    # retirar últimas linhas
    dplyr::slice(-c(11:12)) %>% 
    
    # renomear coluna
    dplyr::rename(muni_valores = "value") %>% 
    
    # separar nomes e números
    dplyr::mutate(
        areas = stringr::str_remove_all(muni_valores, "[:alpha:]"),
        areas = stringr::str_squish(areas),
        municipios = stringr::str_remove_all(muni_valores, "[0-9.]")
    ) %>% 
    
    # retirar coluna inicial
    dplyr::select(-muni_valores) %>% 
    
    # separar nomes dos municípios
    tidyr::separate(col = municipios,
                   into = c("muni_1", "muni_2"),
                   sep = "  ") %>% 
    
    # separar coluna de áreas
    tidyr::separate(col = areas,
                    into = c("area_1", "area_2"),
                    sep = " ") %>% 
    
    # limpar colunas e ajustar tipos
    dplyr::mutate(
        dplyr::across(.fns = stringr::str_squish),
        dplyr::across(.cols = area_1:area_2,
                      readr::parse_number, locale = loc)
        )
    
tbl_muni_geral_2017

# empilhar as duas bases de municípios
tbl_muni_ageflor_geral_2017 <- empilhar_muni_ageflor_2017(tbl_muni_geral_2017)

# corrigir nomes dos municípios e ajustar colunas
tbl_muni_geral_2017_fim <- tbl_muni_ageflor_geral_2017 %>%
    dplyr::mutate(
        
        municipio = dplyr::case_when(
            municipio == "Butia" ~ "Butiá",
            municipio == "Cambara do Sul" ~ "Cambará do Sul",
            municipio == "Sao Grabriel" ~ "São Gabriel",
            municipio == "Bage" ~ "Bagé",
            municipio == "Cangucu" ~ "Canguçu",
            municipio == "Sao Jose do Norte" ~ "São José do Norte",
            municipio == "Sao Francisco de Paula" ~ "São Francisco de Paula",
            municipio == "Sao Jose dos Ausentes" ~ "São José dos Ausentes",
            
            TRUE ~ municipio
        ),
        
        municipio = stringr::str_squish(municipio),
        
        genero = "Todos"
    ) 

tbl_muni_geral_2017_fim



# Faxinar e organizar tabela do pdf - 2017 - Tabela Municípios Pin --------

tbl_muni_pinus_2017 <- ageflor_2017 %>% 
    
    purrr::pluck(5) %>% 

    # dotall para permitir que o ponto capture qualquer coisa, inclusiva o \n
    stringr::str_extract(stringr::regex("AREA +.+", dotall = TRUE)) %>% 
    
    # separar cada linha gerando uma lista
    stringr::str_split("\n") %>% 
    
    # pegar o item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    dplyr::as_tibble(.name_repair = "unique") %>% 
    
    # retirar primeiras linhas
    dplyr::slice(-(1:4)) %>% 
    
    # retirar últimas linhas
    dplyr::slice(-(13:14)) %>% 
    
    # renomear coluna
    dplyr::rename(muni_valores = "value") %>% 
    
    # separar nomes e números
    dplyr::mutate(
        muni_valores = stringr::str_remove(muni_valores,"280 "),
        areas = stringr::str_remove_all(muni_valores, "[:alpha:]"),
        areas = stringr::str_squish(areas),
        municipios = stringr::str_remove_all(muni_valores, "[0-9.]")
    ) %>% 
    
    # retirar coluna inicial
    dplyr::select(-muni_valores) %>% 
    
    # retirar linhas com nomes sem números
    dplyr::filter(!municipios %in% c("Paula", "Ausentes")) %>% 
    
    # separar nomes dos municípios
    tidyr::separate(col = municipios,
                    into = c("muni_1", "muni_2"),
                    sep = "  ") %>% 
    
    # separar coluna de áreas
    tidyr::separate(col = areas,
                    into = c("area_1", "area_2"),
                    sep = " ") %>% 
    
    # limpar colunas e ajustar tipos
    dplyr::mutate(
        dplyr::across(.fns = stringr::str_squish),
        dplyr::across(.cols = area_1:area_2,
                      readr::parse_number, locale = loc)
    )


# empilhar as duas bases de municípios
tbl_muni_ageflor_pinus_2017 <- empilhar_muni_ageflor_2017(tbl_muni_pinus_2017)

# corrigir nomes dos municípios e ajustar colunas
tbl_muni_pinus_2017_fim <- tbl_muni_ageflor_pinus_2017 %>%
    dplyr::mutate(
        
        municipio = dplyr::case_when(
            municipio == "Cambara do Sul" ~ "Cambará do Sul",
            municipio == "Cangugcu" ~ "Canguçu",
            municipio == "Sao Jose do Norte" ~ "São José do Norte",
            municipio == "Francisco de" ~ "São Francisco de Paula",
            municipio == "peo Jose dos" ~ "São José dos Ausentes",
            municipio == "Santa Vitoria do Palmar" ~ "Santa Vitória do Palmar",
            TRUE ~ municipio
        ),
        
        municipio = stringr::str_squish(municipio),
        
        genero = "Pinus"
    ) 

tbl_muni_pinus_2017_fim

    

# Faxinar e organizar tabela do pdf - 2017 - Tabela Municípios Euc --------

tbl_muni_eucalipto_2017 <- ageflor_2017 %>% 
    
    purrr::pluck(4) %>%
    
    # dotall para permitir que o ponto capture qualquer coisa, inclusiva o \n
    stringr::str_extract(stringr::regex("AREA+.+", dotall = TRUE)) %>% 
    
    # separar cada linha gerando uma lista
    stringr::str_split("\n") %>% 
    
    # pegar o item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    dplyr::as_tibble(.name_repair = "unique") %>% 
    
    # retirar primeira e últimas linhas
    dplyr::slice(-1, -13) %>% 
    
    # usar a primeira linha como cabeçalho
    janitor::row_to_names(1) %>% 
    janitor::clean_names() %>% 
    dplyr::rename(muni_valores = "municipio_plantada_ha_municipio_plantada_ha") %>% 
    
    # separar nomes e números
    dplyr::mutate(
        areas = stringr::str_remove_all(muni_valores, "[:alpha:]"),
        areas = stringr::str_squish(areas),
        municipios = stringr::str_remove_all(muni_valores, "[0-9.]")
    ) %>% 
    
    # retirar coluna inicial
    dplyr::select(-muni_valores) %>% 
    
    # separar nomes dos municípios
    tidyr::separate(col = municipios,
                    into = c("muni_1", "muni_2"),
                    sep = "  ") %>% 
    
    # separar coluna de áreas
    tidyr::separate(col = areas,
                    into = c("area_1", "area_2"),
                    sep = " ") %>% 
    
    # retirar NA
    tidyr::drop_na() %>% 
    
    # limpar colunas e ajustar tipos
    dplyr::mutate(
        dplyr::across(.fns = stringr::str_squish),
        dplyr::across(.cols = area_1:area_2,
                      readr::parse_number, locale = loc)
    )

tbl_muni_eucalipto_2017


# empilhar as duas bases de muni
tbl_muni_euc_ageflor_2017 <- empilhar_muni_ageflor_2017(tbl_muni_eucalipto_2017)

# corrigir nomes dos municípios e ajustar colunas
tbl_muni_euc_2017_fim <- tbl_muni_euc_ageflor_2017 %>%
    dplyr::mutate(
        municipio = dplyr::case_when(
            municipio == "Butia" ~ "Butiá",
            municipio == "Sao Gabriel" ~ "São Gabriel",
            municipio == "Bage" ~ "Bagé",
            municipio == "Cangugu" ~ "Canguçu",
            municipio == "Sao Jeronimo" ~ "São Jerônimo",
            municipio == "Sdo Francisco de Assis" ~ "São Francisco de Assis",
            TRUE ~ municipio
        ),
        genero = "Eucalyptus"
    ) 

tbl_muni_euc_2017_fim


# Faxinar e organizar tabela do pdf - 2017 - Tabela Municípios Acacia -----

tbl_muni_acacia_2017 <- ageflor_2017 %>% 
    
    purrr::pluck(6) %>% 
    
    # dotall para permitir que o ponto capture qualquer coisa, inclusiva o \n
    stringr::str_extract(stringr::regex("AREA +.+797", dotall = TRUE)) %>% 
    
    # separar cada linha gerando uma lista
    stringr::str_split("\n") %>% 
    
    # pegar o item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    dplyr::as_tibble(.name_repair = "unique") %>% 
    
    # retirar primeiras linhas
    dplyr::slice(-(1:4)) %>% 
    
    # renomear coluna
    dplyr::rename(muni_valores = "value") %>% 
    
    # separar nomes e números
    dplyr::mutate(
        areas = stringr::str_remove_all(muni_valores, "[:alpha:]"),
        areas = stringr::str_squish(areas),
        municipios = stringr::str_remove_all(muni_valores, "[0-9.]")
    ) %>% 
    
    # retirar coluna inicial
    dplyr::select(-muni_valores) %>% 
    
    # separar nomes dos municípios
    tidyr::separate(col = municipios,
                    into = c("muni_1", "muni_2"),
                    sep = "  ") %>% 
    
    # separar coluna de áreas
    tidyr::separate(col = areas,
                    into = c("area_1", "area_2"),
                    sep = " ") %>% 
    
    # limpar colunas e ajustar tipos
    dplyr::mutate(
        dplyr::across(.fns = stringr::str_squish),
        dplyr::across(.cols = area_1:area_2,
                      readr::parse_number, locale = loc)
    )

tbl_muni_acacia_2017


# empilhar as duas bases de municípios
tbl_muni_ageflor_acacia_2017 <- empilhar_muni_ageflor_2017(tbl_muni_acacia_2017)

# corrigir nomes dos municípios e ajustar colunas
tbl_muni_acacia_2017_fim <- tbl_muni_ageflor_acacia_2017 %>%
    dplyr::mutate(
        
        municipio = dplyr::case_when(
            municipio == "Bage" ~ "Bagé",
            municipio == "Cangucu" ~ "Canguçu",
            municipio == "Jaguarao" ~ "Jaguarão",
            municipio == "Sao Jeronimo" ~ "São Jerônimo",
            municipio == "Butia" ~ "Butiá",
            municipio == "Camaqua" ~ "Camaquã",
            TRUE ~ municipio
        ),
        
        municipio = stringr::str_squish(municipio),
        
        genero = "Acácia",
        
        # ajustar valor do município canguçu
        area_ha = dplyr::case_when(municipio == "Canguçu" ~ 9111,
                                  TRUE ~ area_ha)
    ) 

tbl_muni_acacia_2017_fim



# Juntar tabelas de municípios - 2017 -------------------------------------

# Empilhar
tab_muni_completo_2017 <-tbl_muni_geral_2017_fim %>% 
    dplyr::bind_rows(tbl_muni_pinus_2017_fim) %>% 
    dplyr::bind_rows(tbl_muni_euc_2017_fim) %>% 
    dplyr::bind_rows(tbl_muni_acacia_2017_fim) 
    

# Adicionando infos complementares
tab_municipios_ageflor2017_fim<- tab_muni_completo_2017 %>% 
    dplyr::mutate(
        fonte = "AFUBRA, AGEFLOR, FEPAM, RDK e SEMA",
        mapeamento = "AGEFLOR - A indústria de base florestal no Rio Grande do Sul 2017",
        ano_base = "2016",
        uf = "RS",
        estado = "Rio Grande do Sul"
    ) %>% 
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  municipio,
                  genero,
                  area_ha) 

tab_municipios_ageflor2017_fim %>% tibble::view()

# Conferir totais
tab_municipios_ageflor2017_fim %>% 
    dplyr::group_by(genero, municipio) %>% 
    dplyr::summarise(area = sum(area_ha)) %>% 
    print(n=500)


# Faxinar e organizar tabela do pdf - 2020 - Tabelas gerais ----------------

# Vetor com os nomes de cada tabela
nomes_tabs_ageflor_2020 <-  c("historico",
                              "coredes",
                              "muni_todos",
                              "muni_eucalipto",
                              "muni_pinus",
                              "muni_acacia")

# Nomear listas
names(ageflor_2020) <- nomes_tabs_ageflor_2020

# Verificar no console
ageflor_2020


# Organizar as duas tabelas iniciais
tabs_ageflor_2020_geral <-
    purrr::map(.x = nomes_tabs_ageflor_2020[1:2],
               ~ faxinar_ageflor_2020_geral(ageflor_2020, .x))


# Limpar tabela de histórico
tab_historico_ageflor2020 <- tabs_ageflor_2020_geral %>% 
    purrr::pluck(1) %>% 
    
    # corrigir o valor não capturado em 2010
    dplyr::mutate(
        acacia = dplyr::case_when(ano == "2010" ~ 89.9,
                                 TRUE~ acacia)
    ) %>% 
    
    # retirar coluna desnecessária
    dplyr::select(-total) %>% 
    
    # pivotar
    tidyr::pivot_longer(cols = eucalipto:acacia,
                       names_to = "genero",
                       values_to = "area_ha") %>% 
    
    # ajustar área e gêneros
    dplyr::mutate(
        area_ha = area_ha*1000,
        genero = dplyr::case_when(
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            genero == "acacia" ~ "Acácia",
            TRUE ~ genero
        )
    ) %>% 
    
    # renomear coluna
    dplyr::rename(ano_base = "ano") %>% 
    
    # adicionar infos complementares
    dplyr::mutate(
        fonte = "Fepam, Codex, RDK e AGEFLOR",
        mapeamento = "AGEFLOR - O setor de base florestal no Rio Grande do Sul 2020",
        uf = "RS",
        estado = "Rio Grande do Sul"
    ) %>% 
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  genero,
                  area_ha) 

# Conferir totais
tab_historico_ageflor2020 %>% 
    dplyr::group_by(ano_base) %>% 
    dplyr::summarise(area = sum(area_ha))



# Limpar tabela de COREDES
tab_coredes_ageflor2020 <- tabs_ageflor_2020_geral %>% 
    purrr::pluck(2) %>% 
    dplyr::select(-total) %>% 
    tidyr::pivot_longer(cols = pinus:acacia,
                        names_to = "genero",
                        values_to = "area_ha") %>%
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            genero == "acacia" ~ "Acácia",
            TRUE ~ genero
        )
    ) %>% 
    # adicionar infos complementares
    dplyr::mutate(
        fonte = "Fepam, Codex, RDK e AGEFLOR",
        mapeamento = "AGEFLOR - O setor de base florestal no Rio Grande do Sul 2020",
        ano_base = "2019",
        uf = "RS",
        estado = "Rio Grande do Sul"
    ) %>% 
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  corede,
                  genero,
                  area_ha) 

# Conferir totais
tab_coredes_ageflor2020 %>% 
    dplyr::group_by(corede) %>% 
    dplyr::summarise(area = sum(area_ha))



# Faxinar e organizar tabela do pdf - 2020 - Tabelas municípios -----------

# Organizar as tabelas de municípios
tabs_ageflor_2020_muni <-
    purrr::map_dfr(.x = nomes_tabs_ageflor_2020[3:6],
                   ~ faxinar_ageflor_2020_muni(ageflor_2020, .x))


# Adicionando infos complementares e corrigindo gêneros
tab_municipios_ageflor2020<- tabs_ageflor_2020_muni %>% 
    dplyr::mutate(
        fonte = "Fepam, Codex, RDK e AGEFLOR",
        mapeamento = "AGEFLOR - O setor de base florestal no Rio Grande do Sul 2020",
        ano_base = "2019",
        uf = "RS",
        estado = "Rio Grande do Sul"
    ) %>% 
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            genero == "acacia" ~ "Acácia",
            genero == "todos" ~ "Todos",
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
tab_municipios_ageflor2020 %>% 
    dplyr::group_by(genero) %>% 
    dplyr::summarise(area = sum(area_ha))


# Salvar tabela final do pdf ----------------------------------------------

# Ageflor 2017
tab_coredes_ageflor2017_fim %>% saveRDS("./data/RS_AGEFLOR_HISTORICO_2017.RDS")
tab_historico_ageflor2017_fim %>% saveRDS("./data/RS_AGEFLOR_COREDES_2017.RDS")
tab_municipios_ageflor2017_fim %>% saveRDS("./data/RS_AGEFLOR_MUNICIPIOS_2017.RDS")


# Ageflor 2020
tab_coredes_ageflor2020 %>% saveRDS("./data/RS_AGEFLOR_HISTORICO_2020.RDS")
tab_historico_ageflor2020 %>% saveRDS("./data/RS_AGEFLOR_COREDES_2020.RDS")
tab_municipios_ageflor2020 %>% saveRDS("./data/RS_AGEFLOR_MUNICIPIOS_2020.RDS")
