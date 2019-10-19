using UnityEngine;

public class AudioObj
{
    private readonly string curFileName;
    private AudioSource asComp;
    private GameObject audioObj;
    private AudioClip audioRes;
    
    public AudioObj(string fileName)
    {
        curFileName = fileName;
        CreatAudioGameObject();
    }
    
    public AudioSource GetComp()
    {
        if (null == audioObj)
        {
            PoolManager.Recycle(audioRes);
            CreatAudioGameObject();
        }
        return asComp;
    }
    
    private void CreatAudioGameObject()
    {
        if (!curFileName.Equals(string.Empty))
        {
            audioRes = PoolManager.GetResourceObject(curFileName, 5) as AudioClip;
            audioObj = new GameObject("audioObj");
            asComp = audioObj.AddComponent<AudioSource>();
            asComp.clip = audioRes;
        }
    }
    
    public void Destroy()
    {
        PoolManager.Recycle(audioRes);
        Object.Destroy(audioObj);
        audioObj = null;
    }
}