{iOSPageComponent, iOSPageControl} = require "iOSPageComponent"

page = new iOSPageComponent

page.addPage a
page.addPage b
page.addPage c



pageControl = new iOSPageControl
	y: Align.center
	numberOfPages: 5
	currentPage: 2
# 	hidesForSinglePage: true
	pageIndicatorTintColor: "black"
	currentPageIndicatorTintColor: "black"
# 	currentPageIndicatorTintColor: "red"
