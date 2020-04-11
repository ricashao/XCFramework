using UnityEngine;

public class RaycastUtils
{
    public static GameObject RayCaster(Camera camera)
    {
        GameObject go = null;
        RaycastHit hit;

        if (Application.isPlaying && camera)
        {
            Ray ray = camera.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out hit))
            {
                go = hit.collider.gameObject;
            }
        }

        return go;
    }
}