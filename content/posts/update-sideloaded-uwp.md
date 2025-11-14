---
title: "Enabling automatic updates for sideloaded UWP apps"
date: 2018-12-28
slug: "update-sideloaded-uwp"
tags: ["uwp", "devops"]
---
Recently we wanted to enable auto-updates for an app that we were developing for a client. The app is developed in UWP and it's sideloaded into the client's computers. Although Microsoft has added an auto-update functionality in the `1803` build of Windows, we had a few issues with it:
 - It was not very reliable
 - We didn't have much control over it beside a simple auto-update policy that specified how often it should check for updates.
 - Troubleshooting was very hard as there were no clear way to find out why the auto-updater was not working properly.

So I found [an article](https://matthijs.hoekstraonline.net/2016/09/27/auto-updater-for-my-side-loaded-uwp-apps/) from 2016 and decided to improve upon it and put it a [nuget package](http://nuget.org/packages/Dwrandaz.AutoUpdateComponent). The library is open-source and is available on [GitHub](https://github.com/dwrandaz/AutoUpdateComponent).

## How to use
1. First, [configure the IIS server and create a web app](https://docs.microsoft.com/en-us/windows/uwp/packaging/web-install-iis). You can also take a look [at the sample web app](https://github.com/Dwrandaz/AutoUpdateComponent/tree/master/Sample/CustomStore).
1. Install the nuget package: [Dwrandaz.AutoUpdateComponent](http://nuget.org/packages/Dwrandaz.AutoUpdateComponent) in the UWP app.
1. Set minimum version of the app to `1803`
1. Open the package manifest `.appmanifest` file of the main app and declare an app service:
   - Name: The default values is `Dwrandaz.AutoUpdate`. However, you can change it to any name you like but you should note that this name is important and it should be passed to `AutoUpdateManager.TryToUpdateAsync` if you don't use the default name.
   - Entry point: `Dwrandaz.AutoUpdateComponent.UpdateTask`
1. Right click on the package manifest `.appmanifest` file and click on `View Code`.
1. Add this namespace declaration: `xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities"`
1. Add `rescap` to the `IgnorableNamespaces`, for example: `IgnorableNamespaces="uap mp rescap"`
1. Inside the `Package` tag, make sure these elements exist:

```xml
<Capabilities>
    <Capability Name="internetClient" />
    <rescap:Capability Name="packageManagement" />
</Capabilities>
```
For more information, take a look at the [sample apps manifest file](https://github.com/Dwrandaz/AutoUpdateComponent/blob/master/Sample/SampleApp/Package.appxmanifest).

1. Example usage:
```csharp
var path = "http://localhost:5000/install/AwesomeApp.appinstaller";
var info = await AutoUpdateManager.CheckForUpdatesAsync(path);
if (!info.Succeeded)
{
    // There was an error in getting the update information from the server
    // use info.ErrorMessage to get the error message
    return;
}

if (!info.ShouldUpdate)
{
    // The app is already up-to-date :)
    return;
}

// You can use info.MainBundleVersion to get the update version

var result = await AutoUpdateManager.TryToUpdateAsync(info);
if (!result.Succeeded)
{
    // There was an error in updating the app
    // use result.ErrorMessage to get the error message
    return;
}

// Success! The app was updated, it will restart soon!
```

For more infromation take a look at the [Sample app](https://github.com/Dwrandaz/AutoUpdateComponent/blob/master/Sample/SampleApp/MainPage.xaml.cs#L35).

## Creating update packages

1. Make sure you select the `Release` configuration
1. Right click on the main app project and click `Store` > `Create App Packages...`
1. Select `I want to create packages for sideloading.`And check the `Enable automatic updates` checkbox
1. Click on `Next`
1. Check the `Automatically Incremenent` checkbox under `version`.
1. Select `Always` under `Generate App bundle`
1. Click on `Next`
1. Write the update location path and Select `Check every 1 Week` or more so that the native auto-update mechanism doesn't mess with our auto-update mechanism.
1. Click on `Create`
1. Upload the `.appinstaller`, `.index.html` and the package folder to the web app in the path that was used in `AutoUpdateManager.CheckForUpdatesAsync`.