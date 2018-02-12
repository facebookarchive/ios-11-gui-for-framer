###
	# AlertView

	alert = new AlertView
		# OPTIONAL
		title: <string> (title of the alert)
		message: <string> (message of the alert)
		tintColor: <color> (text color of the actions)

	alert.addAction <string> (title of the action), <string> (style for action, either "default", "cancel", or "destructive"), <function> (callback called when action selected)

	alert.present <bool> (shows the alert)
	alert.dismiss <bool> (dismisses the alert)

###




Events.ActionSelected = "actionSelected"
Events.AlertViewAppear = "alertViewAppear"
Events.AlertViewDismiss = "alertViewDismiss"




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

		super options
		keyline2 = new Layer
			name: ".Keyline2"
			parent: @
			size: @size
			backgroundColor: "rgba(63,63,63,0.4)"
			style:
				mixBlendMode: "color-burn"

class AlertViewAction extends Layer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			height: 43
			backgroundColor: iOSKitColors.transparent
			actionStyle: "default"

			title: "OK"
		super options

		@keyline = new Keyline
			name: ".Keyline"
			parent: @
			width: @width
			height: 0.5

		if @x isnt 0
			@verticalKeyline = new Keyline
				name: ".VerticalKeyline"
				parent: @
				width: 0.5
				height: @height


		@actionTitleLabel = new iOSTextLayer
			name: ".ActionTitleLabel"
			parent: @
			text: @title
			textStyle: if @actionStyle is "cancel" then iOSTextStyle.headline else iOSTextStyle.body
			color: if @actionStyle is "destructive" then iOSKitColors.red else @tintColor
			textAlign: "center"

			width: @width - 32
			point: Align.center

		@onMouseDown ->
			@_triggerPressedState()
		@onMouseUp ->
			@_resetPressedState()
		@onMouseOut ->
			@_resetPressedState()


	showKeyline: ->
		@keyline?.visible = true
	showVerticalKeyline: ->
		@verticalKeyline?.visible = true
	hideKeyline: ->
		@keyline?.visible = false
	hideVerticalKeyline: ->
		@verticalKeyline?.visible = false
	hideKeylinePermanently: ->
		@keyline.destroy()

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
		@backgroundColor = "rgba(0,0,0,0.07)"
		@hideKeyline()
		@hideVerticalKeyline()
		for s in @siblings
			if s.minY is @maxY then s.hideKeyline()
			if s.x isnt 0 then s.hideVerticalKeyline()
	_resetPressedState: ->
		@.backgroundColor = iOSKitColors.transparent
		@showKeyline()
		@showVerticalKeyline()
		for s in @siblings
			if s.minY is @maxY then s.showKeyline()
			if s.x isnt 0 then s.showVerticalKeyline()

class AlertView extends Layer
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

		@alert = new Layer
			name: ".alert"
			parent: @
			width: 270
			borderRadius: 14
			backgroundColor: "rgba(248,248,248,0.82)"
			backgroundBlur: 20
			opacity: 0

		@alert.states.presented =
			opacity: 1
			scale: 1
		if @title
			@titleLabel = new iOSTextLayer
				name: "titleLabel"
				parent: @alert

				text: @title
				textStyle: iOSTextStyle.headline
				color: iOSKitColors.black
				textAlign: "center"
				lineHeight: 1.3

				width: @alert.width - 32
				x: Align.center, y: Align.top(19)

		if @message
			@messageLabel = new iOSTextLayer
				name: "messageLabel"
				parent: @alert

				text: @message
				textStyle: iOSTextStyle.footnote
				color: iOSKitColors.black
				textAlign: "center"

				width: @titleLabel.width
				x: Align.center, y: @titleLabel.maxY + 1


		@_actions = []
		@bottomActions = new Layer
			name: "bottomActions"
			parent: @alert
			y: if @alert.children.length > 0 then @alert.children[@alert.children.length - 1].maxY + 22 else 0
			width: @alert.width, height: 0
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
		@alert.scale = 1.1

		if animated then @alert.animate "presented",
			time: 0.2
			curve: "easeinout"
		else
			@alert.stateSwitch "presented"
		if animated then @overlay.animate "presented",
			time: 0.2
			curve: "easeinout"
		else
			@overlay.stateSwitch "presented"

		@_isShowing = true
		@emit Events.AlertViewAppear
	dismiss: (animated=true) ->
		if animated then @alert.animate "default",
			time: 0.2
			curve: "easein"
		else
			@alert.stateSwitch "default"
			@visible = false
		if animated then @overlay.animate "default",
			time: 0.2
			curve: "easein"
		else
			@overlay.stateSwitch "default"

		if animated then Utils.delay 0.2, =>
			@visible = false
			@destroy()

		@_isShowing = false
		@emit Events.AlertViewDismiss
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

	_isHorizontalActionLayout: ->
		if @_actions.length is 2
			# Measure the actions' labels to see if we need to wrap
			dummyAction = new AlertViewAction
				title: @_actions[0].title
				style: @_actions[0].style

				x: -9999
				y: -9999
				opacity: 0
			dummyAction.actionTitleLabel.autoSize = true
			_firstActionWidth = dummyAction.actionTitleLabel.width
			dummyAction.destroy()

			dummyAction = new AlertViewAction
				title: @_actions[1].title
				style: @_actions[1].style

				x: -9999
				y: -9999
				opacity: 0
			dummyAction.actionTitleLabel.autoSize = true
			_secondActionWidth = dummyAction.actionTitleLabel.width
			dummyAction.destroy()

			return _firstActionWidth < (@alert.width / 2) - 34 and _secondActionWidth < (@alert.width / 2) - 34
		return false

	_reorderActions: ->
		_cancelIndex = -1
		for _action, i in @_actions
			if _action.style is "cancel" then _cancelIndex = i
		if @_isHorizontalActionLayout() and _cancelIndex is 1
			_.reverse @_actions
		else if !@_isHorizontalActionLayout()
			@_actions.push @_actions.splice(_cancelIndex, 1)[0]


	_updateLayout: ->
# 		Logic for updating drawing
		c.destroy() for c in @bottomActions.children
		if @_actions.length is 0
			action = new AlertViewAction
				parent: @bottomActions
				width: @alert.width
			@bottomActions.height = action.height

		else
			for _action, i in @_actions
				parent = @
				action = new AlertViewAction
					parent: @bottomActions
					width: if @_isHorizontalActionLayout() then @alert.width / 2 else @alert.width
					y: if @_isHorizontalActionLayout() then 0 else i * 43
					x: if @_isHorizontalActionLayout() then i * @alert.width / 2 else 0

					title: _action.title
					actionStyle: _action.style
					tintColor: @tintColor
# 				remove keyline if there is no message or title
				if i is 0 and not @title and not @message then action.hideKeylinePermanently()

				do(_action) ->
					action.onClick ->
						parent.emit Events.ActionSelected, _action.title
						_action.callback?()

						parent.dismiss()
			@bottomActions.height = if @_isHorizontalActionLayout() then 43 else @_actions.length * 43
		@alert.height = @alert.children[@alert.children.length - 1].maxY
		@alert.center()
		@alert.states.default = @alert.props

	_updateTintColor: ->
		if @bottomActions
			for a in @bottomActions.children
				a.tintColor = @tintColor

	onActionSelected: (cb) -> @on(Events.ActionSelected, cb)
	onAlertViewAppear: (cb) -> @on(Events.AlertViewAppear, cb)
	onAlertViewDismiss: (cb) -> @on(Events.AlertViewDismiss, cb)


exports.iOSAlertView = AlertView
