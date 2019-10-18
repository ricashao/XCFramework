
--类型
CommMsgType = {};
CommMsgType.TextTip = 1;		--文字（半透）提示框
CommMsgType.DoubleTip = 5;		--双项（单项）
CommMsgType.BoardTip = 4;		--公告（底部）
CommMsgType.BoardTip1 = 15;		--公告（底部）
CommMsgType.ShowInChatTip = 9; 	--部分透明提示||
CommMsgType.TeamTip = 7;		--队伍公告
CommMsgType.FactionTip = 13;	--帮派公告

CloseSign = {}
CloseSign.NoCloseTime = 0;--无
CloseSign.LeftClose = 1; --左按钮加入倒计时（一个按钮默认）
CloseSign.RightClose = 2;--右按钮加入倒计时

CloseAutoSelect = {}
CloseAutoSelect.NoAuto = 0; --无
CloseAutoSelect.AutoLeft = 1; --倒计时结束默认选择左侧按钮
CloseAutoSelect.AutoRight = 2; --倒计时结束默认选择右侧按钮

