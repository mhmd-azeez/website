---
title: "Why my console app gets stuck"
date: 2021-08-09
slug: "quick-edit-mode"
tags: ["console", "windows"]
---
In my current project, we have a console app that runs in the background and sends data to a frontend application. The app works great but sometimes it stops working and we need to press a key for it to continue. It turned out it was because of Windows Console's `Quick Mode` feature. [When a user clicks on the console window, it hangs the app execution to allow the user to select the text.](https://stackoverflow.com/a/30517482).

Fortunately, you can easily disable Quick Edit for your app:

```csharp
// http://msdn.microsoft.com/en-us/library/ms686033(VS.85).aspx
[DllImport("kernel32.dll")]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

private const uint ENABLE_EXTENDED_FLAGS = 0x0080;

private static void DisableQuickEditMode()
{
    // Disable QuickEdit Mode
    // Quick Edit mode freezes the app to let users select text.
    // We don't want that. We want the app to run smoothly in the background.
    // - https://stackoverflow.com/q/4453692
    // - https://stackoverflow.com/a/4453779
    // - https://stackoverflow.com/a/30517482

    IntPtr handle = Process.GetCurrentProcess().MainWindowHandle;
    SetConsoleMode(handle, ENABLE_EXTENDED_FLAGS);
}

public static void Main(string[] args)
{
    DisableQuickEditMode();
    // Do stuff
}
```
