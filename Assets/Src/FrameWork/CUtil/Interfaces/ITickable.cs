public interface ITickable : System.IDisposable
{
    void Tick(float deltaTime);
}