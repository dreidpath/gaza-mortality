# Plot of the cumulative deaths of the days of the Gaza war. These are modeled
# numbers based on Al Jazeera reporting.  The figures for women and children 
# reflect deaths of "at least" that magnitude. The deaths of men reflect deaths 
# strictly less than the figure shown.  The total, however, is correctly reported.
# Thus the figures for women and children could increase, the figures for men 
# could decrease, but the total remains the same.
dDF %>%
  mutate(day = 1:nrow(.),
         total = mg_dead_total - (mg_dead_child + mg_dead_women)) %>%
  select(day, total, child = mg_dead_child, women = mg_dead_women) %>%
  pivot_longer(cols = c(total, child, women),
               names_to = "class",
               values_to = "count") %>% 
  mutate(class = factor(class, levels = c("total", "women", "child")) ) %>%
  ggplot(aes(x=day, y=count, fill=class)) + 
  geom_area() +
  geom_hline(yintercept = 1139, linetype = "dashed") +
  geom_text(aes(x = 50, y = 1139, label = "Deaths in Israel since 7 October 2023"),
            hjust = 0, vjust = -.5, size = 2, color = "darkslategray") +
  ylab("Cumulative Deaths") +
  xlab("Days of War") +
  scale_fill_manual(name = "Group", 
                    labels = c("Men (<)", "Women (≥)", "Children (≥)"), 
                    values = c("darkred", "indianred", "pink")) +
  theme_bw()
# Plot of the cumulative deaths of the days of the Gaza war. These are modeled
# numbers based on Al Jazeera reporting.  The figures for women and children 
# reflect deaths of "at least" that magnitude. The deaths of men reflect deaths 
# strictly less than the figure shown.  The total, however, is correctly reported.
# Thus the figures for women and children could increase, the figures for men 
# could decrease, but the total remains the same.
dDF %>%
  mutate(day = 1:nrow(.),
         men = 1 - (mg_prop_womendeaths + mg_prop_childdeaths)) %>%
  select(day, men, child = mg_prop_childdeaths, women = mg_prop_womendeaths) %>%
  pivot_longer(cols = c(men, child, women),
               names_to = "class",
               values_to = "count") %>% 
  mutate(class = factor(class, levels = c("men", "women", "child")) ) %>%
  ggplot(aes(x=day, y=count, fill=class)) + 
  geom_area() +
  ylab("Proportion of Cumulative Deaths") +
  xlab("Days of War") +
  scale_fill_manual(name = "Group", 
                    labels = c("Men (<)", "Women (≥)", "Children (≥)"), 
                    values = c("darkred", "indianred", "pink")) +
  theme_bw()


# Plot of the cumulative deaths of the days of the Gaza war. These are modeled
# numbers based on Al Jazeera reporting.  The figures for women and children 
# reflect deaths of "at least" that magnitude. The deaths of men reflect deaths 
# strictly less than the figure shown.  The total, however, is correctly reported.
# Thus the figures for women and children could increase, the figures for men 
# could decrease, but the total remains the same.
dDF %>%
  mutate(day = 1:138,
         men = 1 - (mg_prop_womendeaths + mg_prop_childdeaths)) %>%
  select(day, men, child = mg_prop_childdeaths, women = mg_prop_womendeaths) %>%
  pivot_longer(cols = c(men, child, women),
               names_to = "class",
               values_to = "count") %>% 
  mutate(class = factor(class, levels = c("men", "women", "child")) ) %>%
  ggplot(aes(x=day, y=count, fill=class)) + 
  geom_area() +
  ylab("Proportion of Cumulative Deaths") +
  xlab("Days of War") +
  scale_fill_discrete(name = "Group", labels = c("Men (<)", "Women (≥)", "Children (≥)")) +
  theme_bw()
