customValueBox <- function (value, subtitle, icon = NULL, color, background, width = 4, href = NULL) 
{
	#validateColor(color)
	#if (!is.null(icon)) 
	#tagAssert(icon, type = "i")
	
	style <- paste0("color: ", color, "; background-color: ", background, ";")
	
	boxContent <- div(class = "small-box", style = style, 
										div(class = "inner", h3(value), p(subtitle)), if (!is.null(icon)) 
											div(class = "icon-large", icon))
	if (!is.null(href)) 
		boxContent <- a(href = href, boxContent)
	div(class = if (!is.null(width)) 
		paste0("col-sm-", width), boxContent)
}