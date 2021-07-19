
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`
    
    

# Importar base -----------------------------------------------------------

ifpr_sfb_2015 <- readr::read_rds("./data-raw/rds/PR_IFPR_SFB_2015.rds")


# Padronizar --------------------------------------------------------------

# Verificar colunas
ifpr_sfb_2015 %>% dplyr::glimpse()


# Adicionar infos complementares
ifpr_sfb_2015_fim <- ifpr_sfb_2015 %>% 
    dplyr::mutate(
        fonte = "IFPR e SFB",
        mapeamento = "IFPR - Mapeamento dos Plantios Florestais do Estado do Paraná",
        ano_base = "2014",
        uf = "PR",
        estado = "Paraná",
        genero = tipo_genero
    ) %>% 
    dplyr::mutate(
        genero = dplyr::case_when(
            genero == "eucalipto" ~ "Eucalyptus",
            genero == "pinus" ~ "Pinus",
            genero == "corte" ~ "Corte",
            TRUE ~ genero
        )
    ) %>% 
    
    dplyr::select(mapeamento,
                  fonte,
                  ano_base,
                  uf,
                  estado,
                  nucleo_regional,
                  municipio,
                  code_muni,
                  genero,
                  area_ha) 


# Salvar tabela final -----------------------------------------------------
ifpr_sfb_2015_fim %>% saveRDS("./data/PR_IFPR_SFB_MUNICIPIOS_2015_COD-IBGE.RDS")

