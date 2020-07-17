require 'imguidef'

local _config = { }
local path = AshitaCore:GetAshitaInstallPath() .. '/config/timers.json'

_config.settings = { }

local defaults = {
	autohide = true,
	direction = 'ltr',
	scale = 'all',
	position_x = 100,
	position_y = 100,
	anchor = "BOTTOMLEFT",
	notify = nil,
	notifyonlyifleader = true
}

_config.visible = false

_config.save = function()
	local data = ashita.settings.JSON:encode_pretty(_config.settings, nil, { pretty = true, align_keys = false, indent = '    ' })
	local f = io.open(path, 'w')

	if (f == nil) then
		err('Failed to save settings.')
		return true;
	end

	f:write(data);
	f:close();
end

_config.load = function()
	local data = ashita.settings.load(path)

	if (data == nil) then
		print ( 'new data' )
		_config.settings = defaults
		_config.save()
		return true;
	else
		for k,v in pairs(data) do
			_config.settings[k] = v
		end
	end
end

return _config
