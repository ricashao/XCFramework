require "Framework.Class"
Object = Class("Object")

function Object:Clone()
	return Clone(self);
end

return Object  	