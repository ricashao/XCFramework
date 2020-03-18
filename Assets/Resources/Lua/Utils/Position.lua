local Object = require "Framework.Object";
Position = Class("Position", Object);

function Position:Ctor(x, y, z)
	Object.Ctor(self, x, y, z);
	self.x = x or 0;
	self.y = y or 0;
	self.z = z or 0;
end

function Position:SetPosition(x, y, z)
	self.x = x;
	self.y = y;
	self.z = z;
	return self;
end

function Position:SetPositionByStr(str)
	local _array = StringBuilder.split(str, ",");
    self.x = tonumber(_array[1] or 0);
    self.y = tonumber(_array[2] or 0);
    self.z = tonumber(_array[3] or 0);
	return self;
end

function Position:ToVector3()
	return Vector3.New(self.x, self.y, self.z);
end

return Position;