frb_scatter <-
  combined_mods %>%
  ggplot(aes(x = truth, y = corrected_pred, color = corrected_gap)) +
  # abline of true age above other elements for vis
  geom_abline(lty = 1, color = "#cccccc", size = 1.2) +
  geom_point(size = 5, alpha = 0.5) +
  # linear trend of mod
  geom_smooth(
    method = lm, formula = y ~ x,
    # line color
    color = "#ff0091",
    # confidence interval color
    fill = "#0091ff"
  ) +
  # labels
  labs(
    title = "Brain age prediction in validation and independent test set",
    subtitle = "Scatterplot showing predicted brain age by actual chronological / scan age",
    x = "Scan age",
    y = "Predicted age",
    caption = "Warmer colors indicate a positive brain age gap (older appearing brain); 
    cooler colors a negative brain age gap (younger appearing brain)"
  ) +
  # theme setup
  theme_ipsum_rc() +
  theme(legend.position = "none") +
  # scales
  scale_x_continuous(breaks = scales::breaks_width(2)) +
  scale_y_continuous(breaks = scales::breaks_width(2)) +
  # gradient color
  scale_color_gradient(low = "#0091ff", high = "#f0650e") +
  facet_grid(~model)

frb_scatter