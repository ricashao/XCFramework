local Object = require "Framework.Object";
local Event = Class("Event", Object);

function Event:Ctor(eType, eData)
	Object.Ctor(self);
	self.eType = eType;
	self.eData = eData;
end	

return Event