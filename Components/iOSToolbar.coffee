###
	# iOSToolbar
	{iOSToolbar} = require "iOSToolbar"

	toolbar = new iOSToolbar
		# OPTIONAL
		tintColor: <color> (defaults to iOS blue)
		translucent: <bool> (fill the bar background with a light blur)

	toolbar.addButton <Layer>
		# Returns a Layer that is positioned automatically and tinted with toolbar.tintColor

	toolbar.addTextButton <string>
		# Returns a Layer that is positioned automatically with a label with <string> and using toolbar.tintColor


	# EXAMPLE
	toolbar = new iOSToolbar

	doneButton = toolbar.addTextButton "Done"
	doneButton.onTap ->
		print "Done"

###


class exports.iOSToolbar extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			name: "Toolbar"
			width: Screen.width
			y: Align.bottom
			height: @_bgHeight()
			translucent: true
			tintColor: "#027AFF"
			backgroundColor: ""

		super options

		@items = []
		@tintColor = options.tintColor

		Framer.Device.on "change:orientation", (angle) =>
			@height = @_bgHeight()
			@width = Screen.width
			@y = Align.bottom
			@_shadow?.width = @width
			@_layoutItems()

	_bgHeight: ->
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		if isIPhoneX
			return if isPortrait then 83 else 53
		return @_barHeight()

	_barHeight: ->
		isPortrait = Framer.Device.orientationName is "portrait"
		isPlusPhone = Framer.Device.deviceType.includes("-plus-")
		if isPlusPhone or isPortrait then 49 else 33

	_safeAreaMargins: ->
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		if isIPhoneX and !isPortrait then 64 else 0

	@define "translucent",
		get: -> @_translucent
		set: (value) ->
			if value
				@backgroundColor = new Color("#F8F8F8").alpha(0.8)
				@backgroundBlur = 10
				@_shadow = new Layer
					name: ".shadow"
					parent: @
					height: 0.5
					width: @width
					y: Align.top -0.5
					backgroundColor: new Color("black").alpha(0.3)
			else
				@backgroundBlur = 0
				@_shadow?.destroy()

	addButton: (layer) ->
		if layer instanceof SVGLayer
			layer.stroke = ""
			layer.color = @tintColor
		else if layer.image
			layer.backgroundColor = @tintColor
			layer.style =
				webkitMaskSize: "100%"
				webkitMaskRepeat: "no-repeat"
				webkitMaskPosition: "center center"
				webkitMaskImage: "url(#{layer.image})"
			layer.image = null

		button = @_addLayer layer
		button.name = "Button: "+layer.name
		return button

	addTextButton: (text) ->
		label = new TextLayer
			parent: @
			name: ".label"
			text: text
			color: @tintColor
			fontSize: 17
			fontWeight: 400
			backgroundColor: ""

		button = @_addLayer label
		button.name = "Button: "+text
		return button

	_addLayer: (layer) ->
		margins = if layer instanceof TextLayer then 16 else 11

		button = new Layer
			parent: @
			height: @_barHeight()
			width: Math.max(layer.width+margins*2, 60)
			y: Align.top
			backgroundColor: new Color("black").alpha(0.1)
			backgroundColor: ""
		button.margins = margins

		layer.props =
			parent: button
			x: Align.center
			y: Align.center

		if _.indexOf(@items, button) is -1
			@items.push(button)

		@_layoutItems()

		button.onTouchStart (event, layer) ->
			@opacity = 0.2

			# If you touch down on the button and then move off the layer, you don't get the touchEnd so we have to register separately for it
			@parent._trackingButton = @
			Events.wrap(document).addEventListener("tapend", @_touchEnd)

		button._touchEnd = (event, layer) =>
			button = @._trackingButton
			button.opacity = 1
			Events.wrap(document).removeEventListener(Gestures.TapEnd, button._touchEnd)

		return button

	_layoutItems: ->
		firstItem = _.first @items
		lastItem = _.last @items

		# On non-iPhoneX the button's spacing handles the safe area margins. For iPhone X in landscape the safe area is !0 and we have to account for the buttons spacing to get it to align properly
		safeArea = @_safeAreaMargins()
		leftMargin = if safeArea is 0 then 0 else (safeArea - firstItem?.margins)
		rightMargin = if safeArea is 0 then 0 else (-safeArea + lastItem?.margins)

		firstItem?.x = Align.left leftMargin
		lastItem?.x = Align.right rightMargin

		minX = leftMargin
		minX = firstItem.midX if firstItem?
		maxX = @width - leftMargin + rightMargin
		maxX = lastItem.midX if lastItem?

		middleItems = @items[1...-1]
		for item,index in middleItems
			item.midX = Utils.modulate(index+1, [0,@items.length-1], [minX, maxX])

		# Account for height change on rotation
		for item in @items
			item.height = @_barHeight()
			item.y = if @maxY is Screen.height then Align.top else Align.center

			for sublayers in item.children
				sublayers.y = Align.center
