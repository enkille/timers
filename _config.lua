require 'imguidef'

local _common = require '_common'

local _config = { }
local path = AshitaCore:GetAshitaInstallPath() .. '/config/timers/config.json'

_config.settings = { }

local defaults = {
	autohide = true,
	direction = 'ltr',
	scale = 'all',
	position_x = 100,
	position_y = 100,
	anchor = "BOTTOMLEFT",
	notifyonfinish = false,
	notifyonlyifleader = true,
	sortby = 'time',
	sortdirection = 'desc',
	preset = nil,
	maxvisible = 10,
  width = 500
}

_config.defaults = defaults

_config.visible = false

_config.save = function()
	local data = ashita.settings.JSON:encode_pretty(_config.settings, nil, { pretty = true, align_keys = false, indent = '    ' })
	local f = io.open(path, 'w')

	if (f == nil) then
		_common.msg('Failed to save settings.')
		return true;
	end

	f:write(data);
	f:close();
end

_config.load = function()
	local data = ashita.settings.load(path)

	if (data == nil) then
		_config.settings = defaults
		_config.save()
		return true;
	else
		_config.settings = defaults
		for k,v in pairs(data) do
			_config.settings[k] = v
		end
	end
end

_config.draw = function()
	local lineHeight = imgui.GetFontSize() + 4
	local lineCount = 10
	local windowHeight = ((lineHeight + imgui.style.ItemSpacing.y) * lineCount) + imgui.style.FramePadding.y

	if windowHeight < 50 then windowHeight = 50 end

	imgui.SetNextWindowSize(500, windowHeight, ImGuiSetCond_Always)

	if (imgui.Begin('Config') == false) then
		imgui.End()
		return
	end

	imgui.End()
end

return _config
