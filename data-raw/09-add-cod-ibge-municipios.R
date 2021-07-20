
# 00 - Carregar e instalar pacotes ----------------------------------------
# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, geobr)

# Carregar pipe
'%>%' <- magrittr::`%>%`
    

# Importando bases organizadas --------------------------------------------

# Lista de arquivos de municípios
arquivos <- list.files("./data/", full.names = TRUE, pattern = "MUNICIPIOS")

# Retirar da lista o mapeamento do IFPR (pois já tem código do IBGE)
arquivos <- arquivos[-2]

# Abrindo arquivos
mapeamentos_municipios <- arquivos %>%
    purrr::map(.f = readr::read_rds)



# Importando base do IBGE -------------------------------------------------
base_muni <- geobr::read_municipality()

base_muni_rs_mg <- base_muni %>% 
    tibble::tibble() %>% 
    dplyr::select(-geom) %>% 
    dplyr::rename(uf = "abbrev_state",
                  municipio = "name_muni") %>% 
    dplyr::filter(uf %in% c("RS", "MT")) 

base_muni_rs_mg


# Adicionando código município - Mapeamento FAMATO - 2013  ---------------

# Fazer join
famato_2013 <- mapeamentos_municipios %>% 
    purrr::pluck(1) %>% 
    dplyr::left_join(base_muni_rs_mg) %>% 
    dplyr::select(-code_state) %>% 
    dplyr::relocate(code_muni, .before = "genero")

# Verificar itens não encontrados
ageflor_2016 %>% 
    dplyr::filter(is.na(code_muni)) %>% 
    tibble::view()




# Adicionando código município - Mapeamento AGEFLOR - 2016  ---------------



readr::read_rds("./data/PR_IFPR_SFB_MUNICIPIOS_2015_COD-IBGE.RDS")
