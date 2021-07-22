

# 00 - Carregar e instalar pacotes ----------------------------------------
# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar bases ----------------------------------------------------------

# Listar arquivos da pasta 'data'
arquivos <- list.files("./data/", full.names = TRUE, pattern = ".RDS")
arquivos


# Abrir bases
bases <- purrr::map(arquivos, .f = readr::read_rds)
bases

# Função para capturar apenas os nomes
capturar_nomes <- function(lista_arquivos, item){
    
    lista_arquivos %>% 
        purrr::pluck(item) %>% 
        stringr::str_remove_all("./data/|.RDS")
}


# Pegar o nome de cada arquivo
nomes_arquivos <- purrr::map(.x = c(1:19),
                             ~  capturar_nomes(arquivos, .x)) %>%
    purrr::transpose() %>%
    purrr::set_names("nomes") %>%
    tibble::as_tibble(.name_repair = "unique") %>%
    tidyr::unnest(cols = 1)

nomes_arquivos


# Nomear lista de bases
names(bases) <- nomes_arquivos %>% dplyr::pull()

bases


# Consolidar bases com municípios -----------------------------------------

# Pegar somente os nomes das bases com código ibge
nomes_bases_muni <-
    nomes_arquivos %>% 
    dplyr::filter(stringr::str_detect(nomes, "COD-IBGE")) %>% 
    dplyr::pull()


# Empilhar essas bases
mapeamentos_municipios <- purrr::map_dfr(.x = nomes_bases_muni,
                                         ~ purrr::pluck(bases, .x)) %>% 
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  municipio,
                  code_muni,
                  nucleo_regional,
                  latitude,
                  longitude,
                  genero,
                  area_ha
                  )

# Verificando colunas
mapeamentos_municipios %>% dplyr::glimpse()
mapeamentos_municipios %>% tibble::view()




# Consolidar bases estaduais e nacionais ----------------------------------

# Pegar nome das bases gerais
nomes_bases_gerais <- nomes_arquivos %>%
    dplyr::filter(
        !nomes %in% nomes_bases_muni,
        !stringr::str_detect(nomes, "MUNICIPIOS|AUX")
    ) %>% 
    dplyr::pull()
bases

# Empilhar essas bases
mapeamentos_gerais <- purrr::map_dfr(.x = nomes_bases_gerais,
                                         ~ purrr::pluck(bases, .x)) %>% 
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  regiao,
                  nucleo_regional,
                  corede,
                  genero,
                  area_ha
    )


# Retirar 2016 e 2019 do histórico Ageflor (RS), pois o mapeamento dos coredes
# já colocam essa informação dentro da base
itens_para_retirar <- mapeamentos_gerais %>%
    dplyr::filter(
        stringr::str_detect(mapeamento, "AGEFLOR"),
        is.na(corede),
        ano_base %in% c("2016", "2019")
    ) 


# Retirar da base
mapeamentos_gerais_ajust <- mapeamentos_gerais %>% 
    dplyr::anti_join(itens_para_retirar)
    

# Checando se saiu da base mesmo
mapeamentos_gerais %>% nrow()
itens_para_retirar %>% nrow()  
mapeamentos_gerais_ajust %>% nrow()  

# Filtrando
mapeamentos_gerais_ajust %>% 
    dplyr::filter(
        stringr::str_detect(mapeamento, "AGEFLOR"),
        is.na(corede)
    ) %>% 
    tibble::view()


# Verificando soma geral desses mapeamentos de coredes
mapeamentos_gerais_ajust %>% 
    dplyr::filter(stringr::str_detect(mapeamento, "AGEFLOR"),
                 !is.na(corede)) %>% 
    dplyr::group_by(ano_base, genero) %>% 
    dplyr::summarise(total = sum(area_ha, na.rm = TRUE))
    

# Confirmando números de mapeamentos
arquivos %>% length()
nomes_bases_muni %>% length()
nomes_bases_gerais %>% length()


# Salvar bases ------------------------------------------------------------
mapeamentos_municipios %>% saveRDS("./data/consolidado/mapeamentos_municipios.rds")
mapeamentos_gerais_ajust %>% saveRDS("./data/consolidado/mapeamentos_gerais.rds")
