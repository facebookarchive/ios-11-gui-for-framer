###
	# iOSNavigationBar
	{iOSNavigationBar} = require "iOSNavigationBar"

	navBar = new iOSNavigationBar
		# OPTIONAL
		tintColor: <color> (defaults to iOS blue)
		translucent: <bool> (fill the bar background with a light blur)

	navBar.pushNavigationItem <Layer>,
		# OPTIONAL
		title: <string> (defaults to Layer.name)
		useLargeTitle: <bool> (display title of item with iOS 11 style large title)
		canHideLargeTitle: <bool> (if Layer is a scroll component, allow the title to be condensed to a smaller size, true)

		hasSearchField: <bool> (add a search bar to the bar)
		canHideSearchField: <bool> (if Layer is a scroll component, the search bar can be exposed during scrolling, true)

		leftButtons: <optional array of strings,images,layers> (create buttons for the left side of the nav item)
		showBackButton: <bool> (show the back button for the left buttons, even for first nav item)

		rightButtons: <optional array of strings,images,layers> (create buttons for the right side of the nav item)
		boldRightButton: <bool> (specify if text layers on the right side should be bold, defaults to true for "Done", "Cancel", "Close")

		color: <color> (color used for titles, "black")
		titleLayer: <Layer> (a layer that is used in place of a small title)

	# Observe the "pushNavigationItem" event
	navBar.on "pushNavigationItem", (layer, oldLayer) ->

	# Observe the "popNavigationItem" event
	navBar.on "popNavigationItem", (layer, oldLayer) ->

	# Observe the "SelectNavigationItemButton" event
	navBar.on "SelectNavigationItemButton", (button) ->

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


NavItemState =
	HIDDEN: 0
	BACK: 1
	CURRENT: 2
	RIGHT: 3

ClipHeight = 44
LargeItemMidY = 22 + ClipHeight

SearchFieldHeight = 36

class iOSNavigationBarItem extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			backgroundColor: ""
			color: "black"
			useLargeTitle: false
			canHideLargeTitle: true
			hasSearchField: false
			canHideSearchField: true
		
		super _.extend options
		
		@_clipLayer = new Layer
			name: "clip"
			parent: @
			x: @_safeAreaMargins() - 4
			width: @width - @_safeAreaMargins()
			height: ClipHeight
			originX: 0
			originY: 1
			backgroundColor: ""
			clip: true
		
		@_backTitle = new iOSTextLayer
			name: "Back Title"
			parent: @_clipLayer
			y: Align.center
			originX: 0
			textStyle: iOSTextStyle.body
			text: @title
			color: @parent.tintColor
			opacity: 0
		
		@_smallTitle = new iOSTextLayer
			name: "Title"
			parent: @
			originX: 0
			textStyle: iOSTextStyle.headline
			text: @title
			color: @color
		
		@_moveToState(NavItemState.RIGHT, false)
		
		@on "change:size", ->
			@_layout(false)
	
	@define "content",
		get: -> @_content
		set: (value) ->
			@_content = value
			@title = value?.name if !@_title?
			
			scroll = value if value?.constructor is ScrollComponent
			if scroll?
				@_scrollLayer = scroll
				scroll.content.on "change:y", @_scrollMoved
				scroll.on Events.ScrollEnd, @_scrollEnd
				scroll.clip = false
				
				if !scroll.didOffsetY and @canHideSearchField
					scroll.didOffsetY = true
					scroll.content.draggable.constraints.y += SearchBarHeight

			
			if !scroll? or scroll?.scrollY >= 0
				@_content?.y = @_barHeight()
			
			@_layout(false)

	
	@define "title",
		get: -> @_title
		set: (value) ->
			@_title = value
			
			value = "Title" if !value?
			@name = ".NavItem: "+value
			@_smallTitle?.text = value
			@_smallTitle?.midY = @_itemMidY()
			@_backTitle?.text = value
			@_largeTitle?.text = value
	
	@define "useLargeTitle",
		get: -> @_useLargeTitle and  Framer.Device.orientationName is "portrait"
		set: (value) ->
			@_useLargeTitle = value
				
			if value and !@_largeTitle?
				@_largeTitle = new iOSTextLayer
					name: "Large Title"
					parent: @_clipLayer
					x: @_safeAreaMargins()
					originX: 0
					textStyle: iOSTextStyle.boldTitle
					text: @title
					color: @color
				
				@showingLargeTitle = true
			@_layout(false)
	
	@define "canHideLargeTitle",
		get: -> @_canHideLargeTitle and @useLargeTitle
		set: (value) -> @_canHideLargeTitle = value
	
	@define "showingLargeTitle",
		get: -> @useLargeTitle and @_showLargeTitle
		set: (value) ->
			return if @_showLargeTitle is value
			@_showLargeTitle = value
			if @_state is NavItemState.CURRENT
				@_layout(false)
				
				if !@titleLayer?
					@_smallTitle.opacity = if value then 1 else 0
					@_smallTitle.animate
						opacity: 1-@_smallTitle.opacity
						options: time: 0.2
	
	@define "hasSearchField",
		get: -> @_hasSearchField
		set: (value) ->
			@_hasSearchField = value
			
			if value and !@_searchField?
				@_searchField = new Layer
					name: "Search Field"
					parent: @
					x: @_safeAreaMargins()
					y: @_minBarHeight()
					width: @width - 2*@_safeAreaMargins()
					height: SearchFieldHeight
					backgroundColor: new Color("#8E8E93").alpha(0.12)
					borderRadius: 10
				@_searchField.y += LargeTitleHeight if @useLargeTitle

				@_searchLabel = new TextLayer
					name: "Search Label"
					parent: @_searchField
					text: "Search"
					x: 30
					y: Align.center
					color: "#8E8E93"
					fontSize: 17

				@_searchGlyph = new SVGLayer
					parent: @_searchField
					name: "Search Glyph"
					width: 14
					height: 15
					x: 8
					y: Align.center
					backgroundColor: ""
					fill: "#8E8E93"
				@_searchGlyph.svg = "<svg width='14px' height='15px' viewBox='0 0 14 15' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <g id='Search-Glyph' transform='translate(-1.000000, -1.000000)' fill-rule='nonzero'> <path d='M10.8026608,10.2273642 L14.7728173,14.1812939 C15.0757276,14.4829662 15.0757276,14.9720735 14.7728173,15.2737458 C14.4699069,15.5754181 13.9787923,15.5754181 13.675882,15.2737458 L9.69752239,11.3116465 C8.79146642,11.9780226 7.67106475,12.3719429 6.45828047,12.3719429 C3.44375541,12.3719429 1,9.93817555 1,6.93597143 C1,3.93376731 3.44375541,1.5 6.45828047,1.5 C9.47280554,1.5 11.9165609,3.93376731 11.9165609,6.93597143 C11.9165609,8.17314392 11.5015708,9.31378642 10.8026608,10.2273642 Z M6.45828047,11.2275278 C8.83816868,11.2275278 10.7674493,9.30613258 10.7674493,6.93597143 C10.7674493,4.56581028 8.83816868,2.64441504 6.45828047,2.64441504 C4.07839226,2.64441504 2.14911168,4.56581028 2.14911168,6.93597143 C2.14911168,9.30613258 4.07839226,11.2275278 6.45828047,11.2275278 Z'></path> </g> </svg>"

				@_searchField.on "change:height", =>
					opacity = Utils.modulate(@_searchField?.height, [SearchFieldHeight-8,SearchFieldHeight],[0,1],true)

					@_searchLabel?.y = Align.center
					@_searchLabel?.opacity = opacity
					@_searchGlyph?.y = Align.center
					@_searchGlyph?.opacity = opacity
				
			@_layout(false)
	
	@define "canHideSearchField",
		get: -> @_canHideSearchField and @hasSearchField
		set: (value) ->
			@_canHideSearchField = value
			if value is false and @hasSearchField
				@showingSearchField = true
				@canHideLargeTitle = false
	
	
	_buttonsForObj: (value, rightSide) ->
		if value not instanceof Array
			value = [value]
		
		btns = []
		for obj in value
			btns.push obj if obj instanceof Layer
			
			if typeof obj is "string"
				likelyURL = obj.length > 20 or obj[0...6] is "images" or obj[-4..] is ".png" or obj[-4..] is ".jpg"
				
				if likelyURL
					btns.push new Layer
						parent: @
						image: obj
						width: 22
						height: 22
				else
					btns.push new iOSTextLayer
						parent: @
						text: obj
						color: @parent.tintColor
						textStyle: iOSTextStyle.body
						textAlign: if rightSide then "right" else "left"
		
		for btn in btns
			btn.parent = @

			# Tap Events
			btn.onTap (event, btn) =>
				if btn instanceof iOSTextLayer
					obj = btn.text
				else if btn.imageSrc?.length > 0
					obj = btn.imageSrc
				else
					obj = btn

				@parent.emit("SelectNavigationItemButton", obj)

		# Color images
		for btn in btns
			if btn instanceof SVGLayer
				btn.stroke = ""
				btn.color = @parent.tintColor
			else if btn.image
				btn.backgroundColor = @parent.tintColor
				btn.style =
					webkitMaskSize: "100%"
					webkitMaskRepeat: "no-repeat"
					webkitMaskPosition: "center center"
					webkitMaskImage: "url(#{btn.image})"
				btn.imageSrc = btn.image
				btn.image = null
		
		return btns
	
	@define "leftButtons",
		get: -> @_leftButtons
		set: (value) ->
			_.invokeMap @_leftButtons, "destroy"
			@_leftButtons = @_buttonsForObj value, false
			@_layout false
	
	@define "showBackButton",
		get: -> @_showBackButton
		set: (value) ->
			@_showBackButton = value
			@parent._updateBackButton(false)
	
	@define "rightButtons",
		get: -> @_rightButtons
		set: (value) ->
			_.invokeMap @_rightButtons, "destroy"
			@_rightButtons = @_buttonsForObj value, true
			
			@_updateRightBtns()
			@_layout false
	
	@define "boldRightButton",
		get: -> @_boldRightButton
		set: (value) ->
			@_boldRightButton = value
			@_updateRightBtns()
	
	_updateRightBtns: ->
		for btn in @_rightButtons
			if btn instanceof iOSTextLayer
				shouldBold = _.includes(["Done","Cancel","Close"], btn?.text)
				shouldBold = @_boldRightButton if @_boldRightButton?
				btn.textStyle = if shouldBold then iOSTextStyle.headline else iOSTextStyle.body
	
	@define "titleLayer",
		get: -> @_titleLayer
		set: (value) ->
			@_titleLayer?.destroy()
			@_titleLayer = value
			@_titleLayer?.parent = @
			@_layout(false)
	
	@define "color",
		get: -> @_color
		set: (value) ->
			@_color = value
			@iconLayer?.backgroundColor = value if !@selected
			@_smallTitle?.color = value if !@selected
			@_backTitle?.color = value
			@_largeTitle?.color = value
	
	_statusBarHeight: ->
		isPortrait = Framer.Device.orientationName is "portrait"
		return 0 if !isPortrait
		
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		return if isIPhoneX then 44 else 20
	
	_safeAreaMargins: ->
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		return if isIPhoneX and !isPortrait then 64 else 16
		
	_itemMidY: ->
		isPlusPhone = Framer.Device.deviceType.includes("-plus-")
		isPortrait = Framer.Device.orientationName is "portrait"
		
		height = if isPlusPhone or isPortrait then 22 else 16
		height += @_statusBarHeight()
		return height
	
	_minBarHeight: ->
		isPlusPhone = Framer.Device.deviceType.includes("-plus-")
		isPortrait = Framer.Device.orientationName is "portrait"
		
		height = if isPlusPhone or isPortrait then 44 else 32
		height += @_statusBarHeight()
		return height
		
	_barHeight: ->
# 		isPlusPhone = Framer.Device.deviceType.includes("-plus-")
# 		isPortrait = Framer.Device.orientationName is "portrait"
# 		if isPlusPhone or isPortrait then 49 else 33
		height = @_minBarHeight()
		height += LargeTitleHeight if @showingLargeTitle
		height += SearchBarHeight if @showingSearchField
		return height
	
	_maxBarHeight: ->
		height = @_minBarHeight()
		height += LargeTitleHeight if @useLargeTitle
		height += SearchBarHeight if @hasSearchField
		return height
	
	_moveToState: (state, animate=true) ->
		return if @_state is state
		oldState = @_state
		
		@_state = state
		@_layout animate
		
		# Add shadows during animation
		if oldState is NavItemState.RIGHT or state is NavItemState.RIGHT
			@content?.shadowColor = new Color("black").alpha(0.35)
			@content?.animate
				shadowColor: new Color("black").alpha(0)
				options:
					time: 0.3
					instant: !animate
	
	_layout: (animate=true) ->
		isCurrent = @_state is NavItemState.CURRENT

		margin = @_safeAreaMargins()
		@_clipLayer?.x = @_safeAreaMargins() - 4
		@_clipLayer?.width = @width - @_safeAreaMargins()

		titleProps = {}
		backTitleProps = {}
		largeTitleProps = {}
		searchProps = {}
		contentProps = {}
		
		clipY = @_itemMidY()+1
		
		switch @_state
			when NavItemState.HIDDEN
				backTitleProps =
					x: 15 - @_backTitle.width - 50
					opacity: 0
			when NavItemState.BACK
				titleProps =
					x: 15
					opacity: 0
				backTitleProps =
					x: titleProps.x
					opacity: 1
					largeScale: 1
					scale: 1
				largeTitleProps =
					x: titleProps.x
					scale: 0.5
					opacity: 0
				searchProps =
					opacity: 0
				contentProps =
					x: @width*-0.3
			when NavItemState.CURRENT
				titleProps =
					x: Align.center
					opacity: 1
				backTitleProps =
					x: titleProps.x
					largeScale: 2
					largeY: @_clipLayer.height/2
					opacity: 0
				largeTitleProps =
					x: margin - @_clipLayer?.x
					scale: 1
					fontSize: 34
					opacity: 1
				searchProps =
					opacity: if @showingSearchField then 1 else 0
				contentProps =
					x: 0
				clipY = @_statusBarHeight() + LargeItemMidY if @showingLargeTitle
			when NavItemState.RIGHT
				titleProps =
					x: Screen.width - 100
					fontWeight: 600
					color: @color
					opacity: 0
				largeTitleProps =
					x: Screen.width
				searchProps =
					opacity: 0
				contentProps =
					x: @width
					shadowBlur: 25
				clipY = @_statusBarHeight() + LargeItemMidY if @showingLargeTitle
		
		options =
			time: 0.3
			instant: !animate
		halfTime = 
			time: options.time/2
			instant: !animate
		
		# Position the Title Layer that can used in place of the small title
		if @titleLayer
			@titleLayer.midY = @_itemMidY()
			
			@titleLayer.animate
				x: titleProps.x
				opacity: if @_state is NavItemState.CURRENT then 1 else 0
				options: options
			if @_state >= NavItemState.CURRENT
				titleProps.opacity = 0
		
		# Title Visibility
		if @showingLargeTitle
			if largeTitleProps.x?
				backTitleProps.x = largeTitleProps.x
			backTitleProps.scale = backTitleProps.largeScale
			titleProps.opacity = 0
		else
			largeTitleProps.opacity = 0
		searchProps.width = @width - 2*margin
		@_smallTitle?.midY = @_itemMidY()
		
		props.options = options for props in [titleProps, backTitleProps, largeTitleProps]
		
		@_smallTitle?.animate titleProps
		@_backTitle?.animate backTitleProps
		@_largeTitle?.animate largeTitleProps, options
		@_clipLayer?.animate midY:clipY, options
		@_searchField?.animate searchProps, options
		@_content?.animate contentProps, options
		
		# Side Button Position
		if @leftButtons?
			backOffset = if @showBackButton then 11 else 0
			for btn,index in @leftButtons
				btn.x = Align.left (margin + 52*index + backOffset)
				btn.midY = @_itemMidY()
		if @rightButtons?
			for btn,index in @rightButtons
				btn.x = Align.right -(margin + 52*index)
				btn.midY = @_itemMidY()
		
		# Side Button Visibility
		buttons = [].concat @_leftButtons, @_rightButtons
		for btn in buttons
			btn?.animate
				opacity: if isCurrent then 1 else 0
				options: if isCurrent then options else halfTime
			
			# Hide the buttons so they no longer get events
			if isCurrent
				btn?.visible = true
			else if btn?.visible
				btn?.once Events.AnimationEnd, ->
					@visible = @opacity > 0
		
		# Content Visibility
		@_content?.visible = true if isCurrent
		@_content?.once Events.AnimationEnd, ->
			@visible = isCurrent
		
		# Fade out everything
		if @_state is NavItemState.RIGHT and animate
			@animate
				opacity: 0
				options: options
	
	_scrollMoved: =>
		return if @_state isnt NavItemState.CURRENT
		return if !@useLargeTitle and !@hasSearchField
		
		barHeight = @_minBarHeight()
		if @useLargeTitle #and @canHideLargeTitle
			barHeight += LargeTitleHeight
		
		minHeight = @_minBarHeight()
		minHeight += LargeTitleHeight if !@canHideLargeTitle and @useLargeTitle
		minHeight += SearchBarHeight if !@canHideSearchField and @hasSearchField
		
		scrollY = @_scrollLayer?.scrollY
		@parent.height = Math.max(barHeight - scrollY, minHeight)

		@_scrollYChange scrollY
	
	_scrollEnd: (event) =>
		return if @_state isnt NavItemState.CURRENT
		return if !@useLargeTitle
		
		maxHeight = 0
		maxHeight += LargeTitleHeight if @useLargeTitle
		maxHeight += SearchBarHeight if @hasSearchField
		
		scrollY = @_scrollLayer?.scrollY
		return if scrollY > LargeTitleHeight if @useLargeTitle
		return if scrollY < -SearchBarHeight if @hasSearchField
		return if scrollY < 0 if !@hasSearchField
		
		scrollY = 0
		scrollY -= LargeTitleHeight if !@showingLargeTitle
		scrollY += SearchBarHeight if @showingSearchField
		
		@_scrollLayer.content.animate
			y: scrollY
			options: time: 0.3
			
		# @_scrollYChange scrollY
	
	_scrollYChange: (scrollY) ->
		# Bar height
		barHeight = @parent.height
		maxHeight = @_maxBarHeight()

		if @useLargeTitle and @canHideLargeTitle
			# Clip
			@_largeTitle.y = 0
			@_largeTitle.y = -scrollY if scrollY > 0
			
			# Visibility
			@showingLargeTitle = scrollY < 35
			
			# Position for overscroll
			maxY = if @hasSearchField then SearchBarHeight else 0
			@_clipLayer.midY = @_statusBarHeight() + LargeItemMidY-scrollY-maxY if -scrollY >= maxY
			
			# Scale for overscroll
			@_clipLayer.scale = Utils.modulate(scrollY, [-maxY,-maxY-100], [1,1.2], true)
		
		if @hasSearchField and @canHideSearchField
			# Resize
			@_searchField.height = Math.min(SearchFieldHeight, Math.max(SearchFieldHeight-SearchBarHeight-scrollY, 0))
			
			# Visibility
			@_searchField.opacity = 1 if @_searchField.height > 0
			@showingSearchField = -scrollY > SearchBarHeight/2
			
			@_searchField.y = @_minBarHeight()
			@_searchField.y += LargeTitleHeight if @showingLargeTitle
			# Position for overscroll
			@_searchField.y += -scrollY-SearchBarHeight if -scrollY > SearchBarHeight and @showingLargeTitle



LargeTitleHeight = 52
SearchBarHeight = 52

class exports.iOSNavigationBar extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			name: "Navigation Bar"
			width: Screen.width
			height: 64
			y: Align.top
			tintColor: "#027AFF"
			backgroundColor: ""
			translucent: true
		
		super _.extend options
		
		@items = []
		@tintColor = options.tintColor
		
		@_backButton = new Layer
			parent: @
			name: ".Back Button"
			width: 100
			height: @height-20
			x: 0
			y: 20
			backgroundColor: ""
			fill: "red"
			opacity: 0
# Back Button SVG
		@_backButton.html = "<svg width='30px' height='40px' viewBox='0 0 12 40' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <g transform='translate(0,12)'> <path d='M11.5952121,0.417172761 L11.5952121,0.417172761 L11.5952121,0.417172761 C11.074252,-0.121133653 10.2155469,-0.135195652 9.67724045,0.385764408 C9.66659953,0.396062433 9.65612797,0.406534022 9.64582997,0.417174963 L0.403200329,9.96759867 L0.403200329,9.96759867 C0.121980298,10.2581838 0.121765418,10.7193979 0.402714561,11.010245 L9.64909863,20.5823802 L9.64909863,20.5823802 C10.169034,21.120633 11.0268649,21.1354821 11.5651176,20.6155468 C11.5753052,20.6057058 11.585338,20.5957057 11.5952121,20.5855502 L11.5952121,20.5855502 L11.5952121,20.5855502 C12.138504,20.0267723 12.1402728,19.1376659 11.5992083,18.576731 L4.04920922,10.7494592 L4.04920922,10.7494592 C3.90891237,10.60401 3.90910276,10.3735479 4.04963974,10.2283307 L11.5952148,2.43146828 L11.5952148,2.43146828 C12.138608,1.86997871 12.1386068,0.978660833 11.5952121,0.417172761 Z' fill=#{@tintColor}></path> </g> </svg>"
# 		@_backButton.querySelector('path').setAttribute("fill", @tintColor)
		@_backButton.onTap =>
			@_goBack()
		
		Framer.Device.on "change:orientation", (angle) =>
			@height = @_currentItem?._barHeight()
			@width = Screen.width
			@y = Align.top
			for item in @items
				item.width = @width
			@_layoutBar(false)
	
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
				@on "change:size", ->
					@_shadow.y = @height
					@_shadow.width = @width
			else
				@backgroundBlur = 0
				@_shadow?.destroy()


	pushNavigationItem: (layer, props, animate=true) ->
		animate = false if @items.length is 0
		
		navItem = new iOSNavigationBarItem
			parent: @
			frame: @frame
		navItem.props = props
		navItem.content = layer
		
		navItem._moveToState NavItemState.CURRENT, @items.length > 0
		
		lastItem = _.last @items
		lastItem?._moveToState NavItemState.BACK
		
		secondLastItem = _.nth(@items, -2)
		secondLastItem?._moveToState NavItemState.HIDDEN
		
		@items.push(navItem)

		@placeBefore layer
		
		@emit("pushNavigationItem", navItem.content, lastItem?.content)
		@_layoutBar(animate)
	
	_goBack: ->
		return if @items.length is 1
		
		topItem = _.last @items
		topItem._moveToState NavItemState.RIGHT
		topItem.onAnimationEnd ->
			@destroy()
		@items.pop()
		
		backItem = _.last @items
		backItem?._moveToState NavItemState.CURRENT
		
		secondLastItem = _.nth(@items, -2)
		secondLastItem?._moveToState NavItemState.BACK
		
		@emit("popNavigationItem", topItem.content, backItem?.content)
		@_layoutBar()
		
	_updateBackButton: (animate=true) ->
		showBack = @_currentItem?.showBackButton or (@items.length > 1 and !@leftButton?)
		
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		isPortrait = Framer.Device.orientationName is "portrait"
		@_backButton.x = if isIPhoneX and !isPortrait then 46 else 0
		@_backButton.y = if isPortrait then @_currentItem?._statusBarHeight() else -6

		secondLastItem = _.nth(@items, -2)
		if showBack and @_backButton.opacity is 0 and secondLastItem?.showingLargeTitle
			@_backButton.props =
				midY: LargeItemMidY
				scale: 0.75

			@_backButton.animate
				midY: @_currentItem?._itemMidY()
				options:
					time: 0.3
			
			@_backButton.animate
				opacity: 1
				scale: 1
				options:
					time: 0.15
					delay: 0.15
			
		else
			@_backButton.animate
				opacity: if showBack then 1 else 0
				options:
					time: 0.3
					instant: !animate
	
	
	_layoutBar: (animate=true) ->
		@_updateBackButton(animate)
		
		options =
			time: 0.3
			instant: !animate
		
		barHeight = @_currentItem?._barHeight()
		@animate
			height: barHeight
			options: options
	
	@define "_currentItem",
		get: -> _.last @items
	
