# MODIS

library(shiny)
library(RCurl)
library(jpeg)
library(raster)
library(maptools)
library(rgeos)
library(rgdal)


costa <- readShapeLines(fn="~/Git/MODIS/shapes/linea_de_costa.shp", proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 towgs84=0,0,0"))

zonas_juridicas <- readShapePoly(fn="~/Git/MODIS/shapes/zonas_juridicas.shp", proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 towgs84=0,0,0"))

centros_poblados <- readShapePoints(fn="~/Git/MODIS/shapes/seleccion_centros_poblados.shp", proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 towgs84=0,0,0"))

limite_RdelaP <- readShapeLines(fn="~/Git/MODIS/shapes/LIMITES_RPLATA.shp", proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 towgs84=0,0,0"))


shinyServer(function(input, output) {
  
  ### Logos
  output$logo <- renderImage({
    
    filename <- "/home/guzman/Documentos/FREPLATA/R/GUI/LOGO_MODIS_APP.png"
    list(src = filename, contentType = 'image/png')
    }, deleteFile= FALSE)
  
  ### Entradas de datos ####
  datasetInput_URL <- reactive({
    
    if (input$actualizar == 0) return(NULL) else isolate ({
      
      fecha <- paste(substr(x=input$fecha,start=1,stop=4),strftime(input$fecha, format = "%j"),sep="")
      
      url <- paste("http://rapidfire.sci.gsfc.nasa.gov/imagery/subsets/?subset=AERONET_CEILAP-BA", fecha, input$sat, input$res, "jpg", sep=".")
      
      return(url)    
  })
    
  })
  datasetInput_modis_ <- reactive({
    
      image <- getBinaryURL(url=datasetInput_URL())
      
      CP <- as(extent(costa), "SpatialPolygons")
      proj4string(CP) <- CRS(proj4string(costa))
      
      limites <- datasetInput_extent()
      
      array <- readJPEG(image, native=FALSE)
      r <- raster(array[,,2])
      
      projection(r) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 towgs84=0,0,0"
      
      extent(r) <- c(limites[1], limites[2], limites[3], limites[4])
      
      r <- crop(x=image, y=CP)
      
      return(r)
      
      })
  datasetInput_tamaño <- reactive({
    if(input$res == '2km') {
      tamaño <- c(480,360)
    }
    if(input$res == '1km') {
      tamaño <- c(960,720)
    }
    if(input$res == '500m') {
      tamaño <- c(1920,1440)
    }
    if(input$res == '250m') {
      tamaño <- c(3840,2880)
    }
    return(tamaño)
    })
  datasetInput_extent <- reactive({
    
    isolate ({
      
      fecha <- paste(substr(x=input$fecha,start=1,stop=4),strftime(input$fecha, format = "%j"),sep="")
      
      url <- paste("http://rapidfire.sci.gsfc.nasa.gov/imagery/subsets/?subset=AERONET_CEILAP-BA", fecha, input$sat, input$res, "txt", sep=".")
      
    extent <- getURL(url=url)
    extent <- strsplit(extent, split="\n")
    limites <- c(as.numeric(substr(x=extent[[1]][7],start=9,stop=16)),
                 as.numeric(substr(x=extent[[1]][9],start=9,stop=16)),
                 as.numeric(substr(x=extent[[1]][12],start=9,stop=16)),
                 as.numeric(substr(x=extent[[1]][10],start=9,stop=16)))
      
      return(limites)
      })
    })
  datasetInput_modis_jpg <- reactive({
    
    image <- getBinaryURL(url=datasetInput_URL())
    jpg <- readJPEG(image, native=TRUE)
    
    return(jpg)
    
  })
  
  ### Figura MODIS ####
  output$modis <- renderPlot(width=900, height=840, {
    
    if(input$actualizar==0) return(NULL)
    jpg <- datasetInput_modis_jpg()
    limites <- datasetInput_extent()
    extent <- union(x=extent(costa), y=extent(zonas_juridicas))
    par(mar=c(0,0,0,0))
    plot(x=c(extent@xmin,limites[2]), y=c(limites[3],extent@ymax), type="n", ylab="", xlab="", xaxs="i", yaxs="i")
    rasterImage(jpg, xleft=limites[1], ybottom=limites[3], xright=limites[2], ytop=limites[4])
    
  })
   
  ### SIG ####
  output$sig <- renderPlot(width=900, height=840, {
    
    if(input$actualizar==0) return(NULL)
    jpg <- datasetInput_modis_jpg()
    limites <- datasetInput_extent()
    extent <- union(x=extent(costa), y=extent(zonas_juridicas))
    par(mar=c(0,0,0,0))
    plot(x=c(extent@xmin,limites[2]), y=c(limites[3],extent@ymax), type="n", ylab="", xlab="", xaxs="i", yaxs="i")
    rasterImage(jpg, xleft=limites[1], ybottom=limites[3], xright=limites[2], ytop=limites[4])
    
    if(any(input$capas=="costa")) plot(costa, col="black", add=T)
    if(any(input$capas=="zonas_juridicas")) plot(zonas_juridicas, col="transparent", border="orange", add=T)
    if(any(input$capas=="limite_RdelaP")) plot(limite_RdelaP, col="red", add=T)
    if(any(input$capas=="centros_poblados")) {
      plot(centros_poblados, col="grey", pch=19, cex=1, add=T)
      text(centros_poblados, labels=centros_poblados$CENTRO, cex=0.9, font=2, pos=3)
    }
    
    ### Subir Archivos    
    # CSV
    inFile_csv <- input$upload
    if (is.null(inFile_csv)) return(NULL) else {
      
      puntos <- read.csv(inFile_csv$datapath, header=TRUE, sep=",")
      puntos <- SpatialPointsDataFrame(coords=data.frame(lon=puntos[,1], lat=puntos[,2]), data=data.frame(ID=puntos[,3]), proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 towgs84=0,0,0"))

      plot(puntos, add=T, cex=input$tam, col=input$col, pch=19)
      text(puntos, labels=puntos$ID, cex=input$tam_texto, font=2, pos=3, col="grey")
      }
    })
  
  output$tam_puntos <- renderUI({
    
    inFile_csv <- input$upload
    if (is.null(inFile_csv)) return(NULL) else {
    sliderInput('tam',label="", min=0, max=2, value=1, step=0.2)
    }
    
  })
  output$col_puntos <- renderUI({
    
    inFile_csv <- input$upload
    if (is.null(inFile_csv)) return(NULL) else {
    selectInput('col','', list('Negro'="black", 'Rojo'="red", 'Verde'="green", 'Azul'="blue", 'Amarillo'="yellow"))
    }
    
  })
  output$tamtexto <- renderUI({
    
    inFile_csv <- input$upload
    if (is.null(inFile_csv)) return(NULL) else {
    sliderInput('tam_texto', label="", min=0, max=2, value=1, step=0.2)
    }
    
  })
    
  ### Descarga GeoTIFF ####
output$descarga_tiff <- renderUI({
      
      fecha <- paste(substr(x=input$fecha,start=1,stop=4),strftime(input$fecha, format = "%j"),sep="")
      url <- paste("http://rapidfire.sci.gsfc.nasa.gov/imagery/subsets/?subset=AERONET_CEILAP-BA", fecha, input$sat, input$res, "tif", sep=".")  
        
 HTML(paste('<a id=\"descarga\" class=\"btn shiny-download-link btn-success\"','href=\"',url,'\" target=\"_blank\">Descargar GeoTIFF</a>'))
    
})
  
})


  
