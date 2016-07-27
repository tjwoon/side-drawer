Side Drawer
===========

A touch optimised side drawer which is easy to add to your website / HTML5
mobile application.


Setup
-----

Make sure to include jQuery first (v1.x or 2.x), followed by
[my Touch library](https://github.com/tjwoon/touch-events), and lastly this
library:

```html
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>
<script src="touch.js"></script>
<script src="side-drawer.bundle.js"></script>
```


Examples
--------

### HTML and CSS:

To overlap the whole page:

```html
<body>
    <div id="leftMenu">
        <div class="menuContents">
            <!-- Menu items, images, etc go here -->
        </div>
    </div>
</body>
```

```css
html , body {
    height: 100%;
}
body {
    overflow: scroll;
    -webkit-overflow-scrolling: touch;
}
```

To be below a header bar:

```html
<body>
    <div id="header">Demo</div>
    <div id="contentArea">
        <div id="leftMenu">
            <div class="menuContents">
                <!-- Menu items, images, etc go here -->
            </div>
        </div>
        <!-- page contents, etc -->
    </div>
</body>
```

```css
html , body {
    height: 100%;
}
#header {
    height: 60px;
}
#contentArea {
    position: absolute;
    top: 60px;
    bottom: 0px;
    left: 0px;
    right: 0px;
    overflow: scroll;
    -webkit-overflow-scrolling: touch;
}
```


### JavaScript

```javascript
$("#leftMenu").sideDrawer({
    ... // optional config object
})
```


For more complete demos, look in the `demo/` directory.


Config
------

These are the available config properties and their default values:

```javascript
{
    sensitivity: 60,    // catch swipes up to this number of px from the edge
    threshold: 300,     // open the drawer via momentum if swiping at this
                        // speed or faster (px/second)
    offset: 120,        // open the drawer if we have no momentum but we have
                        // already been opened to this amount or more (px)
    opacity: 0.6,       // opacity of the background (behind the drawer)
    speed: 0.2          // menu open/close transition duration (seconds)
}
```


Getting Involved in Development
-------------------------------

Source code is in the `.litcoffee` file, written in
[CoffeeScript](http://www.coffeescript.org).

Edit the litcoffee source, then compile to JS using:
`coffee --compile --map side-drawer.litcoffee`
