###
	# iOSTabBar
	{iOSTabBar} = require "iOSTabBar"

	tabBar = new iOSTabBar
		# OPTIONAL
		tintColor: <color> (defaults to iOS blue)
		translucent: <bool> (fill the bar background with a light blur)

	tabBar.addTab <Layer>,
		title: <string> (defaults to Layer.name)
		icon: <image>

		# OPTIONAL
		color: <color> (defaults to gray)
		selectedColor: <color> (defaults to tabBar.tintColor)
		selectedIcon: <image> (defaults to @icon using tabBar.tintColor)

	tabBar.currentTab = <Layer> (get/set the current tab by layer)
	tabBar.selectedIndex = <number> (get/set the current tab by index)

	# Observe the "chage:currentTab" event
	tabBar.on "change:currentTab", (tab, oldTab) ->
###


class iOSTabBarItem extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			backgroundColor: ""
			color: new Color("#919191").alpha(0.85)
		
		super options
		
		@iconLayer = new Layer
			name: ".Icon"
			parent: @
			width: 25
			height: 25
			backgroundColor: @color
			originX: 1
			visible: !@svgIcon?
			style:
				webkitMaskSize: "100%"
				webkitMaskRepeat: "no-repeat"
				webkitMaskPosition: "center center"
				webkitMaskImage: "url(#{@icon})" if @icon
		
		@titleLayer = new TextLayer
			name: ".Title"
			parent: @
			textAlign: "center"
			text: @title
			color: @color
		@_updateFontSize()

		@_layout()
		@on "change:size", ->
			@_layout()
	
	@define "layer",
		get: -> @_layer
		set: (value) ->
			@_layer = value
			@title = value?.name if !@_title?

	@define "title",
		get: -> @_title
		set: (value) ->
			@_title = value

			value = "Title" if !value?
			@titleLayer?.text = value
			@name = ".Tab: "+value
	
	@define "icon",
		get: -> @_icon
		set: (obj) ->
			@_icon = obj

			@svgIcon?.destroy()

			if obj instanceof SVGLayer
				@svgIcon = obj
				@svgIcon.props =
					parent: @
					stroke: ""
					color: @color
				@_layout() if @iconLayer?
			else
				@iconLayer?.style.webkitMaskImage = obj if !@selected

			@iconLayer?.visible = !@svgIcon?

	
	@define "selectedIcon",
		get: -> @_selectedIcon
		set: (value) ->
			@_selectedIcon = value
			@iconLayer?.style.webkitMaskImage = value if @selected
	
	@define "color",
		get: -> @_color
		set: (value) ->
			@_color = value
			@iconLayer?.backgroundColor = value if !@selected
			@svgIcon?.color = value if !@selected
			@titleLayer?.color = value if !@selected
	
	@define "selectedColor",
		get: -> @_selectedColor or @parent?.tintColor
		set: (value) ->
			@_selectedColor = value
			@iconLayer?.backgroundColor = value if @selected
			@svgIcon?.color = value if @selected
			@titleLayer?.color = value if @selected
	
	@define "selected",
		get: -> @_selected or false
		set: (value) ->
			@_selected = value
			
			if @selectedIcon?
				image = if value then @selectedIcon else @icon
				@iconLayer?.style.webkitMaskImage = "url(#{image})"
			
			color = if value then @selectedColor else @color
			@iconLayer?.backgroundColor = color
			@svgIcon?.color = color
			@titleLayer?.color = color
	
	_updateFontSize: ->
		@titleLayer?.fontSize = if Framer.Device.orientationName is "portrait" then 10 else 13
		
	_minWidth: ->
		@_updateFontSize()
		
		if Framer.Device.orientationName is "portrait"
			Math.max(@iconLayer?.width, @titleLayer?.width)
		else
			@iconLayer?.width + @titleLayer?.width + 8
	
	_layout: ->
		@_updateFontSize()

		
		if Framer.Device.orientationName is "portrait"
			isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
			atBottom = @parent?.maxY is Screen.height
			yOffset = if isIPhoneX and atBottom then -17 else 0

			@iconLayer.x = Align.center
			@iconLayer.y = Align.center (-5 + yOffset)
			@iconLayer.scale = 1
			@svgIcon?.point = @iconLayer.point
			
			@titleLayer.x = Align.center
			@titleLayer.y = Align.center (17 + yOffset)
		else
			margin = (@width - @iconLayer.width - @titleLayer.width - 8) / 2
			
			@iconLayer.scale = if @height < 49 then 2/3 else 1
			@iconLayer.x = margin
			@iconLayer.y = Align.center
			@svgIcon?.point = @iconLayer.point
			
			@titleLayer.maxX = @width - margin
			@titleLayer.y = Align.center



class exports.iOSTabBar extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			name: "Tab Bar"
			width: Screen.width
			y: Align.bottom
			height: @_barHeight()
			tintColor: "#027AFF"
			translucent: true
			backgroundColor: ""

		super options
		
		@items = []
		@tintColor = options.tintColor

		Framer.Device.on "change:orientation", (angle) =>
			@height = @_barHeight()
			@width = Screen.width
			@y = Align.bottom
			@_shadow?.width = @width
			@_layoutItems()
	
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

	_barHeight: ->
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		if isIPhoneX
			return if isPortrait then 83 else 53

		isPlusPhone = Framer.Device.deviceType.includes("-plus-")
		if isPlusPhone or isPortrait then 49 else 33
	
	addTab: (layer, props={}) ->
		item = new iOSTabBarItem props
		item.layer = layer

		if _.indexOf(@items, item) is -1
			@items.push(item)
		
		item.parent = @
		@_layoutItems()

		if props.selected? or @items.length is 1
			@_selectItem item
		else
			item.selected = false
			layer?.visible = false
	
		item.onTap =>
			@_selectItem item
	
	_layoutItems: ->
		xPos = 0
		itemWidth = @width / @items.length
		
		isLandscape = Framer.Device.orientationName is "landscape" 
		if isLandscape
			# Calculate the total min space for all of the items
			minWidth = 0
			for item in @items
				minWidth += item._minWidth()
			
			# Divide the free space equally among the items, with 1 extra item space for the margins to bring them a bit closer
			margin = 4
			itemSpacing = (@width - margin*2 - minWidth) / (@items.length+1)
			
			xPos = margin + itemSpacing/2
		
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")

		itemHeight = @height
		itemHeight -= 20 if isIPhoneX and !isPortrait 

		for item, index in @items
			if isLandscape
				itemWidth = item._minWidth() + itemSpacing
			
			item.x = xPos
			item.width = itemWidth 
			item.height = itemHeight
			
			xPos += item.width
	
	@define "selectedIndex",
		get: -> _.indexOf(@items, @selectedItem)
		set: (index) -> @_selectItem @items[index]

	@define "currentTab",
		get: -> @selectedItem.layer
		set: (layer) -> @_selectItem _.first _.filter(@items, { 'layer': layer })

	_selectItem: (item) ->
		return if !item or item is @selectedItem
		
		oldItem = @selectedItem
		@selectedItem = item

		oldItem?.selected = false
		@selectedItem.selected = true
		
		@selectedItem.layer?.placeBehind @
		@selectedItem.layer?.center()
		
		oldItem?.layer?.visible = false
		@selectedItem.layer?.visible = true
		
		@emit("change:currentTab", item?.layer, oldItem?.layer)
