using UnityEngine;

[ExecuteInEditMode]
public class TestRenderImage : MonoBehaviour {

    #region [Variables]
    public Shader curShader;
    [Range(0,3)]    public float brightnessAmount = 1.0f , saturationAmount = 1.0f, contrastAmount = 1.0f;
    [Range(0, 1)]    public float grayScaleAmount = 1.0f;
    [Range(-1,1f)]    public float distance = 0.001f;
    [Range(0.0f, 0.1f)] public float celsize = 0.5f;
    [Range(1, 10)] public int samples;
    [Range(0f, 1f)] public float scale;
    [Range(-1.0f, 1f)] public float xSpeed = 0.05f;
    [Range(-1.0f, 1f)] public float ySpeed = 0.05f;
    [Range(-10f, 10f)] public float zStrength = 0.05f;
    [Range(-10f, 10f)] public float wStrength = 0.05f;
    [Range(-0f, 10f)] public float refractTexTile;
    public Texture2D refractTexture;
    [Range(0,0.5f)]public float power;
    [Range(0, 1f)] public float depthPower;
    //[Range(0, 0.5f)] public float power2;
    [Range(-1, 1f)] public float distance2 = 0.001f;
    [Range(0, 1)] public float depthPower2;
    [SerializeField]private Material curMaterial;
    public Transform sunTransform;
    private Vector3 objectPosition, damageVector;
    public Color fogColor;
    #endregion

    #region [Properties]
    Material Material {
        get {
            if (curMaterial == null) {
                curMaterial = new Material(curShader)
                {
                    hideFlags = HideFlags.HideAndDontSave
                };
            }
            return curMaterial;
        }
    }
    #endregion
    
    // Use this for initialization
    void Start () {
        if (!SystemInfo.supportsImageEffects) {
            enabled = false;
            return;
        }

        enabled = !(!curShader && !curShader.isSupported);
        curMaterial.shader = curShader;

        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture) {
        //https://living-sun.com/es/unity3d/836731-tex2dstddxddy-not-working-in-fullscreen-in-unity-unity3d-shader-hlsl-effects-post-processing.html
        if (curShader != null)
        {
            Material.SetFloat("_BrightnessAmount", brightnessAmount);
            Material.SetFloat("_SatAmount", saturationAmount);
            Material.SetFloat("_ConAmount", contrastAmount);
            Material.SetFloat("_LuminosityAmount", grayScaleAmount);
            Material.SetFloat("_Distance", distance * 1f);
            Material.SetFloat("_Scale", scale);
            Material.SetInt("_Samples", samples);
            Material.SetFloat("_Power", power);
            Material.SetFloat("_DepthPower", depthPower);
            Material.SetFloat("_Distance2", distance2 * 1f);
            Material.SetFloat("_DepthPower2", depthPower2);
            Material.SetFloat("_CellSize", celsize);
            Material.SetVector("_ObjectPosition", objectPosition);
            Material.SetColor("_Color", fogColor);
            Material.SetVector("_SpeedStrenght", new Vector4(xSpeed, ySpeed, zStrength, wStrength));
            Material.SetFloat("_RefractTexTiling", refractTexTile);
            if(refractTexture)Material.SetTexture("_RefractTex", refractTexture);

            Graphics.Blit(sourceTexture, destTexture, Material);
        }
        else Graphics.Blit(sourceTexture, destTexture);
    }
	// Update is called once per frame
	void Update () {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        depthPower = Mathf.Clamp(depthPower, 0, 200);

        brightnessAmount = Mathf.Clamp(brightnessAmount,0,2);
        saturationAmount = Mathf.Clamp(saturationAmount,0,2);
        contrastAmount = Mathf.Clamp(contrastAmount,0,3);
        grayScaleAmount = Mathf.Clamp01(grayScaleAmount);
        //distance = Mathf.Clamp(distance,0,10);


        if (sunTransform) {
            objectPosition = Vector3.Normalize(Camera.main.transform.position - sunTransform.position);
            damageVector = Camera.main.ViewportToScreenPoint(Input.mousePosition);
            damageVector -= Vector3.one/2;
        }
    }

    void OnDisable() {
        DestroyImmediate(curMaterial);
    }
}
