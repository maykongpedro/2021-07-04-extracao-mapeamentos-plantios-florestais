
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar pdfs -----------------------------------------------------------

# AGEFLORESTA - Diagnóstico das Plantações Florestais em Mato Grosso - 2007

path_agefloresta_2007 <- "./data-raw/pdf/05-MT/agefloresta_diagnostico_plantacoes_florestais_2007.pdf"

# Extraindo infos da página 1 (pois o tabulizer não consegue achar nada)
agefloresta_2007_pg1 <- tabulizer::extract_tables(path_agefloresta_2007,
                                              pag = 1,
                                              method = "lattice")
agefloresta_2007_pg1

# página 2 também

# outras páginas
agefloresta_2007_pgs <- tabulizer::extract_tables(path_agefloresta_2007,
                                                  method = "stream")

agefloresta_2007_pgs




# FEMATO - Diagnóstico de Florestas Plantadas do Mato Grosso - 2013
path_femato_2013 <- "./data-raw/pdf/05-MT/femato_diagnostico_florestas_plantadas_2013.pdf"

# Extraindo tabela
femato_2013 <- tabulizer::extract_tables(path_femato_2013,
                                         method = "stream")

# Esse foi mais simples, tabulizer capturou tudo
femato_2013



# Faxinar e organizar tabela do pdf ---------------------------------------

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")

# Manipular tabela



# Conferir totais



# Salvar tabela final do pdf ----------------------------------------------
