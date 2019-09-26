require "Framework.Object"

--事件、监听及触发
--功能：
--New 新建一个事件
--Add 添加一个事件监听，可以是类的静态函数，也可以是实例的某个成员函数（注意类和实例都是模拟的），参数可选
--Has 查询一个或多个事件监听，用实例或者函数为索引
--Del 删除一个或多个事件监听，用实例或者函数为索引删除
--Bingo 触发一个事件上的所有监听，参数可选，汇总返回监听函数的执行结果

BroadcastEvent = Class("BroadcastEvent",Object);
local M = BroadcastEvent;

function M:Ctor()
    self.static_funcs = {}
    --setmetatable(e.static_funcs,{__mode="v"}) --weak value table
    self.object_funcs = {}
    --setmetatable(e.object_funcs,{__mode="k"}) --weak key table
end

--- func is necessary
--- if func is static, object can be nil; if use self, object is necessary
--- userdata is optional
function M:Add(func, object, userdata)
    if not func then
        return
    end
    local objectfuncs
    if not object then
        objectfuncs = self.static_funcs;
    else
        self.object_funcs[object] = self.object_funcs[object] or {};
        objectfuncs = self.object_funcs[object];
    end
    objectfuncs[func] = userdata or {};
end

--- func nil, object nil, error return false
--- func not nil, object nil, return static func exist
--- func nil, object not nil, return object has any func
--- func not nil, object not nil, return object's func exist
function M:Has(func, object)
    if not object and not func then
        return false;
    end
    local objectfuncs;
    if not object then
        objectfuncs = self.static_funcs
    else
        if not func then
            return self.object_funcs[object] ~= nil; --remove the object's all funcs
        else
            objectfuncs = self.object_funcs[object]
        end
    end
    if not objectfuncs then
        return false;
    end
    return objectfuncs[func] ~= nil;
end

--- func nil, object nil, error return false
--- func not nil, object nil, delete static func
--- func nil, object not nil, delete object's all funcs
--- func not nil, object not nil, delete object's func  
function M:Del(func, object)
    if not object and not func then
        return false;
    end
    local objectfuncs;
    if not object then
        objectfuncs = self.static_funcs
    else
        if not func then
            self.object_funcs[object] = nil; --remove the object's all funcs
            return true;
        else
            objectfuncs = self.object_funcs[object]
        end
    end
    if not objectfuncs then
        return false;
    end
    objectfuncs[func] = nil;
    return true;
end

--- fire events, parameter o is optional, return funcs results
function M:Bingo(o)
   local results = {};
   for func,userdata in pairs(self.static_funcs) do
        local r = func(o, userdata);
        if r then table.insert(results,r) end;
   end  
   for object,objectfuncs in pairs(self.object_funcs) do
        for func,userdata in pairs(objectfuncs) do
            local r = func(object, o, userdata);
            if r then table.insert(results,r) end;
        end
   end
   return results;
end

function M:Clean()
    
    self.static_funcs = {}
    self.object_funcs = {}
end

--- for example
local function EventTestListener(self)
    if self then
        -- print("test broadcast event with self")
    else
        -- print("test broadcast event")
    end  
end

local ExampleEvent = BroadcastEvent.New();
ExampleEvent:Add(EventTestListener);
ExampleEvent:Bingo();
if ExampleEvent:Has(EventTestListener) then
    ExampleEvent:Del(EventTestListener)
end

--只是个例子，不要把事件New在这里

return M;