require "Framework.Class";
require "Utils.TableUtil";

require "Framework.JsonconfigManager";
require "UI.CommMsgTip.CommMsgMgr";
require "LocalSave.LocalSaveManager";
require "UI.UIManager";
require "Scene.SceneManager";
require "Framework.TickerManager";
require "Framework.TouchProxy";
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
    --初始化配置
    JsonConfigManager:GetInstance():Initialize("ConfigJson/", "ConfigBin/")
    -- 初始化UI管理器
    UIManager:GetInstance();
    --初始化时间管理器
    TickerManager:GetInstance();
    --打开登录面板
    LoginUICtrl:GetInstance():Show();
    --TickerManager:GetInstance():AddTicker(GSystem);

end

-- 设置不被销毁的节点
function GameMain.InitDontDestroyOnLoadList()
    if GameMain.BattlerCamera == nil then
        GameMain.BattlerCamera = GameObject.Find("BattlerCamera");
    end
    if GameMain.BattleBg == nil then
        GameMain.BattleBg = GameObject.Find("BattleBg");
    end
    if GameMain.gameMain == nil then
        GameMain.gameMain = GameObject.Find("GameMain");
    end
    if GameMain.Camera == nil then
        GameMain.Camera = GameObject.Find("Camera");
    end
    if GameMain.Root == nil then
        GameMain.Root = GameObject.Find("Root");
    end
    if GameMain.EventSystem == nil then
        GameMain.EventSystem = GameObject.Find("EventSystem");
    end
    if GameMain.Effects == nil then
        GameMain.Effects = GameObject.Find("Effects");
    end
    if GameMain.UICamera == nil then
        GameMain.UICamera = GameObject.Find("BattlerNameCamera");
    end
end

function GameMain.Tick(delta)
    if TickerManager:GetInstanceNotCreate() then
        TickerManager:GetInstanceNotCreate():Tick(delta);
    end
end
return GameMain;