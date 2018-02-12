###
	# iOSSlider
	{iOSSlider} = require "iOSSlider"

	# Extends Framer's SliderComponent
	# (https://framer.com/docs/#slider.slidercomponent)

	slider = new iOSSlider
		# OPTIONAL
		minimumTrackTint: <color> (alias for SliderComponent.backgroundColor)
		maximumTrackTint: <color> (alias for SliderComponent.fill.backgroundColor)
		thumbTintColor: <color> (alias for SliderComponent.knob.backgroundColor)
		minimumValueImage: <Layer> (icon placed to the left of the slider)
		maximumValueImage: <Layer> (icon placed to the right of the slider)
		minimumValueImagePadding: <number> (default is 8pt between bar + icon)
		maximumValueImagePadding: <number> (default is 8pt between bar + icon)
###


class exports.iOSSlider extends SliderComponent

	constructor: (options={}) ->

		@PADDING = 15
		@ICONPADDING = 8

		options = _.defaults {}, options,
			width: Screen.width - @PADDING*2
			borderRadius: 2
			height: 2
			constrained: true
			knobSize: 28
			minimumTrackTintColor: new Color "#C7C7CC"
			maximumTrackTintColor: new Color "#007AFF"
			minimumValueImagePadding: @ICONPADDING
			maximumValueImagePadding: @ICONPADDING
			thumbTintColor: new Color "#FFFFFF"
			iconTintColor: new Color "#8E8E93"

		super options

		@knob.draggable.momentum = false
		@knob.borderColor = "rgba(0,0,0,.04)"
		@knob.borderWidth = .5
		@knob.shadows = []
		@knob.shadow1 =
				y: 3
				blur: 8
				color: "rgba(0,0,0,0.15)"
		@knob.shadow2 =
				y: 1
				blur: 1
				color: "rgba(0,0,0,0.16)"
		@knob.shadow3 =
				y: 3
				blur: 1
				color: "rgba(0,0,0,0.10)"

		# Hide the sublayers in the Layer List
		for child in @children
			child.name = "."+child.name

		@on "change:width", @_positionIcons

	_addIconImage: (imageUrl)->
		img = new Image
		img.src = imageUrl
		icon = new Layer
			image: img.src
			backgroundColor: ""
			name: ".Icon"
			visible: false
			parent: @
		img.iconRef = icon
		img.onload = ->
			@iconRef.width = @naturalWidth
			@iconRef.height = @naturalHeight
			@iconRef.visible = true
			@iconRef.parent._positionIcons()
		return icon

	_positionIcons: ()->
		if @_minIcon?
			@_minIcon.maxX = -@minimumValueImagePadding
			@_minIcon.midY = 0
		if @_maxIcon?
			@_maxIcon.x = @maxX - @x + @maximumValueImagePadding
			@_maxIcon.midY = 0

	@define "minimumValueImage",
		get: -> @_minIcon
		set: (value)->
			@_minIcon?.destroy()
			if value?
				@_minIcon = @_addIconImage value
			else
				@_minIcon = null

	@define "maximumValueImage",
		get: -> @_maxIcon
		set: (value)->
			@_maxIcon?.destroy()
			if value?
				@_maxIcon = @_addIconImage value
			else
				@_maxIcon = null

	@define "minimumValueImagePadding",
		get: -> @_minimumValueImagePadding
		set: (value)->
				@_minimumValueImagePadding = value
				@_positionIcons()

	@define "maximumValueImagePadding",
		get: -> @_maximumValueImagePadding
		set: (value)->
				@_maximumValueImagePadding = value
				@_positionIcons()

	@define "minimumTrackTintColor",
		get: -> @backgroundColor
		set: (value)->
			@backgroundColor = value

	@define "maximumTrackTintColor",
		get: -> @fill.backgroundColor
		set: (value)->
			@fill.backgroundColor = value

	@define "thumbTintColor",
		get: -> @knob.backgroundColor
		set: (value)->
			@knob.backgroundColor = value
