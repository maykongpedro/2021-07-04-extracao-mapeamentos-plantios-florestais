
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Extração de dados de mapeamentos e relatórios de plantios florestais

<!-- badges: start -->
<!-- badges: end -->

Este repositório tem com objetivo armazenar os scripts referentes à
extração e limpeza de dados realizada para compilação e desenvolvimento
do pacote
[plantiosflorestais](https://github.com/maykongpedro/plantiosflorestais).

Essa etapa de faxina de dados ocorreu dentro do âmbito do trabalho de
conclusão de curso do graduando Maykon Gabriel G. Pedro, como requisito
para obtenção de grau de bacharel em Engenharia Florestal.

# Estrutura de arquivos

As pastas deste repositório estão organizados da seguinte maneira:

-   data

É onde constam os dados organizados pós extração dos pdfs, a sub-basta
`consolidado` contém as bases finais que foram usadas pelo pacote
[plantiosflorestais](https://github.com/maykongpedro/plantiosflorestais).

-   data-raw

Nesta pasta ficam armazenados os scripts utilizados para extração e
limpeza, além das pastas para organizar as páginas dos relatórios
originais dos quais os dados são extraídos.

-   R

Na pasta R estão alocadas as funções criadas para realizar limpeza de
dados de várias tabelas em situações semelhantes, visando a
replicabilidade fácil do código dentro dos scripts.

O *output* abaixo exibe todos os arquivos existentes nesse projeto:

    #> .
    #> +-- 2021-07-04-extracao-mapeamentos-plantios-florestais.Rproj
    #> +-- data
    #> |   +-- AUX_IBGE_UF_ESTADOS.RDS
    #> |   +-- BR_IBA_RELATORIO_2020.RDS
    #> |   +-- BR_IBA_SNIF_HISTORICO_2006_2016.RDS
    #> |   +-- BR_IBGE_PEVS_2018.RDS
    #> |   +-- BR_IBGE_SNIF_HISTORICO_MUNICIPIOS_2014_2016.RDS
    #> |   +-- BR_IBGE_SNIF_HISTORICO_MUNICIPIOS_2014_2016_COD-IBGE.RDS
    #> |   +-- consolidado
    #> |   |   +-- mapeamentos_gerais.rds
    #> |   |   \-- mapeamentos_municipios.rds
    #> |   +-- MT_FAMATO_MUNICIPIOS_2013.RDS
    #> |   +-- MT_FAMATO_MUNICIPIOS_2013_COD-IBGE.RDS
    #> |   +-- PR_APRE_UFPR_2020.RDS
    #> |   +-- PR_IFPR_SFB_MUNICIPIOS_2015_COD-IBGE.RDS
    #> |   +-- RS_AGEFLOR_COREDES_2017.RDS
    #> |   +-- RS_AGEFLOR_COREDES_2020.RDS
    #> |   +-- RS_AGEFLOR_HISTORICO_2017.RDS
    #> |   +-- RS_AGEFLOR_HISTORICO_2020.RDS
    #> |   +-- RS_AGEFLOR_MUNICIPIOS_2017.RDS
    #> |   +-- RS_AGEFLOR_MUNICIPIOS_2017_COD-IBGE.RDS
    #> |   +-- RS_AGEFLOR_MUNICIPIOS_2020.RDS
    #> |   +-- RS_AGEFLOR_MUNICIPIOS_2020_COD-IBGE.RDS
    #> |   \-- SC_ACR_UDESC-CAV_2019.RDS
    #> +-- data-raw
    #> |   +-- 01-download-mapeamentos.R
    #> |   +-- 02-ext-fax-mapeamento-iba.R
    #> |   +-- 03-ext-fax-mapeamento-ibge.R
    #> |   +-- 04-ext-fax-mapeamento-apre.R
    #> |   +-- 05-ext-fax-mapeamento-acr.R
    #> |   +-- 06-ext-fax-mapeamento-ageflor.R
    #> |   +-- 07-ext-fax-mapeamento-agefloresta-femato.R
    #> |   +-- 08-padronizacao-mapeamento-ifpr-sfb.R
    #> |   +-- 09-add-cod-ibge-municipios.R
    #> |   +-- 10-consolidar-bases.R
    #> |   +-- csv
    #> |   |   +-- iba_historico_florestas_plantadas_2006-2016.csv
    #> |   |   \-- ibge_florestas_plantadas_2014-2016.csv
    #> |   +-- pdf
    #> |   |   +-- 01-Brasil
    #> |   |   |   +-- 01-IBA
    #> |   |   |   |   \-- relatorio_iba_2020.pdf
    #> |   |   |   \-- 02-IBGE
    #> |   |   |       \-- snif_2019_dados_estaduais_ibge.pdf
    #> |   |   +-- 02-PR
    #> |   |   |   \-- 01-APRE
    #> |   |   |       +-- apre_estudo_setorial_2017-2018.pdf
    #> |   |   |       \-- apre_estudo_setorial_2020.pdf
    #> |   |   +-- 03-SC
    #> |   |   |   \-- acr_anuario_estatistico_2019.pdf
    #> |   |   +-- 04-RS
    #> |   |   |   +-- ageflor_setor_florestal_2017.pdf
    #> |   |   |   \-- ageflor_setor_florestal_2020.pdf
    #> |   |   \-- 05-MT
    #> |   |       \-- famato_diagnostico_florestas_plantadas_2013.pdf
    #> |   \-- rds
    #> |       \-- PR_IFPR_SFB_2015.rds
    #> +-- inst
    #> +-- R
    #> |   +-- 01-fn-empilhar-municipios-ageflor-2017.R
    #> |   +-- 02-fn-faxinar-tab-geral-ageflor-2020.R
    #> |   \-- 03-fn-faxinar-tab-municipios-ageflor-2020.R
    #> +-- README.md
    #> \-- README.Rmd
