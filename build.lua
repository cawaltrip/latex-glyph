#!/usr/bin/env texlua

-- Build script for glyph package

bundle = ""
module = "glyph"

-- TDS zip file
packtdszip = true

-- Need to escape to shell for typesetting.
typesetopts = "-interaction=nonstopmode --shell-escape"

-- Files to typeset
typesetsuppfiles = {"example.pdf"}
typesetfiles = {"glyph.dtx"}

sourcefiles = {
  "glyph.dtx",
  "glyph.ins",
  "glyph-messages.dtx",
  "glyph-functions.dtx",
  "glyph-functions-luatex.dtx",
  "glyph-lua.dtx"
}

installfiles = {"*.sty", "glyph.lua"}

-- ASCII mangling is not useful for us
asciiengines = { }

-- Avoid line-wrap issues
maxprintline = 9999

-- Need to typeset with LuaLaTeX since we're calling
-- our own package in the documentation and it only
-- supports LuaTeX currently.
typesetexe = "lualatex"

-- If we only want to document user manual, uncomment this line.
-- typesetcmds = "\\AtBeginDocument{\\DisableImplementation}"

uploadconfig = {
    author      = "Chris Waltrip",
    license     = "lppl1.3c",
    summary     = "Arbitrary glyph command generation",
    topic       = {"font-supp","font-supp-symbol"},
    ctanPath    = "/macros/luatex/latex/glyph", -- or /support/glyph?
    repository  = "https://github.com/cawaltrip/latex-glyph/",
    bugtracker  = "https://github.com/cawaltrip/latex-glyph/issues",
    update      = true,
    description = [[
  The glyph module provides document writers using LuaLaTeX a method of
  using glyphs from any OTF font installed on the their system. This
  methods uses the glyph's name (as defined inside the font) instead
  of the Unicode codepoint.  Document-level commands are created for
  each glyph in a predictable way, and a fallback is provided. Lastly, 
  a command for showing every glyph (and its name) in a font is made
  available.
  ]]
  }
