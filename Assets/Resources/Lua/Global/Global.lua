--[[szc
require "Global.Common.Math"
require "Global.Common.Layer"
require "Global.Common.List"
require "Global.Common.Event"
require "Global.Common.Quaternion"
require "Global.Common.Vector4"
require "Global.Common.Raycast"
require "Global.Common.Color"
require "Global.Common.Touch"
require "Global.Common.Ray"
require "Global.Common.Coroutine"
]]
require "Global.Common.Vector2"
require "Global.Common.Vector3"

--luanet.load_assembly("UnityEngine")

--废弃 以后直接用 System.Object 不需要在前面写个别名
----------------------------------------------------
object			= CS.System.Object
Type			= CS.System.Type
Object          = CS.UnityEngine.Object
GameObject 		= CS.UnityEngine.GameObject
Transform 		= CS.UnityEngine.Transform
MonoBehaviour 	= CS.UnityEngine.MonoBehaviour
Component		= CS.UnityEngine.Component
Application		= CS.UnityEngine.Application
SystemInfo		= CS.UnityEngine.SystemInfo
Screen			= CS.UnityEngine.Screen
Camera			= CS.UnityEngine.Camera
Light 			= CS.UnityEngine.Light
Material 		= CS.UnityEngine.Material
Renderer 		= CS.UnityEngine.Renderer
AsyncOperation	= CS.UnityEngine.AsyncOperation

CharacterController = CS.UnityEngine.CharacterController
SkinnedMeshRenderer = CS.UnityEngine.SkinnedMeshRenderer
Animation		= CS.UnityEngine.Animation
AnimationClip	= CS.UnityEngine.AnimationClip
AnimationEvent	= CS.UnityEngine.AnimationEvent
AnimationState	= CS.UnityEngine.AnimationState
Input			= CS.UnityEngine.Input
KeyCode			= CS.UnityEngine.KeyCode
AudioClip		= CS.UnityEngine.AudioClip
AudioSource		= CS.UnityEngine.AudioSource
Physics			= CS.UnityEngine.Physics
Light			= CS.UnityEngine.Light
LightType		= CS.UnityEngine.LightType
ParticleEmitter	= CS.UnityEngine.ParticleEmitter
Space			= CS.UnityEngine.Space
CameraClearFlags= CS.UnityEngine.CameraClearFlags
RenderSettings  = CS.UnityEngine.RenderSettings
MeshRenderer	= CS.UnityEngine.MeshRenderer
WrapMode		= CS.UnityEngine.WrapMode
QueueMode		= CS.UnityEngine.QueueMode
PlayMode		= CS.UnityEngine.PlayMode
ParticleAnimator= CS.UnityEngine.ParticleAnimator
TouchPhase 		= CS.UnityEngine.TouchPhase
AnimationBlendMode = CS.UnityEngine.AnimationBlendMode
Animator 		= CS.UnityEngine.Animator
UIText 			= CS.UnityEngine.UI.Text
NavMeshAgent 	= CS.UnityEngine.NavMeshAgent
RectTransform 	= CS.UnityEngine.RectTransform
UnityTime 		= CS.UnityEngine.Time
Sprite 			= CS.UnityEngine.Sprite
RenderTexture   = CS.UnityEngine.RenderTexture
Screen			= CS.UnityEngine.Screen
Rect 			= CS.UnityEngine.Rect
Texture 		= CS.UnityEngine.Texture
Texture2D 		= CS.UnityEngine.Texture2D
TextureFormat	= CS.UnityEngine.TextureFormat
Plane 			= CS.UnityEngine.Plane
Shader 			= CS.UnityEngine.Shader
GridLayoutGroup = CS.UnityEngine.UI.GridLayoutGroup

-- File IO Mode
Resources 		= CS.UnityEngine.Resources
FileStream 		= CS.System.IO.FileStream
StreamReader 	= CS.System.IO.StreamReader
FileMode 		= CS.System.IO.FileMode
File 			= CS.System.IO.File
XMLUtil 		= CS.ConfigData.XMLUtil
XmlDocument 	= CS.System.Xml.XmlDocument
XmlNode 		= CS.System.Xml.XmlNode
XmlNodeList 	= CS.System.Xml.XmlNodeList

-- CommonPalette
CommonPalette  = CS.CheapUtil.CommonPalette 

---- DOTween
DOTween 		= CS.DG.Tweening.DOTween
ShortcutExtensions = CS.DG.Tweening.ShortcutExtensions
TweenSettingsExtensions = CS.DG.Tweening.TweenSettingsExtensions

PrefabPool = CS.CheapUtil.PrefabPool
ioo = CS.ioo
AssetManager = CS.AssetManager
CanvasScaler =CS.UnityEngine.UI.CanvasScaler
----------------------------------------------------

function traceback(msg)
	local msg = debug.traceback(msg, 2)
	return msg
end

