# require "iOSKit"
{iOSTabBar} = require "iOSTabBar"

tabBar = new iOSTabBar
# 	y: Align.center
# 	width: 200
# 	height: 100
# 	translucent: false
# 	backgroundColor: "red"
# 	tintColor: "red"

tabBar.addTab Tab_1, 
# 	title: "Stuff"
	icon: Icon.image

tabBar.addTab Tab_2,
	title: "Second"
	icon: Icon.image
	selectedIcon: Selected.image
	selectedColor: "green"

tabBar.addTab Tab_3,
	title: "Third"
	icon: Icon.image
	color: "#c88"
	selectedColor: "#f00"
	
tabBar.addTab()

# tabBar.currentTab = Tab_2
# tabBar.selectedIndex = 1

tabBar.on "change:currentTab", (tab, oldTab) ->
# 	print @selectedIndex
# 	print @currentTab
	
