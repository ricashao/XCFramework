local Object = require "Framework.Object";
StringBuilder = Class("StringBuilder", Object);

function StringBuilder:Ctor(...)
	Object.Ctor(self,...)
	self.rules = {};
end	

function StringBuilder:Delete()
	print("string builder delete")
	self = nil;
end

--change $str1$ with str2
function StringBuilder:Set(str1, str2)
	self.rules["%$" .. str1 .. "%$"] = str2
end

--change $str$ with num
function StringBuilder:SetNum(str, num)
	self.rules["%$" .. str .. "%$"] = tostring(num)
end

function StringBuilder:GetString(str)
	local resultStr = str
	for i,v in pairs(self.rules) do
		resultStr = string.gsub(resultStr, i, v)
	end
	return resultStr
end

function StringBuilder.split(str,sep)
	local t = {}
	for w in string.gfind(str, "[^"..sep.."]+")do
		table.insert(t, w)
	end
	return t
end

function StringBuilder.splitToNumber(str,sep)
	local t = {}
	for w in string.gfind(str, "[^"..sep.."]+")do
		t[#t+1] = tonumber(w)
	end
	return t
end

--use as "1,300;2,400;5,400"
function StringBuilder.SplitByTwoSep(str,sep1,step2)
	local t = {}
	t = StringBuilder.split(str,sep1)

	local resulttable = {}
	for k,v in pairs(t) do
    	local _t = StringBuilder.split(v,step2)
    	local _k = tonumber(_t[1])
    	local _v = tonumber(_t[2])
    	resulttable[_k] = _v
  end 
	return resulttable
end

return StringBuilder
