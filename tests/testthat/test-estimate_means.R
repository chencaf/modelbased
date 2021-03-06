if (require("testthat") && require("modelbased") && require("rstanarm") && require("insight")) {
  test_that("estimate_means", {
    data <- mtcars
    data$gear <- as.factor(data$gear)

    model <- suppressWarnings(rstanarm::stan_glm(mpg ~ wt * gear, data = data, refresh = 0, iter = 200, chains = 2))
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 4))

    data$cyl <- as.factor(data$cyl)
    model <- suppressWarnings(rstanarm::stan_glm(vs ~ cyl, data = data, refresh = 0, iter = 200, chains = 2))
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 4))



    data <- iris
    data$Petal.Length_factor <- ifelse(data$Petal.Length < 4.2, "A", "B")

    model <- suppressWarnings(rstanarm::stan_glm(Sepal.Width ~ Species * Petal.Length_factor, data = data, refresh = 0, iter = 200, chains = 2))
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(6, 5))

    model <- suppressWarnings(rstanarm::stan_glm(Petal.Length ~ Sepal.Width + Species, data = iris, refresh = 0, iter = 200, chains = 2))
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 4))

    estim <- estimate_means(model, modulate = "Sepal.Width")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(30, 5))

    df <- iris
    df$y <- as.numeric(as.factor(ifelse(df$Sepal.Width > 3, "A", "B"))) - 1
    model <- rstanarm::stan_glm(y ~ Species, family = "binomial", data = df, refresh = 0, iter = 200, chains = 2)

    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 4))
    estim <- estimate_means(model, transform = "response")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 4))
    testthat::expect_true(all(estim$Probability >= 0) & all(estim$Probability <= 1))


    model <- lm(Petal.Length ~ Sepal.Width + Species, data = iris)
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))

    estim <- estimate_means(model, modulate = "Sepal.Width")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(30, 6))

    # In formula modification
    model <- lm(mpg ~ wt * as.factor(gear), data = mtcars)
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))



    # One continuous and one factor
    model <- lm(Petal.Length ~ Species * Sepal.Width, data = iris)

    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))
    estim <- estimate_means(model, fixed = "Sepal.Width")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 6))
    estim <- estimate_means(model, levels = c("Species", "Sepal.Width"), length = 2)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(6, 6))
    estim <- estimate_means(model, levels = "Species=c('versicolor', 'setosa')")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(2, 5))
    estim <- estimate_means(model, levels = "Sepal.Width=c(2, 4)")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(2, 5))
    estim <- estimate_means(model, levels = c("Species", "Sepal.Width=0"))
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 6))
    estim <- estimate_means(model, modulate = "Sepal.Width", length = 5)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(15, 6))
    estim <- estimate_means(model, modulate = "Sepal.Width=c(2, 4)")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(6, 6))

    # Two factors
    data <- iris
    data$Petal.Length_factor <- ifelse(data$Petal.Length < 4.2, "A", "B")
    model <- lm(Petal.Length ~ Species * Petal.Length_factor, data = data)

    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(6, 6))
    estim <- estimate_means(model, fixed = "Petal.Length_factor")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 6))
    estim <- estimate_means(model, fixed = "Petal.Length_factor='B'")
    testthat::expect_true(as.character(unique(estim$Petal.Length_factor)) == "B")


    # Three factors
    data <- mtcars
    data[c("gear", "vs", "am")] <- sapply(data[c("gear", "vs", "am")], as.factor)
    model <- lm(mpg ~ gear * vs * am, data = data)

    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(12, 7))
    estim <- estimate_means(model, fixed = "am")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(6, 7))
    estim <- estimate_means(model, fixed = "gear='5'")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(4, 7))

    data <- iris
    data$factor1 <- ifelse(data$Sepal.Width > 3, "A", "B")
    data$factor2 <- ifelse(data$Petal.Length > 3.5, "C", "D")
    data$factor3 <- ifelse(data$Sepal.Length > 5, "E", "F")

    model <- lm(Petal.Width ~ factor1 * factor2 * factor3, data = data)
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(8, 7))
    estim <- estimate_means(model, fixed = "factor3")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(4, 7))
    estim <- estimate_means(model, fixed = "factor3='F'")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(4, 7))
    estim <- estimate_means(model, modulate = "factor2")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(8, 7))


    # Mixed models
    if (require("lme4")) {
      data <- iris
      data$Petal.Length_factor <- as.factor(ifelse(data$Petal.Length < 4.2, "A", "B"))

      model <- lme4::lmer(Sepal.Width ~ Species + (1 | Petal.Length_factor), data = data)

      estim <- estimate_means(model)
      testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))

      model <- lme4::glmer(Sepal.Width ~ Species + (1 | Petal.Length_factor), data = data, family = "Gamma")

      estim <- estimate_means(model)
      testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))
    }

    # GLM
    data <- iris
    data$Petal.Length_factor <- as.factor(ifelse(data$Petal.Length < 4.2, "A", "B"))
    model <- glm(Petal.Length_factor ~ Species, data = data, family = "binomial")

    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))
    estim <- estimate_means(model, transform = "none")
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))

    model <- glm(Petal.Length ~ Species, data = iris, family = "Gamma")
    estim <- estimate_means(model)
    testthat::expect_equal(c(nrow(estim), ncol(estim)), c(3, 5))
  })
}
