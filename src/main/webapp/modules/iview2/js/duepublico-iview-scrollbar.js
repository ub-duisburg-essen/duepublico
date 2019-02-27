var __extends = (this && this.__extends) || function (d, b) {
        for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
        function __() {
            this.constructor = d;
        }

        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };

var mycore;
(function (mycore) {
    var viewer;
    (function (viewer) {
        var widgets;
        (function (widgets) {
            var canvas;
            (function (canvas) {
                var Scrollbar = (function () {
                    function Scrollbar(_horizontal) {
                        var _this = this;
                        this._horizontal = _horizontal;
                        this._areaSize = null;
                        this._viewSize = null;
                        this._position = null;
                        this._mouseDown = -1;
                        this._scrollhandler = null;
                        this._cachedScrollbarElementSize = null;
                        this.initElements();
                        var body = jQuery(document.body);
                        var moveHandler = function (e) {
                            if (_this._mouseDown != -1) {
                                var val = (_this._horizontal ? (e.clientX - _this._scrollbarElement.offset().left) : (e.clientY - _this._scrollbarElement.offset().top)) - _this._mouseDown;
                                var realSize = (_this._horizontal ? _this._scrollbarElement.width() : _this._scrollbarElement.height()) - 30;
                                var relation = realSize / _this._areaSize;
                                _this._position = (val) / relation;
                                _this.update();
                                if (_this.scrollHandler != null) {
                                    _this.scrollHandler();
                                }
                                e.preventDefault();
                            }
                        };
                        var upHandler = function (e) {
                            _this._mouseDown = -1;
                            if (interv != -1) {
                                window.clearInterval(interv);
                                interv = -1;
                                e.preventDefault();
                            }
                            body.unbind("mousemove", moveHandler);
                        };
                        this._slider.mousedown(function (e) {
                            _this._mouseDown = _this._horizontal ? (e.clientX - _this._slider.offset().left) : (e.clientY - _this._slider.offset().top);
                            body.bind("mousemove", moveHandler);
                            body.bind("mouseup", upHandler);
                            e.preventDefault();
                        });
                        this._scrollbarElement.mousedown(function (e) {
                            if (jQuery(e.target).hasClass("slider")) {
                                return;
                            }
                            var val = (_this._horizontal ? (e.clientX - _this._scrollbarElement.offset().left) : (e.clientY - _this._scrollbarElement.offset().top));
                            var realSize = (_this._horizontal ? _this._scrollbarElement.width() : _this._scrollbarElement.height()) - 30;
                            var relation = realSize / _this._areaSize;
                            var sliderSize = Math.min(Math.max(20, _this._viewSize * relation), realSize);
                            _this._position = (val - (sliderSize / 2)) / relation;
                            _this.update();
                            if (_this.scrollHandler != null) {
                                _this.scrollHandler();
                            }
                        });
                        var interv = -1;
                        this._startButton.mousedown(function (e) {
                            _this._position -= 200;
                            _this.scrollHandler();
                            e.preventDefault();
                            e.stopImmediatePropagation();
                            interv = window.setInterval(function () {
                                _this._position -= 200;
                                _this.scrollHandler();
                            }, 111);
                        });
                        this._endButton.mousedown(function (e) {
                            _this._position += 200;
                            _this.scrollHandler();
                            e.preventDefault();
                            e.stopImmediatePropagation();
                            interv = window.setInterval(function () {
                                _this._position += 200;
                                _this.scrollHandler();
                            }, 111);
                        });
                        
                        console.log("duepublico-iview-scrollbar.js: Add fix for redmine #988");
                        // Redmine miless2mir #988
                        this._startButton.mouseup((e) => {
                            this._mouseDown = -1;
                            if (interv != -1) {
                                window.clearInterval(interv);
                                interv = -1;
                                e.preventDefault();
                            }
                        });
                        this._endButton.mouseup((e) => {
                            this._mouseDown = -1;
                            if (interv != -1) {
                                window.clearInterval(interv);
                                interv = -1;
                                e.preventDefault();
                            }
                        });
                    }

                    Scrollbar.prototype.clearRunning = function () {
                        this._mouseDown = -1;
                    };
                    Scrollbar.prototype.initElements = function () {
                        this._className = (this._horizontal ? "horizontal" : "vertical");
                        this._scrollbarElement = jQuery("<div></div>");
                        this._scrollbarElement.addClass(this._className + "Bar");
                        this._slider = jQuery("<div></div>");
                        this._slider.addClass("slider");
                        this._startButton = jQuery("<div></div>");
                        this._startButton.addClass("startButton");
                        this._endButton = jQuery("<div></div>");
                        this._endButton.addClass("endButton");
                        this._startButton.appendTo(this._scrollbarElement);
                        this._slider.appendTo(this._scrollbarElement);
                        this._endButton.appendTo(this._scrollbarElement);
                    };
                    Object.defineProperty(Scrollbar.prototype, "viewSize", {
                        get: function () {
                            return this._viewSize;
                        },
                        set: function (view) {
                            this._viewSize = view;
                            this.update();
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(Scrollbar.prototype, "areaSize", {
                        get: function () {
                            return this._areaSize;
                        },
                        set: function (area) {
                            this._areaSize = area;
                            this.update();
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(Scrollbar.prototype, "position", {
                        get: function () {
                            return this._position;
                        },
                        set: function (pos) {
                            this._position = pos;
                            this.update();
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Scrollbar.prototype.update = function () {
                        if (this._areaSize == null || this._viewSize == null || this._position == null) {
                            return;
                        }
                        var ret = this.getScrollbarElementSize.call(this);
                        var realSize = (this._horizontal ? ret.width : ret.height) - 30;
                        var relation = realSize / this._areaSize;
                        var sliderSize = Math.min(Math.max(20, this._viewSize * relation), realSize);
                        var sliderSizeStyleKey = this._horizontal ? "width" : "height";
                        var sliderSizeStyle = {};
                        sliderSizeStyle[sliderSizeStyleKey] = sliderSize + "px";
                        this._slider.css(sliderSizeStyle);
                        relation = (realSize - (sliderSize - (this._viewSize * relation))) / this._areaSize;
                        var sliderPos = Math.max(this._position * relation + 15, 15);
                        var sliderPosStyleKey = this._horizontal ? "left" : "top";
                        var sliderPosStyle = {};
                        sliderPosStyle[sliderPosStyleKey] = sliderPos + "px";
                        this._slider.css(sliderPosStyle);
                    };
                    Scrollbar.prototype.getScrollbarElementSize = function () {
                        if (this._cachedScrollbarElementSize == null) {
                            var elementHeight = this._scrollbarElement.height();
                            var elementWidth = this._scrollbarElement.width();
                            this._cachedScrollbarElementSize = new Size2D(elementWidth, elementHeight);
                        }
                        return this._cachedScrollbarElementSize;
                    };
                    Scrollbar.prototype.resized = function () {
                        this._cachedScrollbarElementSize = null;
                    };
                    Object.defineProperty(Scrollbar.prototype, "scrollbarElement", {
                        get: function () {
                            return this._scrollbarElement;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(Scrollbar.prototype, "scrollHandler", {
                        get: function () {
                            return this._scrollhandler;
                        },
                        set: function (handler) {
                            this._scrollhandler = handler;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    return Scrollbar;
                }());
                canvas.Scrollbar = Scrollbar;
            })(canvas = widgets.canvas || (widgets.canvas = {}));
        })(widgets = viewer.widgets || (viewer.widgets = {}));
    })(viewer = mycore.viewer || (mycore.viewer = {}));
})(mycore || (mycore = {}));


addViewerComponent(mycore.viewer.widgets.canvas.Scrollbar);
console.log("DUEPUBLICO-SCROLLBAR MODULE");