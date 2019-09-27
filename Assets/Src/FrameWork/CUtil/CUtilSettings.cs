public struct CheapUtilSettings
{
    public string   urlRoot;
    public bool     useFileMapping;

    public override string ToString ()
    {
        return string.Format ("[CheapUtilSettings] urlRoot={0}, useFileMapping={1}", urlRoot, useFileMapping);
    }
}