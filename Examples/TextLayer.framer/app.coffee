{iOSTextLayer} = require "iOSTextLayer"

Screen.backgroundColor = "white"

text = new iOSTextLayer
	text: "My Label"
	textStyle: iOSTextStyle.caption1
# 	textStyle: iOSTextStyle.largeTitle
# 	textStyle: iOSTextStyle.boldTitle

# text.textStyle = iOSTextStyle.caption1
# text.textStyle = iOSTextStyle.largeTitle
text.textStyle = "boldTitle"
# text.fontSize = 34

text.center()
