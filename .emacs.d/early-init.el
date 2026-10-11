;; -*- lexical-binding: t; -*-

;; Prevent resize flicker on startup
(setq frame-inhibit-implied-resize t)

;; Disable GUI elements before they are created (avoids flicker)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Start with near-opaque background so the white flash is less jarring.
;; The main init sets this to 93 anyway; this just avoids a fully white frame
;; before the theme loads.
(push '(alpha-background . 93) default-frame-alist)

;; Defer GC during startup for faster load; gcmh will manage it afterward.
(setq gc-cons-threshold most-positive-fixnum)

;; package.el is used by the main init — do not disable it here.
