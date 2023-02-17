local _presets = {
  current = nil,
  profiles = { },
  timers = { }
}

local json = require 'json'

local _common = require '_common'
local _timers = require '_timers'
local path = AshitaCore:GetInstallPath() .. 'config/addons/timers/presets'

_presets.create = function(name)
  local default_timers = {
    {
      name = 'behemoth',
      alias = {
        "kb",
        "king behemoth"
      },
      duration = '12s',
      repetitions = {
        '3s',
        'x5'
      }
    },
    {
      name = 'other_timer',
      duration = '1m30s',
      repetitions = { }
    }
  }
  local data = json.encode(default_timers)
  if name ~= nil then
    local f = io.open(path .. '/' .. name .. '.json', 'w')

    if (f == nil) then
      _common.msg('Failed to save settings.')
      return true;
    end

    f:write(data);
    f:close();
  end
  _presets.get_profiles()
end

_presets.load = function(name)
  local data = json.decode(io.open(path .. '/' .. name .. '.json', "r"):read("a"))
  local timers = { }
  if (data ~= nil) then
    _presets.current = name
    for k,v in pairs(data) do
      table.insert(timers, v)
    end
    _presets.timers = timers
  end
end

_presets.list_profiles = function()
  _presets.get_profiles()
  if ( #_presets.profiles > 0 ) then
    for p=1,#_presets.profiles do
      _common.msg(_presets.profiles[p])
    end
  else
    _common.msg( 'No profiles exist. User /timers profile new [name] to create a profile' )
  end
end

_presets.get_profiles = function()
  local profiles = { }
  if ashita.fs.exists(path) then
    local files = ashita.fs.get_dir(path, '.*.json', true)
    if ( #files > 0 ) then
      for k,v in ipairs(files) do
        local rx = ashita.regex.match( tostring(v), '(.*)\\.json' )
        table.insert (profiles, rx[2])
      end
    end
  end
  _presets.profiles = profiles
end

_presets.profile_exists = function(name)
  _presets.get_profiles()
  return _common.has_value( _presets.profiles, name )
end

_presets.create_timer = function( name, time )
  local rx = ashita.regex.match( name, '(.*)[\\|\\/|\\.](.*)' )
  local p = nil
  local pe = false
  local n = nil

  if ( rx ~= nil ) then
    p = rx[1]
    pe = _presets.profile_exists(p)
  end

  if ( _presets.current ~= nil or pe == true ) then
    if ( rx ~= nil ) then
      p = rx[1]
      n = rx[2]
    else
      p = _presets.current
      n = name
    end
    local t = _presets.get_timer( p, n )
    if ( t ~= nil ) then
      if ( time == nil ) then
        _timers.create_timer ( t.duration, t.name, t.repetitions )
      else
        _timers.create_timer_from_tod ( time, t.duration, t.name, t.repetitions )
      end
    else
      _common.msg( 'Could not find a saved timer: ' .. _presets.current .. '\\' .. name )
    end
  else
    _common.msg('No profile loaded. Use "/timer profile list" to view available profiles')
    _common.msg('  Use "/timer profile load [name]" to load a profile')
  end
end

_presets.get_timer = function(profile, name)
  local revert = _presets.current
  local timer = nil

  if ( _presets.current ~= profile ) then
    _presets.load( profile )
  end

  for k,v in ipairs(_presets.timers) do
    if ( v.name == name ) then
      timer = v
      break
    else
      if ( v.alias ~= nil ) then
        for a=1,#v.alias do
          if ( v.alias[a] == name ) then
            timer = v
            break
          end
        end
      end
    end
  end

  if ( profile ~= revert ) then
    if revert == nil then
      _presets.current = nil
      _presets.timers = { }
    else
      _presets.load(revert)
    end
  end
  
  return timer
end

return _presets