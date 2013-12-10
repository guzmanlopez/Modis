library(shiny)

# MODIS

shinyUI(pageWithSidebar(
  
  #### Título de la Aplicación ####
  
  headerPanel(title="MODIS - Río de la Plata", windowTitle="Figura MODIS para Río de la Plata"), 
  
  #### Sidebar ####
  sidebarPanel(
    
    imageOutput(outputId="logo",height=70), ### LOGO
    tags$hr(),
    
    conditionalPanel(condition="input.tabs=='MODIS'",
      
    wellPanel(
    selectInput('satelite', 'Satélite:', c('Terra'='terra', 'Aqua'='aqua'),'Aqua', FALSE)
    ),
    
    wellPanel(
    
    conditionalPanel(
      condition="input.satelite=='aqua'",
      radioButtons('sat', 'Combinación de bandas:', list('Color verdadero'='aqua', 'Bandas 7/2/1'='aqua.721', 'Índice de Vegetación de Diferencia Normalizada (NDVI)'='aqua.ndvi')),
      selectInput('res','Resolución:',c('2 km'='2km', '1 km'='1km', '500 m'='500m', '250 m'='250m')),
      dateInput('fecha', 'Fecha:', language='es', min="2002-05-04", max=Sys.Date()-1, value=Sys.Date()-1)
      ),
    
    conditionalPanel(
      condition="input.satelite=='terra'",
      radioButtons('sat', 'Combinación de bandas:', list('Color verdadero'='terra', 'Bandas 7/2/1'='terra.721', 'Bandas 3/6/7'='terra.367', 'Índice de Vegetación de Diferencia Normalizada (NDVI)'='terra.ndvi')),
      selectInput('res','Resolución:',c('2 km'='2km', '1 km'='1km', '500 m'='500m', '250 m'='250m')),
      dateInput('fecha', 'Fecha:', language='es', min="2000-02-24", max=Sys.Date()-1, value=Sys.Date()-1)
      ),
    
    HTML("<button id=\"actualizar\" type=\"button\" class=\"btn action-button btn-primary\">Actualizar</button>")
    ),
    
    wellPanel(
    uiOutput(outputId='descarga_tiff')
      )
    ),
    
    ### CAPAS
    
    conditionalPanel(condition="input.tabs=='SIG'",
                     wellPanel(strong('Capas'),
                      checkboxGroupInput('capas',
                                         '',
                                         c('Línea de costa'='costa',
                                           'Límite del Río de la Plata'='limite_RdelaP',
                                           'Zonas jurídicas'='zonas_juridicas',
                                           'Centros poblados' ='centros_poblados'))
                      ),
                                         
                     wellPanel(
                       strong('Cargar puntos (Lon, Lat, ID)'),
                       br(),
                       fileInput('upload', '', multiple=FALSE, accept=c('text/csv', 'text/comma-separated-values, text/plain'))
                       ),
                     conditionalPanel(
                       condition="input.upload!=NULL",
                       wellPanel(strong('Puntos'),
                                 uiOutput(outputId='tam_puntos'),
                                 br(),
                                 uiOutput(outputId='col_puntos'),
                                 tags$hr(),
                                 strong('Etiquetas'),
                                 uiOutput(outputId='tamtexto'))
                     )
                     )
    ),
  
  #### Mainpanel ####
    
  mainPanel(tabsetPanel(id="tabs",
                        tabPanel("MODIS", plotOutput("modis")), # Figura Modis
                        tabPanel("SIG", plotOutput("sig")), # Figura SIG
                        tabPanel("Acerca de esta APP",
                                   h3(p(strong('Descripción'))),
                                   p(style="text-align:justify",'Esta aplicación web de R con Shiny se encuentra en desarrollo.'),
                                   p(style="text-align:justify",'Esta aplicación le permite al usuario visualizar y descargar figuras MODIS del Río de la Plata junto con otras capas espaciales. Está siendo desarrollada en el marco del Proyecto FREPLATA URU/09/G31 dentro del', em('"Programa de Monitoreo y Evaluación y Sistema de Información Integrado y establecido para la toma de decisiones y la Gestión del Río de la Plata y su Frente Marítimo".'),'El objetivo es generar una herramienta que permita a los usuarios acceder facilmente a las figuras MODIS del Río de la Plata para un determinado momento y ubicar puntos de interés sobre esta área de estudio.'),
                                   
                                   p(style="text-align:justify",'Todo el software empleado para desarrollar esta aplicación es libre, eso quiere decir que garantiza al usuario la libertad de poder usarlo, estudiarlo, compartirlo (copiarlo), y modificarlo. El software R es un proyecto colaborativo con muchos contribuyentes.'),
                                   
                                   h3(p(strong('Referencias'))),
                                   
                                   p(style="text-align:justify",strong('R Core Team (2013).'),'R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. ISBN 3-900051-07-0, URL',a("http://www.R-project.org/", href="http://www.R-project.org/",target="_blank")),
                                   
                                   p(style="text-align:justify",strong('RStudio and Inc. (2013).'),'shiny: Web Application Framework for R. R package version 0.6.0.',a("http://CRAN.R-project.org/package=shiny", href="http://CRAN.R-project.org/package=shiny",target="_blank")),
                                   p(style="text-align:justify",strong('Dan Kelley (2013).'),'oce: Analysis of Oceanographic data. R package version 0.9-12.',a("http://CRAN.R-project.org/package=oce",href="http://CRAN.R-project.org/package=oce",target="_blank")),
                                   p(style="text-align:justify",strong('Markus Gesmann and Diego de Castillo.'),'Using the Google Visualisation API with R. The R Journal, 3(2):40-44, December 2011.'),
                                   
                                   p(style="text-align:justify",strong('Karoly Antal. (2012).'),'gnumeric: Read data from files readable by gnumeric. R package version 0.7-2.',a("http://CRAN.R-project.org/package=gnumeric",href="http://CRAN.R-project.org/package=gnumeric",target="_blank")),
                                   tags$hr(),
                                   HTML('<div style="clear: left;"><img src="https://dl.dropboxusercontent.com/u/49775366/Shiny/foto_perfil.jpg" alt="" style="float: left; margin-right:5px" /></div>'),
                                   strong('Autor'),
                                   p(a('Guzmán López', href="http://www.linkedin.com/pub/guzm%C3%A1n-l%C3%B3pez/59/230/812", target="_blank"),' - guzilop@gmail.com',
                                     br(),
                                     'Biólogo | Asistente para el manejo de información oceanográfica',
                                     br(),
                                     a('Proyecto FREPLATA - URU/09/G31', href="http://www.freplata.org/", target="_blank")),
                                   br()) # Acerca de este programa
    ))
  ))
        
        
    
