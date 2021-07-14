
# Carregar e instalar pacotes ---------------------------------------------

# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(tidyverse, readr, tabulizer, purrr, janitor)

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



# Boletim SNIF 2019, que compilou dados de 2014 a 2018 do PEVS/IBGE  
sfb_boletim_2019 <- "./data-raw/pdf/01-Brasil/02-IBGE/snif_2019_dados_ibge.pdf"

# Necessário usar OCR para extração (precisa do pacote 'tesseract')
# OCR: Optical Character Recognition
# OCR é feita em 3 passos
# 1. PDF é transformado em imagem
# 2. A imagem é lida no pacote {magick}
# 3. O {magick} chama o {tesseract} para passar OCR
# obs: tesseract é uma ferramenta de OCR open source desenvolvida pela Google.
# nota: explicação retirada da aula de faxina de dados da Curso R
ibge_hist_2014_2018_t <- pdftools::pdf_ocr_text(sfb_boletim_2019)

cat(ibge_hist_2014_2018_t)







# Organizar tabela do csv -------------------------------------------------

ibge_hist_2014_2016 
    




# Faxinar e organizar tabela do pdf ---------------------------------------
