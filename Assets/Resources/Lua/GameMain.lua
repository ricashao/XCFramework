require "Framework.Class";


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
end

return GameMain;