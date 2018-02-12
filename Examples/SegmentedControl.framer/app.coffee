
{iOSSegmentedControl} = require "iOSSegmentedControl"


# --- Examples ---
bg = new BackgroundLayer

switchControl = new iOSSegmentedControl
	x: Align.center
	y: Align.center -50
	tintColor: "#42B72A"
	width: 200
	items: ["On", "Off"]
switchControl.setSelected true, 0
switchControl.on "change:currentSegment", (current, last)->
	print "Switched to", switchControl.selectedSegmentIndex

momentaryControl = new iOSSegmentedControl
	y: Align.center
	items: ["Tap", "Click", "Touch"]
	isMomentary: true
momentaryControl.on "change:currentSegment", (current, last)->
	print "Tapped on", current.title

kitchenSinkControl = new iOSSegmentedControl
	y: Align.center 50
	items: ["Lil Bro", "Bro", "Brah", "Bruh"]
	tintColor: "#555"
kitchenSinkControl.setSelected true, 0
kitchenSinkControl.on "change:currentSegment", (current, last)->
	print "Tapped on", current.title, current.index
# kitchenSinkControl.insertSegment "Nah", 1
# kitchenSinkControl.removeSegment 1
# kitchenSinkControl.setTitle "Bruh Uh", 2
kitchenSinkControl.setWidth 50, 0
# kitchenSinkControl.setWidth null, 0
