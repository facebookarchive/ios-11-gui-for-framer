###
	# iOSNotification
	{iOSNotification} = require "iOSNotification"

	notification = new iOSNotification
		# OPTIONAL
		appIcon: <image> (defaults to Facebook icon)
		appName: <string> (defaults to "Facebook")
		timestamp: <string> (defaults to "Now")
		title: <string> (defaults to "Hey There". Pass empty string("") to remove title. Passing null defaults to "Hello World")
		body: <string> (defautls to "Hello from the other side. I must have called a thousand times.")
		timeout: <value> (defaults to 5s)
		sound: <sound> (defaults to null. If it's provided, notification will play sound as it shows up)

	notification.appIcon = <image>
	notification.appName = <string>
	notification.timestamp = <string>
	notification.title = <string> or pass null to remove title
	notification.body = <string>
	notification.timeout = <value>
	notification.sound = <sound>

	# Call notification.present() to display notification
	layerA.onTap ->
		notification.present()

	# Observe the "tap" event
	notification.on "tap", ->
		print "Tapped."

	# Observe the "notificationDismissed" event
	notification.on "notificationDismissed", ->
		print "Dismissed."
###





Events.NotificationTap = "notificationTap"
Events.NotificationDismissed = "notificationDismissed"




iOSKitColors =
  red: new Color("FF3B30")
  green: new Color("4CD964")
  blue:  new Color("007AFF")
  black: new Color("000")
  gray: new Color("8E8E93")
  grey: new Color("8E8E93")
  white: new Color("fff")
  transparent: new Color("transparent")

iOSTextStyle =
    boldTitle: "boldTitle"
    largeTitle: "largeTitle"
    title1: "title1"
    title2: "title2"
    title3: "title3"
    headline: "headline"
    body: "body"
    callout: "callout"
    subhead: "subhead"
    footnote: "footnote"
    caption1: "caption1"
    caption2: "caption2"

class iOSTextLayer extends TextLayer
    constructor: (options={}) ->
        options = _.defaults {}, options,
            textStyle: iOSTextStyle.body
            fontSize: 17
            fontWeight: 400

        # TextLayer ignores any font changes during construction, so delay setting the style until after super
        textStyle = options.textStyle
        options.textStyle = null

        super options

        @textStyle = textStyle

    @define "textStyle",
        get: -> @_textStyle
        set: (value) ->
            @_textStyle = value
            @_updateStyle()

    _updateStyle: ->
        styles =
            boldTitle:
                fontSize: 34
                fontWeight: 700
                letterSpacing: -0.1
            largeTitle:
                fontSize: 34
                fontWeight: 400
            title1:
                fontSize: 28
                fontWeight: 400
            title2:
                fontSize: 22
                fontWeight: 400
            title3:
                fontSize: 20
                fontWeight: 400
            headline:
                fontSize: 17
                fontWeight: 600
            body:
                fontSize: 17
                fontWeight: 400
            callout:
                fontSize: 16
                fontWeight: 400
            subhead:
                fontSize: 15
                fontWeight: 400
            footnote:
                fontSize: 13
                fontWeight: 400
            caption1:
                fontSize: 12
                fontWeight: 400
            caption2:
                fontSize: 11
                fontWeight: 400

        @props = styles[@textStyle]


FBIcon = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDowNTgwMTE3NDA3MjA2ODExODA4M0NDMTM4MEMyQTVFQiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpCN0YwMzNGRUE2MTYxMUUyOEJFQUJDRTMzOERDQjM5MCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpCN0YwMzNGREE2MTYxMUUyOEJFQUJDRTMzOERDQjM5MCIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6QUM3QUJGQTkzODIwNjgxMThDMTQ5OEFGOTgxQUJBQ0UiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MDU4MDExNzQwNzIwNjgxMTgwODNDQzEzODBDMkE1RUIiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6TtKLTAAABqUlEQVR42mK0Dp8ryMDAMB2IPYCYn2FogY9AvAOIM1mgnghnGJqAH+Z2JiD2Zxj6wB/kEY5h4BEOJoZhAkY9MuoRAoCVhTwnsQxoKDIyMlgYyjDYmykyaKuKMIgJczNwcbCC5b7/+M3w49dfho+ffzC8eP2VoaRj5+D0iK2JPENahDGDoowAVnlOoIdAWJCPg0FBWmDwxQgTEyNDfrwFQ7C7JlXNpbtHihKtGAJc1Yd2Zne0UKSJJ+jqEVBplBVtOvSLXwtDWQZJUR6amU+3PGJnooBT7uevPwzTlp5l2H/iHsO7j98Ht0e01URwys1YfpZh7c6rQyNpiQhy4ZQ7dPrh0MkjsBobG3j7/tvwaGv9+ftvtPU76pFRj9AYMFqHz/1PLcOOrEiiiSNBfRO3xMUM//8P8Rh5+OwjXk8MGY88ePJxeOSRB0/fDw+PPHw6TGLk/pMPQ98jv3//ZXj26hN9i19yi2abiHmjFeKoR0Y9MuqRUY+MemTUI6MeGfXIqEdGPTIyPfJjGPjjB8gjG4eBRzaCJnqyoDHjyzD0VgqBUtNmkB8AAgwAPf9hjEtSu6MAAAAASUVORK5CYII="


class exports.iOSNotification extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			borderRadius: 13
			backgroundColor: new Color("rgba(255,255,255,0.54)")
			backgroundBlur: 20
			shadow1:
				y: 5
				blur: 20
				color: new Color("rgba(0,0,0,0.2)")
			shadow2:
				y: 0.5
				blur: 0
				color: new Color("rgba(255,255,255,0.4)")
			appName: "Facebook"
			appIcon: FBIcon
			title: "Hey There"
			body: "Hello from the other side. I must have called a thousand times."
			timestamp: "now"
			timeout: 5
			z: 1
		super options



		@_initialY = null
		@_animateToY = 8

		@_layout()

		Framer.Device.on "change:orientation", (angle) =>
			@_layout()
			@_updateHeight()

			if @states.current.name is "on"
				@center()
				isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
				@y = if Framer.Device.orientationName is "portrait" and isIPhoneX then 44 else 8



		@_headerGroup = new Layer
			name: ".header"
			parent: @
			backgroundColor: null
			width: @.width - 25
			x: 10
			y: 10
			height: 20

		@_appIconLayer = new Layer
			name: ".appIcon"
			parent: @_headerGroup
			width: 20
			height: 20
			borderRadius: 4
			image: @appIcon

		@_appNameLayer = new iOSTextLayer
			name: ".appName"
			parent: @_headerGroup
			width: @_headerGroup.width - 102
			height: @_headerGroup.height
			x: 27
			text: @appName
			textStyle: iOSTextStyle.footnote
			color: new Color("rgba(63,63,63,0.2)")
			lineHeight: @_headerGroup.height/13
			textTransform: "uppercase"
			textOverflow: "ellipsis"
			style: "mix-blend-mode": "hard-light"

		@_appNameLayerCopy = @_appNameLayer.copy()
		@_appNameLayerCopy.parent = @_headerGroup
		@_appNameLayerCopy.color = new Color("rgba(0,0,0,0.4)")
		@_appNameLayerCopy.style = "mix-blend-mode": "color-burn"

		@_timestampLayer = new iOSTextLayer
			name: ".timestamp"
			parent: @_headerGroup
			width: 75
			height: @_headerGroup.height
			x: Align.right
			text: @timestamp
			textAlign: Align.right
			textStyle: iOSTextStyle.footnote
			color: new Color("rgba(63,63,63,0.2)")
			lineHeight: @_headerGroup.height/13
			textOverflow: "ellipsis"
			style: "mix-blend-mode": "hard-light"

		@_timestampLayerCopy = @_timestampLayer.copy()
		@_timestampLayerCopy.parent = @_headerGroup
		@_timestampLayerCopy.color = new Color("rgba(0,0,0,0.4)")
		@_timestampLayerCopy.style = "mix-blend-mode": "color-burn"

		@_messageGroup = new Layer
			name: ".message"
			parent: @
			width: @.width - 25
			x: 12
			y: @_headerGroup.y + @_headerGroup.height + 8
			backgroundColor: null

		@_titleLayer = new TextLayer
			name: ".title"
			parent: @_messageGroup
			text: @title
			fontSize: 15
			lineHeight: 20/15
			fontWeight: 600
			color: iOSKitColors.black
			width: @_messageGroup.width
			height: 20
			truncate: true

		@_bodyLayer = new iOSTextLayer
			name: ".body"
			parent: @_messageGroup
			text: @body
			textStyle: iOSTextStyle.subhead
			lineHeight: 20/15
			color: iOSKitColors.black
			width: @_messageGroup.width


		@_truncateBody()
		@_updateHeight()
		@_setUpDragEvent()

	@define 'appIcon',
		get: -> @_appIcon
		set: (imagePath) ->
			@_appIcon = imagePath
			@_appIconLayer?.image = imagePath

	@define 'appName',
		get: -> @_appName
		set: (string) ->
			@_appName = string
			@_appNameLayer?.text = string
			@_appNameLayerCopy?.text = string

	@define 'timestamp',
		get: -> @_timestamp
		set: (string) ->
			@_timestamp = string
			@_timestampLayer?.text = string
			@_timestampLayerCopy?.text = string

	@define 'title',
		get: -> @_title
		set: (string) ->
			string = "" if string?.length is 0 or string?.length is undefined
			@_title = string
			@_titleLayer?.text = string
			@_updateHeight()

	@define 'body',
		get: -> @_body
		set: (string) ->
			@_body = string
			@_bodyLayer?.text = string
			@_truncateBody()
			@_updateHeight()

	@define 'timeout',
		get: -> @_timeout
		set: (value) ->
			@_timeout = value

	@define 'sound',
		get: -> @_sound
		set: (soundFile) ->
			@_sound = soundFile
			if @_sound?
				Framer.Extras.Preloader.enable()



	emit: (eventName, event) ->
		if eventName is Events.Tap
			@_handleTap(event)
			return

		eventName = Events.Tap if eventName is "notificationTap"
		super eventName, event

	_handleTap: (event) ->
		return if Math.abs(event.offset.y) > 10 or event.offsetTime > 300
		@_hide 0.1
		@emit "notificationTap"

	_setStates: ->
		@states.on =
			y: @_animateToY
			animationOptions:
				time: 0.3

		@states.off =
			y: @_initialY

	_layout: ->
		if Framer.Device.orientationName is "portrait"
			@width = Screen.width - 16
			isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
			@_animateToY = if isIPhoneX then 44 else 8

		else if Framer.Device.orientationName is "landscape"
			@width = Screen.height - 16
			@_animateToY = 8

		@center()

	_truncateBody: ->
		@_bodyLayer?.truncate = false
		@_bodyLayer?.autoSize = true
		@_maxBodyHeight = @_bodyLayer?.lineHeight * @_bodyLayer?.fontSize * 2

		if @_bodyLayer?.height > @_maxBodyHeight
			@_bodyLayer?.height = @_maxBodyHeight
			@_bodyLayer?.truncate = true

	_updateHeight: ->
		@_bodyLayer?.y = if @_titleLayer?.text.length is 0 then 0 else 20

		@_messageGroup?.height = @_titleLayer?.height + @_bodyLayer?.height
		@height = @_messageGroup?.y + @_bodyLayer?.maxY + 10
		@_initialY = @y = -@height
		@_setStates()

	_setUpDragEvent: ->
		@draggable.enabled = true
		@draggable.horizontal = false

		@onDragStart ->
			clearTimeout @_timer

		@onDragEnd (event) ->
			if event.offset.y < -50 or event.velocity < -0.5
				@_hide 0.1
			else
				@_display()

	_display: ->
		@animate "on"
		@_timer= Utils.delay @timeout, => @_hide()

	_hide: (duration=0.3) ->
		clearTimeout @_timer
		@animate "off", time: duration

		@once Events.StateSwitchEnd, ->
			@emit "notificationDismissed"
			@destroy()

	present: ->
		if @states.current.name isnt "on"
			@ringtone = new Audio(@_sound)
			@ringtone.play()
			@_display()



	onNotificationTap: (cb) -> @on(Events.NotificationTap, cb)
	onNotificationDismissed: (cb) -> @on(Events.notificationDismissed, cb)
