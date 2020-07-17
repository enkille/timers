local _c = require '_config'
local _common = require '_common'

local _timers = { }

_timers.timers = { }
_timers.timerpadlength = 0
_timers.alwaysshow = false
_timers.config = { }

_timers.list_timers = function()
	for k,v in ipairs( _timers.timers ) do
		msg( '[' .. k .. '] : ' .. v.label )
	end
end

_timers.sort = function()
	table.sort( _timers.timers, function(a, b) return a.finish > b.finish end  )
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

_timers.create_timer = function( duration, label )

	local seconds = _common.parse_duration( duration )

	local timer = { }
	timer.start = os.time()
	timer.finish = timer.start + seconds
	timer.label = label
	timer.expired = false
	table.insert(_timers.timers, timer)

	_timers.update_max_length()
	_timers.sort()

end

_timers.remove_timer = function( id )
	table.remove(_timers.timers, id)
	_timers.update_max_length()
end

_timers.clear_timers = function()
	_timers.timers = { }
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

		if ( v.timeremaining <= 0 ) then
			v.expired = true
			_timers.remove_timer(k)
		end
	end

	imgui.End()

end

return _timers
