local Object = require "Framework.Object";
TouchAgent = Class("TouchAgent", Object);
local M = TouchAgent;
local screenTouchAgent = nil;
local mosueUpState = false;
local rayHit = nil;
local player = nil;


function M.SetScreenTouch(screenTouch)
	screenTouchAgent = screenTouch;
end

function M.SetTouchCamera(camera)
	if screenTouchAgent then
		screenTouchAgent:SetRayCamera(camera);
	end
end

function M.SetTouchButtonState(state)
	mosueUpState = state;
end

function M.OnTouchScreen(mousePosition)
	UIManager:GetInstance():OnTouch(mousePosition, mosueUpState);
end

function M.OnTouch(rayHits)

	----主界面在拖动UI
	if MainSceneViewSlipCtrl.InSceneViewDrag() then
		return
	end

	if M.CheckObj(rayHits) then
		return;
	end
	
	rayHit = M.GetRayHit(rayHits);
	if rayHit then
		player = CharacterManager:GetInstance():GetHostCharacter();
		if player then
			player:GetCharacterContext():Move(rayHit.point);
		end		
	end

	if BattleManager.GetIsBattle() == false then
		UIHitEffectManager:GetInstance():PlayEffect(rayHit);

		--防范性代码
		local mainScene = MainSceneViewCtrl:GetInstanceNotCreate();
		if mainScene and mainScene:IsSlipOut() then
			mainScene:SlipIn();
		end
	end
end

function M.GetRayHit(rayHits)
	if rayHits == nil then
		return;
	end

	local bestPointIndex = 0;
	local bestPointY = rayHits[0].point.y;
	for i = 1, (rayHits.Length -1) do
		if (rayHits[i].point.y) > bestPointY then
			bestPointY = rayHits[i].point.y;
			bestPointIndex = i;
		end 
	end

	return rayHits[bestPointIndex];

end

function M.CheckObj(rayHits)
	if not rayHits then
		return;
	end

	local hit, character, objInstanceID, hitTransform;

	for i = 0, (rayHits.Length -1) do
		hit = rayHits[i];
		if hit and hit.transform then
			objInstanceID = hit.transform.gameObject:GetInstanceID();
			hitTransform  = CharacterManager:GetInstance():CheckCharacter(objInstanceID);

			if hitTransform then
				character = hitTransform;
				if character:GetType() == CHARACTER_TYPE.NPC then
					break;
				end
			end
		end
	end

	local curScene = SceneManager:GetInstance():GetCurScene();
	if not curScene then
		return false;
	end

	if character then
		curScene:OnSelectedCharacter(character);
		return true;
	else
		curScene:OnSelectedCharacter(nil);
		return false;
	end

end

return M;