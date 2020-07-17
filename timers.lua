_addon.author   = 'Enkille'
_addon.name     = 'Timers'
_addon.version  = '0.0.1'

require 'common'
require 'json.json'
require 'imguidef'
require 'stringex'

local _common = require '_common'
local _t = require '_timers'
local _config = require '_config'

ashita.register_event('load', function()
	_config.load()
end)

ashita.register_event('incoming_text', function(mode, chat, modifiedmode, modifiedmessage, blocked)
	return false
end)

ashita.register_event('incoming_packet', function(id, size, packet, packet_modified, blocked)
	return false
end)

ashita.register_event('render', function()

	if _t ~= nil then
		if table.getn(_t.timers) > 0 or _config.settings.autohide == false then
			_t.draw()
		end
	end

	if _config.visible == true then _config.show() end

end)

ashita.register_event('command', function(command, ntype)
	local args = command:args()
	local commands = { '/timers', '/timer' }

	if (table.hasvalue(commands, args[1]) == false) then
		return false
	end

	if ( #args == 1 ) then
		_t.visible = not _t.visible
	end

	if ( #args == 2 ) then
		if args[2] == '?' or args[2] == 'help' then
			_common.msg ( 'Addon Usage' )
			_common.msg ( 'Commands: /timer, /timers ' )
			_common.msg ( 'Sub-commands:' )
			_common.msg ( '  add: Adds a new timer' )
			_common.msg ( '  remove: Removes a specific timer' )
			_common.msg ( '  clear: Clears all timers' )
			_common.msg ( '  extend: Add time to an existing timer' )
			_common.msg ( '  list: List existing timers along with their IDs' )
			_common.msg ( 'For additional help, type "/timer help [subcommand]"' )
		elseif args[2] == 'list' then
			_t.list_timers()
		elseif args[2] == 'clear' then
			_t.clear_timers()
		elseif args[2] == 'config' then
			_config.visible = not _config.visible
		end
	end

	if ( #args == 3 ) then
		if args[2] == '?' or args[2] == 'help' then
			if args[3] == 'add' then
				_common.msg ( 'Command: /timer add [duration] [label]' )
				_common.msg ( '  Will add a timer based on given parameters' )
				_common.msg ( '  [duration]: Required - Specifies seconds by default' )
				_common.msg ( '    Also accepts duration strings formatted as "#h#m#s"' )
				_common.msg ( '  [label]: Required - Specifies a text label' )
				_common.msg ( '    If spaces are used, must be enclosed in quotes' )
				_common.msg ( '  Example: /timer add 3m15s "Monster Respawn"' )
			elseif args[3] == 'remove' then
				_common.msg ( 'Command: /timer remove [index]' )
				_common.msg ( '  Will remove a specified timer' )
				_common.msg ( '  [index]: Required - the index of the timer to remove' )
			elseif args[3] == 'extend' then
				_common.msg ( 'Command: /timer extend [index] [duration]' )
				_common.msg ( '  Will extend a timer by a specified duration' )
				_common.msg ( '  [index]: Required - the index of the timer to extend' )
				_common.msg ( '  [duration]: Required - the amount of time to add' )
			elseif args[3] == 'clear' then
				_common.msg ( 'Command: /timer clear' )
				_common.msg ( '  Will remove all timers' )
			elseif args[3] == 'config' then
				_common.msg ( 'Command: /timer config [option] [value]' )
				_common.msg ( '  Set a configuration option' )
				_common.msg ( '  Available options:' )
				_common.msg ( '    autohide [true|false]' )
				_common.msg ( '    direction [ltr|rtl]' )
				_common.msg ( '    scale [single|all]' )
				--_common.msg ( '  For additional help, type "/timer help config [option]' )
			end
		elseif args[2] == 'remove' then
			_t.remove_timer ( args[3] )
		end
	end

	if ( #args == 4 ) then
		if args[2] == 'add' then
			_t.create_timer ( args[3], args[4] )
		end
		if args[2] == 'extend' then
			_t.extend_timer ( args[3], args[4] )
		end
		if args[2] == 'config' then
			local valid_true = { 1, 'true', 'yes' }
			local valid_false = { 0, 'false', 'no' }

			if args[3] == 'autohide' then
				if _common.has_value( valid_true, args[4] ) then
					_config.settings.autohide = true
				elseif _common.has_value( valid_false, args[4] ) then
					_config.settings.autohide = false
				end
			end

			if args[3] == 'direction' then
				if _common.has_value( { 'ltr', 'grow', 'right' }, args[4] ) then
					_config.settings.direction = 'ltr'
				elseif _common.has_value( { 'rtl', 'shrink', 'left' }, args[4] ) then
					_config.settings.direction = 'rtl'
				end
			end

			if args[3] == 'scale' then
				if _common.has_value( { 'single', 'individual' }, args[4] ) then
					_config.settings.scale = 'single'
				elseif _common.has_value( { 'all' }, args[4] ) then
					_config.settings.scale = 'all'
				end
			end

			_config.save()

		end
	end

	return true
end)
