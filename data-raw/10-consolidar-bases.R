

# 00 - Carregar e instalar pacotes ----------------------------------------
# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar bases ----------------------------------------------------------

# Listar arquivos da pasta 'data'
arquivos <- list.files("./data/", full.names = TRUE)
arquivos


# Abrir bases
bases <- purrr::map(arquivos, .f = readr::read_rds)


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



# Consolidar bases estaduais ----------------------------------------------




# Consolidar históricos ---------------------------------------------------




# Salvar bases ------------------------------------------------------------
mapeamentos_municipios %>% saveRDS("./data/consolidado/mapeamentos_municipios.rds")

