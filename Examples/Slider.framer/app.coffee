{iOSSlider} = require "iOSSlider"

bg = new BackgroundLayer

slider = new iOSSlider
slider.center()
slider.y -= 100

volumeSlider = new iOSSlider
	width: Screen.width - 80
	minimumValueImage: VolumeDown.image
	minimumValueImagePadding: 13
volumeSlider.maximumValueImage = VolumeUp.image

volumeSlider.center()


littleSlider = new iOSSlider
	width: 200
	minimumTrackTintColor: "#EEE"
	maximumTrackTintColor: new Color("#EC7EBD").alpha(.25)
	thumbTintColor: "#EC7EBD"
littleSlider.center()
littleSlider.y += 100
