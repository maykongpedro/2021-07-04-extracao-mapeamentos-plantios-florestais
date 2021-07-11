

# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, tabulizer, purrr, janitor)

# Carregar pipe
'%>%' <- magrittr::`%>%`


# Importar pdfs -----------------------------------------------------------

# Obter caminho do pdf
filepath_iba_relatorio_2020 <- "data-raw/pdf/01-Brasil/01-IBA/relatorio_iba_2020.pdf"


# Extrair tableas das páginas
iba_relatorio_2020  <- tabulizer::extract_tables(filepath_iba_relatorio_2020,
                                                 method = "stream")


iba_relatorio_2020 %>% 
    
    # obter apenas o primeiro item da lista
    purrr::pluck(1) %>% 
    
    # transformar em tibble
    tibble::as_tibble(.name_repair = "unique") %>% 
    
    # deletar as duas colunas iniciais
    dplyr::select(-c(1,2)) %>% 
    
    # deletar a primeira linha
    dplyr::slice(-1) %>% 
    
    # transformar a primeira linha em nome da coluna
    janitor::row_to_names(row_number = 1) %>% 
    
    # ajustar nomes das colunas
    janitor::clean_names() %>% 
    
    # separar primeira coluna
    

