server <- function(input, output, session) {
	
	shinyjs::disable("field_conditions")
	
	observeEvent(input$crop_type, {

		# define crop type information
		if(input$crop_type == ""){
			ct <- ""
		}
		
		if(input$crop_type == "Hard red common wheat" | input$crop_type == "Hard white common wheat"){
			ct <- "COMMON"
		}
		
		if(input$crop_type == "Durum wheat"){
			ct <- "DURUM"
		}
		
		if(input$crop_type == "Triticale"){
			ct <- "TRITICALE"
		}
		
		if(input$crop_type == "Feed barley" | input$crop_type == "Malting barley" | input$crop_type == "Naked barley"){
			ct <- "BARLEY"
		}
		
		if(ct != ""){
		variety_list <- variety_data %>% 
			filter(crop_sub_type == ct) %>% 
			arrange(label)
		} else {
			variety_list <- data.frame(label = "")
		}
		
		if(input$crop_type == "Malting barley"){
			variety_list <- variety_list %>% 
				filter(stringr::str_detect(crop_classification, 'RSM'))
		}
		
		if(input$crop_type == "Feed barley"){
			variety_list <- variety_list %>% 
				filter(stringr::str_detect(crop_classification, 'RSF'))
		}
		
		if(input$crop_type == "Naked barley"){
			variety_list <- variety_list %>% 
				filter(stringr::str_detect(crop_classification, 'RSN'))
		}
		
		if(input$crop_type == "Hard red common wheat"){
			variety_list <- variety_list %>% 
				filter(stringr::str_detect(crop_classification, 'HRS'))
		}
		
		if(input$crop_type == "Hard white common wheat"){
			variety_list <- variety_list %>% 
				filter(stringr::str_detect(crop_classification, 'HWS'))
		}
		
		updateSelectInput(session, inputId = "variety", 
											choices = variety_list$label)
	})
	
	observeEvent(input$variety, {
		if(input$variety != ""){
		kw <- variety_data %>% 
			filter(label == input$variety) %>% 
			select(amount) %>% 
			as.numeric()
		updateNoUiSliderInput(session, inputId = "kernelwt", value = kw)
		shinyjs::enable("field_conditions")
			
		}
	})
	
	calc_plant_pop <- function(crop_type, field_conditions){

			base_seeding_rate <- 1100000

		
		if (any(grepl("Irrigated", field_conditions, fixed = TRUE))){
			if(crop_type == "Malting barley" | crop_type == "Feed barley"){
				base_seeding_rate <- base_seeding_rate*1.08
			} else {
				base_seeding_rate <- base_seeding_rate*1.23
			}
		}
		
		if (any(grepl("Broadcast", field_conditions, fixed = TRUE))){
			base_seeding_rate <- base_seeding_rate*1.2
		}
		
		if (any(grepl("Late planting", field_conditions, fixed = TRUE))){
			base_seeding_rate <- base_seeding_rate*1.25
		}
		
		if (any(grepl("Forage planting", field_conditions, fixed = TRUE))){
			base_seeding_rate <- base_seeding_rate*1.1
		}
		
		if (any(grepl("Delta region", field_conditions, fixed = TRUE))){
			base_seeding_rate <- base_seeding_rate*1.8
		}
		
		return(base_seeding_rate/1000000)
	}
	
	observe({
		if(input$crop_type != ""){
		updateNoUiSliderInput(session, inputId = "plantpop", value = calc_plant_pop(input$crop_type, input$field_conditions))
		}
	})
	
	calc_seeding_rate <- function(plantpop, kw, germination){
		
		seeding95 <- kw*(plantpop*1000000/1000)/453.592
	  round(seeding95/(germination/100), 0)
	  
	}
	
	rec_seed_rate <- reactive({
		calc_seeding_rate(input$plantpop, input$kernelwt, input$germ)
	})
	
	observeEvent(input$kernelwt, {
		if(rec_seed_rate() > 250){
			newrate <- rec_seed_rate()
			kw <- input$kernelwt
			while(newrate > 250){
				kw <- kw - 0.5
				newrate <- calc_seeding_rate(kw = kw, plantpop = input$plantpop, germination = input$germ)
			}
			updateNoUiSliderInput(session, inputId = "kernelwt", value = kw)
		}
	})
	
	observeEvent(input$plantpop, {
		if(rec_seed_rate() > 250){
			newrate <- rec_seed_rate()
			pp <- input$plantpop
			while(newrate > 250){
				pp <- pp - 0.05
				newrate <- calc_seeding_rate(kw = input$kernelwt, plantpop = pp, germination = input$germ)
			}
			updateNoUiSliderInput(session, inputId = "plantpop", value = pp)
		}
	})
	
	observeEvent(input$germ, {
		if(rec_seed_rate() > 250){
			newrate <- rec_seed_rate()
			gr <- input$germ
			while(newrate > 250){
				gr <- gr + 0.05
				newrate <- calc_seeding_rate(kw = input$kernelwt, plantpop = input$plantpop, germination = gr)
			}
			updateNoUiSliderInput(session, inputId = "germ", value = gr)
		}
	})

	output$seeding_rate <- renderValueBox({
		if(input$variety != ""){
			customValueBox(value = tags$h3(paste0(rec_seed_rate(), " lb/ac")),
							 subtitle = "Recommended seeding rate", color = "white", background = "#005fae"
			)
			}else {
				customValueBox(value = tags$h3("Not yet calculated"),
								 subtitle = "Recommended seeding rate", color = "white", background = "#005fae"
				)
		}
		
	})
	
}