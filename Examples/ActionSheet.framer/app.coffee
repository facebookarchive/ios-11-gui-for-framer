{iOSActionSheet} = require "iOSActionSheet"

bg = new Layer
	size: Screen.size
	backgroundColor: "white"
	image: Utils.randomImage()

showAlert = (animated=true) ->
	myAlert = new iOSActionSheet
	# 	title: "Alert"
	# 	message: "Here is a message where we can put absolutely anything we want"
	myAlert.addAction "Cancel", "cancel"
	myAlert.addAction "Share"
	myAlert.addAction "Delete", "destructive", ->
		print "Delete"
	# myAlert.addAction "Another Action"
	
	myAlert.present animated
	
	# myAlert.onActionSheetAppear ->
	# 	print "appeared"
	# 
	# myAlert.onActionSheetDismiss ->
	# 	print "dismissed"

showAlert(false)

bg.onClick ->
	showAlert()


