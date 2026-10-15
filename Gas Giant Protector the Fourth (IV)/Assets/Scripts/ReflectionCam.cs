using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class ReflectionCam : MonoBehaviour
{
    void Awake()
    {
        RenderPipelineManager.beginCameraRendering += FlipFaceCull;
        RenderPipelineManager.endCameraRendering += UnflipFaceCull;
    }

    void OnDestroy()
    {
        RenderPipelineManager.beginCameraRendering -= FlipFaceCull;
        RenderPipelineManager.endCameraRendering -= UnflipFaceCull;
    }

    void FlipFaceCull(ScriptableRenderContext context, Camera camera)
    {
        if (camera.gameObject == this.gameObject)
            GL.invertCulling = true;
    }

    void UnflipFaceCull(ScriptableRenderContext context, Camera camera)
    {
        if (camera.gameObject == this.gameObject)
            GL.invertCulling = false;
    }
}
