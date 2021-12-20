using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public enum Sizes
{
    x512 = 0,
    x1024 = 1,
    x2048 = 2,
    x4096 = 3,
    x8192 = 4
}
//[CustomEditor(typeof(TextureChannelCombinator))]
public class TextureChannelCombinatorEditor : EditorWindow {


    public string savePath;
    public string filename, channelRString, channelGString, channelBString, channelAString;
    private bool groupEnabled, optionals;
    private Sizes sizes;

    [MenuItem("Window/Channel combiner")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        TextureChannelCombinatorEditor window = GetWindow(typeof(TextureChannelCombinatorEditor)) as TextureChannelCombinatorEditor;
        window.Show();
    }

    private void OnGUI()
    {
        GUILayout.Label("Base Setting", EditorStyles.boldLabel);

        savePath = EditorGUILayout.TextField("Save Path", savePath);

        EditorGUILayout.HelpBox("Use esta ventana para mezclar canales de texturas, ¿por qué hacerlo?: " +
                                "\n - sirve para ahorrar memoria" +
                                "\n - Use texturas en formato PNG" +
                                "\n - hace mas manejable el proyecto al usar menos texturas" +
                                "\n - Uselo en texturas en escala de grises" +
                                "\n - tamaño mayor o igual a 512", MessageType.Info);

        if (GUILayout.Button("ChR: " + channelRString)) channelRString = EditorUtility.OpenFilePanel("Open Channel R Texture", "", "png");
        if (GUILayout.Button("ChG: " + channelGString)) channelGString = EditorUtility.OpenFilePanel("Open Channel G Texture", "", "png");
        if (GUILayout.Button("ChB: " + channelBString)) channelBString = EditorUtility.OpenFilePanel("Open Channel B Texture", "", "png");
        if (GUILayout.Button("ChA: " + channelAString)) channelAString = EditorUtility.OpenFilePanel("Open Channel A Texture", "", "png");

        optionals = (channelGString != "" || channelGString != "" || channelGString != "");
        groupEnabled = channelRString != "" && optionals && savePath != "";

        EditorGUILayout.BeginToggleGroup("Optional Settings", groupEnabled);

        sizes = (Sizes)EditorGUILayout.EnumPopup("Select Size", sizes);
        if (GUILayout.Button("Apply Combination"))
        {
            if (channelRString != "" && channelBString != "" && savePath != "")
            {
                List<byte[]> dataBytes = new List<byte[]>
                {
                    File.ReadAllBytes(channelRString),
                    File.ReadAllBytes(channelGString),
                    File.ReadAllBytes(channelBString),
                    File.ReadAllBytes(channelAString)
                };


                int size = 512;

                switch (sizes) {
                    case Sizes.x512:
                        size = 512;
                        break;
                    case Sizes.x1024:
                        size = 1024;
                        break;
                    case Sizes.x2048:
                        size = 2048;
                        break;
                    case Sizes.x4096:
                        size = 4096;
                        break;
                    case Sizes.x8192:
                        size = 8192;
                        break;
                }
                TextureChannelCombinator.ApplyCombination(dataBytes, savePath, size);
            }
            else Debug.LogWarning("Please fill data correctly");
        }
    }
}
