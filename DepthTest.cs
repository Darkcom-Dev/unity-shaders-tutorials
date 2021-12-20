using UnityEngine;
[ExecuteInEditMode]
public class DepthTest : MonoBehaviour {

    #region [Variables]
    public Shader depthTestShader;
    [Range(0,1)]
    public float depthAmount = 2.0f;
    public Texture2D fogColor;
    public Material curMaterial;

    #endregion

    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    // Use this for initialization
    void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture) {
        if (depthTestShader != null)
        {
            curMaterial.SetTexture("_FogTex", fogColor);
            curMaterial.SetFloat("_DepthPower", depthAmount);
            
            Graphics.Blit(sourceTexture, destTexture, curMaterial);
        }
        else Graphics.Blit(sourceTexture, destTexture);
	}
}
