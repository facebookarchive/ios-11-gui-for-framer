{iOSActionSheet} = require 'iOSActionSheet'
{iOSActivityIndicator} = require 'iOSActivityIndicator'
{iOSAlertView} = require 'iOSAlertView'
{iOSNavigationBar} = require 'iOSNavigationBar'
{iOSNotification} = require 'iOSNotification'
{iOSPageComponent} = require 'iOSPageComponent'
{iOSSegmentedControl} = require 'iOSSegmentedControl'
{iOSSlider} = require 'iOSSlider'
{iOSStatusBar} = require 'iOSStatusBar'
{iOSSwitch} = require 'iOSSwitch'
{iOSTabBar} = require 'iOSTabBar'
{iOSTextLayer} = require 'iOSTextLayer'
# {iOSToolbar} = require 'iOSToolbar'
{iOSVideoPlayer} = require 'iOSVideoPlayer'

Screen.backgroundColor = "white"

statusBar = new iOSStatusBar
	useCurrentTime: true

viewContainer = new Layer
	size: Screen.size
	backgroundColor: ""
controlContainer = new Layer
	size: Screen.size
	backgroundColor: ""


tabBar = new iOSTabBar
tabBar.addTab viewContainer, 
	title: "Views"
	icon: viewGlyph

viewScroll = new ScrollComponent
	parent: viewContainer
	size: Screen.size
	scrollVertical: true
	scrollHorizontal: false
views = new Layer
	parent: viewScroll.content
	width: Screen.width
	height: Screen.height*1.5
	backgroundColor: ""


navBar = new iOSNavigationBar
	parent: viewContainer
navBar.pushNavigationItem viewScroll, 
	title: "iOS 11 for Framer"
	useLargeTitle: true
	hasSearchField: true
	leftButtons: "Facebook"

showActionSheet = ->
	actionSheet = new iOSActionSheet
	actionSheet.addAction "Cancel", "cancel"
	actionSheet.addAction "Share"
	actionSheet.addAction "Delete", "destructive"
	actionSheet.present()

showAlert = ->
	alert = new iOSAlertView
		title: "Alert"
		message: "Here is a message where we can put absolutely anything we want"
	alert.addAction "Cancel", "cancel"
	alert.addAction "Share"
	alert.present()


navView = new Layer
	parent: viewContainer
	size: Screen.size
	backgroundColor: Screen.backgroundColor
	visible: false
pushNavItem = ->
	navBar.pushNavigationItem navView,
		title: "Navigation Bar"
		useLargeTitle: true
		rightButtons: [grid, refresh]

sendNotification = ->
	notification = new iOSNotification
		title: "Francis Whitman"
		body: "🤪 Anyone who wants to tag along is more than welcome."
	notification.present()

pages = undefined
showPages = ->
	if pages is undefined
		pages = new iOSPageComponent
			parent: viewContainer
			width: Screen.width
			height: Screen.height - statusBar.height - tabBar.height - 44
			backgroundColor: "white"
		
		for index in [0...3]
			aPage = new Layer
				size: pages.size
			aPage.image = Utils.randomImage(aPage)
			pages.addPage aPage, "right"
	
	pages.snapToPage(pages.content.children[0])
	navBar.pushNavigationItem pages,
		title: "Pages"
		

showVideo = ->
	video = new iOSVideoPlayer
		video: "http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v"
		autoplay: true
		volume: 0.5



buttons = ["Action Sheet", "Alert View", "Navigation Bar", "Notification", "Page Component", "Video Player"]
actions = [showActionSheet, showAlert, pushNavItem, sendNotification, showPages, showVideo]

for labelStr,index in buttons
	label = new iOSTextLayer
		parent: views
		name: labelStr
		textStyle: iOSTextStyle.headline
		text: labelStr
		color: "007AFF"
		height: 44
		padding:
			horizontal: 40
			vertical: 10
	
	label.x = Align.center
	label.y = (index)*80 + 70
	
	do (index) ->
		label.onTap ->
			actions[index]()



## Controls
tabBar.addTab controlContainer, 
	title: "Controls"
	icon: controlsGlyph

titlebar = new iOSNavigationBar
	parent: controlContainer
titlebar.pushNavigationItem null,
	title: "Controls"

activityIndicator = new iOSActivityIndicator
	parent: controlContainer
	x: Align.center
	y: 200

aSwitch = new iOSSwitch
	parent: controlContainer
	x: Align.center
	y: activityIndicator.maxY + 30
	isOn: true

aSwitch.onValueChange (value) ->
	activityIndicator.animating = value
	
segmentedControl = new iOSSegmentedControl
	parent: controlContainer
	x: Align.center
	y: aSwitch.maxY + 30
	width: 300
	items: ["Red", "Green", "Blue"]
segmentedControl.setSelected true, 1
segmentedControl.on "change:currentSegment", (current, last)->
	switch current
		when 0 then aSwitch.tintColor = new Color("FF3B30")
		when 1 then aSwitch.tintColor = new Color("4CD964")
		when 2 then aSwitch.tintColor = new Color("007AFF")

slider = new iOSSlider
	parent: controlContainer
	x: Align.center
	y: segmentedControl.maxY + 60
	width: 250
	value: 0.5
	minimumValueImage: VolumeDown.image
	maximumValueImage: VolumeUp.image
	minimumValueImagePadding: 13