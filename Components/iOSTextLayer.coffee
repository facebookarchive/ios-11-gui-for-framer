###
	# iOSTextLayer
	{iOSTextLayer} = require "iOSTextLayer"

	text = new iOSTextLayer
		# OPTIONAL
		textStyle: <iOSTextStyle> (adjusts the fontSize and fontWeight properties, defaults to body)

	# values for textStyle
	iOSTextStyle.boldTitle
	iOSTextStyle.largeTitle
	iOSTextStyle.title1
	iOSTextStyle.title2
	iOSTextStyle.title3
	iOSTextStyle.headline
	iOSTextStyle.body
	iOSTextStyle.callout
	iOSTextStyle.subhead
	iOSTextStyle.footnote
	iOSTextStyle.caption1
	iOSTextStyle.caption2

###


window.iOSTextStyle =
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

class exports.iOSTextLayer extends TextLayer
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
