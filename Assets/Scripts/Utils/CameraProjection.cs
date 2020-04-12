using UnityEngine;
using System.Collections;

public class CameraProjection : MonoBehaviour
{

    //距离摄像机20米 用红色表示
    public float distance = 10.0f;

    private Camera theCamera;

    private Transform tx;

    private bool isFirst = true;
    void Start()
    {
        if (!theCamera)
        {
            theCamera = GetComponent<Camera>();
        }
        tx = theCamera.transform;
    }


    void Update()
    {
        FindCorners();
    }

    void FindCorners()
    {
        Vector3[] corners = GetCorners(distance);
		
        Debug.DrawLine(corners[0], corners[1], Color.red);
        Debug.DrawLine(corners[1], corners[3], Color.red);
        Debug.DrawLine(corners[3], corners[2], Color.red);
        Debug.DrawLine(corners[2], corners[0], Color.red);
    }


    Vector3[] GetCorners(float distance)
    {
        Vector3[] corners = new Vector3[4];

        float halfFOV = (theCamera.fieldOfView * 0.5f) * Mathf.Deg2Rad;
        float aspect = theCamera.aspect;

        float height = distance * Mathf.Tan(halfFOV);
        float width = height * aspect;

        // UpperLeft
        corners[0] = tx.position - (tx.right * width);
        corners[0] += tx.up * height;
        corners[0] += tx.forward * distance;

        // UpperRight
        corners[1] = tx.position + (tx.right * width);
        corners[1] += tx.up * height;
        corners[1] += tx.forward * distance;

        // LowerLeft
        corners[2] = tx.position - (tx.right * width);
        corners[2] -= tx.up * height;
        corners[2] += tx.forward * distance;

        // LowerRight
        corners[3] = tx.position + (tx.right * width);
        corners[3] -= tx.up * height;
        corners[3] += tx.forward * distance;

        return corners;
    }
}