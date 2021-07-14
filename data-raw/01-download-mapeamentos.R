    

# Por conta do tamanho de muitos pdfs, visando facilitar a reprodutibilidade do
# código, vou apenas passar o link que usei para baixá-los manualmente e irei 
# salvar no repositório apenas as páginas que tenho intenção de extrair

# Observação 1: alguns pdfs podem ser acessados diretamente pelo link utilizado
# Observação 2: arquivos .csv optei por deixar salvo diretamente no repositório,
# porém dentro desse script explico como eles foram obtidos


# 00 - Carregar e instalar pacotes ----------------------------------------
# if(!require("pacman")) install.packages("pacman")
# pacman::p_load(pdftools)


# 01 - Mapeamentos do Brasil - IBÁ ----------------------------------------

# IBÁ - RELATÓRIO 2020
# O relatório 2020 foi acessado pelo seguinte link:
# https://iba.org/datafiles/publicacoes/relatorios/relatorio-iba-2020.pdf

iba_relatorio_2020 <- "https://iba.org/datafiles/publicacoes/relatorios/relatorio-iba-2020.pdf"
pdftools::pdf_convert(iba_relatorio_2020, pages = 49, filenames = "pag49.png")

# extraindo e salvando apenas as páginas que serão usadas
pdftools::pdf_subset(iba_relatorio_2020, 
                     pages = c(49, 50), 
                     output = "./data-raw/pdf/01-Brasil/01-IBA/relatorio_iba_2020.pdf")


# Dados mais antigos do IBÁ, organizados em .csv, podem ser encontrados no seguinte link:
# https://dados.gov.br/dataset/sistema-nacional-de-informacoes-florestais-snif
# Buscando o item "Florestas Plantadas - Iba - 2006-2016.csv" obtemos o link abaixo:

iba_historico_csv <- "http://homolog-dados.mma.gov.br/pt_BR/dataset/ffd9ab35-5719-4ec1-8d13-ae8f738bebc2/resource/43251bd6-e2c9-4dc8-93c9-379bf15e29d9/download/rf_florestasplantadas_iba_2006-2016.csv"

# Descobrir o enconding para abrir corretamente
readr::guess_encoding(iba_historico_csv)

# Abrindo o arquivo diretamente da internet
iba_historico_sfb <- read.delim(file = iba_historico_csv,
                                fileEncoding = "ISO-8859-1",
                                sep = ";",
                                header = TRUE)


# Exportando base que será utilizada
readr::write_csv2(iba_historico_sfb,
                  file = "data-raw/csv/iba_historico_florestas_plantadas_2006-2016.csv")



# 02 - Mapeamentos do Brasil - IBGE ---------------------------------------


# IBGE - Histórico antigo
# Os dados de mapeamento do IBGE podem ser encontrados no mesmo local do histórico
# do IBÁ, no seguinte link:
# https://dados.gov.br/dataset/sistema-nacional-de-informacoes-florestais-snif
# Buscando o item "Florestas Plantadas - IBGE - 2014-2016.csv", obtemos o link abaixo:

url_ibge_historico <- "http://homolog-dados.mma.gov.br/pt_BR/dataset/ffd9ab35-5719-4ec1-8d13-ae8f738bebc2/resource/fdf7e4ce-8475-4205-8aad-3f97665b8a41/download/rf_florestasplantadas_ibge_2014-2016.csv"

# Descobrir o enconding para abrir corretamente
readr::guess_encoding(url_ibge_historico)



# Abrindo o arquivo diretamente da internet
url_ibge_historico <- read.delim(file = url_ibge_historico,
                                 fileEncoding = "ISO-8859-1",
                                 sep = ";",
                                 header = TRUE)


# Exportando base que será utilizada
readr::write_csv2(url_ibge_historico,
                  file = "data-raw/csv/ibge_florestas_plantadas_2014-2016.csv")



# IBGE/PEVS - Histórico mais recente
# Esse pode ser obtido no BOLETIM SNIF 2019, que compilou dados de Florestas Plantadas
# da Pesquisa de Extração Vegetal e Silvicultura – PEVS/IBGE.
# O link do Boletim segue abaixo:

snif_2019_ibge <- "https://snif.florestal.gov.br/images/pdf/publicacoes/Boletim-SNIF_Ed1_2019.pdf"

# extraindo e salvando apenas a página que será utilizada
pdftools::pdf_subset(snif_2019_ibge, 
                     pages = 8, 
                     output = "./data-raw/pdf/01-Brasil/02-IBGE/snif_2019_dados_ibge.pdf")


# IBGE/PEVS Histórico mais recente por estado
# Essa informação é compilada no relatório Florestas do Brasil em resumo 2019,
# do Serviço Florestal Brasileiro (SFB). Pode ser obtido no seguinte link:

snif_estadual_ibge <- "http://www.acr.org.br/uploads/biblioteca/Florestas_Brasil_2019_Portugues.pdf"


# extraindo e salvando apenas a página que será utilizada
pdftools::pdf_subset(snif_estadual_ibge, 
                     pages = 46, 
                     output = "./data-raw/pdf/01-Brasil/02-IBGE/snif_2019_dados_estaduais_ibge.pdf")



# 03 - Mapeamentos do Paraná - APRE ---------------------------------------

# APRE - ESTUDO SETORIAL 2020
# Pode ser encontrado no site da APRE, pelo seguinte link:

url_apre_estudo_setorial_2020 <- "https://apreflorestas.com.br/wp-content/uploads/2021/01/estudo_setorial_digital.pdf"

# extraindo e salvando apenas as páginas que serão usadas
pdftools::pdf_subset(url_apre_estudo_setorial_2020, 
                     pages = c(24), 
                     output = "./data-raw/pdf/02-PR/01-APRE/apre_estudo_setorial_2020.pdf")


# APRE - ESTUDO SETORIAL 2017-2018
# Pode ser encontrado no site da APRE, pelo seguinte link:

url_apre_estudo_setorial_2017_2018 <- "https://apreflorestas.com.br/?flowpaper-lite-plugin=get-pdf&pdf=https://apreflorestas.com.br/wp-content/uploads/2020/10/Estudo_Setorial_Apre_2017-2018.pdf"

# extraindo e salvando apenas a página que será utilizada
pdftools::pdf_subset(url_apre_estudo_setorial_2017_2018, 
                     pages = c(19), 
                     output = "./data-raw/pdf/02-PR/01-APRE/apre_estudo_setorial_2017-2018.pdf")

# Uma vez estudado esses números e lendo a fonte dos dados da página extraída, 
# é possível perceber que são os mesmos dados do mapeamento do IFPR & SFB de 2015.
# Ou seja, não será necessário extraí-los.



# 04 - Mapeamentos do Paraná - SFB & IFPR ---------------------------------

# IFPR e SFB - Mapeamento dos plantios florestais do Paraná
# Pode ser encontrado no site da APRE, pelo seguinte link:
# https://apreflorestas.com.br/publicacoes/ifpr-e-sfb-mapeamento-dos-plantios-florestais-do-estado-do-parana/

# Para esse mapeamento não será realizada extração nesse projeto pois esse trabalho
# já foi executado no seguinte projeto:
# https://github.com/maykongpedro/2021-06-17-tcc-curso-r-faxina-de-dados

# Então nesse projeto apenas será feito o download da base final já organizada:

ifpr_sfb_2015 <- "https://github.com/maykongpedro/2021-06-17-tcc-curso-r-faxina-de-dados/raw/r-studio-cloud/data/mapeamento_SFB-IFPR_completo_cod_IBGE.rds"

download.file(url = ifpr_sfb_2015, destfile = "./data/PR_IFPR_SFB_2015.rds")




# 05 - Mapeamentos de Santa Catarina - ACR --------------------------------

# ACR - ANUÁRIO ESTATÍSTICO 2019
# Pode ser obtido na página de publicações da ACR, pelo seguinte link:
# http://www.acr.org.br/biblioteca.php?pageNumber=5

# O pdf em si consta no seguinte link:

acr_anuario_est_2019 <- "http://www.acr.org.br/uploads/biblioteca/Anuario_ACR_2019_atualizado.pdf"


# extraindo e salvando apenas a página que será utilizada
pdftools::pdf_subset(acr_anuario_est_2019, 
                     pages = 31, 
                     output = "./data-raw/pdf/03-SC/acr_anuario_estatistico_2019.pdf")



# 06 - Mapeamentos do Rio Grande do Sul - AGEFLOR -------------------------

# Os relatórios da AGEFLOR podem ser encontrados no site da organização:
# http://www.ageflor.com.br/dados

# AGEFLOR - SETOR DE BASE FLORESTAL NO RS 2020
# Pode ser obtido pelo seguinte link:

ageflor_relatorio_2020 <- "http://www.ageflor.com.br/noticias/wp-content/uploads/2020/12/O-Setor-de-Base-Florestal-no-Rio-Grande-do-Sul-2020-ano-base-2019.pdf"


# extraindo e salvando apenas as páginas que seram utilizadas
pdftools::pdf_subset(ageflor_relatorio_2020, 
                     pages = c(20, 24, 28, 31:33), 
                     output = "./data-raw/pdf/04-RS/ageflor_setor_florestal_2020.pdf")


# AGEFLOR - SETOR DE BASE FLORESTAL NO RS 2017
# Pode ser obtido pelo seguinte link:

ageflor_relatorio_2017 <- "http://www.ageflor.com.br/noticias/wp-content/uploads/2017/08/A-INDUSTRIA-DE-BASE-FLORESTAL-NO-RS-2017.pdf"

# extraindo e salvando apenas as páginas que seram utilizadas
pdftools::pdf_subset(ageflor_relatorio_2017, 
                     pages = c(17, 20, 25, 27,29, 31), 
                     output = "./data-raw/pdf/04-RS/ageflor_setor_florestal_2017.pdf")




# 07 - Mapeamentos do Mato Grosso - FAMATO --------------------------------
# FAMATO: Federação da Agricultura e Pecuária do Estado de Mato Grosso

# FAMATO - Diagnóstico de Florestas Plantadas 2013
# Pode ser obtido no site da AREFLORESTA (Associação de Reflorestadores do Mato Grosso)
# pelo seguite link:

femato_diag_flor_plant_2013 <- "http://www.arefloresta.org.br/uploads/downloads/00072201414739.pdf"

# extraindo e salvando apenas as páginas que seram utilizadas
pdftools::pdf_subset(femato_diag_flor_plant_2013, 
                     pages = c(103:105), 
                     output = "./data-raw/pdf/05-MT/femato_diagnostico_florestas_plantadas_2013.pdf")



# 08 - Mapeamento do Mato Grosso - AREFLORESTA ----------------------------

# AREFLORESTA - Diagnóstico de Plantações Florestais 2007
# Pode ser obtido no site da AREFLORESTA pelo seguinte link:

arefloresta_disg_plant_flor_2007 <- "http://www.arefloresta.org.br/uploads/downloads/0001522012113335.pdf"

# extraindo e salvando apenas as páginas que seram utilizadas
pdftools::pdf_subset(arefloresta_disg_plant_flor_2007, 
                     pages = c(15:18, 20, 23, 25:27), 
                     output = "./data-raw/pdf/05-MT/agefloresta_diagnostico_plantacoes_florestais_2007.pdf")



# 09 - Bases adicionais ---------------------------------------------------

# Base de estados e unidades federativas
# obter base de estados + ufs
base_ufs <- geobr::read_state()

ibge_uf_estados <- 
    base_ufs %>% 
    tibble::tibble() %>% 
    dplyr::select(abbrev_state , name_state, -geom) %>% 
    dplyr::rename(uf = "abbrev_state",
                  estado = "name_state")

# salvar base
saveRDS(ibge_uf_estados, 
        file = "data/AUX_IBGE_UF_ESTADOS.RDS")


