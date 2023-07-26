-- glyph.lua
-- Copyright 2023 Chris Waltrip
-- 
-- This work may be distributed and/or modified under the
-- conditions of the LaTeX Project Public License, either version 1.3
-- of this license or (at your option) any later version.
-- The latest version of this license is in
--   https://www.latex-project.org/lppl.txt
-- and version 1.3c or later is part of all distributions of LaTeX
-- version 2008 or later.
-- 
-- This work has the LPPL maintenance status `maintained'.
--  
-- The Current Maintainer of this work is Chris Waltrip.
-- 
-- This work consists of all files listed in ../MANIFEST-LPPL.md.

-- require("inspect")
-- json = require("json")
-- -- json = require("dkjson")
userdata = userdata or {}
u = userdata

function u.generate_glyph_commands(fontId, prefix, debug)
  debug = debug or false
  print("fontId: '" .. fontId .."'")
  print("prefix: '" .. prefix .."'")
  print("debug: '" .. debug .."'")

  -- Generate the internal command
  iconCommandName = u.generate_icon_command_name(prefix)
  iconCommandString = ""


  for name, index in pairs(font.getfont(fontId).resources.unicodes) do
    commandName = u.generate_command_name(name, prefix)
    charName = "c__" .. prefix .. "glyph_" .. name .. "_char"
    commandString = "\\exp_args:NNn\\tex_global:D\\tex_chardef:D{" .. charName .. "}" .. index .. "\\scan_stop:"
    if (debug) then
      print("glyph: '" .. name .. "', index: '" .. index .. "', commandName: '" .. commandName .."', setting: '" .. commandString .. "'")
    end
    tex.sprint(luatexbase.catcodetables.expl, commandString)
    if (index > 31) then -- avoid non-printable characters
      glyphNewCommand = "\\cs_new_protected:N\\" .. commandName
      glyphSetCommand = "\\cs_gset_protected:Npn\\" .. commandName .. "{\\" .. iconCommandName .. "{" .. name .. "}}"
      if (debug) then
        print("running new command: '" .. glyphNewCommand .. "'")
        print("running set command: '" .. glyphSetCommand .. "'")
      end
      tex.sprint(luatexbase.catcodetables.expl, glyphNewCommand)
      tex.sprint(luatexbase.catcodetables.expl, glyphSetCommand)
    end
    break -- only do the first for now.
  end
end

function u.generate_command_name(glyph, prefix)
  local commandString = u.sanitize_glyph(glyph)
  commandString = prefix:lower() .. "-" .. commandString
  commandString = commandString:gsub('-(%w)', string.upper)
  return commandString
end

function u.generate_icon_command_name(prefix)
  return prefix:lower() .. "Icon"
end

function u.sanitize_glyph(glyphName)
  local glyphString = glyphName
  if string.find(glyphName, "%d") then
    local replacementTable = {
      ["0"] = "Zero",
      ["1"] = "One",
      ["2"] = "Two",
      ["3"] = "Three",
      ["4"] = "Four",
      ["5"] = "Five",
      ["6"] = "Six",
      ["7"] = "Seven",
      ["8"] = "Eight",
      ["9"] = "Nine"
    }
    glyphString = glyphString.gsub("d%", replacementTable)
  end
  return glyphString
end

function u.get_glyph_index(glyphName, returnVariable)
  print("starting u.get_glyph_index")
  returnVariable = returnVariable or "g__glyph_tmpint_int"
  if(glyphName) then print("got glyphName = " .. glyphName) end
  if(returnVariable) then print("got returnVariable = " .. returnVariable) end
  local f = font.getfont(font.current())
  local index = f.resources.unicodes[glyphName] or 0
  print("u.get_glyph_index returning '" .. index .. "'.")
  if (returnVariable) then
    print("returnVariable = " .. returnVariable)
    print("index = " .. index)
    -- token.set_macro(returnVariable, tostring(index))
    tex.sprint(luatexbase.catcodetables.expl, index)
  else
    tex.sprint(index) -- Should never be reached.
  end
end

function u.print_glyph_table(fontId, prefix)
  -- TODO: Programmatically look up font family code (or create it?)
  -- local fontFromId = font.getfont(fontId)
  local f = fontloader.open((font.getfont(fontId)).filename)
  local glyphs = {}
  for i = 0, f.glyphmax - 1 do
    local g = f.glyphs[i]
    if g then
      -- print("name = '" .. g.name .. "', unicode = '" .. g.unicode .. "'")
      table.insert(glyphs, {name = g.name, unicode = g.unicode})
    end
  end
  table.sort(glyphs, function (a,b) return (a.unicode < b.unicode) end)
  for i = 1, #glyphs do
    outputString = "unicode = '" .. glyphs[i].unicode .. "', name = '" .. glyphs[i].name .. "'"
    print(outputString)
    -- print("unicode = '" .. glyphs[i].unicode .. "', name = '" .. glyphs[i].name .. "'")
    tex.sprint(glyphs[i].unicode .. ": ")
    if (glyphs[i].unicode > 0) then
      -- tex.sprint("{\\OD\\char" .. glyphs[i].unicode .. "}");
    else
      -- Here the updated code: the first glyph table in LuaTeX printing ALL glyphs in a font!
      -- tex.sprint("{\\OD\\char\\directlua{tex.print(luaotfload.aux.slot_of_name(font.current(), [[" .. glyphs[i].name .. "]]))}}")
    end
    -- tex.print(" {\\small(")
    -- tex.print(-2, glyphs[i].name )
    -- tex.sprint(')}\\\\')
  end
  fontloader.close(f)
end

function u.repeater(string)
  -- text.sprint(\\)
  -- The below worked as expected.
  -- string = string or "foobar"
  -- string = "Repeating~back~the~string:~" .. string
  -- tex.sprint(luatexbase.catcodetables.expl, string)
end

-- function u.print_glyph_table(fontId)
--   resources = font.getfont(fontId).resources
--   unicodes = resources.unicodes
--   -- print("resources debug information following")
--   -- debug.getinfo(resources)
--   -- print("unicodes debug information following")
--   -- debug.getinfo(unicodes)
--   local f = font.getfont(fontId)
--   local g = fontloader.open(f.filename)
--   -- local inspection = inspect(f, {depth=5})
--   -- print("Inspection of FA Font")
--   -- print(inspection)

--   local jsondata = json.encode(f)
--   print(jsondata)
--   -- file = io.open("fa6table.json", "w")
--   -- io.output(file)
--   -- io.write(jsondata)
--   -- io.close(file)

--   -- for i, v in font.each() do
--   --   print("font index '" .. i .. "' table below:")
--   --   local inspection = inspect(v, {depth=5})
--   --   print(inspection)
--   -- end
--   for glyph, value in pairs(font.getfont(fontId).resources.unicodes) do
--     -- print("glyph: '" .. glyph .. "', value: '" .. value .."'")
--   end
--   -- print("Passed in font: '" .. fontName .. "' (id: " .. fontId .. ")")x
-- end