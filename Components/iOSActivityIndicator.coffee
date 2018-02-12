###
	# iOSActivityIndicator
	{iOSActivityIndicator} = require "iOSActivityIndicator"

	indicator = new iOSActivityIndicator
		# OPTIONAL
		animating: <bool> (value indicates if the animation is running, set calls startAnimating and stopAnimating, default true)
		color: <color> (the color of the acitivity indicator, defaults to a gray value)
		large: <bool> (specifies if the indicator should be large or small, default false)
		hidesWhenStopped: <bool> (controls if the indicator should be visible only while the animation is running, default false)
	
	indicator.startAnimating()	# starts the animation
	indicator.stopAnimating()	# stops the animation

	# Observe the start/stop animation events
	indicator.onAnimationStart ->
	indicator.onAnimationStop ->

###

class exports.iOSActivityIndicator extends SVGLayer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			backgroundColor: ""
			color: new Color("black").alpha(0.45)
			width: 20
			height: 20
			animating: true
			large: false
			hidesWhenStopped: false
		
		super options
		
		@_spinner = new SVGLayer
			parent: @
			name: ".spinner"
			color: @color
			backgroundColor: ""
			htmlIntrinsicSize:
				width: 20
				height: 20
			html: "<svg width='20px' height='20px' viewBox='0 -4 20 20' id='svg' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <g id='spinner' transform='scale(1)'> <path d='M9,1 L9,4 C9,4.55228475 9.44771525,5 10,5 C10.5522847,5 11,4.55228475 11,4 L11,1 C11,0.44771525 10.5522847,0 10,0 C9.44771525,0 9,0.44771525 9,1 Z' id='Line' opacity='0.269999981'></path> <path d='M9,16 L9,19 C9,19.5522847 9.44771525,20 10,20 C10.5522847,20 11,19.5522847 11,19 L11,16 C11,15.4477153 10.5522847,15 10,15 C9.44771525,15 9,15.4477153 9,16 Z' id='Line' opacity='0.560000002'></path> <path d='M13.6339746,1.70577137 C13.910117,1.22747874 14.5217074,1.06360359 15,1.33974596 C15.4782926,1.61588834 15.6421678,2.22747874 15.3660254,2.70577137 L13.8660254,5.30384758 C13.589883,5.7821402 12.9782926,5.94601536 12.5,5.66987298 C12.0217074,5.39373061 11.8578322,4.7821402 12.1339746,4.30384758 L13.6339746,1.70577137 Z' id='Combined-Shape' opacity='0.269999981'></path> <path d='M6.1339746,14.6961524 C6.41011697,14.2178598 7.02170738,14.0539846 7.5,14.330127 C7.97829262,14.6062694 8.14216778,15.2178598 7.8660254,15.6961524 L6.3660254,18.2942286 C6.08988303,18.7725213 5.47829262,18.9363964 5,18.660254 C4.52170738,18.3841117 4.35783222,17.7725213 4.6339746,17.2942286 L6.1339746,14.6961524 Z' id='Combined-Shape' opacity='0.659999967'></path> <path d='M17.2942286,4.6339746 C17.7725213,4.35783222 18.3841117,4.52170738 18.660254,5 C18.9363964,5.47829262 18.7725213,6.08988303 18.2942286,6.3660254 L15.6961524,7.8660254 C15.2178598,8.14216778 14.6062694,7.97829262 14.330127,7.5 C14.0539846,7.02170738 14.2178598,6.41011697 14.6961524,6.1339746 L17.2942286,4.6339746 Z' id='Combined-Shape' opacity='0.269999981'></path> <path d='M4.30384758,12.1339746 C4.7821402,11.8578322 5.39373061,12.0217074 5.66987298,12.5 C5.94601536,12.9782926 5.7821402,13.589883 5.30384758,13.8660254 L2.70577137,15.3660254 C2.22747874,15.6421678 1.61588834,15.4782926 1.33974596,15 C1.06360359,14.5217074 1.22747874,13.910117 1.70577137,13.6339746 L4.30384758,12.1339746 Z' id='Combined-Shape' opacity='0.75'></path> <path d='M19,9 C19.5522847,9 20,9.44771525 20,10 C20,10.5522847 19.5522847,11 19,11 L16,11 C15.4477153,11 15,10.5522847 15,10 C15,9.44771525 15.4477153,9 16,9 L19,9 Z' id='Combined-Shape' opacity='0.269999981'></path> <path d='M4,9 C4.55228475,9 5,9.44771525 5,10 C5,10.5522847 4.55228475,11 4,11 L1,11 C0.44771525,11 0,10.5522847 0,10 C0,9.44771525 0.44771525,9 1,9 L4,9 Z' id='Combined-Shape' opacity='0.849999964'></path> <path d='M18.2942286,13.6339746 C18.7725213,13.910117 18.9363964,14.5217074 18.660254,15 C18.3841117,15.4782926 17.7725213,15.6421678 17.2942286,15.3660254 L14.6961524,13.8660254 C14.2178598,13.589883 14.0539846,12.9782926 14.330127,12.5 C14.6062694,12.0217074 15.2178598,11.8578322 15.6961524,12.1339746 L18.2942286,13.6339746 Z' id='Combined-Shape' opacity='0.359999985'></path> <path d='M5.30384758,6.1339746 C5.7821402,6.41011697 5.94601536,7.02170738 5.66987298,7.5 C5.39373061,7.97829262 4.7821402,8.14216778 4.30384758,7.8660254 L1.70577137,6.3660254 C1.22747874,6.08988303 1.06360359,5.47829262 1.33974596,5 C1.61588834,4.52170738 2.22747874,4.35783222 2.70577137,4.6339746 L5.30384758,6.1339746 Z' id='Combined-Shape' opacity='0.269999981'></path> <path d='M15.3660254,17.2942286 C15.6421678,17.7725213 15.4782926,18.3841117 15,18.660254 C14.5217074,18.9363964 13.910117,18.7725213 13.6339746,18.2942286 L12.1339746,15.6961524 C11.8578322,15.2178598 12.0217074,14.6062694 12.5,14.330127 C12.9782926,14.0539846 13.589883,14.2178598 13.8660254,14.6961524 L15.3660254,17.2942286 Z' id='Combined-Shape' opacity='0.459999979'></path> <path d='M7.8660254,4.30384758 C8.14216778,4.7821402 7.97829262,5.39373061 7.5,5.66987298 C7.02170738,5.94601536 6.41011697,5.7821402 6.1339746,5.30384758 L4.6339746,2.70577137 C4.35783222,2.22747874 4.52170738,1.61588834 5,1.33974596 C5.47829262,1.06360359 6.08988303,1.22747874 6.3660254,1.70577137 L7.8660254,4.30384758 Z' id='Combined-Shape' opacity='0.269999981'></path> </svg>"
		@_updateScale()

		@point = options.point


	@define "large",
		get: -> @_large
		set: (value) ->
			@_large = value
			@_updateScale()
			
	_updateScale: ->
		scale = if @large then 2.6 else 1
		size = 20 * scale
		@width = size
		@height = size

		@_spinner?.width = size
		@_spinner?.height = size
		@_spinner?.x = Align.center
		@_spinner?.y = -4 * scale
	
	@define "animating",
		get: -> @_animating
		set: (value) ->
			return if @_animating is value
			
			@stopAnimating() if !value
			@startAnimating() if value
			@_animating = value
	
	startAnimating: ->
		return if @animating
		
		@_animating = true
		@visible = true

		@emit Events.AnimationStart

		@_timer = Utils.interval 1/12, =>
			@rotation += 360/12
	
	stopAnimating: ->
		return if !@animating
		
		@_animating = false
		@visible = false if @hidesWhenStopped

		@emit Events.AnimationStop

		window.clearInterval(@_timer)

	@define "hidesWhenStopped",
		get: -> @_hidesWhenStopped
		set: (value) ->
			@_hidesWhenStopped = value
			@visible = @animating or !value

