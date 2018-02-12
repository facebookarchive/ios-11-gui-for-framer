###
	# iOSPageComponent
	{iOSPageComponent, iOSPageControl} = require "iOSPageComponent"

	A simple subclass of PageComponent that automaticaly displays the page control

	page = new iOSPageComponent

	# Access the Page Control
	page.pageControl



	# iOSPageControl
	{iOSPageComponent, iOSPageControl} = require "iOSPageComponent"

	pageControl = new iOSPageControl
		# OPTIONAL
		numberOfPages: <number> (the number of page dots)
		currentPage: <number> (the index of the current dot)
		hidesForSinglePage: <bool> (hide the control if only one page, defaults to false)

		# Note, if both pageIndicatorTintColor and currentPageIndicatorTintColor are both "white" or "black", the inactive dots will be displayed with a transparent version of the color
		pageIndicatorTintColor: <color> (color used for inactive dots, defaults to "white")
		currentPageIndicatorTintColor: <color> (color used for current dot, defaults to "white")

###

class iOSPageControl extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			name: "Page Control"
			height: 7
			backgroundColor: ""
			numberOfPages: 0
			currentPage: 0
			hidesForSinglePage: false
			pageIndicatorTintColor: "white"
			currentPageIndicatorTintColor: "white"
		
		super options
		
		@_dots = []
		@_updateDots()

	@define "numberOfPages",
		get: -> @_numPages
		set: (value) ->
			@_numPages = value
			@_updateDots()
	
	@define "currentPage",
		get: -> @_currentPage
		set: (value) ->
			@_currentPage = value
			@_updateDots()
	
	@define "hidesForSinglePage",
		get: -> @_hideForSingle
		set: (value) ->
			@_hideForSingle = value
			@_updateDots() if @numberOfPages is 1
	
	@define "pageIndicatorTintColor",
		get: -> @_tintColor
		set: (value) ->
			@_tintColor = value
			@_updateDotColors()
	
	@define "currentPageIndicatorTintColor",
		get: -> @_currentTintColor
		set: (value) ->
			@_currentTintColor = value
			@_updateDotColors()
	
	_updateDots: ->
		return if !@_dots?
		
		# Create additional dots
		while @_dots.length < @numberOfPages
			dot = new Layer
				name: ".dot"
				parent: @
				width: 7
				height: 7
				borderRadius: 3.5
				backgroundColor: @pageIndicatorTintColor
			@_dots.push dot
		
		# Remove extra dots
		while @_dots.length > @numberOfPages
			lastDot = @_dots.pop()
			lastDot.destroy()
		
		# Position dots
		for dot, index in @_dots
			dot.x = index * 16
		
		# Resize control and center
		@width = _.last(@_dots)?.maxX
		@x = Align.center
		
		# Hide if only one dot
		@visible = @_dots.length > 1 or !@hidesForSinglePage
		
		@_updateDotColors()

	_updateDotColors: ->
		return if !@_dots?
		
		otherColor = @pageIndicatorTintColor
		otherColor = new Color(otherColor) if !Color.isColorObject(otherColor)
		
		selectedColor = @currentPageIndicatorTintColor
		
		# The desired API is to just set both tint colors to white/black. In that case, this is where we change the color opacity
		if otherColor.isEqual selectedColor
			otherColor = otherColor.alpha(0.45) if otherColor.isEqual("white")
			otherColor = otherColor.alpha(0.32) if otherColor.isEqual("black")
		
		dot.backgroundColor = otherColor for dot in @_dots
		
		currentIndex = Math.max(Math.min(@currentPage, @_dots.length-1), 0)
		@_dots[currentIndex]?.backgroundColor = selectedColor


class exports.iOSPageComponent extends PageComponent
	constructor: (options={}) ->
		options = _.defaults {}, options,
			size: Screen.size
			x: Align.center 
			y: Align.center
			scrollVertical: false
		
		super options
		
		@pageControl = new iOSPageControl
			name: "pageControl"
			parent: @
			y: Align.bottom -15
			numberOfPages: @content.children.length
			currentPage: @horizontalPageIndex(@currentPage)
		
		@content.on "change:children", =>
			@pageControl.numberOfPages = @content.children.length
		
		@on "change:currentPage", ->
			@pageControl.currentPage = @horizontalPageIndex(@currentPage)
		
		@on "change:size", ->
			@pageControl.x = Align.center
			@pageControl.y = Align.bottom -15


exports.iOSPageControl = iOSPageControl
