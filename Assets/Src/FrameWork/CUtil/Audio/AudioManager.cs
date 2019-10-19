using System.Collections;
using System.Collections.Generic;
using LitJson;
using UnityEngine;

public class AudioManager : ITickable
{
    private static AudioManager instance;

    public static AudioManager Instance
    {
        get
        {
            if (null == instance)
                instance = new AudioManager();
            return instance;
        }
    }

    private readonly List<AudioObj> rubbish = new List<AudioObj>(16);

    private readonly List<AudioObj> tmpObjs = new List<AudioObj>(8);

    private int checkTick;
    private string curAudioFile;
    private AudioSource curBgAs;
    private string oldAudioFile;
    private AudioSource oldBgAs;

    private JsonData uiJsonRootData;

    public AudioManager()
    {
        InitUiCfg();
        InitBGMObj();
    }

    public void PlayBg(string newFileName)
    {
        if (newFileName.Equals(curAudioFile))
            return;

        if (null == curAudioFile && null == oldAudioFile)
        {
            curBgAs.clip = PoolManager.GetResourceObject(newFileName, 5) as AudioClip;
            curBgAs.Play();
        }
        else
        {
            CoroutineManager.Instance.StartCoroutine(ChangeBgm(newFileName));
        }

        oldAudioFile = curAudioFile;
        curAudioFile = newFileName;
    }

    private IEnumerator ChangeBgm(string fileName)
    {
        while (curBgAs.volume > 0)
        {
            curBgAs.volume -= 0.01f;
            yield return null;
        }

        curBgAs.Pause();

        if (!CheckIfPlayOld(fileName))
        {
            PoolManager.Recycle(oldBgAs.clip);
            oldBgAs = curBgAs;
            curBgAs.clip = PoolManager.GetResourceObject(fileName, 1) as AudioClip;
            curBgAs.volume = 0f;
            curBgAs.Play();
        }

        while (curBgAs.volume < 1)
        {
            curBgAs.volume += 0.01f;
            yield return null;
        }
    }

    private bool CheckIfPlayOld(string fileName)
    {
        if (fileName.Equals(oldAudioFile))
        {
            AudioSource tmp = oldBgAs;
            oldBgAs = curBgAs;
            curBgAs = tmp;
            curBgAs.volume = 0;
            curBgAs.UnPause();
            return true;
        }

        return false;
    }

    public void PlayUi(string resKey)
    {
        JsonData pathObj = uiJsonRootData[resKey];
        if (null != pathObj)
            PlayObj(pathObj.ToString(), 0);
    }

    public void PlayObj(string fileName, ulong delay = 0)
    {
        var audioObj = new AudioObj(fileName);
        AudioSource newComp = audioObj.GetComp();
        newComp.Play(delay);
        tmpObjs.Add(audioObj);
    }

    public void Dispose()
    {
        for (int i = 0; i < tmpObjs.Count; i++)
        {
            tmpObjs[i].Destroy();
        }

        tmpObjs.Clear();

        PoolManager.Recycle(curBgAs.clip);
        PoolManager.Recycle(oldBgAs.clip);

        Object.Destroy(curBgAs.gameObject);
        Object.Destroy(oldBgAs.gameObject);

        curBgAs = null;
        oldBgAs = null;
    }

    public void Tick(float deltaTime)
    {
        if (checkTick < 60)
        {
            checkTick++;
            return;
        }

        checkTick = 0;

        for (int i = 0; i < tmpObjs.Count; i++)
        {
            AudioObj obj = tmpObjs[i];
            if (!obj.GetComp().isPlaying)
            {
                obj.Destroy();
                rubbish.Add(obj);
            }
        }

        for (int index = 0; index < rubbish.Count; index++)
        {
            tmpObjs.Remove(rubbish[index]);
            rubbish[index] = null;
        }

        rubbish.Clear();
    }

    private void InitUiCfg()
    {
        var text = Resources.Load("Music/Sound/UI/1001") as TextAsset;
        JsonData data = JsonMapper.ToObject(text.text);
        uiJsonRootData = data["data"];
    }

    private void InitBGMObj()
    {
        curBgAs = GameObject.Find("BGMA").GetComponent<AudioSource>();
        oldBgAs = GameObject.Find("BGMB").GetComponent<AudioSource>();
    }
}