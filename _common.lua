local _common = { }

_common.generate_uuid = function()
	local random = math.random
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end

_common.has_value = function ( tab, val )
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

_common.msg = function ( s )
	local txt = '\31\200[\31\05' .. _addon.name .. '\31\200]\31\130 ' .. s;
	print(txt);
end

_common.parse_duration = function ( duration )

	local seconds = 0

	if ( duration ~= nil ) then
		local rx = ashita.regex.match( duration, '^(\\d*)$' )
		if ( rx ~= nil ) then
			seconds = tonumber(rx[1])
		else
			local h = ashita.regex.search( duration, '(\\d*)[H|h]{1}' )
			local m = ashita.regex.search( duration, '(\\d*)[M|m]{1}' )
			local s = ashita.regex.search( duration, '(\\d*)[S|s]{1}' )

			if ( h ~= nil ) then
				seconds = seconds + (tonumber(h[1]) * 60 * 60)
			end
			if ( m ~= nil ) then
				seconds = seconds + (tonumber(m[1]) * 60)
			end
			if ( s ~= nil ) then
				seconds = seconds + tonumber(s[1])
			end
		end
	else
		seconds = 0
	end

	return seconds

end

_common.parse_time = function ( time )
	local t = time
	local now = os.date('*t')

	local year, month, day, hour, min, sec, ampm

	if ( t ~= nil ) then
		local rx
		year = now.year
		month = now.month
		day = now.day

		rx = ashita.regex.match( t, '^(\\d{1,2})\\:(\\d{2})\\:(\\d{2})([am|pm]{2}|[am|pm]{0})$' )
		if ( rx ~= nil ) then
			hour = tonumber(rx[1])
			min = tonumber(rx[2])
			sec = tonumber(rx[3])
			ampm = rx[4]
		else

			rx = ashita.regex.match( t, '^(\\d{1,2})\\:(\\d{2})([am|pm]{2}|[am|pm]{0})$' )
			if ( rx ~= nil ) then
				hour = tonumber(rx[1])
				min = tonumber(rx[2])
				sec = 0
				ampm = rx[3]
			else
				return false
			end
		end

		if ( ampm == 'pm' and hour < 12 ) then hour = hour + 12 end
		t = os.time({year=now.year, month=now.month, day=now.day, hour=hour, min=min, sec=sec})
		if ( t > os.time() ) then day = day - 1 end

		return os.time( { year=year, month=month, day=day, hour=hour, min=min, sec=sec } )

	end
	return false
end

_common.format_time = function ( seconds )

	local tmp = seconds
	local ret = ''
	local h = 0
	local m = 0
	local s = 0

	h = math.floor(tmp / 60 / 60)

	if h >= 1 then
		tmp = tmp - (h * 60 * 60)
		ret = ret .. string.lpad(tostring(h), '0', 2) .. ':'
	end

	m = math.floor(tmp / 60)

	if m >= 1 then
		tmp = tmp - (m * 60)
		ret = ret .. string.lpad(tostring(m), '0', 2) .. ':'
	end

	s = tmp
	ret = ret .. string.lpad(tostring(s), '0', 2)

	return ret

end

return _common
