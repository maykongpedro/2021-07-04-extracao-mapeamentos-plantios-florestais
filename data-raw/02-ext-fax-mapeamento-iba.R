
# Carregar pipe
'%>%' <- magrittr::`%>%`

# Obter caminho do pdf
file_iba_relatorio_2020 <- "data-raw/pdf/01-Brasil/01-IBA/relatorio_iba_2020.pdf"


# Extrair tableas das páginas
iba_relatorio_2020  <- tabulizer::extract_tables(file_iba_relatorio_2020,
                                                 method = "stream")


iba_relatorio_2020[2]

