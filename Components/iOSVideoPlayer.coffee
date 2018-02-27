###
	# iOSVideoPlayer
	{iOSVideoPlayer} = require "iOSVideoPlayer"

	videoPlayer = new iOSVideoPlayer
		video: <url> location of the video to be played
		fullScreen: <bool> sets the video to be presented in full screen mode or embedded in the UI (defaults to true)
		autoplay: <bool> begin playback of the video once it is loaded (defaults to false)
		volume: <number 0-1> convience accessor to player.volume, sets the volume of the video (defaults to 0)

	# EXAMPLE
	video = new iOSVideoPlayer
		video: "http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v"

	video = new iOSVideoPlayer
		video: "http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v"
		fullScreen: false
		parent: container
		width: 350
		height: 250

###



class exports.iOSVideoPlayer extends VideoLayer
	constructor: (options={}) ->
		options = _.defaults {}, options,
			name: "VideoPlayer"
			point: Align.center
			backgroundColor: "black"
			fullScreen: true
			autoplay: false
			volume: 0

		super options
		
		@_setupControls()
		
		@_updateVideoLayout false
		@scrubStartTime = 0
		
		@_updateVolume false
		
		@_setupEvents()
	
	_setupControls: ->
		@_fullscreenBG = new Layer
			name: ".Background"
			parent: @parent
			size: Screen.size
			backgroundColor: "black"
			visible: @fullScreen
			opacity: if @fullScreen then 1 else 0
		@_fullscreenBG.placeBehind @
			
		@_controls = new Layer
			name: ".controls"
			size: @size
			parent: @parent
			backgroundColor: ""
		@_controls.states.show =
			opacity: 1
			options: time: 0.15
		@_controls.states.hide =
			opacity: 0
			options: time: 0.15
		@_controls.onTap (event) =>
			return if @_isClosingFullScreen
# 			return if event.offsetTime > 300 or Utils.pointDistance(Utils.pointZero, event.offset) > 10
			@_showVolumeSlider false if @_controls.states.current.name is "hide"
			@_controls.animate "show"
			@_cancelAutoHide()
			@_autoHideControls()
		
		@_closeContainer = new Layer
			name: "closeContainer"
			parent: @_controls
			width: 120
			height: 47
			borderRadius: 16
			backgroundColor: ""
			backgroundBlur: 50
		
		@_closeBtn = new Layer
			name: "close"
			parent: @_closeContainer
			width: 60
			height: 47
			borderRadius: {topLeft:16, topRight:0, bottomRight:0, bottomLeft:16}
			backgroundColor: Color.gray(0.27,0.3)
		@_closeGlyph = new SVGLayer
			name: "closeGlyph"
			parent: @_closeBtn
			width: 22
			height: 22
			point: Align.center
			opacity: 0.6
			svg: "<svg width='20px' height='19px' viewBox='0 0 20 19'> <path d='M12.8994949,11.4852814 L20.6776695,3.70710678 C21.0681938,3.31658249 21.0681938,2.68341751 20.6776695,2.29289322 C20.2871452,1.90236893 19.6539803,1.90236893 19.263456,2.29289322 L11.4852814,10.0710678 L3.70710678,2.29289322 C3.31658249,1.90236893 2.68341751,1.90236893 2.29289322,2.29289322 C1.90236893,2.68341751 1.90236893,3.31658249 2.29289322,3.70710678 L10.0710678,11.4852814 L2.29289322,19.263456 C1.90236893,19.6539803 1.90236893,20.2871452 2.29289322,20.6776695 C2.68341751,21.0681938 3.31658249,21.0681938 3.70710678,20.6776695 L11.4852814,12.8994949 L19.263456,20.6776695 C19.6539803,21.0681938 20.2871452,21.0681938 20.6776695,20.6776695 C21.0681938,20.2871452 21.0681938,19.6539803 20.6776695,19.263456 L12.8994949,11.4852814 Z'></path></svg>"
		@_closeBtn.onTap =>
			event.stopImmediatePropagation()
			@_closeFullScreen()
		
		@_fitFillBtn = new Layer
			name: "fitFill"
			parent: @_closeContainer
			width: 60
			height: 47
			x: @_closeBtn.maxX
			borderRadius: {topLeft:0, topRight:16, bottomRight:16, bottomLeft:0}
			backgroundColor: Color.gray(0.27,0.5)
		
		@_fitFillGlyph = new Layer
			name: "fitFill"
			parent: @_fitFillBtn
			width: 25
			height: 16
			point: Align.center
			borderRadius: 1.5
			borderWidth: 1.5
			backgroundColor: ""
			borderColor: Color.gray(1).alpha(0.65)
		@_fitFillTopLine = new Layer
			name: "fitTop"
			parent: @_fitFillGlyph
			width: 23
			height: 0
			x: 1
			y: 1
			backgroundColor: Color.gray(1).alpha(0.65)
		@_fitFillBottomLine = new Layer
			name: "fitBottom"
			parent: @_fitFillGlyph
			width: 23
			height: 0
			x: 1
			y: 15
			backgroundColor: Color.gray(1).alpha(0.65)
		@_fitFillArrows = new SVGLayer
			parent: @_fitFillBtn
			width: 26
			height: 26
			point: Align.center
			fill: Color.gray(1).alpha(0.65)
			svg: "<svg width='5px' height='10px' viewBox='-0.5 -5 5 10'><path d='M13.25,5.52949399 L13.25,10.470506 L13.743337,9.91074435 C14.0687739,9.58530744 14.4304854,9.58530744 14.7559223,9.91074435 C15.0813592,10.2361813 15.0813592,10.7638187 14.7559223,11.0892557 L13.0892557,12.7559223 C13.062768,12.78241 13.0349408,12.8067418 13.0059922,12.8289178 L12.950002,13 L12.049998,13 L11.9940078,12.8289178 C11.9650592,12.8067418 11.937232,12.78241 11.9107443,12.7559223 L10.2440777,11.0892557 C9.91864077,10.7638187 9.91864077,10.2361813 10.2440777,9.91074435 C10.5695146,9.58530744 10.9312261,9.58530744 11.256663,9.91074435 L11.75,10.470506 L11.75,5.52949399 L11.256663,6.08925565 C10.9312261,6.41469256 10.5695146,6.41469256 10.2440777,6.08925565 C9.91864077,5.76381874 9.91864077,5.23618126 10.2440777,4.91074435 L11.9107443,3.24407768 C11.9316433,3.22317877 11.953376,3.20362194 11.9758356,3.1854072 L12.049998,3 L12.950002,3 L13.0241644,3.1854072 C13.046624,3.20362194 13.0683567,3.22317877 13.0892557,3.24407768 L14.7559223,4.91074435 C15.0813592,5.23618126 15.0813592,5.76381874 14.7559223,6.08925565 C14.4304854,6.41469256 14.0687739,6.41469256 13.743337,6.08925565 L13.25,5.52949399 Z' id='Combined-Shape'></path></svg>"
		
		@_fitFillBtn.onTap =>
			@scaleToFillScreen = !@scaleToFillScreen
		
		@_fullscreenBtn = new Layer
			name: "fullscreen"
			parent: @_controls
			width: 47
			height: 31
			borderRadius: 8
			backgroundColor: Color.gray(0.27,0.5)
			backgroundBlur: 50
		@_fullscreenBtn.onTap =>
			event.stopImmediatePropagation()
			@_goToFullScreen()
		
		@_maximizeGlyph = new SVGLayer
			parent: @_fullscreenBtn
			width: 26
			height: 26
			point: Align.center
			opacity: 0.65
			svg: "<svg width='15px' height='15px' viewBox='0 0 15 15'><path d='M19.6456473,18.7180967 L19.6456473,16.222068 C19.6456473,15.8450996 19.9490823,15.5395063 20.3233884,15.5395063 C20.6976945,15.5395063 21.0011296,15.8450996 21.0011296,16.222068 L21.0011296,20.3174383 C21.0011296,20.5059225 20.9252708,20.6765629 20.8026238,20.8000823 C20.6799768,20.9236017 20.5105415,21 20.3233884,21 L16.2569416,21 C15.8826355,21 15.5792004,20.6944067 15.5792004,20.3174383 C15.5792004,19.9404699 15.8826355,19.6348766 16.2569416,19.6348766 L18.639011,19.6348766 L14.5385059,15.5052059 C14.2738316,15.2386489 14.2738316,14.8064748 14.5385059,14.5399178 C14.8031803,14.2733609 15.2323023,14.2733609 15.4969767,14.5399178 L19.6456473,18.7180967 Z M7.35548229,8.3135606 L7.35548229,10.7433835 C7.35548229,11.1176261 7.05204724,11.4210097 6.67774114,11.4210097 C6.30343505,11.4210097 6,11.1176261 6,10.7433835 L6,6.67762621 C6,6.4905049 6.07585876,6.32109835 6.19850578,6.19847212 C6.32115281,6.0758459 6.49058809,6 6.67774114,6 L10.744188,6 C11.1184941,6 11.4219291,6.30338359 11.4219291,6.67762621 C11.4219291,7.05186884 11.1184941,7.35525243 10.744188,7.35525243 L8.313953,7.35525243 L12.4626236,11.5032195 C12.727298,11.767849 12.727298,12.1968982 12.4626236,12.4615277 C12.1979493,12.7261572 11.7688273,12.7261572 11.5041529,12.4615277 L7.35548229,8.3135606 Z'></path></svg>"
		
		@_transportContainer = new Layer
			name: "transportContainer"
			parent: @_controls
			height: 94
			borderRadius: 16
			backgroundColor: Color.gray(0.27,0.5)
			backgroundBlur: 50
		
		@_transportBG = new Layer
			name: "transport bg"
			parent: @_transportContainer
			height: 4.5
			backgroundColor: Color.gray(1, 0.25)
			style: "mix-blend-mode": "soft-light"
			
		@_transportSlider = new SliderComponent
			name: "transport slider"
			parent: @_transportContainer
			height: @_transportBG.height
			backgroundColor: Color.gray(1, 0.1)
			knobSize: 9
		@_transportSlider.fill.backgroundColor = Color.gray(1,0.4)
		@_transportSlider.knob.draggable.momentum = false
		@_transportSlider.hitArea = 30
		@_transportSlider.sliderOverlay.center()
		
		# Seeking
		@_transportSlider.on "change:value", (value, layer) =>
			return if @_transportSlider.knob.isAnimating
			@player.currentTime = @_transportSlider.value * @_duration
		
		@_transportSlider.onTouchStart (event) =>
			@_wasPlaying = !@player.paused
			@player.pause()
			@_cancelAutoHide()
		
		@_transportSlider.onTouchEnd (event) =>
			@player.play() if @_wasPlaying
			@_updateTransport()
			@_autoHideControls()
			
		# Labels
		@_elapsedLabel = new TextLayer
			name: "elapsedTime"
			parent: @_transportContainer
			text: "0:00"
			# textStyle: iOSTextStyle.caption2
			fontSize: 11
			fontWeight: 400
			textAlign: "left"
			color: "white"
			style:{"font-variant-numeric":"tabular-nums"}
			width: 25
			height: 13
		@_elapsedLabel.states.mini = 
			# textStyle: iOSTextStyle.footnote
			fontSize: 13
			fontWeight: 400
			width: 38
			height: 16
			y: Align.center
			clip: false
			textAlign: "right"
		
		@_remainingLabel = @_elapsedLabel.copy()
		@_remainingLabel.props = 
			name: "remainingTime"
			parent: @_transportContainer
			textAlign: "right"
			text: "--:--"
			width: 35
			height: 13
		@_remainingLabel.states.mini = 
			# textStyle: iOSTextStyle.footnote
			fontSize: 13
			fontWeight: 400
			width: 48
			height: 16
			y: Align.center
			textAlign: "left"
		
		# Play/Pause
		@_pauseBtn = new SVGLayer
			name: "pause"
			parent: @_transportContainer
			width: 28
			height: 28
			opacity: 0.87
			visible: !@player.paused
			backgroundColor: ""
			svg: "<svg width='21px' height='23px' viewBox='0 0 21 23'> <path d='M19,2 L22,2 C23.1045695,2 24,2.8954305 24,4 L24,23 C24,24.1045695 23.1045695,25 22,25 L19,25 C17.8954305,25 17,24.1045695 17,23 L17,4 C17,2.8954305 17.8954305,2 19,2 Z M6,2 L9,2 C10.1045695,2 11,2.8954305 11,4 L11,23 C11,24.1045695 10.1045695,25 9,25 L6,25 C4.8954305,25 4,24.1045695 4,23 L4,4 C4,2.8954305 4.8954305,2 6,2 Z'></path></svg>"
		@_pauseBtn.onTap =>
			@player.pause()
			
		@_playBtn = new SVGLayer
			name: "play"
			parent: @_transportContainer
			width: 28
			height: 28
			opacity: 0.87
			visible: @player.paused
			backgroundColor: ""
			svg: "<svg width='20px' height='24px' viewBox='0 0 20 24'> <path d='M23.5124279,14.8598676 L5.50808625,25.6090316 C5.03457867,25.8917306 4.42224057,25.7358931 4.14039083,25.2609586 C4.04850369,25.1061231 4,24.9292762 4,24.7490867 L4,3.25075874 C4,2.69805495 4.44670885,2.25 4.99775214,2.25 C5.17740029,2.25 5.35371587,2.29864985 5.50808625,2.39081388 L23.5124279,13.1399779 C23.9859354,13.4226769 24.1413048,14.0368602 23.8594551,14.5117947 C23.7744763,14.6549892 23.6551922,14.7746327 23.5124279,14.8598676 Z'></path></svg>"
		@_playBtn.onTap =>
			@player.play()
		
		@_back15Btn = new SVGLayer
			name: "back15"
			parent: @_transportContainer
			width: 28
			height: 28
			opacity: 0.87
			backgroundColor: ""
			svg: "<svg width='20px' height='21px' viewBox='0 0 20 21'> <path d='M10.9365234,18.7701882 L10.9365234,12.993821 L10.8535156,12.993821 L9.10058594,14.2242898 L9.10058594,13.0133523 L10.9414062,11.7242898 L12.1962891,11.7242898 L12.1962891,18.7701882 L10.9365234,18.7701882 Z M16.2753047,18.9459695 C15.5493896,18.9459695 14.9536924,18.7474038 14.4881953,18.3502663 C14.0226982,17.9531289 13.7753048,17.4420663 13.7460078,16.8170632 L14.9276484,16.8170632 C14.9667111,17.1393305 15.1115664,17.3997445 15.3622187,17.5983132 C15.612871,17.7968819 15.9204851,17.8961648 16.2850703,17.8961648 C16.6984838,17.8961648 17.0329531,17.7683991 17.2884883,17.512864 C17.5440234,17.2573289 17.6717891,16.9196044 17.6717891,16.4996804 C17.6717891,16.0797564 17.5440234,15.7387768 17.2884883,15.4767312 C17.0329531,15.2146856 16.701739,15.0836648 16.2948359,15.0836648 C16.0083762,15.0836648 15.7536587,15.1438855 15.5306758,15.2643288 C15.3076929,15.3847722 15.1310996,15.5556689 15.0008906,15.7770242 L13.8583125,15.7770242 L14.2245234,11.7242898 L18.4676875,11.7242898 L18.4676875,12.7887429 L15.2010859,12.7887429 L15.0301875,14.766282 L15.1131953,14.766282 C15.4387178,14.3268267 15.9351321,14.1071023 16.6024531,14.1071023 C17.2697742,14.1071023 17.8174575,14.3284542 18.2455195,14.7711648 C18.6735816,15.2138753 18.8876094,15.7802759 18.8876094,16.4703835 C18.8876094,17.2060643 18.6475401,17.8025753 18.1673945,18.2599343 C17.6872489,18.7172934 17.0565586,18.9459695 16.2753047,18.9459695 Z M15.5,7.6649956 L15.5,9.24033111 C15.5,9.40601654 15.3656854,9.54033111 15.2,9.54033111 C15.1456268,9.54033111 15.0922759,9.52555376 15.0456513,9.49757899 L11.5,7.37018822 L11.5,9.24033111 C11.5,9.40601654 11.3656854,9.54033111 11.2,9.54033111 C11.1456268,9.54033111 11.0922759,9.52555376 11.0456513,9.49757899 L6.92874646,7.0274361 C6.78667238,6.94219165 6.74060286,6.75791358 6.82584731,6.6158395 C6.85118224,6.57361462 6.88652158,6.53827528 6.92874646,6.51294035 L11.0456513,4.04279746 C11.1877254,3.95755301 11.3720034,4.00362253 11.4572479,4.14569661 C11.4852226,4.19232123 11.5,4.24567215 11.5,4.30004534 L11.5,6.17018822 L15.0456513,4.04279746 C15.1877254,3.95755301 15.3720034,4.00362253 15.4572479,4.14569661 C15.4852226,4.19232123 15.5,4.24567215 15.5,4.30004534 L15.5,6.14114913 C19.9113445,6.85970186 23.25,10.6897807 23.25,15.2701882 C23.25,20.3788222 19.1086339,24.5201882 14,24.5201882 C8.89136606,24.5201882 4.75,20.3788222 4.75,15.2701882 C4.75,15.1895146 4.75075285,15.0886854 4.75225855,14.9677006 C4.75316643,14.8947508 4.75316643,14.822184 4.75225855,14.75 L6.25,14.75 C6.25,14.8231542 6.25,14.8965503 6.25,14.9701882 L6.25,15.2701882 C6.25,19.550395 9.71979319,23.0201882 14,23.0201882 C18.2802068,23.0201882 21.75,19.550395 21.75,15.2701882 C21.75,11.5170745 19.074128,8.3648916 15.5,7.6649956 Z'></path></svg>"
		@_back15Btn.onTap =>
			@player.currentTime = Math.max(0, @player.currentTime-15)
			@_updateTransport()
		
		@_forward15Btn = new SVGLayer
			name: "forward15"
			parent: @_transportContainer
			width: 28
			height: 28
			opacity: 0.87
			backgroundColor: ""
			svg: "<svg width='20px' height='21px' viewBox='0 0 20 21'><path d='M10.9365234,18.7701882 L10.9365234,12.993821 L10.8535156,12.993821 L9.10058594,14.2242898 L9.10058594,13.0133523 L10.9414062,11.7242898 L12.1962891,11.7242898 L12.1962891,18.7701882 L10.9365234,18.7701882 Z M16.2753047,18.9459695 C15.5493896,18.9459695 14.9536924,18.7474038 14.4881953,18.3502663 C14.0226982,17.9531289 13.7753048,17.4420663 13.7460078,16.8170632 L14.9276484,16.8170632 C14.9667111,17.1393305 15.1115664,17.3997445 15.3622187,17.5983132 C15.612871,17.7968819 15.9204851,17.8961648 16.2850703,17.8961648 C16.6984838,17.8961648 17.0329531,17.7683991 17.2884883,17.512864 C17.5440234,17.2573289 17.6717891,16.9196044 17.6717891,16.4996804 C17.6717891,16.0797564 17.5440234,15.7387768 17.2884883,15.4767312 C17.0329531,15.2146856 16.701739,15.0836648 16.2948359,15.0836648 C16.0083762,15.0836648 15.7536587,15.1438855 15.5306758,15.2643288 C15.3076929,15.3847722 15.1310996,15.5556689 15.0008906,15.7770242 L13.8583125,15.7770242 L14.2245234,11.7242898 L18.4676875,11.7242898 L18.4676875,12.7887429 L15.2010859,12.7887429 L15.0301875,14.766282 L15.1131953,14.766282 C15.4387178,14.3268267 15.9351321,14.1071023 16.6024531,14.1071023 C17.2697742,14.1071023 17.8174575,14.3284542 18.2455195,14.7711648 C18.6735816,15.2138753 18.8876094,15.7802759 18.8876094,16.4703835 C18.8876094,17.2060643 18.6475401,17.8025753 18.1673945,18.2599343 C17.6872489,18.7172934 17.0565586,18.9459695 16.2753047,18.9459695 Z M12.5,7.6649956 C8.92587197,8.3648916 6.25,11.5170745 6.25,15.2701882 C6.25,19.550395 9.71979319,23.0201882 14,23.0201882 C18.2802068,23.0201882 21.75,19.550395 21.75,15.2701882 L21.75,14.9701882 C21.75,14.8965503 21.75,14.8231542 21.75,14.75 L23.2477415,14.75 C23.2468336,14.822184 23.2468336,14.8947508 23.2477415,14.9677006 C23.2492472,15.0886854 23.25,15.1895146 23.25,15.2701882 C23.25,20.3788222 19.1086339,24.5201882 14,24.5201882 C8.89136606,24.5201882 4.75,20.3788222 4.75,15.2701882 C4.75,10.6897807 8.08865555,6.85970186 12.5,6.14114913 L12.5,4.30004534 C12.5,4.24567215 12.5147774,4.19232123 12.5427521,4.14569661 C12.6279966,4.00362253 12.8122746,3.95755301 12.9543487,4.04279746 L16.5,6.17018822 L16.5,4.30004534 C16.5,4.24567215 16.5147774,4.19232123 16.5427521,4.14569661 C16.6279966,4.00362253 16.8122746,3.95755301 16.9543487,4.04279746 L21.0712535,6.51294035 C21.1134784,6.53827528 21.1488178,6.57361462 21.1741527,6.6158395 C21.2593971,6.75791358 21.2133276,6.94219165 21.0712535,7.0274361 L16.9543487,9.49757899 C16.9077241,9.52555376 16.8543732,9.54033111 16.8,9.54033111 C16.6343146,9.54033111 16.5,9.40601654 16.5,9.24033111 L16.5,7.37018822 L12.9543487,9.49757899 C12.9077241,9.52555376 12.8543732,9.54033111 12.8,9.54033111 C12.6343146,9.54033111 12.5,9.40601654 12.5,9.24033111 L12.5,7.6649956 Z'></path></svg>"
		@_forward15Btn.onTap =>
			@player.currentTime = Math.min(@player.duration, @player.currentTime+15)
			@_updateTransport()
	
		@_airplayBtn = new SVGLayer
			name: "airplay"
			parent: @_transportContainer
			width: 24
			height: 24
			opacity: 0.65
			backgroundColor: ""
			svg: "<svg width='19px' height='17px' viewBox='0 0 19 17'><path d='M16.775,15.5 L19.5,15.5 C20.0522847,15.5 20.5,15.0522847 20.5,14.5 L20.5,6.5 C20.5,5.94771525 20.0522847,5.5 19.5,5.5 L5.5,5.5 C4.94771525,5.5 4.5,5.94771525 4.5,6.5 L4.5,14.5 C4.5,15.0522847 4.94771525,15.5 5.5,15.5 L8.225,15.5 L6.8,17 L5,17 C3.8954305,17 3,16.1045695 3,15 L3,6 C3,4.8954305 3.8954305,4 5,4 L20,4 C21.1045695,4 22,4.8954305 22,6 L22,15 C22,16.1045695 21.1045695,17 20,17 L18.2,17 L16.775,15.5 Z M12.7918149,13.3112692 L19.3685221,20.3264235 C19.5196142,20.4875885 19.5114486,20.7407228 19.3502836,20.8918149 C19.2761452,20.9613197 19.1783311,21 19.0767072,21 L5.9232928,21 C5.70237891,21 5.5232928,20.8209139 5.5232928,20.6 C5.5232928,20.498376 5.56197312,20.400562 5.63147792,20.3264235 L12.2081851,13.3112692 C12.3592772,13.1501043 12.6124115,13.1419387 12.7735765,13.2930308 C12.7798504,13.2989126 12.785933,13.3049952 12.7918149,13.3112692 Z'></path></svg>"

		@_subtitlesBtn = new SVGLayer
			name: "subtitles"
			parent: @_transportContainer
			width: 28
			height: 28
			opacity: 0.65
			backgroundColor: ""
			svg: "<svg width='20px' height='17px' viewBox='0 0 20 17'><path d='M7,13 L12,13 L12,14 L7,14 L7,13 Z M13,13 L21,13 L21,14 L13,14 L13,13 Z M8,15 L10,15 L10,16 L8,16 L8,15 Z M11,15 L18,15 L18,16 L11,16 L11,15 Z M19,15 L21,15 L21,16 L19,16 L19,15 Z M20.9530408,17.5 L22.1666667,17.5 C22.3507616,17.5 22.5,17.3507616 22.5,17.1666667 L22.5,7.83333333 C22.5,7.64923842 22.3507616,7.5 22.1666667,7.5 L5.83333333,7.5 C5.64923842,7.5 5.5,7.64923842 5.5,7.83333333 L5.5,17.1666667 C5.5,17.3507616 5.64923842,17.5 5.83333333,17.5 L19.5007528,17.5 L19.5007528,19.2861222 L20.9530408,17.5 Z M5.83333333,6 L22.1666667,6 C23.1791887,6 24,6.82081129 24,7.83333333 L24,17.1666667 C24,18.1791887 23.1791887,19 22.1666667,19 L21.6666667,19 L18.5483182,22.8351562 C18.4408885,22.9672804 18.2466918,22.9872993 18.1145676,22.8798697 C18.042558,22.8213191 18.0007528,22.7334469 18.0007528,22.6406376 L18.0007528,19 L5.83333333,19 C4.82081129,19 4,18.1791887 4,17.1666667 L4,7.83333333 C4,6.82081129 4.82081129,6 5.83333333,6 Z'></path></svg>"
		
		@_bigPlayBtn = new Layer
			name: "BigPlay"
			parent: @_controls
			point: Align.center
			size: 60
			borderRadius: 30
			backgroundColor: Color.gray(0.27).alpha(0.5)
			backgroundBlur: 50
			visible: false
		@_bigPlayGlyph = @_playBtn.copy()
		@_bigPlayGlyph.props =
			parent: @_bigPlayBtn
			x: Align.center 3
			y: Align.center
			opacity: 1
		@_bigPlayBtn.onTap =>
			@_bigPlayBtn.visible = false
			@_goToFullScreen()
			@player.play()
			
		@_setupVolumeControl()
		@_layoutControls()
	
	_setupVolumeControl: ->
		@_volumeBtn = new Layer
			name: "volume"
			parent: @_controls
			width: 60
			height: 47
			borderRadius: 16
			backgroundColor: Color.gray(0.27,0.5)
			backgroundBlur: 50
		
		@_volumeGlyph = new Layer
			name: "volumeGlyph"
			parent: @_volumeBtn
			width: 60
			height: 47
			point: Align.center
			backgroundColor: ""
		
		@_speaker = new SVGLayer
			name: "speaker"
			parent: @_volumeGlyph
			width: 28
			height: 28
			point: Align.center
			opacity: 0.65
			svg: "<svg width='10px' height='15px' viewBox='0 0 10 15'>    <clipPath id='clipPath'><path d='M0,9.14618188 L16.2129223,23.5758755 C16.8956476,24.1835091 17.9502702,24.1321107 18.5684879,23.4610739 C19.1867056,22.7900372 19.1344119,21.7534701 18.4516866,21.1458365 L0.787077651,5.42412446 C0.556709824,5.21909436 0.283999658,5.08909828 -2.77555756e-17,5.03262282 L0,0 L48,0 L48,46 L0,46 L0,9.14618188 Z'></path></clipPath>     <path  clip-path='url(#clipPath)' d='M7.25,11 L10.8964466,7.35355339 C11.0917088,7.15829124 11.4082912,7.15829124 11.6035534,7.35355339 C11.6973216,7.44732158 11.75,7.57449854 11.75,7.70710678 L11.75,20.2928932 C11.75,20.5690356 11.5261424,20.7928932 11.25,20.7928932 C11.1173918,20.7928932 10.9902148,20.7402148 10.8964466,20.6464466 L7.25,17 L3,17 C2.44771525,17 2,16.5522847 2,16 L2,12 C2,11.4477153 2.44771525,11 3,11 L7.25,11 Z'></path></svg>"
		@_muteLine = new Layer
			name: "muteLine"
			parent: @_speaker
			width: 25
			height: 1
			rotation: 42
			originX: 0
			x: -0.5
			y: 5
			backgroundColor: "white"
		@_muteLine.states.show = 
			width: 25
			options:
				time: 0.25
		@_muteLine.states.hide = 
			width: 0
			options:
				time: 0.25
		
		@_wave1 = new SVGLayer
			name: "wave1"
			parent: @_volumeGlyph
			width: 28
			height: 28
			point: Align.center
			fill: Color.gray(1).alpha(0.65)
			svg: "<svg width='3px' height='9px' viewBox='0 0 3 9'><path d='M13.8050265,10.7509156 C14.5719512,11.6495546 15,12.7884604 15,13.9948071 C15,15.2011537 14.5719512,16.3400596 13.8050265,17.2386986 C13.6257656,17.4487465 13.6507233,17.7643437 13.8607712,17.9436047 C14.0708191,18.1228656 14.3864162,18.0979079 14.5656772,17.88786 C15.4856674,16.8098675 16,15.441387 16,13.9948071 C16,12.5482272 15.4856674,11.1797467 14.5656772,10.1017541 C14.3864162,9.89170625 14.0708191,9.86674853 13.8607712,10.0460095 C13.6507233,10.2252705 13.6257656,10.5408677 13.8050265,10.7509156 Z'></path></svg>"
		
		@_wave2 = new SVGLayer
			name: "wave2"
			parent: @_volumeGlyph
			width: 28
			height: 28
			point: Align.center
			fill: Color.gray(1).alpha(0.65)
			svg: "<svg width='4px' height='13px' viewBox='0 0 4 13'><path d='M17.7950884,8.47962715 C19.201934,9.95739004 20,11.9127629 20,13.9948071 C20,16.0768512 19.201934,18.0322241 17.7950884,19.509987 C17.6046842,19.7099892 17.612465,20.0264761 17.8124672,20.2168802 C18.0124693,20.4072844 18.3289562,20.3995036 18.5193604,20.1995014 C20.101491,18.5376176 21,16.3361454 21,13.9948071 C21,11.6534688 20.101491,9.45199657 18.5193604,7.79011274 C18.3289562,7.59011056 18.0124693,7.58232982 17.8124672,7.77273396 C17.612465,7.96313811 17.6046842,8.27962497 17.7950884,8.47962715 Z'></path></svg>"
			
		@_wave3 = new SVGLayer
			name: "wave3"
			parent: @_volumeGlyph
			width: 28
			height: 28
			point: Align.center
			fill: Color.gray(1).alpha(0.65)
			svg: "<svg width='5px' height='19px' viewBox='0 0 5 19'><path d='M21.9860365,6.04153262 C23.9163657,8.22082762 25,11.0229947 25,13.9948071 C25,16.9666195 23.9163657,19.7687865 21.9860365,21.9480815 C21.8029393,22.1547939 21.8220831,22.4707971 22.0287955,22.6538943 C22.2355078,22.8369916 22.551511,22.8178477 22.7346082,22.6111354 C24.8254099,20.2506707 26,17.2133015 26,13.9948071 C26,10.7763127 24.8254099,7.73894343 22.7346082,5.37847881 C22.551511,5.17176643 22.2355078,5.15262259 22.0287955,5.33571985 C21.8220831,5.5188171 21.8029393,5.83482024 21.9860365,6.04153262 Z'></path></svg>"
			
		for wave in [@_wave1,@_wave2,@_wave3]
			wave.states.show =
				fill: Color.gray(1).alpha(0.65)
				options: time: 0.25
			wave.states.hide =
				fill: Color.gray(1).alpha(0.2)
				options: time: 0.25
			
		# Changing the width of the line drives the mute animation
		@_muteLine.on "change:width", (width) =>
			xPos = Utils.modulate(width, [0,25], [-20,1])
			yPos = Utils.modulate(width, [0,25], [-18,0])	
			
			clipPath = @_speaker.querySelector("#clipPath")
			@_speaker.style.webkitClipPath = clipPath
			clipPath.setAttribute('transform', "translate(#{xPos} #{yPos})")
			
			xOffset = Utils.modulate(width, [0,25], [0,7])
			@_speaker.x = Align.center xOffset
			
			waveOpacity = Utils.modulate(width, [0,25], [1,0])
			@_wave1?.opacity = waveOpacity
			@_wave2?.opacity = waveOpacity
			@_wave3?.opacity = waveOpacity
			
			waveScale = Utils.modulate(width, [0,25], [1,0.667])
			@_wave1?.scale = waveScale
			@_wave2?.scale = waveScale
			@_wave3?.scale = waveScale
		
		@_muteLine.stateSwitch if @player.muted then "hide" else "show"
		
		@_volumeSliderBG = @_transportBG.copy()
		@_volumeSliderBG.props =
			name: "volume slider bg"
			parent: @_volumeBtn
			x: Align.left
			y: Align.center
			width: 0
			opacity: 0
		
		@_volumeSlider = new SliderComponent
			name: "volume slider"
			parent: @_volumeBtn
			height: @_volumeSliderBG.height
			backgroundColor: Color.gray(1, 0.1)
			knobSize: 9
			y: Align.center
			width: 0
			opacity: 0
			visible: false
		@_volumeSlider.fill.backgroundColor = ""
		@_volumeSlider.knob.draggable.momentum = false
		@_volumeSlider.hitArea = 30
		@_volumeSlider.sliderOverlay.center()
		
		@_volumeSlider.on "change:value", (value, layer) =>
			return if !@_volumeSlider.knob.draggable.isDragging
			@player.volume = @_volumeSlider.value
			@player.muted = false
		
		@_volumeSlider.onTouchStart (event) =>
			@_cancelAutoHide()
		
		@_volumeSlider.onTouchEnd (event) =>
			@_autoHideControls()
		
		@_volumeGlyph.onTap =>
			return if @_didLongPress
			@player.muted = !@player.muted
			@_updateVolume
		
		@_volumeGlyph.onTapStart =>
			@_didLongPress = false
			
		@_volumeGlyph.onLongPress =>
			@_didLongPress = true
			@_showVolumeSlider true, true
		
		@_updateVolume false
	
	_controlFrame: ->
		return @frame if !@fullScreen
		point = Utils.pointZero()
		point = Utils.convertPointFromContext(point, @parent) if @parent?
		return {"x":point.x,"y":point.y,"width":Screen.width,"height":Screen.height}
		
	_layoutControls: ->
		return if !@_controls?
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		
		controlWidth = if @fullScreen then 60 else 54
		controlHeight = if @fullScreen then 47 else 31
		
		@_controls?.frame = @_controlFrame()
		@_fullscreenBG?.frame = @_controls?.frame
		safeArea = @_safeArea()
		
		screenAspect = Screen.width / Screen.height
		aspectMatch = Math.abs(screenAspect - @_videoAspectRatio) < 0.001	
		@_closeContainer.props =
			x: Align.left safeArea.x
			y: Align.top safeArea.y
			width: (if aspectMatch then 60 else 120)
			visible: @fullScreen
		
		@_fitFillBtn.visible = !aspectMatch
		@_closeBtn.props =
			borderRadius: if aspectMatch then 16 else {topLeft:16, topRight:0, bottomRight:0, bottomLeft:16}
		
		@_fitFillArrows.props =
			rotation: if @_videoAspectRatio > screenAspect then 0 else 90
		
		@_fullscreenBtn?.props =
			x: Align.left safeArea.x
			y: Align.top safeArea.y
			visible: !@fullScreen
		
		@_volumeBtn.props =
			height: controlHeight
			width: controlWidth
			maxX: Utils.frameGetMaxX(safeArea)
			y: Align.top safeArea.y
			borderRadius: if @fullScreen then 16 else 8
		@_volumeGlyph.props =
			height: controlHeight
			width: controlWidth
		for glyph in @_volumeGlyph.children
			glyph.point = Align.center
			glyph.scale = if @fullScreen then 1 else 0.85
		
		@_transportContainer.props =
			width: safeArea.width
			x: Align.center
		
		for control in [@_transportContainer, @_volumeBtn, @_transportBG, @_transportSlider, @_remainingLabel, @_elapsedLabel, @_back15Btn, @_forward15Btn, @_airplayBtn, @_subtitlesBtn]
			control.visible = true
		
		if !@fullScreen
			margins = 8
			
			availableWidth = @_transportContainer.width - 2*margins
			
			if availableWidth < 186
#				Big play only
				@_transportContainer.visible = false
				@_fullscreenBtn.visible = false
				@_volumeBtn.visible = false
				@_bigPlayBtn.visible = true
			
			@_elapsedLabel.visible = availableWidth > 245
			@_airplayBtn.visible = availableWidth > 284
			@_back15Btn.visible = availableWidth > 313
			@_forward15Btn.visible = availableWidth > 342
			
			@_subtitlesBtn.visible = false
			
			availableWidth -= @_back15Btn.width if @_back15Btn.visible
			availableWidth -= @_forward15Btn.width if @_forward15Btn.visible
			availableWidth -= @_airplayBtn.width if @_airplayBtn.visible
			availableWidth -= @_elapsedLabel.width if @_elapsedLabel.visible
			
			@_transportContainer.props =
				height: 31
				borderRadius: 8
			
			@_back15Btn.props =
				x: margins
				y: Align.center
				scale: 16/28
			
			@_playBtn.props =
				x: if @_back15Btn.visible then @_back15Btn.maxX else margins
				y: Align.center
				scale: 16/28
				
			@_pauseBtn.props =
				point: @_playBtn.point
				scale: 16/28
				
			@_forward15Btn.props =
				x: @_playBtn.maxX
				y: Align.center
				scale: 16/28
			
			@_airplayBtn.props =
				x: Align.right -2*margins
				y: Align.center
				scale: 0.75
			
			@_elapsedLabel.stateSwitch "mini"
			@_elapsedLabel.props =
				x: 2 + if @_forward15Btn.visible then @_forward15Btn.maxX else @_playBtn.maxX
				y: Align.center
			
			@_remainingLabel.stateSwitch "mini"
			@_remainingLabel.props =
				maxX: @_transportContainer.width - margins - if @_airplayBtn.visible then @_airplayBtn.width+margins else 0
				y: Align.center
			
			@_transportBG.x = 10 + if @_elapsedLabel.visible then @_elapsedLabel.maxX else @_playBtn.maxX
			@_transportBG.props =
				width: @_remainingLabel.x - @_transportBG.x - 10
				y: Align.center
			
		else if isPortrait
			@_transportContainer.props =
				height: 94
				borderRadius: 8
			
			@_transportBG.props =
				width: @_transportContainer.width - 32
				x: Align.center
				y: Align.top 20
			
			@_elapsedLabel.stateSwitch "default"
			@_elapsedLabel.props =
				x: @_transportBG.x
				y: @_transportBG.maxY + 6
			
			@_remainingLabel.stateSwitch "default"
			@_remainingLabel.props = 
				maxX: @_transportBG.maxX
				y: @_transportBG.maxY + 6
			
			@_playBtn.props =
				x: Align.center
				y: Align.top 53
				scale: 1
			
			@_pauseBtn.props =
				point: @_playBtn.point
				scale: 1
				
			@_back15Btn.props =
				x: Align.center -(28+24)
				y: Align.top 53
				scale: 1
			
			@_forward15Btn.props =
				x: Align.center (28+24)
				y: Align.top 53
				scale: 1
			
			@_airplayBtn.props =
				x: Align.left 13
				y: Align.top 55
				scale: 1
			
			@_subtitlesBtn.props =
				x: Align.right -13
				y: Align.top 55
				visible: true
		else
			@_transportContainer.props =
				height: 47
				borderRadius: 16
			
			@_transportBG.props =
				width: @_transportContainer.width - 378
				x: Align.center 29
				y: Align.center 1
			
			@_elapsedLabel.stateSwitch "mini"
			@_elapsedLabel.props =
				maxX: @_transportBG.x - 10
			
			@_remainingLabel.stateSwitch "mini"
			@_remainingLabel.props = 
				x: @_transportBG.maxX + 10
			
			@_back15Btn.props =
				x: Align.left 15
				y: Align.center
				scale: 1
			
			@_playBtn.props =
				x: @_back15Btn.maxX + 31
				y: Align.center
				scale: 1
				
			@_pauseBtn.props =
				point: @_playBtn.point
				scale: 1
			
			@_forward15Btn.props =
				x: @_playBtn.maxX + 31
				y: Align.center
				scale: 1
			
			@_subtitlesBtn.props =
				x: Align.right -16
				y: Align.center
				visible: true
				
			@_airplayBtn.props =
				maxX: @_subtitlesBtn.x - 26
				y: Align.center
				scale: 1
		
		@_transportContainer.maxY = Utils.frameGetMaxY(safeArea)
		
		@_transportSlider.props =
			width: @_transportBG.width
			point: @_transportBG.point
		
	
	_safeArea: ->
		isPortrait = Framer.Device.orientationName is "portrait"
		isIPhoneX = Framer.Device.deviceType.includes("-iphone-x-")
		
		inset = if isIPhoneX and @fullScreen then 27 else 6
		
		frame = @_controlFrame()
		frame.x = 0
		frame.y = 0
		frame = Utils.frameInset frame, inset
		
		return frame if !@fullScreen
		
		if isPortrait
			if isIPhoneX
				frame.y += 23
				frame.height -= 23
			else
				frame.y = 23
				frame.height -= 17
		return frame
	
	_goToFullScreen: ->
		@_controls.stateSwitch "hide"
		@fullScreen = true
		@_miniFrame = @frame
		
		@_updateVideoLayout()
		
		@_fullscreenBG.frame = @_controlFrame()
		@_fullscreenBG.visible = true
		@_fullscreenBG.animate
			opacity: 1
			options: time: 0.25

		Utils.delay 0.25, =>
			@_controls.frame = @_controlFrame()
			@_layoutControls()
			@_controls.animate "show"
	
	_closeFullScreen: (event) ->
		@player.pause()
		@_controls.stateSwitch "hide"
		@fullScreen = false
		
		@_isClosingFullScreen = true

		animOptions = 
			curve: Spring(tension: 850, friction: 55)
		
		if @_miniFrame?
			@animate
				frame: @_miniFrame
				scale: 1
				options: animOptions
			@_fullscreenBG.animate
				opacity: 0
				options: animOptions
			
			Utils.delay 0.25, =>
				@_controls.frame = @_controlFrame()
				@_layoutControls()
				@_controls.animate "show"
				@_isClosingFullScreen = false
		else
			@animate
				scale: 0
				options: animOptions
			Utils.delay 0.25, =>
				@_controls.destroy()
				@destroy()
	
	_updateTransport: ->
		@_transportSlider.value = @player.currentTime / @player.duration
		@_transportSlider.knob.animateStop()
		
		# animate the reminaing duration instead of just updating to the new value so short videos aren't choppy
		if !@player.paused
			remainingTime = @player.duration - @player.currentTime
			@_transportSlider?.animateToValue 1,
				curve: Bezier.linear
				time: remainingTime
		
	_setupEvents: ->
		@_controls.onPanStart =>
			return if !@fullScreen
			@_isPanning = event.target is @_controls._element
			return if !@_isPanning
			
			@_panStartPoint = @point
			@_controls.animate "hide"
		
		@_controls.onPanEnd (event) =>
			return if !@_isPanning
			@_isPanning = false
			
			animOptions = 
				curve: Spring(tension: 850, friction: 55)
			
			point = {"x":Screen.width/2, "y":Screen.height/2}
			point = Utils.convertPointFromContext(point, @parent) if @parent?
			
			@animate
				midX: point.x
				midY: point.y
				scale: 1
				options: animOptions
					
			if event.offset.y > 100
				# Close
				@_closeFullScreen(event)
			else
				# Reset
				@_controls.animate "show"
				@_fullscreenBG.animate
					opacity: 1
					options: animOptions
		
		@_controls.onPan (event) =>
			return if !@_isPanning
			@x += event.delta.x
			@y += event.delta.y
			
			progress = Utils.modulate(event.offset.y, [0,400], [0,1])
			@_fullscreenBG.opacity = Utils.modulate(progress, [0,1], [1,0])
			@scale = Utils.modulate(progress, [0,1], [1,0.5])
			
		Events.wrap(@player).on "play", =>
			@_playBtn.visible = false
			@_pauseBtn.visible = true
			@_autoHideControls()
		
		Events.wrap(@player).on "pause", =>
			@_playBtn.visible = true
			@_pauseBtn.visible = false
			@_transportSlider.knob.animateStop()
			@player.currentTime = @_transportSlider.value * @_duration
			
		
		Events.wrap(@player).on "loadedmetadata", =>
			@_videoSize = 
				width: @player.videoWidth
				height: @player.videoHeight
			@_videoAspectRatio = @_videoSize.width / @_videoSize.height
			
			@_layoutControls()
			@_updateVideoLayout false
		
		Events.wrap(@player).on "canplay", =>
			@player.play() if @autoplay

		Events.wrap(@player).on "durationchange", =>
			@_duration = @player.duration
			
		Events.wrap(@player).on "timeupdate", =>
			return if !@_duration?
			
			currentTime = @player.currentTime
			currentSec = Math.floor(currentTime % 60)
			currentSec = "0"+currentSec if currentSec < 10
			currentMin = Math.floor(currentTime / 60)
			currentMin = 12 if currentMin > 1
			@_elapsedLabel.text = "#{currentMin}:#{currentSec}"
			
			remainingTime = @player.duration - currentTime
			remainingSec = Math.floor(remainingTime % 60)
			remainingSec = "0"+remainingSec if remainingSec < 10
			remainingMin = Math.floor(remainingTime / 60)
			remainingMin = 12 if remainingMin > 1
			@_remainingLabel.text = "-#{remainingMin}:#{remainingSec}"
			
			isPortrait = Framer.Device.orientationName is "portrait"
			if @fullScreen
				if isPortrait
					@_remainingLabel.maxX = @_transportBG.maxX
				else
					@_remainingLabel.x = @_transportBG.maxX + 5
			
			@_updateTransport()
		
		Events.wrap(@player).on "volumechange", =>
			@_updateVolume()
			
		Framer.Device.on "change:orientation", =>
			@_updateVideoLayout() if @fullScreen
			@_layoutControls()
	
	_autoHideControls: ->
		@_cancelAutoHide()
		return if @player.paused
		
		@_autohideTimer = Utils.delay 3, =>
			@_controls.animate "hide"
	
	_cancelAutoHide: ->
		clearTimeout @_autohideTimer
	
	_showVolumeSlider: (show, animate=false) ->
		options =
			time: 0.25
			instant: !animate
			
		width = if show then 162 else 60
		safeInset = @width - Utils.frameGetMaxX(@_safeArea())
		
		@_volumeBtn.animate
			x: @width - safeInset - width
			width: width
			options: options
		@_volumeGlyph.animate
			x: if show then width-55 else Align.center
			options: options
		
		@_volumeSliderBG.visible = show
		@_volumeSlider.visible = show
		@_volumeSliderBG.animate
			x: if show then 14 else 0
			width: if show then 100 else 0
			opacity: if show then 1 else 0
			options: options
		@_volumeSlider.animate
			x: if show then 14 else 0
			width: if show then 100 else 0
			opacity: if show then 1 else 0
			options: options
		
	_updateVolume: (animated=true) ->
		volume = @player.volume
		volume = 0 if @player.muted
		
		options =
			time: 0.25
			instant: !animated
		
		@_changeState @_wave1, (if volume >=  0.25 then "show" else "hide"), options
		@_changeState @_wave2, (if volume >=  0.50 then "show" else "hide"), options
		@_changeState @_wave3, (if volume >=  0.75 then "show" else "hide"), options
		@_changeState @_muteLine, (if @player.muted then "show" else "hide"), options
		@_volumeSlider.animateToValue volume, options
	
	_changeState: (layer, state, options) ->
		return if layer.states.current.name is state
		layer.animate state, options

	@define "autoplay",
		get: -> @_autoplay
		set: (value) -> @_autoplay = value

	@define "volume",
		get: -> @player.volume
		set: (value) -> @player.volume = value
	
	@define "fullScreen",
		get: -> @_fullScreen
		set: (value) ->
			@_fullScreen = value
			@_layoutControls()
			@_fullscreenBG?.visible = value
			
			@emit("change:fullScreen", value)
		
	@define "scaleToFillScreen",
		get: -> @_scaleToFill
		set: (value) ->
			@_scaleToFill = value
			@_updateVideoLayout()
			
			@_fitFillTopLine?.height = if value then 2.5 else 0
			@_fitFillBottomLine?.height = if value then 2.5 else 0
			@_fitFillBottomLine?.y = if value then 12.5 else 15
			@_fitFillArrows?.opacity = if value then 0 else 1
	
	_updateVideoLayout: (animate=true) ->
		return if !@_videoAspectRatio?
		options = 
			time: 0.25
			instant: !animate
		
		scaleFill = @scaleToFillScreen
		
		point = Utils.pointZero()
		point = Utils.convertPointFromContext(point, @parent) if @parent?
		size = if @fullScreen then Screen.size else @size
			
		if scaleFill
			if Framer.Device.orientation == 0
				point.x += (size.width / 2) - (size.height * @_videoAspectRatio / 2)
				size.width = size.height * @_videoAspectRatio
			else
				size.height = size.width / @_videoAspectRatio
		else if @fullScreen
			size.height = size.width / @_videoAspectRatio
			point.y += (Screen.height - size.height) / 2
		else
			point = @point
		
		midPoint = {"x":Screen.width/2, "y":Screen.height/2}
		midPoint = Utils.convertPointFromContext(point, @parent) if @parent?
		
		@animate
			size: size
			point: point
			options: options
