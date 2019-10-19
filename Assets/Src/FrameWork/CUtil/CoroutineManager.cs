using System.Collections;
using System.Collections.Generic;

public class CoroutineManager: ITickable
{
    private static CoroutineManager instance;
    private readonly List<CoroutineTask> tasks = new List<CoroutineTask>(8);
    public static CoroutineManager Instance
    {
        get
        {
            if (null == instance)
                instance = new CoroutineManager();
            return instance;
        }
    }

    public void Dispose()
    {
        tasks.Clear();
    }

    public void Tick(float deltaTime)
    {
        if (tasks.Count > 0)
        {
            bool flag = false;
            int count = tasks.Count;
            for (int index = 0; index < count; ++index)
            {
                CoroutineTask task = tasks[index];
                if (!task.done)
                {
                    task.done = !task.routine.MoveNext();
                    if (task.done)
                    {
                        tasks[index] = task;
                        flag = true;
                    }
                }
                else
                {
                    flag = true;
                }
            }
            if (flag)
            {
                tasks.RemoveAll(item => item.done);
            }
        }
    }
    
    public void StartCoroutine(IEnumerator routine)
    {
        if (routine.MoveNext())
        {
            var item = new CoroutineTask(routine);
            tasks.Add(item);
        }
    }
}

internal struct CoroutineTask
{
    public readonly IEnumerator routine;
    public bool done;

    public CoroutineTask(IEnumerator routine)
    {
        this.routine = routine;
        done = false;
    }
}