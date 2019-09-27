public sealed class CheapUtilMain
{
    public static readonly CheapUtilMain Instance = new CheapUtilMain();

    static CheapUtilMain()
    {
    }

    private CheapUtilMain()
    {
    }

    public CheapUtilSettings Settings { get; private set; }
}