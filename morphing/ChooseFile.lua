--- Initial file-choosing phase of the morphing demo.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Modules --
local buttons = require("corona_ui.widgets.button")
local image_patterns = require("corona_ui.patterns.image")

-- Corona globals --
local display = display

-- Corona modules --
local composer = require("composer")

-- Choose File phase overlay (morphing demo) --
local Scene = composer.newScene()

--
function Scene:show (event)
	if event.phase == "did" then
		-- TODO:
		-- If database not empty, populate list (do file existence / integrity checks?)
		-- Add remove option: removes current entry from list (closes list if empty)
	--	local resume

		--
		local params = event.params

		-- Add a listbox to be populated with some image choices.
		local funcs, cancel, ok, preview = params.funcs

		local function Wait ()
			funcs.SetStatus("Press OK to add landmarks")

			cancel.isVisible = false
		end

		funcs.SetStatus("Choose an image")

		local image_list = image_patterns.ImageList(self.view, {
			left = 295, top = 20, path = params.dir, base = params.base, height = 120, add_preview = true,
--[[
			filter_info = function(_, w, h) -- Add any images in a certain size range to the list.
				return w >= 16 and w <= CW - 10 and h >= 16 and h <= CH - 150
			end,
]]
			press = function(event)
				local listbox = event.listbox

				-- On the first selection, add a button to launch the next step. When fired, the selected
				-- image is read into memory; assuming that went well, the algorithm proceeds on to the
				-- energy computation step. The option to cancel is available during loading (although
				-- this is typically a quick process).
				ok = ok or buttons.Button_XY(self.view, preview.x + 90, preview.y - 20, 100, 40, funcs.Action(function()
					funcs.SetStatus("Loading image")

					cancel.isVisible = true

					local image = listbox:LoadImage(funcs.TryToYield)

					cancel.isVisible = false

					if image then
						return function()
							params.ok_x = ok.x
							params.ok_y = ok.y
							params.cancel_y = cancel.y
							params.image = image

						--	funcs.ShowOverlay("morphing.AddLandmarks", params)
						end
					else
						funcs.SetStatus("Choose an image")
					end
				end), "OK")

				cancel = cancel or buttons.Button_XY(self.view, ok.x, ok.y + 100, 100, 40, Wait, "Cancel")

				Wait()
			end
		})

		image_list:Init()

		-- Place the preview pane relative to the listbox.
		preview = image_list:GetPreview()

		preview.x, preview.y = image_list.x + image_list.width / 2 + 55, image_list.y
	end
end

Scene:addEventListener("show")

return Scene