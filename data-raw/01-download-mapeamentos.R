    

# Por conta do tamanho de muitos pdfs, visando facilitar a reprodutibilidade do
# código, vou apenas passar o link que usei para baixá-los manualmente e irei 
# salvar no repositório apenas as páginas que tenho intenção de extrair

# Observação 1: alguns pdfs podem ser acessados diretamente pelo link utilizado
# Observação 2: arquivos .csv optei por deixar salvo diretamente no repositório,
# porém dentro desse script explico como eles foram obtidos


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

# preciso descobri o enconding
readr::read_csv2(file = iba_historico_csv,)


# exportando base que será utilizada



# 02 - Mapeamentos do Brasil - IBGE ---------------------------------------


# IBGE - Histórico antigo
# Os dados de mapeamento do IBGE podem ser encontrados no mesmo local do histórico
# do IBÁ, no seguinte link:
# https://dados.gov.br/dataset/sistema-nacional-de-informacoes-florestais-snif
# Buscando o item "Florestas Plantadas - IBGE - 2014-2016.csv", obtemos o link abaixo:

url_ibge_historico <- "http://homolog-dados.mma.gov.br/pt_BR/dataset/ffd9ab35-5719-4ec1-8d13-ae8f738bebc2/resource/fdf7e4ce-8475-4205-8aad-3f97665b8a41/download/rf_florestasplantadas_ibge_2014-2016.csv"

# preciso descobri o enconding
readr::read_csv(file = url_ibge_historico)


# exportando base que será utilizada




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






