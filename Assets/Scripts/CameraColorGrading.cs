using System;
using UnityEngine;

public class CameraColorGrading : MonoBehaviour
{
    public Material lutMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Debug.Log("OnRenderImage called");

        if (lutMaterial != null)
        {
            Graphics.Blit(source, destination, lutMaterial);
            
        }
        else
        {
            Graphics.Blit(source, destination);
        }
        throw new NotImplementedException();
    }
}
