###GKNativeExtensions

##What is this?
GKNativeExtensions is a small package wrapping the missing features of Unity's Game Center integration. This package mainly provides the necessary cloud save feature.

##How to use the extensions?
Get the .unitypackage from the latest release and import it in your project.
The GKNativeExtensions.cs file contains all the interfaces you can use for your project, each with an appropriate callback.


Keep in mind that the native code may return at odd times during execution, so it is a good idea to have a piece of code to wait for the next Update() call to make sure all unity data structures are available, something like (this)[https://gist.github.com/Fireforge/3c7003794dcd804e135cac3822f78416] does the job nicely.