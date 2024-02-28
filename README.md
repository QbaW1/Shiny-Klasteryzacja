# Cel projektu  
Głównym celem projektu było stworzenie prostego interaktywnego narzędzia Shiny, które umożliwi klasteryzację szeregów czasowych.   
Dane używane do klasteryzacji pochodzą z portalu *stooq* i odnoszą się do 8 największych spółek pod względem wolumenu transakcji.  
Aplikacja umożliwia generowanie dendrogramów oraz wykresów liniowych przy użyciu dwóch różnych metod grupowania: "complete" oraz "ward.D".  

# Obsługa  
Projekt zawiera trzy zakładki, które prezentują:
- Dendogramy
- Wykresy liniowe
- Średnie w każdej z grup

Aby generować wartości, należy wybrać jedną z metod grupowania za pomocą przycisków "complete" lub "ward.D".   
Wartości te można dostosować za pomocą suwaków, umożliwiających regulację liczby obserwacji w zakresie od 1 do 60.   
Dodatkowo, na wykresy liniowe można wpłynąć, wybierając liczbę grup z dostępnej listy.
