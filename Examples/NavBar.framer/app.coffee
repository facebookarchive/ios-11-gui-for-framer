{iOSNavigationBar} = require "iOSNavigationBar"

Screen.backgroundColor = "white"

scrollForView = (view) ->
	scroll = view.scrollView
	if !scroll?
		scroll = new ScrollComponent
			size: Screen.size
			scrollVertical: true
			scrollHorizontal: false
		
	view.x = 0
	view.height = Screen.height *1.5
	view.parent = scroll.content
	view.scrollView = scroll
	scroll.scrollY = 0
	
	return scroll


navBar = new iOSNavigationBar

navBar.pushNavigationItem scrollForView(Screen_1), 
	title: "Screen 1"
	useLargeTitle: true
	hasSearchField: true
	rightButtons: "Done"
	leftButtons: "Cancel"
	

Button1.onTap ->
	closeButton = Buttons.children[2].copy()
	listButton = Buttons.children[1].copy()
	
	navBar.pushNavigationItem scrollForView(Screen_2),
		title: "Screen 2"
		useLargeTitle: true
		rightButtons: [closeButton, listButton]
	
	closeButton.onTap ->
		print "Close"
	listButton.onTap ->
		print "List"

Button2.onTap ->
	navBar.pushNavigationItem scrollForView(Screen_3),
		title: "Screen 3"
		rightButtons: "Edit"

Button3.onTap ->
	navBar.pushNavigationItem scrollForView(Screen_4),
		title: "Screen 4"
		rightButtons: ["Stuff", Buttons.children[0].image]
		color: "red"
		
Button4.onTap ->
	navBar.pushNavigationItem scrollForView(Screen_5),
		title: "Screen 5"



navBar.on "SelectNavigationItemButton", (button) ->
	print button

