

# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar pdfs -----------------------------------------------------------

# AGEFLOR - A Indústria de Base Florestal no RS - 2017
# Nesse relatório as tabelas estão como imagens
path_ageflor_2017 <- "./data-raw/pdf/04-RS/ageflor_setor_florestal_2017.pdf"

# Extraindo infos
ageflor_2017 <- pdftools::pdf_ocr_text(path_ageflor_2017)
path_ageflor_2017


# Como eu capturo as tabelas?
ageflor_2017 %>% 
    purrr::pluck(1) %>% 
    cat()



# AGEFLOR - A Indústria de Base Florestal no RS - 2020
path_ageflor_2020 <- "./data-raw/pdf/04-RS/ageflor_setor_florestal_2020.pdf"

# Extraindo tabela
ageflor_2020 <- tabulizer::extract_tables(path_ageflor_2020,
                                          method = "lattice")
ageflor_2020


# Faxinar e organizar tabela do pdf ---------------------------------------

# Variável auxiliar para transformação de tipos de colunas
loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")

# Manipular tabela



# Conferir totais



# Salvar tabela final do pdf ----------------------------------------------
