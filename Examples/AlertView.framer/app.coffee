{iOSAlertView} = require 'iOSAlertView'

bg = new Layer
	size: Screen.size
	backgroundColor: "white"
	image: Utils.randomImage()

showAlert = ->
	myAlert = new iOSAlertView
		title: "Alert"
		message: "Here is a message where we can put absolutely anything we want"
	myAlert.addAction "Yes", "cancel"
	myAlert.addAction "No"
	# myAlert.addAction "Another Action"
	
	myAlert.present()
	
	# myAlert.onAlertViewAppear ->
	# 	print "appeared"
	# 
	# myAlert.onAlertViewDismiss ->
	# 	print "dismissed"
	# myAlert.tintColor = "yellow"
	myAlert.onActionSelected (action) ->
		print action
	
showAlert()
bg.onClick ->
	showAlert()
	