###
	# iOSStatusBar
	{iOSStatusBar} = require "iOSStatusBar"

	statusBar = new iOSStatusBar
		# OPTIONAL
		translucent: <bool> (fill the bar background with a light blur)
		darkStyle: <bool> (use light text and icons for a dark background)
		time: <string> (specify a custom time)
		useCurrentTime: <bool> (use the current system time as the time, defaults to false)
		backAppName: <string> (display the back to app button with the specified app name)
		carrier: <string> (display the name of a cell carrier)
		cellStrength: <number> (value from 0-1 of the strength of cell signal that is represented by the cell bars)
		wifiStrength: <number> (value from 0-1 of the strength of wifi signal that is represented by the wifi waves)
		networkType: ["Wifi", "LTE", "4G", "3G"]
		showBatteryLevel: <bool> (display the battery %, defaults to false)

###



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



class exports.iOSStatusBar extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			name: "Status Bar"
			width: Screen.width
			height: @_barHeight()
			y: Align.top
			z: 1	# display above other layers
			translucent: false
			backgroundColor: ""
			showBatteryLevel: false
			time: @_timeForDate(new Date(2007, 0, 9, 9, 41, 0))
			useCurrentTime: false
			darkStyle: false
			cellStrength: 1
			wifiStrength: 1
			networkType: "Wifi"
		
		super options

		isPortrait = Framer.Device.orientationName is "portrait"
		@opacity = 0 if !isPortrait
		
		# Show a Home Indicator for iPhoneX when in Framer on the desktop
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		if isIPhoneX and Utils.isDesktop()
			@_homeIndicator = new Layer
				name: ".HomeIndicator"
				width: if isPortrait then 134 else 210
				height: 5
				x: Align.center
				y: Align.bottom -9
				borderRadius: 2.5
				backgroundColor: if @darkStyle then "white" else "black"
				z: 1
		
		@_timeLabel = new TextLayer
			parent: @
			name: ".Time"
			fontSize: 12
			fontWeight: 600
			color: "black"
		@_updateTime()
		
		@_battery = new SVGLayer
			parent: @
			name: ".Battery"
			backgroundColor: ""
			width: 27
			height: 12
			htmlIntrinsicSize:
				width: 27
				height: 12
			color: "black"
			html: "<svg width='27px' height='12px' viewBox='0 -12 27 12' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <g id='Battery'> <path d='M2.5,0.5 L21.5,0.5 C22.8807119,0.5 24,1.61928813 24,3 L24,9.5 C24,10.8807119 22.8807119,12 21.5,12 L2.5,12 C1.11928813,12 0,10.8807119 0,9.5 L0,3 C0,1.61928813 1.11928813,0.5 2.5,0.5 Z M2.5,1.5 C1.67157288,1.5 1,2.17157288 1,3 L1,9.5 C1,10.3284271 1.67157288,11 2.5,11 L21.5,11 C22.3284271,11 23,10.3284271 23,9.5 L23,3 C23,2.17157288 22.3284271,1.5 21.5,1.5 L2.5,1.5 Z' id='Body' fill-opacity='0.4'></path> <path d='M25,3.7998548 C25.890419,4.25503254 26.5,5.18132863 26.5,6.25 C26.5,7.31867137 25.890419,8.24496746 25,8.7001452 L25,3.7998548 Z' id='Terminal' fill-opacity='0.5'></path> <path d='M3,2.5 L21,2.5 C21.5522847,2.5 22,2.94771525 22,3.5 L22,9 C22,9.55228475 21.5522847,10 21,10 L3,10 C2.44771525,10 2,9.55228475 2,9 L2,3.5 C2,2.94771525 2.44771525,2.5 3,2.5 Z' id='Reserve'></path> </g> </svg>"
		
		@_batteryLevel = new iOSTextLayer
			parent: @
			name: ".Battery Level"
			text: "100%"
			color: "black"
			textStyle: iOSTextStyle.caption1
			visible: @showBatteryLevel
		
		@_cellBars = new SVGLayer
			parent: @
			name: ".Cell"
			width: 17
			height: 10
			htmlIntrinsicSize:
				width: 17
				height: 10
			color: "black"
			backgroundColor: ""
			html: "<svg width='17px' height='10px' viewBox='0 -14 17 10' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <path d='M1,5.5 L2,5.5 C2.55228475,5.5 3,5.94771525 3,6.5 L3,9 C3,9.55228475 2.55228475,10 2,10 L1,10 C0.44771525,10 6.76353751e-17,9.55228475 0,9 L0,6.5 C-6.76353751e-17,5.94771525 0.44771525,5.5 1,5.5 Z' id='CellBar-4'></path> <path d='M5.5,4 L6.5,4 C7.05228475,4 7.5,4.44771525 7.5,5 L7.5,9 C7.5,9.55228475 7.05228475,10 6.5,10 L5.5,10 C4.94771525,10 4.5,9.55228475 4.5,9 L4.5,5 C4.5,4.44771525 4.94771525,4 5.5,4 Z' id='CellBar-3'></path> <path d='M10,2 L11,2 C11.5522847,2 12,2.44771525 12,3 L12,9 C12,9.55228475 11.5522847,10 11,10 L10,10 C9.44771525,10 9,9.55228475 9,9 L9,3 C9,2.44771525 9.44771525,2 10,2 Z' id='CellBar-2'></path> <path d='M14.5,0 L15.5,0 C16.0522847,-1.01453063e-16 16.5,0.44771525 16.5,1 L16.5,9 C16.5,9.55228475 16.0522847,10 15.5,10 L14.5,10 C13.9477153,10 13.5,9.55228475 13.5,9 L13.5,1 C13.5,0.44771525 13.9477153,1.01453063e-16 14.5,0 Z' id='CellBar-1'></path></svg>"
		@_updateCellBars()
		
		@_wifiBars = new SVGLayer
			parent: @
			name: ".Wifi"
			width: 15
			height: 11
			htmlIntrinsicSize:
				width: 15
				height: 11
			color: "black"
			backgroundColor: ""
			html: "<svg width='15px' height='11px' viewBox='0 -13 15 11' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <path d='M5.44974747,8.02081528 C6.62132034,6.8492424 8.52081528,6.8492424 9.69238816,8.02081528 L7.57106781,10.1421356 L5.44974747,8.02081528 Z' id='WifiBar-1'></path> <path d='M2.97487373,5.54594155 C5.51328163,3.00753365 9.62885399,3.00753365 12.1672619,5.54594155 L10.7530483,6.96015511 C8.99568901,5.2027958 6.14644661,5.2027958 4.3890873,6.96015511 L2.97487373,5.54594155 Z' id='WifiBar-2'></path> <path d='M0.5,3.07106781 C4.40524292,-0.834175105 10.7368927,-0.834175105 14.6421356,3.07106781 L13.2279221,4.48528137 C10.1037277,1.36108704 5.0384079,1.36108704 1.91421356,4.48528137 L0.5,3.07106781 Z' id='WifiBar-3'></path></svg>"
		@_updateWirelessIndicator()

		@_updateBarStyle()
		@_layoutItems()
		
		Framer.Device.on "change:orientation", (angle) =>
			@opacity = if angle is 0 then 1 else 0
			@width = Screen.width
			@_layoutItems()
	
	_barHeight: ->
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		return if isIPhoneX then 44 else 20
	
	@define "translucent",
		get: -> @_translucent
		set: (value) ->
			@_translucent = value
			@_updateBarStyle()
	
	@define "darkStyle",
		get: -> @_darkStyle
		set: (value) ->
			@_darkStyle = value
			@_updateBarStyle()
	
	_updateBarStyle: ->
		if @translucent and !@darkStyle
			@backgroundColor = new Color("#F8F8F8").alpha(0.8)
			@backgroundBlur = 10
		else if @translucent and @darkStyle
			@backgroundColor = new Color("black").alpha(0.8)
			@backgroundBlur = 10
		else
			@backgroundColor = ""
			@backgroundBlur = 0
		
		color = if @darkStyle then "white" else "black"
		@_homeIndicator?.backgroundColor = color

		labels = _.filter @children, (child) -> child instanceof TextLayer
		_.invokeMap labels, ((color) -> @color = color), color
		
		svgs = _.filter @children, (child) -> child instanceof SVGLayer
		_.invokeMap svgs, ((color) -> @color = color), color
	
	@define "showBatteryLevel",
		get: ->
			isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
			if isIPhoneX then false else @_showBatteryLevel
		set: (value) ->
			@_showBatteryLevel = value
			@_batteryLevel?.visible = @showBatteryLevel

	@define "time",
		get: -> @_time
		set: (value) ->
			@_time = value
			@useCurrentTime = false if value?.length > 0
			
			@_updateTime()
	
	@define "useCurrentTime",
		get: -> @_useCurrentTime
		set: (value) ->
			@_useCurrentTime = value
			@_updateTime()
	
	_timeForDate: (date) ->
		date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
		
	_updateTime: ->
		time = @_time
		
		# Use the system time if no time is provided
		if @useCurrentTime
			date = new Date
			time = @_timeForDate date
			
			clearTimeout @_clockTimer
			@_clockTimer = Utils.delay 60-date.getSeconds(), =>
				@_updateTime()

		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		if isIPhoneX
			time = _.trimEnd time, " AM"
			time = _.trimEnd time, " PM"
			
		@_timeLabel?.text = time
		@_layoutItems()
	
	@define "carrier",
		get: -> @_carrier
		set: (value) ->
			@_carrier = value
			
			if !value? or value?.length == 0
				@_carrierLabel?.destroy()
			else
				@_carrierLabel = new iOSTextLayer
					parent: @
					name: ".Carrier"
					text: value
					color: "black"
					textStyle: iOSTextStyle.caption1
			
			@_layoutItems()

	@define "backAppName",
		get: -> @_backAppName
		set: (value) ->
			@_backAppName = value
			
			if !value? or value?.length == 0
				@_appBack?.destroy()
				@_appBackLabel?.destroy()
			else
				@_appBack = new SVGLayer
					parent: @
					name: ".AppBack"
					width: 12
					height: 13
					htmlIntrinsicSize:
						width: 12
						height: 13
					color: "black"
					backgroundColor: ""
					html: "<svg width='12px' height='13px' viewBox='4 -7 12 13' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <path d='M6.5,4.5 L13.5,4.5 C14.8807119,4.5 16,5.61928813 16,7 L16,14 C16,15.3807119 14.8807119,16.5 13.5,16.5 L6.5,16.5 C5.11928813,16.5 4,15.3807119 4,14 L4,7 C4,5.61928813 5.11928813,4.5 6.5,4.5 Z M11.842765,7.60888195 L10.9588815,6.72499847 L7.19000244,10.5 L10.9429231,14.2767806 L11.8106962,13.4090074 L8.93899903,10.5 L11.842765,7.60888195 Z' id='Back'></path> </svg>"
				
				isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
				if isIPhoneX
					@_appBack.props =
						width: 7
						height: 9
						htmlIntrinsicSize:
							width: 7
							height: 9
						html: "<svg width='7px' height='9px' viewBox='0 -15 7 9' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <path d='M0,4.5 L7,0 L7,8.5 Z' id='Back'></path> </svg>"
				
				@_appBackLabel = new iOSTextLayer
					parent: @
					name: ".AppBackName"
					text: value
					color: "black"
					textStyle: if isIPhoneX then iOSTextStyle.caption2 else iOSTextStyle.caption1
			
			@_updateBarStyle()
			@_layoutItems()
	
	@define "cellStrength",
		get: -> @_cellStrength
		set: (value) ->
			@_cellStrength = value
			@_updateCellBars()

	_updateCellBars: ->
			bars = @_cellBars?.querySelectorAll('path')
			bars?.item(0).setAttribute("fill-opacity", if @cellStrength > 0    then 1 else 0.25)
			bars?.item(1).setAttribute("fill-opacity", if @cellStrength > 0.25 then 1 else 0.25)
			bars?.item(2).setAttribute("fill-opacity", if @cellStrength > 0.5  then 1 else 0.25)
			bars?.item(3).setAttribute("fill-opacity", if @cellStrength > 0.75 then 1 else 0.25)

	@define "wifiStrength",
		get: -> @_wifiStrength
		set: (value) ->
			@_wifiStrength = value
			@_updateWirelessIndicator()

	@define "networkType",
		get: -> @_networkType
		set: (value) ->
			modes = ["3G", "4G", "LTE", "Wifi"]
			value = "Wifi" if _.indexOf(modes, value) is -1

			@_networkType = value
			@_updateWirelessIndicator()

	_updateWirelessIndicator: ->
			bars = @_wifiBars?.querySelectorAll('path')
			bars?.item(0).setAttribute("fill-opacity", if @wifiStrength > 0    then 1 else 0.25)
			bars?.item(1).setAttribute("fill-opacity", if @wifiStrength > 0.33 then 1 else 0.25)
			bars?.item(2).setAttribute("fill-opacity", if @wifiStrength > 0.66 then 1 else 0.25)

			if @networkType is "Wifi"
				@_networkLabel?.destroy()
			else
				if !@_networkLabel?
					@_networkLabel = new TextLayer
						parent: @
						name: ".NetworkLabel"
						fontSize: 12
						fontWeight: 600
						color: "black"
				@_networkLabel.text = @networkType
				@_layoutItems()
	
	_layoutItems: ->
		hasAppBack = @backAppName?.length > 0
		hasCarrier = @_carrier?.length > 0 and !hasAppBack
		
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		if isIPhoneX
			@_timeLabel?.midX = 48
			@_timeLabel?.y = if hasAppBack then 8 else 14
			@_timeLabel?.fontSize = 14
			@_timeLabel?.fontWeight = 600
			
			@_battery?.x = Align.right -13
			@_battery?.y = 6
			@_battery?.scaleX = 0.9
			
			@_cellBars?.x = Align.right -64
			@_cellBars?.y = 4
			@_cellBars?.scaleY = 1.1
			
			@_carrierLabel?.visible = false
			
			@_wifiBars?.x = @_cellBars?.maxX + 5
			@_wifiBars?.y = 5
			@_wifiBars?.scale = 1.1
			@_wifiBars?.visible = @networkType is "Wifi"

			@_networkLabel?.midX = @_cellBars?.maxX + 12
			@_networkLabel?.y = 17
			
			@_appBack?.x = 9
			@_appBack?.y = 16
			@_appBackLabel?.y = 28
			@_appBackLabel?.x = @_appBack?.maxX + 5

			@_homeIndicator?.width = if isPortrait then 134 else 210
			@_homeIndicator?.x = Align.center
			@_homeIndicator?.y = Align.bottom -9
		else
			@_timeLabel?.x = Align.center
			@_timeLabel?.y = 2.5
			
			@_battery?.x = Align.right -5
			@_battery?.y = -8
			@_batteryLevel?.maxX = @_battery.x - 3
			@_batteryLevel?.y = 2.5
		
			@_cellBars?.x = if hasAppBack then @_appBackLabel.maxX+7 else 6
			@_cellBars?.y = -9
			
			@_carrierLabel?.x = @_cellBars?.maxX + 3
			@_carrierLabel?.y = 2.5
			@_carrierLabel?.visible = hasCarrier
			
			@_wifiBars?.x = if hasCarrier then @_carrierLabel?.maxX + 5 else @_cellBars?.maxX + 4
			@_wifiBars?.y = -8
			@_wifiBars?.visible = @networkType is "Wifi"
			
			@_networkLabel?.x = @_wifiBars?.x
			@_networkLabel?.y = 2.5

			@_appBack?.x = 4
			@_appBack?.y = -7.5
			@_appBackLabel?.y = 2.5
			@_appBackLabel?.x = @_appBack?.maxX + 4