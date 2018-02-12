{iOSActivityIndicator} = require "iOSActivityIndicator"

Screen.backgroundColor = "#CEE8FD"
# Screen.backgroundColor = "white"

indicator = new iOSActivityIndicator
	point: Align.center
# 	animating: false
# 	color: "red"
# 	color: "white"
# 	color: "black"
# 	large: true
# 	hidesWhenStopped: true

# indicator.animating = true
# indicator.animating = false
# indicator.onPan (event) ->
# 	@refreshProgress = event.offset.y / 160

indicator.onTap (event) ->
	return if Math.abs(event.offset.y) > 10
	if indicator.animating
		indicator.stopAnimating()
	else
		indicator.startAnimating()
# 	indicator.animating = !indicator.animating

# indicator.onAnimationStart ->
# 	print "start"
# indicator.onAnimationStop ->
# 	print "stop"


# indicator.animating = true
# indicator.animating = false
	
