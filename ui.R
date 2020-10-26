ui <- dashboardPage(
	dashboardHeader(title = "University of California Small Grain Seeding Rate Calculator", titleWidth = 600),
	dashboardSidebar(disable = TRUE,
									 sidebarMenu(id = "tabs", menuItem("one_dash", tabName = "one_dash")
									 						)
									 ),
	dashboardBody(
		shinyjs::useShinyjs(),
		tags$head(tags$style(HTML('
        /* logo */
        .skin-blue .main-header .logo {
                              background-color: #005fae;
        }
                              /* logo when hovered */
        .skin-blue .main-header .logo:hover {
                              background-color: #005fae;
                              }
															/* navbar (rest of the header) */
        .skin-blue .main-header .navbar {
                              background-color: #005fae;
                              }')
		)
		),
		tags$script(type="text/javascript", async = T, src=paste0("https://www.googletagmanager.com/gtag/js?id=", Sys.getenv("ANALYTICS_KEY"))),
		tags$script(
			paste0("
				 window.dataLayer = window.dataLayer || [];
					function gtag(){dataLayer.push(arguments);}
					gtag('js', new Date());
					gtag('config', '", Sys.getenv("ANALYTICS_KEY"), "');")
		),
		box(
			p("This calculator includes small grains varieties released to the public
				and tested within the last three years in the UC Small Grains Regional Trials."),
						selectInput("crop_type", label = "Select Crop Type",
												choices = c("", "Hard red common wheat",
																		"Hard white common wheat", "Durum wheat",
																		"Triticale", "Feed barley", "Naked barley",
																		"Malting barley")),
			selectInput("variety", label = "Select variety", choices = ""),
			checkboxGroupInput(inputId = "field_conditions",
												 "Select field conditions that apply:",
												 c("Irrigated", "Broadcast", "Late planting",
												 	"Forage planting", "Delta region"), inline = TRUE),
			br(),
			valueBoxOutput("seeding_rate", width = 12)
		),
		box(
			shinyWidgets::noUiSliderInput(inputId = "kernelwt",
											label = "Adjust Thousand Kernel Weight (g)",
											value = 45,
											min = 30,
											max = 60,
											tooltips = TRUE,
											pips = list(
												mode = "values",
												values = c(30, 40, 50, 60),
												format = wNumbFormat(decimals = 0)
											),
											step = 0.5,
											format = wNumbFormat(decimals = 1),
											color = '#005fae'),
			br(),
			shinyWidgets::noUiSliderInput(inputId = "plantpop",
																		label = "Adjust the Desired Plant Population (million plants/ac)",
																		value = 1.1,
																		min = 0.8,
																		max = 3.2,
																		tooltips = TRUE,
																		pips = list(
																			mode = "values",
																			values = c(1, 2, 3),
																			format = wNumbFormat(decimals = 0)
																		),
																		step = 0.05,
																		format = wNumbFormat(decimals = 2),
																		color = '#005fae'),
			br(),
			shinyWidgets::noUiSliderInput(inputId = "germ",
																		label = "Adjust Germination Rate (%)",
																		value = 95,
																		min = 70,
																		max = 100,
																		tooltips = TRUE,
																		pips = list(
																			mode = "values",
																			values = c(70, 80, 90, 100),
																			format = wNumbFormat(decimals = 0)
																		),
																		step = 1,
																		format = wNumbFormat(decimals = 0),
																		color = '#005fae')
		)
	)
	)
