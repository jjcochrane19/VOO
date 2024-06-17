library(dplyr)
library(tidyverse)
library(ggplot2)
library(googlesheets4)
library(dplyr)

url = "https://docs.google.com/spreadsheets/d/1BX3usGHx1Chf98rI7OXaZHXuJKiyutu-AAz0X73TX7Q/edit#gid=2082717798"

#gs4_auth()

sheet = gs4_get(url)

voo = sheet %>% 
  range_read("Sheet3")  # Adjust sheet name if necessary

write.csv(voo, "voo.csv", row.names = FALSE)

voo = voo %>%
  mutate(
    Close = as.numeric(gsub("\\$", "", Close)),
    Date = as.Date(Date, format = "%m/%d/%Y"))

model = lm(Close ~ Date, data = voo)
voo = voo %>%
  mutate(
    Predicted = predict(model),
    Upper = Predicted * 1.03,
    Lower = Predicted * 0.97
  )

plot = ggplot(voo, aes(x = Date, y = Close)) +
  geom_point(color = "blue") +  
  geom_line(color = "skyblue") +  
  geom_line(aes(y = Predicted), color = "red") +
  geom_line(aes(y = Upper), color = "green", linetype = "dashed") +
  geom_line(aes(y = Lower), color = "green", linetype = "dashed") +
  geom_text(aes(x = max(Date), y = Upper[Date == max(Date)], 
                label = paste("$", round(Upper[Date == max(Date)], 2))), 
            vjust = -1, hjust = 1.1) +
  geom_text(aes(x = max(Date), y = Lower[Date == max(Date)], 
                label = paste("$", round(Lower[Date == max(Date)], 2))), 
            vjust = 3, hjust = 1.1) +
  labs(title = "Vanguard VOO S&P 500 Tracker Trendline and 3% Boundaries",
       subtitle = "Data from 10/1/2022 - Today",
       x = "Date",
       y = "Close Price")+
  scale_y_continuous(breaks = seq(0, ceiling(max(voo$Close)), by = 10))

ggsave(filename = "voo.png", plot = plot, width = 14, height = 10, dpi = 800)
