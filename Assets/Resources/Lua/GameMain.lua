require "Framework.Class";


require "UI.UIManager";
require "Scene.SceneManager";
require "Framework.TickerManager";
require "UI.Login.SkinCtrl.LoginUICtrl";
GameMain = {};

function GameMain.Awake()
	--C#端调用
	print("game awake")
end

function GameMain.Start()
	GameMain.InitDontDestroyOnLoadList();
end

--登陆游戏
function GameMain.LoginGame()
	--游戏开始
	print("game start")
	-- 初始化UI管理器
	UIManager:GetInstance();
	TickerManager:GetInstance();
	LoginUICtrl:GetInstance():Show();
	
end


function GameMain.InitDontDestroyOnLoadList()
	if GameMain.BattlerCamera == nil then GameMain.BattlerCamera = GameObject.Find("BattlerCamera"); end
	if GameMain.BattleBg == nil then GameMain.BattleBg = GameObject.Find("BattleBg"); end
	if GameMain.gameMain == nil then GameMain.gameMain = GameObject.Find("GameMain"); end
	if GameMain.Camera == nil then GameMain.Camera = GameObject.Find("Camera"); end
	if GameMain.Root == nil then GameMain.Root = GameObject.Find("Root"); end
	if GameMain.EventSystem == nil then GameMain.EventSystem = GameObject.Find("EventSystem"); end
	if GameMain.Effects == nil then GameMain.Effects = GameObject.Find("Effects"); end
	if GameMain.UICamera == nil then GameMain.UICamera = GameObject.Find("BattlerNameCamera"); end
end

return GameMain;