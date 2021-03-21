local _c = require '_config'
local _common = require '_common'

local _timers = { }
local path = AshitaCore:GetAshitaInstallPath() .. '/config/timers/timers.json'

_timers.timers = { }
_timers.timerpadlength = 0
_timers.alwaysshow = false
_timers.config = { }

_timers.list_timers = function()
	for k,v in ipairs( _timers.timers ) do
		_common.msg( '[' .. k .. '] : ' .. v.label )
	end
end

_timers.sort = function()
	local sortby = _c.settings.sortby or 'time'
	if ( sortby == 'time' ) then
		table.sort( _timers.timers, function(a, b) return a.finish > b.finish end  )
	elseif ( sortby == 'pct' ) then
		--(1-((v.finish - os.time()) / (v.finish - v.start))
		table.sort( _timers.timers, function(a, b) return (1-((a.finish - os.time()) / (a.finish - a.start))) > (1-((b.finish - os.time()) / (b.finish - b.start))) end  )
	end
end

_timers.update_max_length = function()

	local maxLength = 0

	for k,v in ipairs( _timers.timers ) do
		if string.len(v.label) > maxLength then
			maxLength = string.len(v.label)
		end
	end

	_timers.timerpadlength = maxLength

end

_timers.create_timer = function( duration, label, ... )

	local reps = ... or nil
	local seconds = _common.parse_duration( duration )

	local timer = { }
	timer.id = _common.generate_uuid()
	timer.parent = nil
	timer.start = os.time()
	timer.finish = timer.start + seconds
	timer.label = label
	timer.expired = false
	--timer.rep = reps
	table.insert(_timers.timers, timer)

	if ( reps ~= nil ) then
		if ( #reps > 0 ) then
			local s = seconds
			for i=1,#reps do
				local rep = _common.parse_duration( reps[i] )
				s = s + rep
				local t = _timers.create_timer( s, label .. ' [' .. tostring(i) .. ']' )
				t.parent = timer.id
			end
		end
	end

	_timers.update_max_length()
	_timers.sort()
	_timers.save()

	return timer

end

_timers.remove_timer = function( id )
	table.remove(_timers.timers, id)
	_timers.update_max_length()
	_timers.save()
end

_timers.clear_timers = function()
	_timers.timers = { }
	_timers.save()
end

_timers.extend_timer = function( id, duration )
	local i
	local d

	i = tonumber(id)
	d = _common.parse_duration(duration)

	if ( _timers.timers[i] ~= nil and d > 0 ) then
		_timers.timers[i].finish = _timers.timers[i].finish + d
	else
		msg('timer "' .. tostring(i) .. '"not located')
	end
	_timers.save()
end

_timers.clear_expired = function()
	for k,v in ipairs( _timers.timers ) do
		if ( v.expired == true ) then
			_timers.remove_timer(k)
			return
		end
	end
end

_timers.draw = function()

	local lineHeight = imgui.GetFontSize() + 4
	local windowHeight = ((lineHeight + imgui.style.ItemSpacing.y) * (table.getn(_timers.timers) + 1)) + imgui.style.FramePadding.y

	if windowHeight < 50 then windowHeight = 50 end

	imgui.SetNextWindowSize(500, windowHeight, ImGuiSetCond_Always)

	if (imgui.Begin('Timers') == false) then
		imgui.End()
		return
	end

	for k,v in ipairs( _timers.timers ) do
		v.timeremaining = v.finish - os.time()
		if ( v.timeremaining > 0 ) then
			v.labelpadded = string.lpad(v.label, ' ', _timers.timerpadlength) .. ': ' .. string.lpad(_common.format_time(v.timeremaining), ' ', 8)

			imgui.PushStyleColor(ImGuiCol_PlotHistogram, 1.0, 0.61, 0.61, 0.6)
			imgui.Text( v.labelpadded )
			imgui.SameLine()
			imgui.PushStyleColor(ImGuiCol_Text, 1.0, 1.0, 1.0, 1.0)
			if _c.settings.direction == 'rtl' then
				imgui.ProgressBar(1-((v.finish - os.time()) / (v.finish - v.start)), -1, lineHeight, '')
			else
				imgui.ProgressBar(((v.finish - os.time()) / (v.finish - v.start)), -1, lineHeight, '')
			end
			imgui.PopStyleColor(2)
		end

		if ( v.timeremaining <= 0 ) then
			if ( v.rep ~= nil ) then
				if ( #v.rep > 0 ) then
					local d = v.rep[1]
					table.remove(v.rep, 1)
					_timers.create_timer( d, v.label, v.rep )
				end
			end
			v.expired = true
			_timers.clear_expired()
		end
	end

	imgui.End()

	if ( _c.settings.sortby == 'pct' ) then
		_timers.sort()
	end

end

_timers.save = function()
	local data = ashita.settings.JSON:encode_pretty(_timers.timers, nil, { pretty = true, align_keys = false, indent = '    ' })
	local f = io.open(path, 'w')

	if (f == nil) then
		_common.msg('Failed to write timer to file. Timer will not exist after logging out.')
		return true;
	end

	f:write(data);
	f:close();
end

_timers.load = function()
	local data = ashita.settings.load(path)

	if (data == nil) then
		return true
	else
		_timers.timers = data
		_timers.sort()
		_timers.update_max_length()
	end
end

_timers.load()

return _timers
