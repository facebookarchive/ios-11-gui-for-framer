# Facebook iOS 11 iPhone GUI for Framer
### Design better, faster

Quickly make prototypes with native-feeling iOS 11 interactions. We’ve created customizable Framer components that mirror the behavior of the most important UI elements including navigation bar, notifications, action sheets, alerts, video player, sliders, switches, and more. Whether using these components to mock up apps, concept ideas, or create custom interface elements that work harmoniously with those native to iOS, we hope they help you work faster and elevate your designs.

New to designing apps? You may want to get acquainted with some of the support documentation that Apple has put together in their [Human Interface Guidelines](https://developer.apple.com/ios/human-interface-guidelines/overview/themes/) and their [Apple UI Design Resources](https://developer.apple.com/design/resources/).

Check out our page at [facebook.design](http://facebook.design/ios11) for addition iOS templates for Sketch, Photohop, and Origami
If something is off, we want to fix it. Shoot us a message at designresources@fb.com

### Disclaimer
While Facebook has redrawn and shares these assets for the benefit of the design community, Facebook does not own any of the underlying product or user interface designs. By accessing these assets, you agree to obtain all necessary permissions from the underlying rights holders and/or adhere to any applicable brand use guidelines before using them. Facebook disclaims all express or implied warranties with respect to these assets, including non-infringement of intellectual property rights.

### Installation
Download a zip or clone the repository.  
Drag any of the coffee component files into your Framer project, or manually copy them into the project's "modules" folder.  
Add any necessary `require` statements to your project, including braces {}  
```
{iOSStatusBar} = require "iOSStatusBar"
```

### Contents

* [ActionSheet](#actionsheet)
* [ActivityIndicator](#activityindicator)
* [AlertView](#alertview)
* [NavigationBar](#navigationbar)
* [Notification](#notification)
* [PageComponent](#pagecomponent)
* [SegmentedControl](#segmentedcontrol)
* [Slider](#slider)
* [StatusBar](#statusbar)
* [Switch](#switch)
* [TabBar](#tabbar)
* [TextLayer](#textlayer)
* [ToolBar](#toolbar)
* [VideoPlayer](#videoplayer)

# ActionSheet

### Properties

`title` – a string, the title of the alert  
`message` – a string, the message of the alert  
`tintColor` – the color to be used for the action labels  


```
actionSheet = new ActionSheet
    title: "Here is an alert"
    message: "Here is a message"

actionSheet.addAction "Add to Playlist", ->
    print "Song Added"

actionSheet.present()

```

## actionSheet.addAction(title, style, callback)

Add an action to the ActionSheet. Style is optional and will rearrange the actions' order based on iOS convention around the "cancel" action being the lowest most action, and visually separate.

### Arguments

`title` – a string, the title of the label for the action (required)  
`style` – a string, either "default", "cancel" (bold text), or "destructive" (red text.)  
`callback` – function to be called when the action is selected  


```
actionSheet = new ActionSheet
    title: "Edit Message"

actionSheet.addAction "Mark as Read"
actionSheet.addAction "Flag Message"
```


Change the style of the action to `"destructive"` to make the text red or `"cancel"` to move the action to the bottom.

```
actionSheet = new ActionSheet
    title: "Edit Message"

actionSheet.addAction "Go Back", "cancel"
actionSheet.addAction "Delete", "destructive"
```


Add a callback to execute some code when a given action is selected

```
actionSheet = new ActionSheet
    title: "Edit Message"

actionSheet.addAction "Mark as Unread", ->
    print "Message now unread"
```



## actionSheet.present(animated)

Shows the ActionSheet. It's animated by default and will come up from the bottom. The event `"actionSheetAppear"` is emitted upon animation completion.

### Properties

`animated` – bool to control whether the ActionSheet is animated in or appears instantly  


```
actionSheet = new ActionSheet
    title: "Edit Message"

actionSheet.addAction "Mark as Read"
actionSheet.addAction "Flag Message"

# Animate the ActionSheet in when the prototype runs
actionSheet.present()
```



## actionSheet.dismiss(animated)

Hides the ActionSheet. It's animated by default. The event `"actionSheetDismiss"` is emitted upon animation completion.

### Properties

`animated` – bool to control whether the ActionSheet is animated out or appears instantly. (Optional)  


```
actionSheet = new ActionSheet
    title: "Edit Message"

actionSheet.addAction "Mark as Read"
actionSheet.addAction "Flag Message"

# Show the ActionSheet instantly
actionSheet.present(false)

# Animate the ActionSheet out after a delay
Utils.delay 5, ->
    actionSheet.dismiss()
```

### 

Events
The following events are emitted and available from ActionSheet.

`"actionSelected"` – emitted when a given action is selected. Has the title of the selected action available as an argument.  
`"actionSheetAppear"` – emitted on entrance animation complete  
`"actionSheetDismiss"` – emitted on exit animation complete  



# ActivityIndicator

A standard indeterminate spinner that shows that an activity is in progress.

### Properties

`animating` – a boolean indicating if the indicator is currently animating, defaults to true (setting this value calls stopAnimating and startAnimating)  
`color` – the color of the activity indicator, defaults to a gray value  
`large` – a boolean indicating if the indicator should be a large size, defaults to false  
`hidesWhenStopped` – a boolean indicating if the indicator should hidden when not animating, defaults to false  

### Events

`Events.AnimationStart` – emitted startAnimation() is called  
`Events.AnimationStop` – emitted when stopAnimation() is called  

Create a standard activity indicator

```
indicator = new iOSActivityIndicator`
```

Create a large, white activity indicator

```
indicator = new iOSActivityIndicator
    color: "white"
    large: true
```

Create an activity indicator that starts animating in response to a button click and stops after 3 seconds

```
indicator = new iOSActivityIndicator
    animating: false
    hidesWhenStopped: true

indicator.onAnimationStop ->
    print "display search results"

myButton.onTap ->
    indicator.animating = true
    Utils.delay 3, ->
        indicator.animating = false
```

## activityIndicator.startAnimating()

Start animating the indicator. Called automatically when setting the `animating` to `true`
Used when you want to control when an activity indicator should start animating.

```
indicator = new iOSActivityIndicator
    animating: false

indicator.startAnimating()
```

## activityIndicator.stopAnimating()

Stop animating the indicator. Called automatically when setting the `animating` to `false`
Used when you want to control when an activity indicator should start animating.

```
indicator = new iOSActivityIndicator

indicator.stopAnimating()
```



# AlertView

```
alert = new AlertView
    # OPTIONAL
    title: <string> (title of the alert)
    message: <string> (message of the alert)
    tintColor: <color> (text color of the actions)

alert.addAction <string> (title of the action), <string> (style for action, either "default", "cancel", or "destructive"), <function> (callback called when action selected)

alert.present <bool> (shows the alert)
alert.dismiss <bool> (dismisses the alert)`
```



# NavigationBar

A configurable navigation controller that manages displaying the header and animating the content layers onscreen

### Properties

`tintColor` – color used to show the selected tab  
`translucent` – boolean that controls if the status bar should be displayed with a light blur background, defaults to true  

### Events

`pushNavigationItem` – emitted when a new item is pushed on the navigation bar, the current and previous layers are sent as arguments  
`popNavigationItem` – emitted when the back button is tapped and the current item is popped from the navigation bar, the new and old layers are sent as arguments  
`SelectNavigationItemButton` – emitted when a button on the left/right sides are tapped, the button is sent as the argument  

## navigationBar.pushNavigationItem(layer, properties)

Adds a layer to the navigation stack with the specified properties

### Arguments

`layer` – a layer that is animated onscreen and managed by the NavigationBar  
`properties` – the following properties can be used to navigation bar  

### Properties

`title` – string that is displayed as the title and back button  
`useLargeTitle` – boolean that specifies if the title should be displayed with a large font  
`canHideLargeTitle` – boolean that specifies the large title should be collapsed during scroll to a small title  
`titleLayer` – a layer that is used in place of a small title  
`color` – color used for the titles  

`hasSearchField` – boolean that specifies if the navigation bar should have a search field  
`canHideSearchField` – boolean that specifies the search field should only be exposed after scrolling or is always visible  

`leftButtons` – array of strings/images/layers that are displayed on the left side of the navigation bar  
`showBackButton` – boolean that specifies that the back button should be displayed, even if this is the first navigation item  

`rightButtons` – array of strings/images/layers that are displayed on the right side of the navigation bar  
`boldRightButton` – boolean that specifies that text layers on the right side should be bold, defaults to true if the title is “Done”,”Cancel”, or “Close”  

Create a NavigationBar with and Edit Button

```
navBar = new iOSNavigationBar

navBar.pushNavigationItem AlbumScroll,
    title: "Albums"
    rightButtons: "Edit"

navBar.on "SelectNavigationItemButton", (button) ->
    edit() if button is "Edit"
```

Create a NavigationBar with large title, search field and buttons on each side

```
navBar = new iOSNavigationBar

navBar.pushNavigationItem AlbumScroll,
    title: "Albums"
    useLargeTitle: true
    hasSearchField: true
    leftButtons: [AddButton]
    rightButtons: [SearchButton, "Edit"]

AddButton.onTap ->
    print "Add Album"

SearchButton.onTap ->
    print "Search"

navBar.on "SelectNavigationItemButton", (button) ->
    edit() if button is "Edit"
```



# Notification

A pushed iOS notification with customizable app information, messaging, behavior and sound.

**Properties**

`appIcon` - a path to an image file for an app icon  
`appName` - a string, app name  
`timestamp` - a string, time the notification push is arrived  
`title` - a string, title of the notification  
`body` - a string, body content of the notification  
`timeout` - a value in second, a duration to display notification before it hides  
`sound` - a path to a sound file to play when notification occurs  

Create a Whatsapp notification that dismisses after 3 seconds it is displayed.

```
notification = new iOSNotification
    appName: "Whatsapp"
    title: "Francis Whitman"
    body: "🤪 Anyone who wants to tag along is more than welcome."
    duration: 3
```

## ****notification.present()****

Displays a notification.

```
button = new TextLayer
button.onTap ->
    notification.present()
```

**Events**
`notificationDismissed` - emitted when notification is dismissed whether by itself, drag or tap  
`Events.Tap` - emitted when notification is tapped  



# PageComponent

The iOSPageComponent extends Framer's [PageComponent](https://framer.com/docs/#slider.slidercomponent) by adding an iOSPageControl that displays the standard the iOS page dots.

Create a simple page component with three pages.

```
{iOSPageComponent, iOSPageControl} = require "iOSPageComponent"

page = new iOSPageComponent

page.addPage a
page.addPage b
page.addPage c
```

### Properties

`pageControl` – the iOSPageControl that is automatically configured and managed  

# PageControl

The standard the iOS page dots that can be manually setup and controlled. For standard behaviors consider using the iOSPageComponent

### Properties

`numberOfPages` – the number of page dots  
`currentPage` – the index of the current page  
`hidesForSinglePage` – hide the control if only one page, defaults to false  
`pageIndicatorTintColor` – the color used to display unselected pages  
`currentPageIndicatorTintColor` – the color used to display the current page  

**Note**: if both pageIndicatorTintColor and currentPageIndicatorTintColor are both "white" or "black", the inactive dots will be displayed with a transparent version of the color

Create a custom page control with 5 dots using white and red colors 

```
{iOSPageComponent, iOSPageControl} = require "iOSPageComponent"

pageControl = new iOSPageControl
    numberOfPages: 5
    currentPage: 2
    pageIndicatorTintColor: "white"
    currentPageIndicatorTintColor: "red"
```



# SegmentedControl

### Properties

`items` – an array of strings, the titles of each segment in the order they will appear from left to right  
`tintColor` – the color of the control's outline, text and selected segment. (defaults to iOS blue)  
`backgroundColor` – the control's background color. (defaults to white)  
`isMomentary` – a boolean indicating whether segments can be selected and highlighted. If isMomentary = true, then the selected segment won't stay highlighted. (defaults to false)  

Create a control with default styling and three segments, and select the first segment.

```
segmentedControl = new iOSSegmentedControl
    items: ["First thing", "Second thing", "Third thing"]
    
segmentedControl.setSelected true, 0
```

Create a small, green, momentary switch control.

```
momentarySwitch = new iOSSegmentedControl
    items: ["On", "Off"]
    width: 200
    tintColor: "#42b72a"
    isMomentary: true
```

### Read-only properties

`numberOfSegments` – how many segments are in the control  
`selectedSegmentIndex` – the index of the segment that's currently selected. This will always be undefined for momentary controls, since you can't select segments if a control is momentary.  

```
segmentedControl = new iOSSegmentedControl
    items: ["First thing", "Second thing", "Third thing"]
    
segmentedControl.setSelected true, 0

print segmentedControl.numberOfSegments # 3
print segmentedControl.selectedSegmentIndex # 0
```

### 

## segmentedControl.setSelected(enabled, index)

Select, or unselect, a segment at the specified index.

### Arguments

`enabled` – a boolean, indicating whether to enable to disable the segment  
`index` – the index of the segment you're targeting  

Select the first segment in the control. Since by default no segments are selected, you would do this you want a segment to be initially selected when the control first appears.

```
segmentedControl = new iOSSegmentedControl
    items: ["First", "Second", "Third"]

segmentedControl.setSelected true, 0
```



## segmentedControl.insertSegment(title, index)

Add a new segment to the control.

### Arguments

`title` – a string, the title of the new segment you're adding  
`index` – the position in which you'd like to add the new segment  

Add a new segment called “Fourth” in the final (default) position at the far right of the control.

```
segmentedControl = new iOSSegmentedControl
    items: ["First", "Second", "Third"]

segmentedControl.insertSegment "Fourth"
```

Add a new segment called “Zero” to the first position in the control.

```
segmentedControl = new iOSSegmentedControl
    items: ["One", "Two"]

segmentedControl.insertSegment "Zero", 0
```



## segmentedControl.removeSegment(index)

Remove the segment at the specified index.

### Arguments

`index` – the index of the segment you're targeting for removal.  

Remove the segment at index=2 from the control.

```
segmentedControl = new iOSSegmentedControl
    items: ["First", "Second", "NaN", "Third"]

segmentedControl.removeSegment 2
```



## segmentedControl.setTitle(title, index)

Change the title of a segment at a specified index.

### Arguments

`title` – a string, the new title for the segment you're targeting  
`index` – the segment's index that you are targeting  

Update the title of the second segment to “Second”.

```
segmentedControl = new iOSSegmentedControl
    items: ["First", "Fifth", "Third"]

segmentedControl.setTitle "Second", 1
```



## segmentedControl.setWidth(width, index)

Hard-set the width of a segment at a specific index. Other segments will dynamically resize to equally fill the remaining space.

### Arguments

`width` – the width of the targeted segment  
`index` – the segment's index that you are targeting  

Set the width of the second segment to fit the mightily long title.

```
segmentedControl = new iOSSegmentedControl
    items: ["First", "The Second Segment's Long Title", "Third"]

segmentedControl.setWidth 230, 1
```



### Events

The following events are emitted and available from SegementedControl.

`"change:currentSegment"` – emitted when the current segment is changed. This is emitted from both standard and momentary controls. This event has the currently-selected and previously-selected segment layers as arguments and allows you to access both the segment's title (current.title or last.title) and index (current.index or last.index).

```
segmentedControl.on "change:currentSegment", (current, last)->
    print "Switched to", current.title, current.index
```




# Slider

The iOSSlider component extends Framer's [SliderComponent](https://framer.com/docs/#slider.slidercomponent) and adopts the iOS look-and-feel by default, extends the API to mirror iOS conventions, and allows the addition of optional icons on each end of the slider.

### Properties

`minimumTrackTintColor` – the track's default color. (alias for SliderComponent.backgroundColor)  
`maximumTrackTintColor` –  the “active” portion of the track's color. (alias for SliderComponent.fill.backgroundColor)  
`thumbTintColor` – the slider knob's color. (alias for SliderComponent.knob.backgroundColor)  
`minimumValueImage` – an image URL, appears to the left of the slider  
`maximumValueImage` – an image URL, appears to the right of the slider  
`minimumValueImagePadding` – padding between the slider bar and the minimumValueImage  
`maximumValueImagePadding` – padding between the slider bar and the maximumValueImage  

```
slider = new iOSSlider

volumeSlider = new iOSSlider
    width: Screen.width - 80
    minimumValueImage: VolumeDown.image
    minimumValueImagePadding: 13
volumeSlider.maximumValueImage = VolumeUp.image

yellowSlider = new iOSSlider
    minimumTrackTintColor: "#ddd"
    maximumTrackTintColor: new Color("#f5c33b").alpha(.25)
    thumbTintColor: "#f5c33b"
```



# StatusBar

A standard iOS status bar that can be configured for different uses. The iOSStatusBar is automatically configured for different device sizes (iPhone 8 / iPhone 8 Plus / iPhone X) and hides in landscape orientation.

### Properties

`translucent` – a boolean that controls if the status bar should be displayed with a translucent background, defaults to false  
`darkStyle` – a boolean that specifies the text and icons should be light to be used on a dark background  
`time` – string that is displayed as the clock  
`useCurrentTime` – a boolean that indicates that the current system time and locale should be used to display the time in the clock  
`backAppName` – display the back to app button with the specified app name  
`carrier` – the name of the cell carrier  
`cellStrength` – value from 0-1 of the strength of cell signal that is represented by the cell bars  
`wifiStrength` – value from 0-1 of the strength of wifi signal that is represented by the wifi waves  
`networkType` – `["Wifi", "LTE", "4G", "3G"]` used to indicator the type of network  
`showBatteryLevel` – boolean that controls if the battery % label should be displayed, defaults to false  

Create a status bar using the current system time

```
statusBar = new iOSStatusBar
    useCurrentTime: true
```

Create a status bar that has a link back to Instagram

```
statusBar = new iOSStatusBar
    backAppName: "Instagram"
```

Create a dark, translucent status bar that is using LTE

```
statusBar = new iOSStatusBar
    translucent: true
    darkStyle: true
    networkType: "LTE"
    cellStrength: 0.5
```



# Switch

A control that is used to represent an on/off state.

### Properties

`isOn` – boolean that controls the on/off state of the switch  
`tintColor` – color of the switch background when `isOn` is true  
`thumbTintColor` – color of the switch thumb  

### Events

The “Events.ValueChange” event is emitted when the isOn property is changed and the isOn value is passed to the event handler.

```
mySwitch = new iOSSwitch
    point: Align.center

mySwitch.onValueChange (value) -> print value
```




# TabBar

A standard iOS tab bar that is automatically configured for different device sizes (iPhone 8 / iPhone 8 Plus / iPhone X) and both portrait and landscape orientation.

### Properties

`tintColor` – color used to show the selected tab  
`translucent` – boolean that controls if the status bar should be displayed with a light blur background, defaults to true  
`currentTab` – get/set the current tab by layer  
`selectedIndex` – get/set the current tab by index  

## tabBar.addTab(layer, properties)

Adds a tab to the tab bar with the specified title and icon

### Arguments

`layer` – a layer that is made visible when the tab is selected  
`properties` – the following properties can be used to customize the tab  

### Properties

`title` – the name of the tab, defaults to layer.name  
`icon` – the image to be displayed in the tab bar and will be used as a mask with the specified colors  

`color` – color of the title and icon when the tab is unselected, defaults to gray  
`selectedColor` – color of the title and icon when the tab is selected, defaults to tabBar.tintColor  
`selectedIcon` – the image displayed when the tab is selected, defaults to `icon`  

Create a tab bar with 3 tabs

```
tabBar = new iOSTabBar

tabBar.addTab Tab_1, 
    title: "First"
    icon: Image_1

tabBar.addTab Tab_2,
    title: "Second"
    icon: Image_2

tabBar.addTab Tab_3,
    title: "Third"
    icon: Image_3
```

### Events

The following events are emitted and available from SegementedControl.

`"change:currentTab"` – emitted when the current tab is changed. This event has the currently-selected and previously-selected tab layers as arguments

```
tabBar.on "change:currentTab", (current, last) ->
    print "Switched to: ", current.name
```



# TextLayer

The iOSTextLayer extends Framer's [TextLayer](https://framer.com/docs/#text.textlayer) by adding a textStyle property.

### Properties

`textStyle` – adjusts the fontSize and fontWeight, defaults to iOSTextStyle.body  

### Styles

```
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
```


## Toolbar

A standard iOS toolbar that is automatically configured for different device sizes (iPhone 8 / iPhone 8 Plus / iPhone X) and both portrait and landscape orientation.

### Properties

`tintColor` – color used to show the selected tab  
`translucent` – boolean that controls if the status bar should be displayed with a light blur background, defaults to true  


## toolbar.addButton(layer)

Adds a button to the toolbar with the provided layer as the content of the button. SVGLayers and layers with images will be colored automatically with the toolbar's tintColor

### Return Value

a Layer that is positioned automatically by the toolbar


## toolbar.addTextButton(string)

Adds a button to the toolbar with the provided string as the button title

### Return Value

a Layer that is positioned automatically by the toolbar


Create a toolbar with Cancel and Done buttons

```
toolbar = new iOSToolbar

cancelButton = toolbar.addTextButton "Cancel"

doneButton = toolbar.addTextButton "Done"
doneButton.onTap ->
  print "Done"
```



# VideoPlayer

The iOSVideoPlayer extends [VideoPlayer](https://framer.com/docs/#videolayer.videolayer) by adding the standard iOS player controls. The iOSVideoPlayer can be presented in-place or fullscreen. As with the standard VideoLayer, for additional controls and events, access the `player` object.

### Properties

`video` – the URL to the video  
`player` – the HTML Video object that controls the video playback, see this [Overview](http://www.w3schools.com/tags/ref_av_dom.asp) for more info  
`fullScreen` – sets the video to be presented in full screen mode or embedded in the UI, defaults to true  
`autoplay` – begin playback of the video after it is loaded, defaults to false  
`volume` – number 0-1, convience accessor to player.volume, sets the volume of the video, defaults to 0  

### Events

`"change:fullScreen"` – emitted when the fullScreen property is changed.  

```
videoPlayer.on "change:fullScren", (fullScreen) ->
    print "Closed Video Player" if fullScreen is false
```


Create a video player presented in fullscreen:

```
videoPlayer = new iOSVideoPlayer
    video: "http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v"
    autoplay: true
    volume: 0.5
```

Create a video player embedded in the UI:

```
videoPlayer = new iOSVideoPlayer
    video: "http://mirror.cessen.com/blender.org/peach/trailer/trailer_iphone.m4v"
    fullScreen: false
    parent: container
    width: 350
    height: 250
```
