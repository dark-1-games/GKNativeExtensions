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
public delegate void savedGamesCallbackDelegate(IntPtr gamesPtr, uint length);
public delegate void savedGameCallbackDelegate(IntPtr gamePtr);

[Serializable, StructLayout(LayoutKind.Sequential)]
public class SavedGameDataGameCenter
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
    public static extern void _GKInit(savedGamesCallbackDelegate conflictCallback, savedGameCallbackDelegate modifiedCallback);

    [DllImport(Lib)]
    public static extern void _GKResolveConflictingSaves(IntPtr sgData, int sgLength, byte[] saveArray, int length, boolCallbackDelegate callback);

    [DllImport(Lib)]
    public static extern void _GKFetchSavedGames(savedGamesCallbackDelegate callback);

    [DllImport(Lib)]
    public static extern void _GKDeleteGame(string saveName, boolCallbackDelegate callback);

    [DllImport(Lib)]
    public static extern void _GKLoadGame(IntPtr sgData, byteArrayPtrCallbackDelegate callback);

    [DllImport(Lib)]
    public static extern void _GKSaveGame(byte[] byteArray, int length, string saveName, savedGameCallbackDelegate callback);
#endif
    static bool isInited = false;
    static bool isRunningFetchGames = false;
    static bool isRunningDeleteGame = false;
    static bool isRunningSaveGame = false;
    static bool isRunningLoadGame = false;
    static bool isRunningResolveConflicts = false;

    static Action<SavedGameDataGameCenter[]> fetchGamesCallback;
    static Action<SavedGameDataGameCenter[]> conflictCallback;
    static Action<SavedGameDataGameCenter> saveCallback;
    static Action<SavedGameDataGameCenter> modifiedCallback;
    static Action<bool> deleteCallback;
    static Action<bool> resolveConflictCallback;
    static Action<byte[]> loadCallback;

    [MonoPInvokeCallback(typeof(savedGamesCallbackDelegate))]
    private static void fetchSavesCompleteCalled(IntPtr games, uint length)
    {
        isRunningFetchGames = false;

        Debug.Log("Length:" + length);

        SavedGameDataGameCenter[] savedGames = new SavedGameDataGameCenter[length];

        IntPtr p = games;
        for (uint i = 0; i < length; i++)
        {
            savedGames[i] = (SavedGameDataGameCenter)Marshal.PtrToStructure(p, typeof(SavedGameDataGameCenter));
#if NET_4_6
            p += Marshal.SizeOf(typeof(SavedGameDataGameCenter)); // move to next structure
#else
            p = new IntPtr( p.ToInt64() + Marshal.SizeOf( typeof( SavedGameDataGameCenter ) ) ); // move to next structure
#endif
        }

        fetchGamesCallback(savedGames);
    }

    [MonoPInvokeCallback(typeof(savedGamesCallbackDelegate))]
    private static void conflictCallbackCalled(IntPtr games, uint length)
    {
        Debug.Log("Length:" + length);

        SavedGameDataGameCenter[] savedGames = new SavedGameDataGameCenter[length];

        IntPtr p = games;
        for (uint i = 0; i < length; i++)
        {
            savedGames[i] = (SavedGameDataGameCenter)Marshal.PtrToStructure(p, typeof(SavedGameDataGameCenter));
#if NET_4_6
            p += Marshal.SizeOf(typeof(SavedGameDataGameCenter)); // move to next structure
#else
            p = new IntPtr( p.ToInt64() + Marshal.SizeOf( typeof( SavedGameDataGameCenter ) ) ); // move to next structure
#endif
        }

        conflictCallback(savedGames);
    }

    [MonoPInvokeCallback(typeof(boolCallbackDelegate))]
    private static void resolveConflictCallbackCalled(bool success)
    {
        isRunningResolveConflicts = false;
        resolveConflictCallback(success);
    }

    [MonoPInvokeCallback(typeof(savedGameCallbackDelegate))]
    private static void modifiedCallbackCalled(IntPtr savePtr)
    {
        if (modifiedCallback != null)
        {
            SavedGameDataGameCenter savedGameMeta;
            savedGameMeta = (SavedGameDataGameCenter)Marshal.PtrToStructure(savePtr, typeof(SavedGameDataGameCenter));
            modifiedCallback(savedGameMeta);
        }
        else
        {
            Debug.Log("Save complete called but there's no callback registered yet.");
        }
    }

    [MonoPInvokeCallback(typeof(savedGameCallbackDelegate))]
    private static void saveCompleteCalled(IntPtr savePtr)
    {
        isRunningSaveGame = false;

        if (saveCallback != null)
        {
            if (savePtr == IntPtr.Zero)
            {
                saveCallback(null);
            }
            else
            {
                SavedGameDataGameCenter savedGameMeta;
                savedGameMeta = (SavedGameDataGameCenter)Marshal.PtrToStructure(savePtr, typeof(SavedGameDataGameCenter));
                saveCallback(savedGameMeta);
            }
        }
        else
        {
            Debug.Log("Save complete called but there's no callback registered yet.");
        }
    }

    [MonoPInvokeCallback(typeof(boolCallbackDelegate))]
    private static void deleteCompleteCalled(bool success)
    {
        isRunningDeleteGame = false;
        deleteCallback(success);
    }

    [MonoPInvokeCallback(typeof(byteArrayPtrCallbackDelegate))]
    private static void loadCompleteCalled(IntPtr dataPtr, int length)
    {
        isRunningLoadGame = false;

        byte[] result = new byte[length];

        Marshal.Copy(dataPtr, result, 0, length);
        loadCallback(result);
    }


    public static void GKInit(Action<SavedGameDataGameCenter[]> conflictCallback, Action<SavedGameDataGameCenter> modifiedCallback)
    {
        if (isInited)
        {
            conflictCallback(null);
            return;
        }
        GKNativeExtensions.conflictCallback = conflictCallback;
        GKNativeExtensions.modifiedCallback = modifiedCallback;
#if (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKInit(conflictCallbackCalled, modifiedCallbackCalled);
#endif
        isInited = true;
    }

    public static void GKFetchSavedGames(Action<SavedGameDataGameCenter[]> callback)
    {
        if (isRunningFetchGames)
        {
            callback(null);
            return;
        }
        fetchGamesCallback = callback;
        isRunningFetchGames = true;
#if (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKFetchSavedGames(fetchSavesCompleteCalled);
#endif
    }

    public static void GKResolveConflicts(SavedGameDataGameCenter[] sgData, byte[] saveArray, Action<bool> callback)
    {
        if (isRunningResolveConflicts)
        {
            callback(false);
            return;
        }
        resolveConflictCallback = callback;
        isRunningResolveConflicts = true;

        Debug.Log(sgData.Length);

        IntPtr savedGamePtr = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(SavedGameDataGameCenter)) * sgData.Length);
        long LongPtr = savedGamePtr.ToInt64(); // Must work both on x86 and x64
        for (int i = 0; i < sgData.Length; i++)
        {
            IntPtr sgDataPtr = new IntPtr(LongPtr);
            Marshal.StructureToPtr(sgData[i], sgDataPtr, false); // You do not need to erase struct in this case
            LongPtr += Marshal.SizeOf(typeof(SavedGameDataGameCenter));
        }

#if (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKResolveConflictingSaves(savedGamePtr, sgData.Length, saveArray, saveArray.Length, resolveConflictCallbackCalled);
#endif
    }


    public static void GKDeleteGame(string savedGame, Action<bool> callback)
    {
        if (isRunningDeleteGame)
        {
            callback(false);
            return;
        }

        deleteCallback = callback;
        isRunningDeleteGame = true;


#if (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKDeleteGame(savedGame, deleteCompleteCalled);
#endif
    }

    public static void GKSaveGame(byte[] data, string savedGameName, Action<SavedGameDataGameCenter> callback)
    {
        if (isRunningSaveGame)
        {
            callback(null);
            return;
        }

        saveCallback = callback;
        isRunningSaveGame = true;

        Debug.Log("SaveName: " + savedGameName);

#if (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKSaveGame(data, data.Length, savedGameName, saveCompleteCalled);
#endif
    }

    public static void GKLoadGame(SavedGameDataGameCenter savedGame, Action<byte[]> savedDataCallback)
    {
        if (isRunningLoadGame)
        {
            savedDataCallback(null);
            return;
        }

        loadCallback = savedDataCallback;
        isRunningLoadGame = true;

        IntPtr savedGamePtr = Marshal.AllocHGlobal(Marshal.SizeOf(savedGame));
#if NET_4_6
        Marshal.StructureToPtr<SavedGameDataGameCenter>(savedGame, savedGamePtr, false);
#else
        Marshal.StructureToPtr( savedGame, savedGamePtr, false );
#endif

#if (UNITY_IOS || UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX)
        _GKLoadGame(savedGamePtr, loadCompleteCalled);
#endif
    }
}