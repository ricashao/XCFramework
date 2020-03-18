----本地存储管理

LocalStorage = {}
local PlayerPrefs = CS.UnityEngine.PlayerPrefs

function LocalStorage.Get(key)

	if LocalStorage.HasKey(key) then
		return PlayerPrefs.GetString(key)
	end
	return nil
end 

function LocalStorage.Put(key, value)

	if not key then return end

	if LocalStorage.HasKey(key) then
		if info then info("override storage" .. key) end
	end

	if value then
		PlayerPrefs.SetString(key, value)
		PlayerPrefs.Save()
	end
end

function LocalStorage.HasKey(key)

	if not key then return false end

	return PlayerPrefs.HasKey(key)
end

function LocalStorage.Remove(key)

	if not key then return end

	if LocalStorage.HasKey(key) then
		PlayerPrefs.DeleteKey(key)
	end
end

function LocalStorage.Clear()

	PlayerPrefs.DeleteAll()
end

return LocalStorage