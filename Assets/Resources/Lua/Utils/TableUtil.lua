TableUtil = {}

function TableUtil.TableLength(T)
	local count = 0
	if T ~= nil then 	
		for _ in pairs(T) do count = count+1 end
	end	
	return count
end

return TableUtil
