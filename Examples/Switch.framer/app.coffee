{iOSSwitch} = require 'iOSSwitch'
bg = new Layer
	size: Screen.size
	backgroundColor: "white"


mySwitch = new iOSSwitch
	point: Align.center
	isOn: true
# 	tintColor: "red"

mySwitch.onValueChange (value) -> print value
