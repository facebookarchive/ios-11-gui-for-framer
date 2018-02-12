###
	# ActionSheet

	actionSheet = new ActionSheet
		# OPTIONAL
		title: <string> (title of the alert)
		message: <string> (message of the alert)
		tintColor: <color> (text color of the actions)

	actionSheet.addAction <string> (title of the action), <string> (style for action, either "default", "cancel", or "destructive"), <function> (callback called when action selected)

	actionSheet.present <bool> (shows the sheet)
	actionSheet.dismiss <bool> (dismisses the sheet)

###

ACTIONHEIGHT = 57


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



class Keyline extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			backgroundColor: "rgba(0,0,80,0.05)"
			height: 0.5

		super options
		keyline2 = new Layer
			name: ".Keyline2"
			parent: @
			size: @size
			backgroundColor: "rgba(63,63,63,0.4)"
			style:
				mixBlendMode: "color-burn"

class ActionSheetAction extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			height: ACTIONHEIGHT
			backgroundColor: iOSKitColors.transparent
			actionStyle: "default"

			title: "OK"
		super options

		if @actionStyle is "cancel"
			@backgroundColor = iOSKitColors.white
		else
			@keyline = new Keyline
				name: ".Keyline"
				parent: @
				width: @width



		@actionTitleLabel = new iOSTextLayer
			name: ".ActionTitleLabel"
			text: @title
			color: if @actionStyle is "destructive" then iOSKitColors.red else @tintColor
			textAlign: "center"
			textStyle: if @actionStyle is "cancel" then iOSTextStyle.headline else iOSTextStyle.body

		if @actionTitleLabel.width > @width - 32
			@actionTitleLabel.textStyle = iOSTextStyle.footnote
			# Truncation logic
			_truncationIndex = -1
			@actionTitleLabel.text = ""
			for char, i in @title
				@actionTitleLabel.text += char
				if @actionTitleLabel.width > @width - 32
					_truncationIndex = i-1
					break
			@actionTitleLabel.text = @title.substring(0, _truncationIndex - 3)
			@actionTitleLabel.text += "..."

		@actionTitleLabel.props =
			width: @width - 32
			parent: @
			point: Align.center


		@onMouseDown ->
			@_triggerPressedState()
		@onMouseUp ->
			@_resetPressedState()
		@onMouseOut ->
			@_resetPressedState()


	showKeyline: ->
		@keyline?.visible = true
	hideKeyline: ->
		@keyline?.visible = false
	hideKeylinePermanently: ->
		@keyline?.destroy()

	@define "title",
		get: -> @_title
		set: (value) ->
			@_title = value
	@define "actionStyle",
		get: -> @_actionStyle
		set: (value) ->
			@_actionStyle = value
	@define "tintColor",
		get: -> @_tintColor
		set: (value) ->
			@_tintColor = value
			@_updateTintColor()

	_updateTintColor: ->
		@actionTitleLabel?.color = @tintColor unless @actionStyle is "destructive"
	_triggerPressedState: ->
		@backgroundColor = if @actionStyle is "cancel" then "rgba(230,230,230,1)" else "rgba(0,0,0,0.07)"
		@hideKeyline()
		for s in @siblings
			if s.minY is @maxY then s.hideKeyline()
	_resetPressedState: ->
		@backgroundColor = if @actionStyle is "cancel" then iOSKitColors.white else iOSKitColors.transparent
		@showKeyline()
		for s in @siblings
			if s.minY is @maxY then s.showKeyline()


Events.ActionSelected = "actionSelected"
Events.ActionSheetAppear = "actionSheetAppear"
Events.ActionSheetDismiss = "actionSheetDismiss"
class ActionSheet extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			size: Screen.size
			backgroundColor: iOSKitColors.transparent

			tintColor: iOSKitColors.blue
		super options

		if @message and not @title
			@title = @message
			@message = null

		@overlay = new Layer
			name: ".overlay"
			parent: @
			size: Screen.size
			backgroundColor: iOSKitColors.black
			opacity: 0
		@overlay.states.presented =
			opacity: 0.4
		@overlay.onTap =>
			lastAction = _.last(@_actions)
			return if !lastAction? or lastAction?.style isnt "cancel"

			@emit Events.ActionSelected, lastAction.title
			lastAction.callback?()
			@dismiss()

		@sheet = new Layer
			name: ".sheet"
			parent: @
			width: Math.min(Screen.width,Screen.height) - 20
			backgroundColor: ""
		@topSection = new Layer
			name: ".topSection"
			parent: @sheet
			width: @sheet.width
			borderRadius: 14
			backgroundColor: "rgba(248,248,248,0.82)"
			backgroundBlur: 20


		@sheet.states.presented =
			maxY: Screen.height - 12
		if @title
			@titleLabel = new TextLayer
				name: ".titleLabel"
				parent: @topSection

				text: @title
				color: "rgba(0,0,0,0.4)"
				textAlign: "center"
				fontSize: 13
				fontWeight: 600


				width: @topSection.width - 32
				x: Align.center, y: Align.top(15)

		if @message
			@messageLabel = new iOSTextLayer
				name: ".messageLabel"
				parent: @topSection

				text: @message
				textStyle: iOSTextStyle.footnote
				color: "rgba(0,0,0,0.4)"
				textAlign: "center"

				width: @titleLabel.width
				x: Align.center, y: @titleLabel.maxY + 12


		@_actions = []
		@actions = new Layer
			name: ".actions"
			parent: @topSection
			y: if @topSection.children.length > 0 then @topSection.children[@topSection.children.length - 1].maxY + 22 else 0
			width: @topSection.width, height: 0
			backgroundColor: iOSKitColors.transparent


		@_updateLayout()
		@visible = false

	addAction: (action, style="default", callback) ->
# 		Support flexibility if a callback exists without a style
		if _.isFunction(arguments[1])
			callback = arguments[1]
			style = "default"
		@_actions.push {title: action, style: style, callback: callback}
		@_reorderActions()
		@_updateLayout()

	present: (animated=true) ->
		if @_isShowing then return
		@visible = true

		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		yMargin = 12
		if isIPhoneX
			yMargin = if isPortrait then 32 else 21

		@sheet.states.presented.maxY = Screen.height - yMargin

		if animated then @sheet.animate "presented",
			time: 0.5
			curve: Spring(damping: 0.9)
		else
			@sheet.stateSwitch "presented"
		if animated then @overlay.animate "presented",
			time: 0.5
			curve: Spring(damping: 0.9)
		else
			@overlay.stateSwitch "presented"

		@_isShowing = true
		@emit Events.ActionSheetAppear
	dismiss: (animated=true) ->
		if animated then @sheet.animate "default",
			time: 0.5
			curve: Spring(damping: 0.9)
		else
			@sheet.stateSwitch "default"
			@visible = false
		if animated then @overlay.animate "default",
			time: 0.5
			curve: Spring(damping: 0.9)
		else
			@overlay.stateSwitch "default"

		if animated then Utils.delay 0.5, =>
			@visible = false
			@destroy()

		@_isShowing = false
		@emit Events.ActionSheetDismiss
	@define "title",
		get: -> @_title
		set: (value) ->
			@_title = value

	@define "message",
		get: -> @_message
		set: (value) ->
			@_message = value

	@define "tintColor",
		get: -> @_tintColor
		set: (value) ->
			@_tintColor = value
			@_updateTintColor()


	_cancelButtonPresent: ->
		return (_.last(@_actions))?.style is "cancel"

	_reorderActions: ->
		_cancelIndex = _.findIndex @_actions, (o) -> o.style is "cancel"
# 		for _action, i in @_actions
# 			if _action.style is "cancel" then _cancelIndex = i

		@_actions.push @_actions.splice(_cancelIndex, 1)[0]

	_updateTopSectionHeight: ->
		@topSection.height = _.last(@topSection.children).maxY
	_updateLayout: ->
# 		Logic for updating drawing
		c.destroy() for c in @actions.children
		@actions.height = 0
# 		Remove cancel button to redraw
		if @_cancelButtonPresent() and _.last(@sheet.children).name is ".cancel" then _.last(@sheet.children).destroy()
		if @_actions.length is 0
			action = new ActionSheetAction
				parent: @actions
				width: @sheet.width
			@actions.height = action.height

		else
			for _action, i in @_actions
				parent = @
				if _action.style is "cancel"
					action = new ActionSheetAction
						name: ".cancel"
						parent: @sheet
						width: @sheet.width
						y: @topSection.maxY + 7

						title: _action.title
						actionStyle: _action.style
						tintColor: @tintColor

						borderRadius: 14
						backgroundColor: iOSKitColors.white

				else
					action = new ActionSheetAction
						parent: @actions
						width: @sheet.width
						y: i * ACTIONHEIGHT

						title: _action.title
						actionStyle: _action.style
						tintColor: @tintColor
					@actions.height += ACTIONHEIGHT
					@_updateTopSectionHeight()
# 				remove keyline if there is no message or title
				if i is 0 and not @title and not @message then action.hideKeylinePermanently()

				do(_action) ->
					action.onClick ->
						parent.emit Events.ActionSelected, _action.title
						_action.callback?()

						parent.dismiss()
# 			If a cancel button is present, size the topSection accordingly
# 			@actions.height = if @_cancelButtonPresent() then ((@_actions.length) - 1) * ACTIONHEIGHT else @_actions.length * ACTIONHEIGHT
		@sheet.height = _.last(@sheet.children).maxY
		@sheet.y = Screen.height + 12
		@sheet.centerX()
		@sheet.states.default = @sheet.props

	_updateTintColor: ->
		if @bottomActions
			for a in @bottomActions.children
				a.tintColor = @tintColor

	onActionSelected: (cb) -> @on(Events.ActionSelected, cb)
	onActionSheetAppear: (cb) -> @on(Events.ActionSheetAppear, cb)
	onActionSheetDismiss: (cb) -> @on(Events.ActionSheetDismiss, cb)


exports.iOSActionSheet = ActionSheet
