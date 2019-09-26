using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XLua;

/// <summary>
/// lua管理器
/// </summary>
public class LuaScriptMgr
{
    public static LuaScriptMgr Instance { get; private set; }


    public LuaEnv lua;
    private HashSet<string> fileList = null;
    private Dictionary<string, LuaBase> dict = null;
    LuaFunction updateFunc = null;
    LuaFunction lateUpdateFunc = null;
    LuaFunction fixedUpdateFunc = null;
    LuaFunction levelLoaded = null;

    LuaFunction unpackVec3 = null;
    LuaFunction unpackVec2 = null;
    LuaFunction unpackVec4 = null;
    LuaFunction unpackQuat = null;
    LuaFunction unpackColor = null;
    LuaFunction unpackRay = null;

    LuaFunction packVec3 = null;
    LuaFunction packVec2 = null;
    LuaFunction packVec4 = null;
    LuaFunction packQuat = null;
    LuaFunction packTouch = null;
    LuaFunction packRay = null;
    LuaFunction packRaycastHit = null;
    LuaFunction packColor = null;


    public static ObjectTranslator _translator = null;


    string luaIndex =
        @"        
        local rawget = rawget
        local rawset = rawset
        local getmetatable = getmetatable      
        local type = type  
        local function index(obj,name)  
            local o = obj            
            local meta = getmetatable(o)            
            local parent = meta
            local v = nil
            
            while meta~= nil do
                v = rawget(meta, name)
                
                if v~= nil then
                    if parent ~= meta then rawset(parent, name, v) end

                    local t = type(v)

                    if t == 'function' then                    
                        return v
                    elseif t == 'table' then
                        local func = v[1]
                
                        if func ~= nil then
                            return func(obj, name)                         
                        end
                    end

                    break
                end
                
                meta = rawget(meta, 'base')
            end

           error('unknown member name '..name, 2)
           return nil	        
        end
        return index";

    string luaNewIndex =
        @"
        local rawget = rawget
        local getmetatable = getmetatable   
        local rawset = rawset     
        local function newindex(obj, name, val)           
            local meta = getmetatable(obj)            
            local parent = meta
            local v = nil
            
            while meta~= nil do
                v = rawget(meta, name)    
            
                if v~= nil then
                    local func = v[2]
                    
                    if func ~= nil then                        
                        return func(obj, name, val)                        
                    end             
                    break       
                end                
                meta = rawget(meta, 'base')                       
            end 
       
            error('field or property '..name..' does not exist', 2)
            return nil		
        end
        return newindex";

    string luaTableCall =
        @"
        local rawget = rawget
        local getmetatable = getmetatable     

        local function call(obj, ...)
            local meta = getmetatable(obj)
            local fun = rawget(meta, 'New')
            
            if fun ~= nil then
                return fun(...)
            else
                error('unknow function __call',2)
            end
        end

        return call
    ";

    string luaEnumIndex =
        @"
        local rawget = rawget                
        local getmetatable = getmetatable         

        local function indexEnum(obj,name)
            local v = rawget(obj, name)
            
            if v ~= nil then
                return v
            end

            local meta = getmetatable(obj)  
            local func = rawget(meta, name)            
            
            if func ~= nil then
                v = func()
                rawset(obj, name, v)
                return v
            else
                error('field '..name..' does not exist', 2)
            end
        end

        return indexEnum
    ";

    public LuaScriptMgr()
    {
        Instance = this;
        lua = new LuaEnv();
        lua.AddLoader(Loader);
    }

    public byte[] Loader(ref string name)
    {
        byte[] str = null;

#if UNITY_EDITOR
        string path = Application.dataPath + "/Resources/Lua/" + name;
        if (!File.Exists(path))
        {
//            name = name.Substring(0, name.IndexOf("."));
            path = Application.dataPath + "/Resources/Lua/" + name + ".txt";
        }

        str = File.ReadAllBytes(path);
#else
        
#endif
        return str;
    }
}