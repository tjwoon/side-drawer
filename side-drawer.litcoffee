Copyright 2016 TJ Woon

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


Side Drawer Implementation
==========================

    "use strict"


Helpers
-------

Open or close the drawer.

    openDrawer = ->
        me = @

        fullyOpen = @fullyOpen
        unless fullyOpen? then fullyOpen = drawerWidth.call @

        @holder.show()

        @drawer
        .css "transition", "transform #{@options.speed}s ease-out"
        .css "transform", "translate3d(#{fullyOpen}px,0px,0px)"

        @holder
        .css "transition", "background #{@options.speed}s ease-out"
        .css "background", "rgba(0,0,0,#{@options.opacity})"

        @previousOverflow =  @parent.css "overflow"
        @parent.css "overflow", "hidden"

        @fingerId = undefined # Prevent touchstart/touchend in wrong handlers
        @handleEvent = swipeToCloseHandler

    closeDrawer = ->
        me = @

        @drawer
        .css "transition", "transform #{@options.speed}s ease-out"
        .css "transform", "translate3d(0px,0px,0px)"

        @holder
        .css "transition", "background #{@options.speed}s ease-out"
        .css "background", "rgba(0,0,0,0)"

        @parent.css "overflow", @previousOverflow

        @fingerId = undefined # Prevent touchstart/touchend in wrong handlers
        setTimeout (-> me.holder.hide()), 300 # FIXME
        @handleEvent = swipeToOpenHandler

    drawerWidth = ->
        # Hack to calculate width of hidden elements
        # http://stackoverflow.com/a/1472385
        @holder.css("visibility","hidden").css("display","block")
        outerWidth = @drawer.outerWidth()
        @holder.css("visibility","visible").css("display","none")
        outerWidth

Event handler to handle swipe to open drawer.

    swipeToOpenHandler = (evt) ->
        switch evt.type
            when "touchstart"
                left = @holder[0].getBoundingClientRect().left
                unless @fingerId?
                    touch = evt.changedTouches[0]
                    if touch.clientX - left <= @options.sensitivity
                        @fingerId = touch.identifier
                        @startX = touch.clientX
                        @offset = 0
                        @offsetList = []

                        @fullyOpen = drawerWidth.call @

                        @drawer.css "transition", "none"
                        @holder.css "transition", "none"

                    evt.stopPropagation()

            when "touchmove"
                unless @fingerId? then return

                for touch in evt.changedTouches
                    if @fingerId is touch.identifier
                        delta = Math.round touch.clientX - @startX
                        @offset = Math.max 0, Math.min @fullyOpen, delta
                        @drawer.css "transform", "translate3d(#{@offset}px,0px,0px)"

                        @offsetList.push
                            offset: @offset
                            time: (new Date).getTime()
                        while @offsetList.length >= 10 then @offsetList.shift()

                        darkness = @offset / @fullyOpen * @options.opacity
                        @holder.css "background", "rgba(0,0,0,#{darkness.toFixed 3})"
                        if @offset > 0 then @holder.show()
                        else @holder.hide()

                        evt.stopPropagation()
                        evt.preventDefault()

            when "touchend", "touchcancel"
                unless @fingerId? then return

                for touch in evt.changedTouches
                    if @fingerId is touch.identifier
                        # Figure out swipe velocity
                        now = (new Date).getTime()
                        while @offsetList.length and (now - @offsetList[0].time > 300)
                            @offsetList.shift()
                        earliest = @offsetList[0]
                        latest = @offsetList[-1..][0]
                        if earliest is latest then velocity = 0
                        else velocity = (@offset - earliest.offset) / (now - earliest.time) * 1000

                        if velocity >= 0 and (velocity >= @options.threshold or @offset >= @options.offset)
                            openDrawer.call @
                        else
                            closeDrawer.call @

                        evt.stopPropagation()

                        @fingerId = undefined
                        @startX = undefined
                        @offset = undefined
                        @offsetList = undefined
                        @fullyOpen = undefined
                        @previousOverflow = undefined

                        break

Event handler to handle swipe to close drawer.

    swipeToCloseHandler = (evt) ->
        switch evt.type
            when "touchstart"
                right = @drawer[0].getBoundingClientRect().right
                unless @fingerId?
                    touch = evt.changedTouches[0]
                    if right - @options.sensitivity <= touch.clientX
                        @fingerId = touch.identifier
                        @startX = touch.clientX
                        @fullyOpen = @drawer.outerWidth()
                        @offset = @fullyOpen
                        @offsetList = []

                        @drawer.css "transition", "none"
                        @holder.css "transition", "none"

                    evt.stopPropagation()

            when "touchmove"
                unless @fingerId? then return

                for touch in evt.changedTouches
                    if @fingerId is touch.identifier
                        delta = Math.round touch.clientX - @startX
                        @offset = Math.max 0, Math.min @fullyOpen, @fullyOpen+delta
                        @drawer.css "transform", "translate3d(#{@offset}px,0px,0px)"

                        @offsetList.push
                            offset: @offset
                            time: (new Date).getTime()
                        while @offsetList.length >= 10 then @offsetList.shift()

                        darkness = @offset / @fullyOpen * @options.opacity
                        @holder.css "background", "rgba(0,0,0,#{darkness.toFixed 3})"
                        if @offset > 0 then @holder.show()
                        else @holder.hide()

                        evt.stopPropagation()
                        evt.preventDefault()

            when "touchend", "touchcancel"
                unless @fingerId? then return

                for touch in evt.changedTouches
                    if @fingerId is touch.identifier
                        # Figure out swipe velocity
                        now = (new Date).getTime()
                        while @offsetList.length and (now - @offsetList[0].time > 300)
                            @offsetList.shift()
                        earliest = @offsetList[0]
                        latest = @offsetList[-1..][0]
                        if earliest is latest then velocity = 0
                        else velocity = (@offset - earliest.offset) / (now - earliest.time) * 1000

                        if velocity < 0 and (velocity <= -@options.threshold or @offset <= @fullyOpen - @options.offset)
                            closeDrawer.call @
                        else
                            openDrawer.call @

                        evt.stopPropagation()

                        @fingerId = undefined
                        @startX = undefined
                        @offset = undefined
                        @offsetList = undefined
                        @fullyOpen = undefined
                        @previousOverflow = undefined

                        break


Side Drawer Class
-----------------

    SideDrawer = (elt, conf={}) ->
        me = @

### Config

Default values. Can be overridden by `conf`.

        @options = $.extend({
            sensitivity: 60 # catch swipes up to this number of px from the edge
            threshold: 300 # open the drawer via momentum if swiping at this
                # speed or faster (px/second)
            offset: 120 # open the drawer if we have no momentum but we have
                # already been opened to this amount or more (px)
            opacity: 0.6 # opacity of the background (behind the drawer)
            speed: 0.2 # menu open/close transition duration (seconds)
        }, conf)


### Constants

        @holder = $ elt
        @drawer = @holder.children().eq(0)
        @parent = @holder.parent()


### State

        @fingerId = undefined # ID of the finger which initiated the swipe
        @startX = undefined # starting X position of the finger for the swipe

        @offset = undefined # drawer offset from closed position (px)
        @offsetList = undefined # for figuring out velocity for momentum purpose
            # [ { offset:N, time:timestamp }, ... ]

        @fullyOpen = undefined # max offset for fully open drawer.

        @previousOverflow = undefined # original value of @parent's `overflow` CSS

### Tap

        $(@holder).Touch()
        $(@holder).on "tap", ->
            closeDrawer.call me

        $(@drawer).on "tap", (evt) ->
            evt.stopPropagation()

### Init

        @holder.hide()
        @holder.css "position", "absolute"
        @holder.css "top", "0px"
        @holder.css "bottom", "0px"
        @holder.css "left", "0px"
        @holder.css "right", "0px"
        @holder.css "z-index", "9000"

        @drawer.css "position", "absolute"
        @drawer.css "top", "0px"
        @drawer.css "bottom", "0px"
        @drawer.css "left", "0px"
        @drawer.css "width", "calc(100% - 60px)"
        @drawer.css "margin-left", "calc(-100% + 60px)"

        @handleEvent = swipeToOpenHandler
        for event in ["touchstart", "touchmove", "touchend", "touchcancel"]
            @parent[0].addEventListener event, @, false

        @

    SideDrawer::open = ->
        openDrawer.call @

    SideDrawer::close = ->
        closeDrawer.call @

    SideDrawer.version = "0.0.1"


jQuery
------

    $.fn.SideDrawer = (conf) ->
        @each ->
            d = $(this).data "SideDrawer"
            unless d?
                d = new SideDrawer this, conf
                $(this).data "SideDrawer", d
            d

    $.SideDrawer = SideDrawer
