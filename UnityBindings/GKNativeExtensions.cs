/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

using System;
using System.Collections;
using System.Collections.Generic;
using AOT;
using UnityEngine;
using System.Runtime.InteropServices;

public delegate void byteArrayPtrCallbackDelegate(IntPtr dataPtr, int length);
public delegate void boolCallbackDelegate(bool success);
public delegate void saveGamesCallbackDelegate(IntPtr gamesPtr, long length);

[Serializable, StructLayout(LayoutKind.Sequential)]
public struct SavedGameDataGameCenter
{
    [MarshalAs(UnmanagedType.LPStr)]
    public string deviceName;
    [MarshalAs(UnmanagedType.LPStr)]
    public string name;
    public double modificationDate;
};

public class GKNativeExtensions
{

#if UNITY_IOS
    const string Lib = "__Internal";
#elif UNITY_STANDALONE_OSX
    const string Lib = "GKNativeExtensionsMac";
#endif

#if UNITY_IOS || UNITY_STANDALONE_OSX
    [DllImport(Lib)]
    public static extern void _GKFetchSavedGames(saveGamesCallbackDelegate callback);

    [DllImport(Lib)]
    public static extern void _GKDeleteGame(boolCallbackDelegate callback, [In]char[] saveName);

    [DllImport(Lib)]
    public static extern void _GKLoadGame(byteArrayPtrCallbackDelegate callback, [In]char[] saveName);

    [DllImport(Lib)]
    public static extern void _GKSaveGame([In] byte[] byteArray, int length, [In]char[] saveName, boolCallbackDelegate callback);
#endif

    static bool isRunningFetchGames = false;
    static bool isRunningDeleteGame = false;
    static bool isRunningSaveGame = false;
    static bool isRunningLoadGame = false;

    static Action<SavedGameDataGameCenter[]> fetchGamesCallback;
    static Action<bool> saveCallback;
    static Action<bool> deleteCallback;
    static Action<byte[]> loadCallback;



    [MonoPInvokeCallback(typeof(saveGamesCallbackDelegate))]
    public static void fetchSavesCompleteCalled(IntPtr games, long length)
    {
        Debug.Log("FetchSaves called back");
        isRunningSaveGame = false;

        SavedGameDataGameCenter[] savedGames = new SavedGameDataGameCenter[length];

        Debug.Log("Length: " + length);

        IntPtr p = games;
        for (int i = 0; i < length; i++)
        {
            savedGames[i] = (SavedGameDataGameCenter)Marshal.PtrToStructure(p, typeof(SavedGameDataGameCenter));
            p += Marshal.SizeOf(typeof(SavedGameDataGameCenter)); // move to next structure
        }

        fetchGamesCallback(savedGames);
    }

    [MonoPInvokeCallback(typeof(boolCallbackDelegate))]
    public static void saveCompleteCalled(bool success)
    {
        isRunningSaveGame = false;
        saveCallback(success);
    }

    [MonoPInvokeCallback(typeof(boolCallbackDelegate))]
    public static void deleteCompleteCalled(bool success)
    {
        isRunningDeleteGame = false;
        deleteCallback(success);
    }

    [MonoPInvokeCallback(typeof(byteArrayPtrCallbackDelegate))]
    public static void loadCompleteCalled(IntPtr dataPtr, int length)
    {
        isRunningLoadGame = false;

        byte[] result = new byte[length];

        Marshal.Copy(dataPtr, result, 0, length);
        loadCallback(result);
    }


    public static void GKFetchSavedGames(Action<SavedGameDataGameCenter[]> callback)
    {
        if(isRunningFetchGames)
        {
            callback(null);
            return;
        }
        fetchGamesCallback = callback;
        isRunningFetchGames = true;
#if CPS_GAME_CENTER && (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKFetchSavedGames(fetchSavesCompleteCalled);
#endif
    }


    public static void GKDeleteGame(Action<bool> callback, string saveName)
    {
        if (isRunningDeleteGame)
        {
            callback(false);
            return;
        }

        deleteCallback = callback;
        isRunningDeleteGame = true;


#if CPS_GAME_CENTER && (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKDeleteGame(deleteCompleteCalled, saveName.ToCharArray());
#endif
    }

    public static void GKSaveGame(byte[] data, string name, Action<bool> callback)
    {
        if(isRunningSaveGame)
        {
            callback(false);
            return;
        }
        saveCallback = callback;
        isRunningSaveGame = true;
        Debug.Log("SaveName: " + name);

#if CPS_GAME_CENTER && (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKSaveGame(data, data.Length, name.ToCharArray(), saveCompleteCalled);
#endif
    }

    public static void GKLoadGame(Action<byte[]> savedDataCallback, string saveName)
    {
        if (isRunningLoadGame)
        {
            savedDataCallback(null);
            return;
        }

        loadCallback = savedDataCallback;
        isRunningLoadGame = true;
        Debug.Log("LoadName: " + saveName);

#if CPS_GAME_CENTER && (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKLoadGame(loadCompleteCalled, saveName.ToCharArray());
#endif
    }
}