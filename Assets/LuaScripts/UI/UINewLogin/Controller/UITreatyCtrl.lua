--[[
-- added by ricashao @ 2020-04-05
-- UITreatyCtrl控制层
--]]

local UITreatyCtrl = BaseClass("UITreatyCtrl", UIBaseCtrl)

local function CloseSelf(self)
    UIManager:GetInstance():CloseWindow(UIWindowNames.UITreaty)
end

UITreatyCtrl.CloseSelf = CloseSelf

return UITreatyCtrl