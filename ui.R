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
    strong('Satélite'),
    selectInput('satelite', '', c('Terra'='terra', 'Aqua'='aqua'),'Aqua', FALSE)
    ),
    
    wellPanel(
      
      strong('Combinación de bandas'),
    
    conditionalPanel(
      condition="input.satelite=='aqua'",
      radioButtons('sat', '', list('Color verdadero'='aqua', 'Bandas 7-2-1'='aqua.721', 'Índice de Vegetación de Diferencia Normalizada (NDVI)'='aqua.ndvi')),
      selectInput('res','Resolución:',c('2 km'='2km', '1 km'='1km', '500 m'='500m', '250 m'='250m')),
      dateInput('fecha', 'Fecha:', language='es', min="2002-05-04", max=Sys.Date()-1, value=Sys.Date()-1)
      ),
    
    conditionalPanel(
      condition="input.satelite=='terra'",
      radioButtons('sat', '', list('Color verdadero'='terra', 'Bandas 7-2-1'='terra.721', 'Bandas 3-6-7'='terra.367', 'Índice de Vegetación de Diferencia Normalizada (NDVI)'='terra.ndvi')),
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
                     wellPanel(strong('Capas espaciales'),
                      checkboxGroupInput('capas',
                                         '',
                                         c('Línea de costa'='costa',
                                           'Límite del Río de la Plata'='limite_RdelaP',
                                           'Zonas jurídicas'='zonas_juridicas',
                                           'Centros poblados' ='centros_poblados',
                                           'Estaciones de Monitoreo Ambiental' ='ema'))
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
                                   p(style="text-align:justify",'Esta aplicación web de R con Shiny le permite al usuario visualizar y descargar imágenes MODIS del Río de la Plata junto con otras capas espaciales. Está siendo desarrollada en el marco del Proyecto FREPLATA URU/09/G31 dentro del', em('"Programa de Monitoreo y Evaluación y Sistema de Información Integrado y establecido para la toma de decisiones y la Gestión del Río de la Plata y su Frente Marítimo".'),'El objetivo es generar una herramienta que permita a los usuarios acceder facilmente a las imágenes MODIS del Río de la Plata para un determinado momento y ubicar puntos de interés sobre esta área de estudio.'),
                                   
                                 p(style="text-align:justify",'La mayor parte del software empleado para desarrollar esta aplicación es libre, eso quiere decir que garantiza al usuario la libertad de poder usarlo, estudiarlo, compartirlo (copiarlo), y modificarlo. El software R es un proyecto de software libre que es colaborativo y tiene muchos contribuyentes.'),
                                 tags$hr(),
                                 h3(p(strong('Créditos'))),
                                 p(style="text-align:justify",strong('NASA/GSFC, MODIS Rapid Response')),
                                 p('Contacto:',a('Coordinador de Divulgación de MODIS Rapid response', href="mailto:Holli.Riebeek@nasa.gov?subject=Rapid%20Response%20Request",target='_blank')),
                                 p('Sitio web:',a('NASA/GSFC, MODIS Rapid Response', href='https://earthdata.nasa.gov/data/near-real-time-data/rapid-response',target='_blank')),        
                                 
                                 tags$hr(),
                                 h3(p(strong('Guía de usuario'))),
                                 HTML('<div style="clear: left;"><img src="https://dl.dropboxusercontent.com/u/49775366/Ema/PDF.png" alt="" style="width: 5%; height: 5%; float: left; margin-right:5px" /></div>'),
                                 br(),
                                 a('MODIS web app', href="https://dl.dropboxusercontent.com/u/49775366/MODIS/Gu%C3%ADa%20de%20usuario%20MODIS%20web%20app.pdf", target="_blank"),
                                 tags$hr(),
                                 h3(p(strong('Código fuente'))),
                                 HTML('<div style="clear: left;"><img src="https://dl.dropboxusercontent.com/u/49775366/Ema/github-10-512.png" alt="" style="width: 5%; height: 5%; float: left; margin-right:5px" /></div>'),
                                 br(),
                                 a('Repositorio GitHub', href="https://github.com/guzmanlopez/Modis.git", target="_blank"),
                                 tags$hr(),
                                 h3(p(strong('Referencias'))),
                                 p(style="text-align:justify",strong('R Core Team (2013).'),'R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. ISBN 3-900051-07-0, URL',a("http://www.R-project.org/",href="http://www.R-project.org/",target="_blank")),
                                 p(style="text-align:justify",strong('RStudio and Inc. (2013).'),'shiny: Web Application Framework for R. R package version 0.8.0.',a("http://CRAN.R-project.org/package=shiny", href="http://CRAN.R-project.org/package=shiny",target="_blank")),
                                 
                                 p(style="text-align:justify",strong('Duncan Temple Lang (2013).'),'RCurl: General network (HTTP/FTP/...) client interface for R. R package version 1.95-4.1.',a("http://CRAN.R-project.org/package=RCurl",href="http://CRAN.R-project.org/package=RCurl")),
                                 
                                 p(style="text-align:justify",strong('Markus Gesmann & Diego de Castillo.'),'Using the Google Visualisation API with R. The R Journal, 3(2):40-44, December 2011.'),
                                 
                                     
                                 p(style="text-align:justify",strong('Simon Urbanek (2013).'),'jpeg: Read and write JPEG  images. R package version 0.1-6.',a("http://CRAN.R-project.org/package=jpeg",href="http://CRAN.R-project.org/package=jpeg",target="_blank")),
                                
                                 p(style="text-align:justify",strong('Robert J. Hijmans (2013).'),'raster: Geographic data analysis and modeling. R package  version 2.1-66.',a("http://CRAN.R-project.org/package=raster",href="http://CRAN.R-project.org/package=raster", target="_blank")),
                                 
                                 p(style="text-align:justify",strong('Roger Bivand and Nicholas Lewin-Koh (2013).'),'maptools: Tools for reading and handling spatial objects. R package version 0.8-27.',a("http://CRAN.R-project.org/package=maptools",href="http://CRAN.R-project.org/package=maptools", target="_blank")),    
                                 
                                 p(style="text-align:justify",strong('Roger Bivand and Colin Rundel (2013).'),'rgeos: Interface to Geometry Engine - Open Source  (GEOS). R package version 0.3-2.',a(" http://CRAN.R-project.org/package=rgeos",href=" http://CRAN.R-project.org/package=rgeos", target="_blank")),
                                 
                                 p(style="text-align:justify",strong('Roger Bivand and Colin Rundel (2013).'),'rgdal: Bindings for the Geospatial Data Abstraction Library. R package version 0.8-14.',a("http://CRAN.R-project.org/package=rgdal",href="http://CRAN.R-project.org/package=rgdal", target="_blank")),
                                 
                                   
                                 
                                    
                                 
                                 tags$hr(),
                                 HTML('<div style="clear: left;"><img src="https://dl.dropboxusercontent.com/u/49775366/Ema/foto_perfil.jpg" alt="" style="float: left; margin-right:5px" /></div>'),
                                 strong('Autor'),
                                 p(a('Guzmán López', href="http://www.linkedin.com/pub/guzm%C3%A1n-l%C3%B3pez/59/230/812", target="_blank"),' - guzilop@gmail.com',br(),'Biólogo | Asistente para el manejo de información oceanográfica',br(),a('Proyecto FREPLATA - URU/09/G31',href="http://www.freplata.org/", target="_blank")),
                                 br()) # Acerca de este programa
  ))
))
        
    
