--[[

	使用方法：
		创建：local model = UIModelCtrl:Create("Archer", "Artres/Actor/Archer", self.m_pSkin.m_pBg2, 500, 400)
		销毁：model:Destroy()

]]
require "Utils.TableUtil"
local Object = require "Framework.Object"
local UIModelCtrl = Class("UIModelCtrl", Object)

UIModelCtrl.ObjectPool = {}
local objOffsetY = 0

--///////////======调用的接口======/////////////////
---public
function UIModelCtrl:Destroy()
	
	if self.loader then
		self.loader:Destroy()
		self.loader = nil
	end

	if self.mModel then
		GameObject.Destroy(self.mModel)
		self.mModel = nil
	end
	if self.mHolder then
		UIModelCtrl.ReturnObj(self.mHolder)
		self.mHolder = nil
	end

	if self.mRenderTexture then
		GameObject.Destroy(self.mRenderTexture)
		self.mRenderTexture = nil
	end
	self.modelOffset = nil
	self.effectPath  = nil
end

function UIModelCtrl:Show()
	if self.mHolder then
		self.mHolder:SetActive(true)
	end
end

function UIModelCtrl:Hide()
	if self.mHolder then
		self.mHolder:SetActive(false)
	end
end

----public 加入一个偏移量，方便同一个ui需要显示多个
function UIModelCtrl:CreateModel(modelname, path, rawImage, width, height, 
									antiAliasing, cameraOffset, modelOffset, cameraRotation)
	
	----创建一个容器挂载：摄像机，3d模型
	local obj = UIModelCtrl.GetModelFromPool()
	self.mHolder = obj
	obj.transform:SetParent(GameLayerManager.trdModelSite.transform, false)
	

	obj.name = "CameraObj"

	---- 设置摄像机
	local c = obj.transform:Find("cameraH")
	self.mCamera = c:GetComponent("Camera")
	self.mCamera.clearFlags = CameraClearFlags.SolidColor
	self.mCamera.farClipPlane = 4
	self.mCamera.fieldOfView = 60
	-- self.mCamera.backgroundColor = Color.New(49,77,121,0)
	self.mCamera.cullingMask =  BitOperator.lMove(1, SceneLayer.Character) +  BitOperator.lMove(1, SceneLayer.Effect);
	---- 设置灯光
	self.mLight = obj:GetComponent("Light")
	self.mLight.intensity = 3.6
	self.mLight.bounceIntensity = 0

	---- 设置rendertexture
	if rawImage then
		local texture = CS.UnityEngine.RenderTexture(width or 400, height or 400, 1)
		texture.antiAliasing = antiAliasing or 4
		self.mCamera.targetTexture = texture
		rawImage.texture = texture
		self.mRenderTexture = texture
		rawImage.gameObject:SetActive(false)
	end
	self.rawImage = rawImage

	----设置相机位置 
	self.mCamera.transform.localPosition = cameraOffset or Vector3.New(-0.04, 100.64, -0.29)
	---- 设置相机的旋转
	self.mCamera.transform.rotation = cameraRotation or Quaternion.Euler(22, 180, 358)
	
	self.modelOffset = modelOffset;
	--- 开始加载模型
	self:LoadModel(modelname, path)

	return self
end

--///////////////========以下下方法不需要关注======////////////////////////////////
----public:
function UIModelCtrl.DestroyPool()
	for _, v in pairs(UIModelCtrl.ObjectPool) do
		if v then
			GameObject.Destroy(v)
		end
	end
	UIModelCtrl.ObjectPool = {}
end

---protected
function UIModelCtrl:Ctor( ... )
	self.mCamera = nil
	self.mRenderTexture = nil
	self.mModel = nil
	self.modelOffset = nil;
end

function UIModelCtrl:LoadModel(modelname, path)
	if self.loader then
		self.loader:Destroy()
	end
	self.loader = AsynPrefabLoader.New()
	self.loader:Load(path .. "/" .. modelname .. ".ga", self.ModelLoadEnd, nil, self)
end

function UIModelCtrl:ModelLoadEnd(path, pfb)
	
	self.mModel = pfb
	self.mModel.transform:SetParent(self.mHolder.transform)
	self.mModel.transform.localPosition = (self.modelOffset) or Vector3.New(0, 99, -2.23)
	self.mModel:SetActive(true)
	if self.rawImage then
		self.rawImage.gameObject:SetActive(true)
	end
	----保证模型不叠加
	objOffsetY = objOffsetY + 1
	if objOffsetY > 50 then
		objOffsetY = 0
	end
	self.mHolder.transform.localPosition = Vector3.New(0, objOffsetY * 100, 0)

	if self.effectPath then
		SpriteManager:GetInstance():CreateSimple(self.effectPath, self.mModel.transform)
	end

end

function UIModelCtrl:AddEffectModel(effectName, effectPath)
	if (not effectName) or (not effectPath) then
		self.effectPath = nil
		return
	end

	local nameLen = string.len(effectName)
	local pathLen = string.len(effectPath)

	if (nameLen <= 0) or (pathLen <= 0) then
		self.effectPath = nil
		return
	end

	self.effectPath = effectPath .. "/" .. effectName

end

function UIModelCtrl:UpdateLayer(pfb, layer)
	if (not pfb) or (not layer) then
		return
	end
	pfb.layer = layer
	local components = pfb:GetComponentsInChildren(Transform.GetClassType())
	local length = components.Length - 1
	for i=0, length do
		components[i].gameObject.layer = layer
	end
end


function UIModelCtrl.GetModelFromPool()
	local obj
	if TableUtil.TableLength(UIModelCtrl.ObjectPool) > 0 then
		for k, v in pairs(UIModelCtrl.ObjectPool) do
			if v then
				obj = v
				obj:SetActive(true)
				UIModelCtrl.ObjectPool[k] = nil
				break
			end
		end
	else
		obj = GameObject()
		---- 添加摄像机
		local c = GameObject()
		c.name = "cameraH"
		c:AddComponent(typeof(Camera))
		c.transform:SetParent(obj.transform)

		---- 添加灯光
		obj:AddComponent(typeof(Light))
	end
	return obj
end

----private:
function UIModelCtrl.ReturnObj( obj )
	if obj then
		obj:SetActive(false)
		table.insert(UIModelCtrl.ObjectPool, obj)
	end
		
end

return UIModelCtrl