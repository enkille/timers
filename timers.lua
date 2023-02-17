addon.author   = 'Enkille'
addon.name     = 'Timers'
addon.version  = '0.2.0'

require 'common'
require 'json'
require 'imgui'
require 'string'

local _common = require '_common'
local _t = require '_timers'
local _config = require '_config'
local _presets = require '_presets'

if (ashita.fs.exists(AshitaCore:GetInstallPath() .. 'config/addons/timers') == false) then
  ashita.fs.create_dir(AshitaCore:GetInstallPath() .. 'config/addons/timers')
end

if (ashita.fs.exists(AshitaCore:GetInstallPath() .. 'config/addons/timers/presets') == false) then
  ashita.fs.create_dir(AshitaCore:GetInstallPath() .. 'config/addons/timers/presets')
end

ashita.events.register('load', 'load_cb', function()
  _config.load()
  if ( _config.settings['profile'] ~= nil ) then
    _presets.load(_config.settings['profile'])
  end
end)

ashita.events.register('text_in', 'incoming_text_cb', function(e)
  return false
end)

ashita.events.register('incoming_packet', 'incoming_packet_cb', function(e)
  return false
end)

ashita.events.register('d3d_present', 'render_cb', function()
  if _t ~= nil then
    if table.getn(_t.timers) > 0 or _config.settings.autohide == false then
      _t.draw()
    end
  end

end)

ashita.events.register('command', 'command_cb', function(e)
  local args = e.command:args()
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
      _common.msg ( '  tod: Adds a ToD timer' )
      _common.msg ( '  remove: Removes a specific timer' )
      _common.msg ( '  clear: Clears all timers' )
      _common.msg ( '  extend: Add time to an existing timer' )
      _common.msg ( '  list: List existing timers along with their IDs' )
      _common.msg ( '  profile: Create or load a timer preset profile' )
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
        _common.msg ( 'Command: /timer add [duration] [label] [[repetitions]]' )
        _common.msg ( '  Will add a timer based on given parameters' )
        _common.msg ( '  [duration]: Required - Specifies seconds by default' )
        _common.msg ( '    Also accepts duration strings formatted as "#h#m#s"' )
        _common.msg ( '  [label]: Required - Specifies a text label' )
        _common.msg ( '    If spaces are used, must be enclosed in quotes' )
        _common.msg ( '  [repetitions]: Optional - Specifies repeating timers' )
        _common.msg ( '  Example: /timer add 3m15s "Monster Respawn"' )
        _common.msg ( '  Example: /timer add 21h "HNM Respawn" 30m 30m 30m' )
        _common.msg ( '  Example: /timer add 21h "HNM Respawn" 30m x3' )
      elseif args[3] == 'tod' then
        _common.msg ( 'Command: /timer tod [time] [duration] [label] [[repetitions]]' )
        _common.msg ( '  Will add a ToD timer based on given parameters' )
        _common.msg ( '  [time]: Required - Specifies the time of death' )
        _common.msg ( '  [duration]: Required - Specifies seconds by default' )
        _common.msg ( '    Also accepts duration strings formatted as "#h#m#s"' )
        _common.msg ( '  [label]: Required - Specifies a text label' )
        _common.msg ( '    If spaces are used, must be enclosed in quotes' )
        _common.msg ( '  [repetitions]: Optional - Specifies repeating timers' )
        _common.msg ( '  Example: /timer tod 8:45am 3m15s "Monster Respawn"' )
        _common.msg ( '  Example: /timer tod 8:45:37 21h "HNM Respawn" 30m 30m 30m' )
        _common.msg ( '  Example: /timer tod 8:45:37 21h "HNM Respawn" 30m x3' )
      elseif args[3] == 'remove' then
        _common.msg ( 'Command: /timer remove [name]' )
        _common.msg ( '  Will remove a specified timer' )
        _common.msg ( '  [name]: Required - the name of the timer to remove' )
      elseif args[3] == 'extend' then
        _common.msg ( 'Command: /timer extend [name] [duration]' )
        _common.msg ( '  Will extend a timer by a specified duration' )
        _common.msg ( '  [name]: Required - the name of the timer to extend' )
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
      elseif args[3] == 'profile' then
        _common.msg ( 'Command: /timer profile load [name]' )
        _common.msg ( '  Load a saved profile' )
        _common.msg ( 'Command: /timer profile new [name]' )
        _common.msg ( '  Create a profile' )
        --_common.msg ( '    scale [single|all]' )
        --_common.msg ( '  For additional help, type "/timer help config [option]' )
      end
    elseif args[2] == 'add' then
      --_t.create_timer ( args[3], "unnamed" )
      _presets.create_timer ( args[3] )
    elseif args[2] == 'profile' then
      if args[3] == 'list' then
        _presets.list_profiles()
      end
    elseif args[2] == 'remove' then
      _t.remove_timer ( args[3] )
    elseif args[2] == 'tod' then
      _t.load_preset ( args[3] )
    --[[
    elseif args[2] == 'test' then
      _common.msg('testing')
      local test = _common.parse_duration(args[3])
      _common.msg(test or "nil value")
      ]]
    end
  end

  if ( #args == 4 ) then
    if args[2] == 'add' then
      _t.create_timer ( args[3], args[4] )
    end
    if args[2] == 'tod' then
      _presets.create_timer ( args[3], args[4] )
    end
    if args[2] == 'extend' then
      _t.extend_timer ( args[3], args[4] )
    end
    if args[2] == 'profile' then
      local valid_create = { 'new', 'create', 'save' }
      if args[3] == 'load' then
        _presets.load(args[4])
        _config.settings['profile'] = args[4]
        _config.save()
      elseif _common.has_value( valid_create, args[3] ) then
        _presets.create(args[4])
      end
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

      if args[3] == 'sortby' then
        if _common.has_value( { 'pct' }, args[4] ) then
          _config.settings.sortby = 'pct'
          _t.sort()
        elseif _common.has_value( { 'time' }, args[4] ) then
          _config.settings.sortby = 'time'
          _t.sort()
        end
      end

      if args[3] == 'sortdirection' then
        if _common.has_value( { 'up', 'asc', 'ascending' }, args[4] ) then
          _config.settings.sortdirection = 'asc'
          _t.sort()
          _common.msg( 'sortdirection' )
        elseif _common.has_value( { 'down', 'desc', 'descending' }, args[4] ) then
          _config.settings.sortdirection = 'desc'
          _t.sort()
          _common.msg( 'sortdirection' )
        end
      end

      if args[3] == 'maxvisible' then
        if tonumber(args[4]) > 1 then
          _config.settings.maxvisible = tonumber(args[4])
        end
      end

      if args[3] == 'notifyonfinish' then
        if _common.has_value( valid_true, args[4] ) then
          _config.settings.notifyonfinish = true
        elseif _common.has_value( valid_false, args[4] ) then
          _config.settings.notifyonfinish = false
        end
      end

      if args[3] == 'width' then
        if tonumber(args[4]) > 1 then
          _config.settings.width = tonumber(args[4])
        end
      end

      _config.save()

    end
  end

  if ( #args >= 5 ) then
    if args[2] == 'tod' then
      --/timer tod 15:15:00 21h "name"
      --              3     4    5
      local time = args[3]
      local duration = args[4]
      local label = args[5]
      local reps = nil
      if ( #args >= 6 ) then
        reps = args
        table.remove(reps, 1) --remove slash command
        table.remove(reps, 1) --remove tod
        table.remove(reps, 1) --remove time
        table.remove(reps, 1) --remove duration
        table.remove(reps, 1) --remove name
      end
      _t.create_timer_from_tod ( time, duration, label, reps )
    end
    if args[2] == 'add' then
      local duration = args[3]
      local label = args[4]

      local reps = args
      table.remove(reps, 1) --remove slash command
      table.remove(reps, 1) --remove add
      table.remove(reps, 1) --remove duration
      table.remove(reps, 1) --remove name
      
      _t.create_timer ( duration, label, reps )
    end
  end

  return true
end)
