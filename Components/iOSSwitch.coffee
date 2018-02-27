###
	# iOSSwitch
	{iOSSwitch} = require "iOSSwitch"

	switch = new iOSSwitch
		isOn: <bool> is the switch in the on position (defaults to false)
		tintColor: <color> the color of the switch background when isOn is true (defaults to iOS green)
		thumbTintColor: <color> the color of the switch thumb (defaults to white)

	# Observe the "Events.ValueChange" event
	switch.onValueChange (value) ->

###

iOSKitColors =
  red: new Color("FF3B30")
  green: new Color("4CD964")
  blue:  new Color("007AFF")
  black: new Color("000")
  gray: new Color("8E8E93")
  grey: new Color("8E8E93")
  white: new Color("fff")
  transparent: new Color("transparent")


Events.SwitchValueChange = "switchValueChange"
class Switch extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			width: 51
			height: 31
			backgroundColor: iOSKitColors.transparent

			tintColor: iOSKitColors.green
			thumbTintColor: iOSKitColors.white
			isOn: false
		super options

		rimColor = "E5E5EA"

		@base = new Layer
			name: ".base"
			parent: @
			width: @width
			height: @height
			backgroundColor: iOSKitColors.transparent
			borderRadius: 20
			borderColor: rimColor
			borderWidth: 1.5

			shadowColor: rimColor
			shadowType: "inner"

		@base.states.on =
			borderWidth: 0
			shadowColor: @tintColor
			shadowSpread: 20

		@base.animationOptions =
			time: 0.6
			curve: Spring(damping: 0.75)

		@thumb = new Layer
			name: ".thumb"
			parent: @
			width: 29, height: 29
			borderRadius: 14.5
			x: 1
			midY: @height / 2
			backgroundColor: iOSKitColors.transparent
			borderWidth: 0.5
			borderColor: "rgba(0,0,0,0.04)"
		@thumb.states.on =
			x: 21
		@thumb.animationOptions =
			time: 0.6
			curve: Spring(damping: 0.8)

		@thumbFill = new Layer
			name: "thumbFill"
			parent: @thumb
			x: 0.5
			y: 0.5
			width: 28, height: 28
			borderRadius: 14
			backgroundColor: @thumbTintColor

			shadow1:
				y: 3
				blur: 8
				color: "rgba(0,0,0,0.15)"
			shadow2:
				y: 1
				blur: 1
				color: "rgba(0,0,0,0.16)"
			shadow3:
				y: 3
				blur: 1
				color: "rgba(0,0,0,0.10)"

		if @isOn
			@base.stateSwitch "on"
			@thumb.stateSwitch "on"



		@onClick ->
			@setOn !@isOn, true


	@define "tintColor",
		get: -> @_tintColor
		set: (value) ->
			@_tintColor = value
			@_updateTintColor()
	@define "thumbTintColor",
		get: -> @_thumbTintColor
		set: (value) ->
			@_thumbTintColor = value
			@_updateThumb()

	@define "isOn",
		get: -> @_isOn
		set: (value) ->
			@_isOn = value

	setOn: (switchOn, animated) ->
		@isOn = switchOn
		animated = animated ? true

		if @isOn
			if animated
				@base.animate "on"
				@thumb.animate "on"
			else
				@base.stateSwitch "on"
				@thumb.stateSwitch "on"
		else
			if animated
				@base.animate "default"
				@thumb.animate "default"
			else
				@base.stateSwitch "default"
				@thumb.stateSwitch "default"

		@emit Events.SwitchValueChange, @isOn


	_updateTintColor: ->
		if @base
			@base.states.on.shadowColor = @tintColor
			@base.stateSwitch "on" if @isOn

	_updateThumb: ->
		if @thumbFill then @thumbFill.backgroundColor = @thumbTintColor

	onValueChange: (cb) -> @on(Events.SwitchValueChange, cb)


exports.iOSSwitch = Switch
