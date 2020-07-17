local _common = { }

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

	return seconds

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
