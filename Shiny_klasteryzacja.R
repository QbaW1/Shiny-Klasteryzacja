library(shiny)
library(shinydashboard)
library(clusterSim)

# Dane
symbole <- c("tsla", "amd", "nvda", "jnpr", "aapl", "amzn", "f", "pfe")
szereg_czasowy <- NULL

# Pobranie danych dla poszczególnych symboli
for (x in symbole) {
  dane <- read.csv(paste0("https://stooq.pl/q/d/l/?s=", x,
                          ".us&c=0&d1=20190110&d2=20240110&o=1000000&i=m&o_s=1"))
  szereg_czasowy <- cbind(szereg_czasowy, dane$Wolumen)
}
colnames(szereg_czasowy) <- symbole

szereg_czasowy <- na.omit(round(szereg_czasowy, 2))

feature_scaling <- function(x) {
  x <- (x - min(x))/(max(x) - min(x))
  return(x)
}
szereg_czasowy_norm <- apply(szereg_czasowy, 2, feature_scaling)

# UI Shiny Dashboard
ui <- dashboardPage(
  dashboardHeader(title = "Klasteryzacja szeregów czasowych"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dendogram", tabName = "Dane", icon = icon("th"),
               badgeLabel = "Wykres", badgeColor = "red"),
      menuItem("Wykres liniowy", icon = icon("th"), tabName = "Wykres",
               badgeLabel = "Wykres", badgeColor = "red"),
      menuItem("Średnie w grupach", icon = icon("th"), tabName = "Mean",
               badgeLabel = "Tabela", badgeColor = "blue")
    ),
    selectInput(
      'Grupy', label = "Wybierz liczbę grup",
      choices = c(1:3), 
      multiple = FALSE, selected = 1
    ),
    sliderInput("slider", "Liczba obserwacji:", 2, 60, 30),
    actionButton("w1", "complete"),
    actionButton("w2", "ward.D")
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Dane", plotOutput("DanePlot")),
      tabItem(tabName = "Wykres", plotOutput("wykresliniowy")),
      tabItem(tabName = "Mean", tableOutput("grmean"))
    )
  )
)

# Serwer Shiny
server <- function(input, output) {
  metoda <- reactiveVal(NULL)  # Inicjalizacja reactiveVal na początku
  
  observeEvent(input$w1, {
    metoda("complete")  # Używam reactiveVal() jako funkcji do ustawiania wartości
  })
  
  observeEvent(input$w2, {
    metoda("ward.D")  
  })
  
  output$DanePlot <- renderPlot({
    dd <- as.dist((1 - cor(szereg_czasowy_norm[1:input$slider, ]))/2)
    
    if (is.null(metoda())) return()
    hc <- hclust(dd, method = metoda())
    hcd <- as.dendrogram(hc)
    plot(hcd, main = "Dendrogram", "triangle", 
         edgePar = list(col = 2:3, lwd = 2:1),
         xlab = NULL, ylab = "Wysokość")
  })
  
  output$wykresliniowy <- renderPlot({
    
    if (is.null(metoda())) return()
    
    gr <- cutree(hclust(as.dist((1 - cor(szereg_czasowy_norm[1:input$slider, ]))/2), 
                        method = metoda()), k = 3)
    
    matplot(szereg_czasowy_norm[1:input$slider, gr == input$Grupy], type = "l", 
            xlab = NULL, 
            ylab = "Wysokość",
            main = paste("Wykresy liniowy dla", input$Grupy, "liczby grup"))
  })
  
  output$grmean <- renderTable({
    
    if (is.null(metoda())) return()
    
    gr <- cutree(hclust(as.dist((1 - cor(szereg_czasowy_norm[1:input$slider,]))/2), method = metoda()), k = 3)
    sr.gr <- aggregate(t(szereg_czasowy_norm[1:input$slider,]), by = list(gr), FUN = mean)
    sr.gr <- t(sr.gr)
    colnames(sr.gr)<- c("gr.1", "gr.2", "gr.3")
    sr.gr
  })
}

# Uruchomienie aplikacji
shinyApp(ui = ui, server = server)
