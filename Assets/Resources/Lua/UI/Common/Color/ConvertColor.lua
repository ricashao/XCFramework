ConvertColor = {}

-- 根据读表颜色 对string 进行改变
-- public   color 类型是读取策划表 或者 "#1aaee6" 类型 
function ConvertColor.RefreshStringColor(color, str)
	if tonumber(color) == -1 then
		return str
	else
		return "<color=" .. color .. ">" .. str .. "</color>";
	end
end

return ConvertColor;