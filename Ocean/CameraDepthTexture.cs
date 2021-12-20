using UnityEngine;

[ExecuteInEditMode]
public class CameraDepthTexture : MonoBehaviour {

    private Camera cam;
	// Use this for initialization
	void Start () {
        cam = Camera.main;
        cam.depthTextureMode = DepthTextureMode.Depth;
	}
	
}
