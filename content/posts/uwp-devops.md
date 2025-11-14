---
title: "Setting up automated build and release pipeline for side-loaded UWP apps using Azure DevOps"
date: 2019-10-27
slug: "uwp-devops"
tags: ["devops", "uwp"]
---
This week we set up a CI/CD pipeline for one of our UWP apps that needs to be sideloaded because we don't publish it through the Microsoft Store. [This article](https://docs.microsoft.com/en-us/windows/uwp/packaging/auto-build-package-uwp-apps) was super useful in getting me started. Microsoft has made things quite easy with Azure DevOps, but there were a few things that took us a little bit of time to figure out.

## A little bit of context
We have an enterprise UWP application that we publish via an http server. We also have a custom auto-update mechanism that updates the apps whenever an update is available. You can learn more about the [auto-updater here](https://mazeez.dev/posts/update-sideloaded-uwp).

So what we needed, is a build pipeline that builds the app for both `x64` and `x86` and generate an index.html page, `appinstaller` file and the `msixbundle` files for both the app and its dependencies. 

## The plan
1. Setup a build pipeline to generate update package and increase version
2. Set up a release pipeline to upload the update package via FTP
3. Celebrate

# 1. Setting up a build pipeline
[This article](https://docs.microsoft.com/en-us/windows/uwp/packaging/auto-build-package-uwp-apps) provides most of the information needed. But I have a few notes:

### 1.1 Use self hosted agents
Unfortunately, it seems like Microsoft hosted agents [are not powerful enough](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops#capabilities-and-limitations) to build release modes of moderate to big UWP applications. Because in release mode, it has to compile the app natively and so uses the native compilation toolchain. In our experience, the native compilation toolchain requires at least 8 GB of RAM to work properly. For our app, the Microsft hosted agents had a build success rate of less than 50%. They fail because [of memory usage issues](https://dev.to/encrypt0r/solving-nutcdriver-exe-returned-code-1-error-while-building-uwp-app-in-release-mode-2mc6).

Besides, hosted agents are much faster. Microsoft hosted agents would take about 45 minutes to build our app, our own hosted agents usually take about 10 minutes. This is partly because they use incremental build, instead of a clean build every time they need to build the app.

So you have to use your own hosted agents. You use your own machines or virtual machines to build the application. Adding an agent to a pool is very easy:

1. Go to project settings > Agent Pools
2. Click on "Default" or create another pool
3. Click on "New Agent" and follow the instructions

Now you will need to tell the build pipeline to use your self-hosted agents. 
You can specify the pool name very easily in yaml:
```yaml
pool:
  name: "Default"
```

You might also want to use the 64 bit compiler, for that add this xml snippet a `PropertyGroup` in your project's `csproj` file:

```xml
<Use64Bitcompiler>true</Use64Bitcompiler>
```



### 1.2 Use Nuget version `4.x`

For some reason, not specifying Nuget version leads to the failure of the build.

### 1.3 Using Extension SDKs with a build pipeline
> An Extension SDK is similar in concept to a regular assembly reference, but is instead a rich collection of files to cover various configurations and design time scenarios.

If you're using an SDK reference, for example if you use [SQLite for UWP](https://marketplace.visualstudio.com/items?itemName=SQLiteDevelopmentTeam.SQLiteforUniversalWindowsPlatform), you must include the SDK with the source code and tell MSBuild to use the local version before searching for the SDK in the global folder. [This article](https://oren.codes/2012/03/24/how-to-use-extension-sdks-per-project/) explains the steps, but here is a summary:

1. Create a folder beside your solution file and call it `SDKs`.
1. Copy UAP folder from `C:\Program Files (x86)\Microsoft SDKs` into the `SDKs` folder beside your solution file.
1. Add this snippet to the `.csproj` file:
```xml
<PropertyGroup>
  <SDKReferenceDirectoryRoot>$(SolutionDir)\SDKs;$(SDKReferenceDirectoryRoot)</SDKReferenceDirectoryRoot>
</PropertyGroup>
```

### 1.4 Versioning the packages
Usually the version of the package is stored inside `Package.appxmanifest` and auto-incremented by Visual Studio. But this requires you to commit the changes to make sure you don't reuse versions.

I am not comfortable with build pipelines committing changes to source code. Fortunately there are a few extensions for Azure DevOps that can help with this. The one I decided to use is [Version Number counter](https://marketplace.visualstudio.com/items?itemName=maikvandergaag.maikvandergaag-versioncounter). [This article](https://msftplayground.com/2018/11/version-number-counter-for-azure-devops/) does a great job of explaining how you can use it.

What we can do is have a PowerShell script  update the app manifest file:

```powershell
# https://stackoverflow.com/a/42699995
$xmlFileName = "$(Build.SourcesDirectory)\{ProjectName}\Package.appxmanifest"
      
[xml]$xmlDoc = Get-Content $xmlFileName
$xmlDoc.Package.Identity.Version = "$env:appVersion.0"

echo 'New version:' $xmlDoc.Package.Identity.Version

$xmlDoc.Save($xmlFileName)
```

For that you need to define a variable called `appVersion` with the initial version in this format: `1.0.0`. Because UWP package version format is like `1.0.0.0`, you have to concatenate another "0" at the end of `appVersion`.

If you're a desktop developer, you might not like PowerShell or bash scripts. But they are very powerful and flexible for automation scenarios.

### 1.5 Use templates
Sometimes you have multiple configurations and environments you want to build for. We wanted to be able to build for both Production and Staging environments. Each of which have different build configuration (Release, Debug, Staging...), supported different build platforms (x86, x64, ARM), had different auto-update URLs, etc..

Azure DevOps yaml files support templates. You define a base template and put all of the common steps and jobs there, then you define a bunch of parameters for the template so that the pipelines that inherit from the base template can configure these parameters.

## The code

`Template.yaml`

```yaml
parameters:
    # Platforms to generate bundles for: x86, x64, x86|x64
    buildPlatform: 'x86|x64'
    # Platforms to generate bundles for (Debug, Release...)
    buildConfiguration: 'Release'

    # Where will the installer be uploaded to?
    installerUrl: 'Replace this by the actual URL'

    # The version of the app
    appVersion: '1.1.1'

    solution: '{ProjectName}.sln'
    appxPackageDir: '$(build.artifactStagingDirectory)\AppxPackages\\'

steps:
- task: PowerShell@2
  env:
    appVersion: ${{ parameters.appVersion }}
    buildPlatform: ${{ parameters.buildPlatform }}
    buildConfiguration: ${{ parameters.buildConfiguration }}
    installerUrl: ${{ parameters.installerUrl }}

  displayName: 'Print variables'
  inputs:
    targetType: 'inline'
    script: |
      echo "appVersion: $env:appVersion"
      echo "buildPlatform: $env:buildPlatform"
      echo "buildConfiguration: $env:buildConfiguration"
      echo "installerUrl: $env:installerUrl"

- task: versioncounter@1
  inputs:
    VersionVariable: 'appVersion'
    UpdateMinorVersion: true
    DevOpsPat: '{Your_PAT}'

- task: PowerShell@2
  env:
    appVersion: ${{ parameters.appVersion }}
  displayName: 'Replace Version Number in the manifest file'
  inputs:
    targetType: 'inline'
    script: |
      # https://stackoverflow.com/a/42699995
      $xmlFileName = "$(Build.SourcesDirectory)\{ProjectName}\Package.appxmanifest"
      
      [xml]$xmlDoc = Get-Content $xmlFileName
      $xmlDoc.Package.Identity.Version = "$env:appVersion.0"

      echo 'New version:' $xmlDoc.Package.Identity.Version

      $xmlDoc.Save($xmlFileName)

- task: NuGetToolInstaller@1
  inputs:
    versionSpec: '4.9.2'

- task: NuGetCommand@2
  inputs:
    command: 'restore'
    restoreSolution: '${{ parameters.solution }}'

- task: VSBuild@1
  inputs:
    solution: '${{ parameters.solution }}'
    msbuildArgs: '/p:AppxBundlePlatforms="${{ parameters.buildPlatform}}" /p:AppxPackageDir="${{ parameters.appxPackageDir}}" /p:AppxBundle=Always /p:UapAppxPackageBuildMode=SideloadOnly'
    platform: 'x64'
    configuration: '${{ parameters.buildConfiguration }}'
    msbuildArchitecture: 'x64'

- task: PowerShell@2
  env:
    installerUrl: ${{ parameters.installerUrl }}
  displayName: 'Replace installer url'
  inputs:
    targetType: 'inline'
    script: |
      # https://stackoverflow.com/a/17144445
      $fileName = "$(build.artifactStagingDirectory)\AppxPackages\{ProjectName}.appinstaller"
      
      $original = "{Original Url in the .appinstaller file}"

      $content = Get-Content $fileName
      $content = $content.replace($original, $env:installerUrl)

      Set-Content -Path $fileName -Value $content

      echo 'Install Url:' $env:installerUrl

- task: CopyFiles@2
  displayName: 'Copy Files to: $(build.artifactstagingdirectory)'
  inputs:
    SourceFolder: '$(system.defaultworkingdirectory)'
    Contents: '**\bin\${{ parameters.buildConfiguration }}\**'
    TargetFolder: '$(build.artifactstagingdirectory)'

- task: PublishBuildArtifacts@1
  displayName: 'Publish Artifact: drop'
  inputs:
    PathtoPublish: '$(build.artifactstagingdirectory)'

```

`Staging.yml`

```yaml
# Staging
trigger:
 - master

pool:
  name: "Default"

steps:
    - template: Template.yml
      parameters:
        buildPlatform: 'x64'
        buildConfiguration: 'Release'
        installerUrl: '{Staging_URL}'
        appVersion: $(appVersion)
```

`Production.yml`
```yml
# Production
trigger: none

pool:
  name: "Default"

steps:
    - template: Template.yml
      parameters:
        buildPlatform: 'x86|x64'
        buildConfiguration: 'Release'
        installerUrl: '{Production_URL}'
        appVersion: $(appVersion)
```

# 2. Setup a release pipeline
The release pipeline is very easy, since all of the hard work is done in the build pipeline. The only thing you have to do is:

1. Get the build artifacts from the build pipeline. You can do that by clicking "Artifacts" part. Select "Build" from "Source Type" and select the appropriate build pipeline.

2. Upload the `index.html`, `{ProjectName}.appinstaller` and the package folder to the update website via FTP. Azure DevOps has a built-in task for FTP upload.

# 3. Celebrate 🎉
The title pretty much says it all.

------

Update 04/25/2020:

You can use the [Code Signing Task](https://marketplace.visualstudio.com/items?itemName=stefankert.codesigning) for signing your WUP app easily and securely.