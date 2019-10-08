using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using UnityEngine;
using XLua;
using XLua.LuaDLL;

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

    public static ObjectTranslator _translator = null;


   
    public LuaScriptMgr()
    {
        Instance = this;
        lua = new LuaEnv();
        lua.AddLoader(Loader);
        _translator = lua.translator;
        //todo 第三库初始化


        fileList = new HashSet<string>();
        dict = new Dictionary<string, LuaBase>();


        Lua.lua_pushnumber(lua.L, 0);
        Lua.xlua_setglobal(lua.L, "_LuaScriptMgr");
    }

    public byte[] Loader(ref string name)
    {
        byte[] str = null;

#if UNITY_EDITOR
        name = name.Replace('.', '/');
        string path = Application.dataPath + "/Resources/Lua/" + name;
        if (!File.Exists(path))
        {
//            name = name.Substring(0, name.IndexOf("."));
            path = Application.dataPath + "/Resources/Lua/" + name + ".lua";
        }

        str = File.ReadAllBytes(path);
#else
#endif
        return str;
    }


    public void Start()
    {
        OnBundleLoaded();
    }

    void OnBundleLoaded()
    {
//        DoFile("Global/Global");
        
    }
    
    
    public void OnLevelLoaded(int level)
    {
        levelLoaded.Call(level);
    }

    public void Update()
    {
        if (updateFunc != null)
        {
            updateFunc.Call(Time.deltaTime);
        }
        
        //if (LuaDLL.lua_gettop(lua.L) != 0)
        //{
        //    Debugger.Log("stack top {0}", LuaDLL.lua_gettop(lua.L));
        //}
    }

    public void LateUpate()
    {
        if (lateUpdateFunc != null)
        {
            lateUpdateFunc.Call();
        }        
    }

    public void FixedUpdate()
    {
        if (fixedUpdateFunc != null)
        {
            fixedUpdateFunc.Call(Time.fixedDeltaTime);            
        }
    }
    
    void SafeRelease(ref LuaFunction func)
    {
        if (func != null)
        {
            func.Dispose();
            func = null;
        }
    }
    
    
    public void Destroy()
    {        
        Instance = null;        
       
        SafeRelease(ref updateFunc);
        SafeRelease(ref lateUpdateFunc);
        SafeRelease(ref fixedUpdateFunc);       

        Lua.lua_gc(lua.L, LuaGCOptions.LUA_GCCOLLECT, 0);

        foreach(KeyValuePair<string, LuaBase> kv in dict)
        {
            kv.Value.Dispose();
        }        

        //foreach(KeyValuePair<string, IAssetFile> kv in dictBundle)
        //{
        //    kv.Value.Close();
        //}
        
        dict.Clear();
        fileList.Clear();
        
        
        lua.Dispose();
        lua = null;

        Debugger.Log("Lua module destroy");        
    }
    
    public object[] DoString(string str)
    {
        return lua.DoString(str);
    }


    public object[] CallLuaFunction(string name, params object[] args)
    {
        LuaBase lb = null;

        if (dict.TryGetValue(name, out lb))
        {
            LuaFunction func = lb as LuaFunction;
            return func.Call(args);
        }
        else
        {
            IntPtr L = lua.L;
            LuaFunction func = null;
            int oldTop = Lua.lua_gettop(L);

            if (PushLuaFunction(L, name))
            {
                int reference = Lua.luaL_ref(L, LuaIndexes.LUA_REGISTRYINDEX);
                func = new LuaFunction(reference, lua);
                Lua.lua_settop(L, oldTop);
                object[] objs = func.Call(args);
                func.Dispose();
                return objs;            
            }

            return null;
        }        
    }
    
    public bool IsFuncExists(string name)
    {
        IntPtr L = lua.L;
        int oldTop = Lua.lua_gettop(L);

        if (PushLuaFunction(L, name))
        {
            Lua.lua_settop(L, oldTop);
            return true;
        }

        return false;
    }

    
    //会缓存LuaFunction
    public LuaFunction GetLuaFunction(string name)
    {
        LuaBase func = null;

        if (!dict.TryGetValue(name, out func))
        {
            IntPtr L = lua.L;
            int oldTop = Lua.lua_gettop(L);

            if (PushLuaFunction(L, name))
            {
                int reference = Lua.luaL_ref(L, LuaIndexes.LUA_REGISTRYINDEX);
                func = new LuaFunction(reference, lua);                
//                func.name = name;
                dict.Add(name, func);
            }
            else
            {
                Debugger.LogWarning("Lua function {0} not exists", name);
            }

            Lua.lua_settop(L, oldTop);            
        }

        return func as LuaFunction;
    }
    
    static bool PushLuaFunction(IntPtr L, string fullPath)
    {
        int oldTop = Lua.lua_gettop(L);
        int pos = fullPath.LastIndexOf('.');

        if (pos > 0)
        {
            string tableName = fullPath.Substring(0, pos);

            var pushResult = PushLuaTable(L, tableName);
            if (pushResult)
            {
                string funcName = fullPath.Substring(pos + 1);
                Lua.lua_pushstring(L, funcName);
                Lua.lua_rawget(L, -2);
            }

            LuaTypes type = Lua.lua_type(L, -1);

            if (type != LuaTypes.LUA_TFUNCTION)
            {
                Lua.lua_settop(L, oldTop);
                return false;
            }

#if UNITY_EDITOR
            if (!pushResult)
            {
                ThrowLuaException(L);
            }
            else
            {
#endif
                Lua.lua_insert(L, oldTop + 1);
                Lua.lua_settop(L, oldTop + 1);
#if UNITY_EDITOR
            }
#endif
        }
        else
        {
            Lua.xlua_getglobal(L, fullPath);
            LuaTypes type = Lua.lua_type(L, -1);

            if (type != LuaTypes.LUA_TFUNCTION)
            {
                Lua.lua_settop(L, oldTop);
                return false;
            }
        }

        return true;
    }
    
    public static void ThrowLuaException(IntPtr L)
    {
        string err = Lua.lua_tostring(L, -1);        
        if (err == null) err = "Unknown Lua Error";
        throw new LuaException(err.ToString());    
    }

   
    
    static bool PushLuaTable(IntPtr L, string fullPath)
    {        
        string[] path = fullPath.Split(new char[] { '.' });
        int oldTop = Lua.lua_gettop(L);
        Lua.xlua_getglobal(L, path[0]);

        LuaTypes type = Lua.lua_type(L, -1);

        if (type != LuaTypes.LUA_TTABLE)
        {
            Lua.lua_settop(L, oldTop);
            Debugger.LogError("Push lua table {0} failed", path[0]);
            return false;
        }

        for (int i = 1; i < path.Length; i++)
        {
            Lua.lua_pushstring(L, path[i]);
            Lua.lua_rawget(L, -2);
            type = Lua.lua_type(L, -1);

            if (type != LuaTypes.LUA_TTABLE)
            {
                Lua.lua_settop(L, oldTop);
                Debugger.LogError("Push lua table {0} failed", fullPath);
                return false;
            }
        }

        if (path.Length > 1)
        {
            Lua.lua_insert(L, oldTop + 1);
            Lua.lua_settop(L, oldTop + 1);
        }

        return true;
    }
    
    public LuaTable GetLuaTable(string tableName)
    {
        LuaBase lt = null;

        if (!dict.TryGetValue(tableName, out lt))
        {            
            IntPtr L = lua.L;
            int oldTop = Lua.lua_gettop(L);

            if (PushLuaTable(L, tableName))
            {
                int reference = Lua.luaL_ref(L, LuaIndexes.LUA_REGISTRYINDEX);
                lt = new LuaTable(reference, lua);
                dict.Add(tableName, lt);           
            }

            Lua.lua_settop(L, oldTop);             
        }
        return lt as LuaTable;
    }

    public void RemoveLuaRes(string name)
    {
        dict.Remove(name);
    }
    
    static void CreateTable(IntPtr L, string fullPath)
    {        
        string[] path = fullPath.Split(new char[] { '.' });
        int oldTop = Lua.lua_gettop(L);

        if (path.Length > 1)
        {            
            Lua.xlua_getglobal(L, path[0]);
            LuaTypes type = Lua.lua_type(L, -1);

            if (type == LuaTypes.LUA_TNIL)
            {
                Lua.lua_pop(L, 1);
                Lua.lua_createtable(L, 0, 0);
                Lua.lua_pushstring(L, path[0]);
                Lua.lua_pushvalue(L, -2);
                Lua.xlua_psettable(L, -10002);
            }

            for (int i = 1; i < path.Length - 1; i++)
            {
                Lua.lua_pushstring(L, path[i]);
                Lua.lua_rawget(L, -2);

                type = Lua.lua_type(L, -1);

                if (type == LuaTypes.LUA_TNIL)
                {
                    Lua.lua_pop(L, 1);
                    Lua.lua_createtable(L, 0, 0);
                    Lua.lua_pushstring(L, path[i]);
                    Lua.lua_pushvalue(L, -2);
                    Lua.lua_rawset(L, -4);
                }
            }

            Lua.lua_pushstring(L, path[path.Length - 1]);
            Lua.lua_rawget(L, -2);

            type = Lua.lua_type(L, -1);

            if (type == LuaTypes.LUA_TNIL)
            {
                Lua.lua_pop(L, 1);
                Lua.lua_createtable(L, 0, 0);
                Lua.lua_pushstring(L, path[path.Length - 1]);
                Lua.lua_pushvalue(L, -2);           
                Lua.lua_rawset(L, -4);
            }            
        }
        else
        {
            Lua.xlua_getglobal(L, path[0]);
            LuaTypes type = Lua.lua_type(L, -1);

            if (type == LuaTypes.LUA_TNIL)
            {
                Lua.lua_pop(L, 1);
                Lua.lua_createtable(L, 0, 0);
                Lua.lua_pushstring(L, path[0]);
                Lua.lua_pushvalue(L, -2);                
                Lua.xlua_psettable(L, -10002);
            }
        }

        Lua.lua_insert(L, oldTop + 1);
        Lua.lua_settop(L, oldTop + 1);
    }




    public object[] DoFile(string fileName)
    {
        if (!fileList.Contains(fileName))
        {
            return lua.DoString(string.Format("require \"{0}\"",fileName) , null);
        }

        return null;
    }
}