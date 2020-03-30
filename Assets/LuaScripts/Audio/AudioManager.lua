---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/3/29 23:13
---
local AudioManager = BaseClass("AudioManager", Singleton)
local audio_type = typeof(CS.UnityEngine.AudioClip)

local curAudioFile = ""
local oldAudioFile = ""

local function __init(self)
    self:InitUICfg()
    self:InitBgmObj()
end



local function InitUICfg(self)

end

local function CheckIfPlayOld(self, fileName)

    if (fileName == oldAudioFile) then
        local tmp = oldBgAs;
        oldBgAs = curBgAs
        curBgAs = tmp
        curBgAs.volume = 0
        curBgAs.UnPause()
        return true
    end
    return false
end

local function InitBgmObj(self)
    local go = CS.UnityEngine.GameObject.Find("BGM")
    CS.UnityEngine.Object.DontDestroyOnLoad(go)
    self.curBgAs = CS.UnityEngine.GameObject.Find("BGMA"):GetComponent(typeof(CS.UnityEngine.AudioSource))
    self.oldBgAs = CS.UnityEngine.GameObject.Find("BGMB"):GetComponent(typeof(CS.UnityEngine.AudioSource))
end



-- 异步加载audioclip：回调方式
local function LoadAudioClipAsync(self, audio_path, callback, ...)

    ResourcesManager:GetInstance():LoadAsync(audio_path, audio_type, function(audio, ...)
        if callback then
            callback(not IsNull(audio) and audio or nil, ...)
        end
    end, ...)
end

-- 从异步加载audioclip：协程方式
local function CoLoadAudioAsync(self, audio_path, progress_callback)
    local audio = ResourcesManager:GetInstance():CoLoadAsync(audio_path, audio_type, progress_callback)
    return not IsNull(audio) and audio or nil
end

local function CoChangeBgm(self, audioFile)
    while (self.curBgAs.volume > 0)
    do
        self.curBgAs.volume = self.curBgAs.volume - 0.01
        coroutine.waitforframes(1)
    end
    self.curBgAs:Pause()
    if (not self:CheckIfPlayOld(audioFile)) then
        self.oldBgAs = self.curBgAs
        coroutine.waitforasyncop(self:CoLoadAudioAsync(audioFile,function (audioClip)
            self.curBgAs.clip = audioClip
        end))
        self.curBgAs.volume = 0
        self.curBgAs.Play();
    end

    while (self.curBgAs.volume < 1)
    do
        self.curBgAs.volume = self.curBgAs.volume + 0.01
        coroutine.waitforframes(1)
    end
end



local function PlayBg(self, newAudioFile)
    if newAudioFile == curAudioFile then
        return
    end

    if (curAudioFile == "" and oldAudioFile == "") then
        self:LoadAudioClipAsync(newAudioFile, function(audioClip)
            self.curBgAs.clip = audioClip
            self.curBgAs:Play()
        end)
    else
        coroutine.start(CoChangeBgm, self, newAudioFile)
    end
    oldAudioFile = curAudioFile
    curAudioFile = newAudioFile

end

AudioManager.__init = __init
AudioManager.InitUICfg = InitUICfg
AudioManager.InitBgmObj = InitBgmObj
AudioManager.PlayBg = PlayBg
AudioManager.LoadAudioClipAsync = LoadAudioClipAsync
AudioManager.CoLoadAudioAsync = CoLoadAudioAsync
AudioManager.CoChangeBgm = CoChangeBgm
AudioManager.CheckIfPlayOld = CheckIfPlayOld

return AudioManager
