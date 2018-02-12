# require "iOSKit"
{iOSToolbar} = require "iOSToolbar"

Screen.backgroundColor = "#CEE8FD"

toolbar = new iOSToolbar
# 	y: Align.center
# 	width: 200
# 	height: 100
# 	tintColor: "red"
# 	translucent: false
# 	backgroundColor: "red"
	

cancelButton = toolbar.addTextButton "Cancel"

# refreshButton = toolbar.addButton Refresh
# refreshButton.onTap ->
# 	print "Refresh"

addButton = toolbar.addButton Add

doneButton = toolbar.addTextButton "Done"
doneButton.onTap ->
	print "Done"


