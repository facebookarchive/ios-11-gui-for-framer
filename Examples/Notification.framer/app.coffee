{iOSNotification} = require 'iOSNotification'

Screen.backgroundColor = "#28affa"

# A button to trigger notification
button = new TextLayer
	x: Align.center
	y: Align.center
	height: 50
	backgroundColor: null
	text: "Notify Me"
	fontSize: 24
	color: "white"
Framer.Device.on "change:orientation", (angle) =>
	button.center()


button.onTap ->
	notification = new iOSNotification
# 		appName: "Whatsapp"
# 		appIcon: "https://cdn0.iconfinder.com/data/icons/social-flat-rounded-rects/512/whatsapp-256.png"
# 		timestamp: "5m ago"
# 		timeout: 5
		title: "Francis Whitman"
		body: "🤪 Anyone who wants to tag along is more than welcome."
		sound: "sounds/Notification2.m4a"
	notification.present()
	
	notification.onTap -> 
		print "Tapped."
	
	notification.on "notificationDismissed", ->
		print "Dismissed."

