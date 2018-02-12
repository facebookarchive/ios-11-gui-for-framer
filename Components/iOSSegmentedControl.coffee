###
    # iOSSegmentedControl
    {iOSSegmentedControl} = require "iOSSegmentedControl"

    segControl = new iOSSegmentedControl
        # OPTIONAL
        items: <array> (strings for each segment title)
        tintColor: <color> (defaults to iOS blue)
        backgroundColor: <color> (defaults to white)
        width: <number> (defaults to Screen.width with 16dp padding)
        height: <number> (defaults to 29)
        isMomentary: <bool> (don't highlight items on tap), defaults to false)

    segControl.setSelected <bool>, <number>
        # if bool=true, select, or if bool=false, unselect the segment at index <number>

    segControl.insertSegment <string>, <number> optional
        # add a new segment with the name <string>
        # optionally specify the index to insert the new segment at
        # by default, insert in the last postion

    segControl.removeSegment <number>
        # remove the segment at index <number>

    segControl.setTitle <string>, <number>
        # change the title to <string> of the segment at index <number>

    segControl.setWidth <number>, <number>
        # hard-set width of segment at the second <number> index to the first <number>

    # Observe the "change:currentSegment" event
    navBar.on "change:currentSegment", (currentSegment, lastSegment) ->

###


class exports.iOSSegmentedControl extends Layer

    constructor: (options={}) ->

        @HPADDING = 16
        @HEIGHT = 29

        options = _.defaults {}, options,
            items: []
            tintColor: "#007AFF"
            backgroundColor: "#FFFFFF"
            width: Screen.width - @HPADDING*2
            height: @HEIGHT
            x: @HPADDING
            isMomentary: false
            clip: true

        super options

        @tintColor = options.tintColor
        @isMomentary = options.isMomentary
        @borderWidth = 1
        @borderRadius = 4

        @_backgroundColor = options.backgroundColor
        @_segments = []
        for item in options.items
            @_addSegment item
        @_layoutSegments()
        @_touchDown = false
        
    _segmentForEvent: (event) ->
        # TouchMove doesn't work the same on mobile, so do the hit testing ourselves
        touchEvent = Events.touchEvent(event)
        point = {x:touchEvent.clientX, y:touchEvent.clientY}
        point = Utils.convertPoint(point, undefined, @, true)
        for aLayer in @children
            return aLayer if Utils.pointInFrame(point, aLayer.frame)
        return undefined

    _addSegment: (title, index) ->
        segment = new Layer
            height: @height
            backgroundColor: @_backgroundColor
            parent: @
            name: ".Segment"+@_segments.length

        segment.onTouchStart (event, layer) =>
            @_touchDown = true
            Events.wrap(document).addEventListener("tapend", @_touchEnd)
            return if layer is @_selectedItem
            layer.backgroundColor = new Color(@_tintColor).alpha(.1)

        segment.onTouchMove (event, layer) =>
            layer = @_segmentForEvent event
            return if layer is undefined
            
            @_unselectAll()
            return if layer is @_selectedItem
            if @_touchDown then layer.backgroundColor = new Color(@_tintColor).alpha(.1)

        segment.onTouchEnd (event, layer) =>
            layer = @_segmentForEvent event
            return if layer is undefined
            
            @_selectItem layer

        titleText = new TextLayer
            text: title
            parent: segment
            name: ".Label"
            color: @_tintColor
            fontSize: 17
            fontWeight: 400
            textAlign: "center"
            width: segment.width
        segment.title = title
        segment.label = titleText
        titleText.fontSize = 13

        if index?
            @_segments.splice index, 0, segment
        else
            @_segments.push segment

    _touchEnd: (event, layer)=>
        @_touchDown = false
        @_unselectAll()

    _layoutSegments: ()->
        for segment, i in @_segments
            segment.index = i # passed in event handler in case of re-layout after init
            # btw the ability to setWidth of any segment is why this complexity exists
            unless segment.hasExplicitWidth?
                segmentsWithExplicitWidth = _.filter @_segments, (o)-> return o.hasExplicitWidth?
                remainingWidth = @width
                for wSegment in segmentsWithExplicitWidth
                    remainingWidth -= wSegment.width
                segment.width = Math.round (remainingWidth / (@_segments.length - segmentsWithExplicitWidth.length))
            segment.x = nextX
            nextX = segment.maxX

            segment.style.borderRight = "1px solid #{@_tintColor}"
            segment.style.borderRadius = "0"
            if i is 0 then segment.style.borderRadius = "4px 0 0 4px"
            if i is @_segments.length-1
                if @_segments.length is 1
                    segment.style.borderRadius = "4px"
                else
                    segment.style.borderRight = ""
                    segment.style.borderRadius = "0 4px 4px 0"

            label = segment.children[0]
            label?.width = segment.width
            label?.center()
        @width = nextX

    _selectItem: (item)->
        return if item is @_selectedItem
        if !@isMomentary
            oldItem = @_selectedItem
            @_selectedItem = item
            @_unselectItem oldItem
            @_highlightItem @_selectedItem
        else
            @_unselectItem item
        @emit("change:currentSegment", item?.index, oldItem?.index)

    _unselectAll: ()->
        for segment in @_segments
            @_removeHighlight segment unless segment is @_selectedItem
            
    _unselectItem: (item, isClearing)->
        if item? then @_removeHighlight item
        if isClearing
            @_selectedItem = null
            @emit("change:currentSegment", null, item?.index)

    _highlightItem: (item)->
        item.backgroundColor = @_tintColor
        item.label.color = @_backgroundColor

    _removeHighlight: (item)->
        item.backgroundColor = @_backgroundColor
        item.label.color = @_tintColor

    _layout: ()->
        @width = Screen.width - @HPADDING*2
        @_layoutSegments()

    @define "isMomentary",
        get: -> @_isMomentary
        set: (value)->
            @_isMomentary = value

    @define "tintColor",
        get: -> @_tintColor
        set: (value)->
            @borderColor = value
            if @_segments
                for segment in @_segments
                    segment.label.color = value
                    segment.style.borderRight = "1px solid #{value}"
            @_selectedItem?.backgroundColor = value
            @_selectedItem?.label.color = @_backgroundColor
            @_tintColor = value

    @define "numberOfSegments",
        get: -> @_segments?.length

    @define "selectedSegmentIndex",
        get: -> @_selectedItem?.index

    @define "autoLayout",
        get: -> @_autoLayout
        set: (value)->
            @_autoLayout = value

    setSelected: (isSelected, index) ->
        segment = @_segments[index]
        if isSelected then @_selectItem segment else @_unselectItem segment, true

    insertSegment: (title, index) ->
        if !index? then index = @_segments.length
        @_addSegment title, index
        @_layoutSegments()

    removeSegment: (index)->
        if @_segments[index]?
            @_segments[index].destroy()
            @_segments.splice index, 1
            @_layoutSegments()

    removeAllSegments: ()->
        @removeSegment 0 while @_segments.length > 0

    setTitle: (title, index)->
        @_segments[index]?.label.text = title

    setWidth: (width, index)->
        if width?
            @_segments[index]?.hasExplicitWidth = @_segments[index]?.width = width
        else
            @_segments[index]?.hasExplicitWidth = null
        @_layoutSegments()

    autoWidthLayout: ()->
        @width = Screen.width - @HPADDING*2
        @_layoutSegments()


