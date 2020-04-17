local TweenTarget = BaseClass("TweenTarget")

local function __init(self, ui, props, key)

    self.ui = ui
    self.props = props
    self.key = key

    self.transform = ui.transform
    self.x = self.transform.localPosition.x
    self.y = self.transform.localPosition.y
    self.width = 0
    self.height = 0
    self.rtx = 0
    self.rty = 0
    self.psx = 0
    self.psy = 0
    self.psz = 0

    self.children = nil
    self.color = nil
    self.alpha = 0

    --[[
        拓展到RectTransfrom组件，可以考虑针对RectTransform组件单独设计一个缓动模块
        width/height：调整RectTransform的宽高（对于anchor不在中心点的对象，变化尺寸可能会跟预期的不同，尚未测试）
        rtx/rty：     调整RectTransform的位置（localPosition对于RectTransform组件并不适用，因为在不同分辨率的情况下，localPosition并不是固定的）
    --]]
    if props["width"] or props["height"] or props["rtx"] or props["rty"] then
        local rectTransform = ui.gameObject:GetComponent("RectTransform")
        if rectTransform then
            self.rectTransform = rectTransform
            self.width = rectTransform.sizeDelta.x
            self.height = rectTransform.sizeDelta.y

            if props["rtx"] or props["rty"] then
                self.rtx = rectTransform.anchoredPosition.x
                self.rty = rectTransform.anchoredPosition.y
            end
        end
    end
    if props["alpha"] then
        self.children = ui.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.UI.Graphic))
        if self.children[0] then
            local color = self.children[0].gameObject:GetComponent(typeof(UnityEngine.UI.Graphic)).color
            self.alpha = color.a
        end
    end

    if props["psx"] or props["psy"] then
        self.psx = self.transform.position.x
        self.psy = self.transform.position.y
        self.psz = self.transform.position.z
    end

end

local function SetProp(self, key, value)

    if key == "x" then
        self.ui.transform.localPosition = Vector3.New(value, self.y, 0)
        self.x = value
    elseif key == "y" then
        self.ui.transform.localPosition = Vector3.New(self.x, value, 0)
        self.y = value
    elseif key == "width" and self.rectTransform then
        self.height = self.rectTransform.sizeDelta.y
        self.rectTransform.sizeDelta = Vector2.New(value, self.height)
    elseif key == "height" and self.rectTransform then
        self.width = self.rectTransform.sizeDelta.x
        self.rectTransform.sizeDelta = Vector2.New(self.width, value)
    elseif key == "rtx" and self.rectTransform then
        self.rtx = self.rectTransform.anchoredPosition.x
        self.rectTransform.anchoredPosition = Vector2.New(value, self.rty)
    elseif key == "rty" and self.rectTransform then
        self.rty = self.rectTransform.anchoredPosition.y
        self.rectTransform.anchoredPosition = Vector2.New(self.rtx, value)
    elseif key == "psx" then
        self.transform.position = Vector3.New(value, self.psy, self.psz)
    elseif key == "psy" then
        self.transform.position = Vector3.New(self.psx, value, self.psz)
    elseif key == "alpha" then
        self.alpha = value
        self:SetAlpha()
    end
end

local function TweenEnd(self)

    ----校正数据
    for k, v in pairs(self.props) do
        self:SetProp(k, v)
    end
end

local function GetKey(self)
    return self.key
end

local function SetAlpha(self)
    if self.children then
        for i = 1, self.children.Length do
            local comp = self.children[i - 1]
            local color = Color.New(comp.color.r, comp.color.g, comp.color.b, self.alpha)
            comp.color = color
        end
    end
end

local function GetAlpha(self)
    return self.alpha
end

TweenTarget.__init = __init
TweenTarget.SetProp = SetProp
TweenTarget.TweenEnd = TweenEnd
TweenTarget.GetKey = GetKey
TweenTarget.SetAlpha = SetAlpha
TweenTarget.GetAlpha = GetAlpha
return TweenTarget