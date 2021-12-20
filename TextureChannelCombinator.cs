using System.IO;
using System.Collections.Generic;
using UnityEngine;

public class TextureChannelCombinator : MonoBehaviour {

    public List<Texture2D> incomeTextures;
    public Texture2D outcomeTextures;
    public int width;

    private void Start()
    {
        outcomeTextures = MergeChannels(incomeTextures, width);
    }

    public static List<Texture2D> ConvertBytesToTextures(List<byte[]> dataBytes, int size) {

        List<Texture2D> results = new List<Texture2D>();
        foreach (byte[] data in dataBytes)
        {
            // load the RChannel map
            Texture2D channel = new Texture2D(size, size, TextureFormat.ARGB32, true);
            channel.LoadImage(data);
            // apply the diffuse texture
            //channel.Resize(size, size);
            channel.Apply();
            
            results.Add(channel);
        }
        return results;
    }


    /// <summary>
    /// Toma el canal R de la primera textura y lo combina con el canal G de otra textura y el canal B de otra textura.
    /// </summary>
    public static Texture2D MergeChannels (List<Texture2D> dataTextures, int size = 512) {

        size = Mathf.ClosestPowerOfTwo(size);
        List<Color[]> colorList = new List<Color[]>();

        foreach (Texture2D tex in dataTextures) {
            colorList.Add(tex.GetPixels(0, 0, size, size));
        }

        for (int j = 0; j < colorList[0].Length; j++)
        {
            //colorList[i][0].r = colorList[][0].r;//colorList.Count-1 - i
            if(colorList.Count > 1)colorList[0][j].g = colorList[1][j].r;
            if (colorList.Count > 2) colorList[0][j].b = colorList[2][j].r;
            else colorList[0][j].b = 0;
            if (colorList.Count > 3) colorList[0][j].a = colorList[3][j].r;
            else colorList[0][j].a = 255;
        }

        Texture2D newTexture = new Texture2D(size, size, TextureFormat.ARGB32, false);
        newTexture.SetPixels(colorList[0]);
        newTexture.Apply();

        return newTexture;
    }

    public static void ApplyCombination(List<byte[]> dataBytes, string savePath, int size)
    {
        List<Texture2D> dataTextures = ConvertBytesToTextures(dataBytes, size);
        Texture2D newTexture = MergeChannels(dataTextures,size);// combine texture with it's normal map, saves it to a file
        File.WriteAllBytes(savePath, newTexture.EncodeToPNG());
    }
}
