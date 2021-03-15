Title: Why I love Powershell as a scripting language
Published: 03/14/2021
Tags:

 - powershell
 - automation
---

Every once in a while, I have to write a script to automate a task. Maybe it's part of a CI/CD pipeline, or it's part of my dev workflow. My favorite language for writing scripts is PowerShell. Here is why:

# 1. Powershell has an object pipeline

When you pass data (or pipe them) from one command to the next, the data is treated as an object, not as a string. Which means the data can have different properties and it retains these properties.

This is very powerful and unlocks all kinds of composability scenarios. Commands don't have to be single purpose, they don't have to provide different switches to get different outputs. They give you everything and you can use only the properties you need.

# 2. You have the full power of .NET

Powershell is a first class programming language on .NET. You can do almost everything with Powershell. that you can do with C# or F#.  [You can even create GUIs if you want to](https://devblogs.microsoft.com/scripting/create-a-simple-graphical-interface-for-a-powershell-script/). This means that you have access to the coherent and well designed Base Class Library of .NET as well as the entire gallery of [nuget](https://www.nuget.org/) packages. It also has [a lot of modules of it's own](https://www.powershellgallery.com/packages).

# 3. You can use Select/Where/GroupBy

Because Powershell is built on top of .NET, it has access to .NET's version of map/filter/reduce. They make scripts much more pleasant to write and read. However the names are a bit different from Javascript or other languages:

| JS Name | Powershell        |
| ------- | ----------------- |
| Filter  | Where             |
| Map     | Select            |
| Reduce  | Measure / ForEach |
| Reduce  | GroupBy           |

# 4. It's now cross-platform and open-source

[Powershell Core](https://github.com/PowerShell/PowerShell) is a cross-platform and open-source version of Powershell built on top of .NET Core maintained by Microsoft.

# 5. Working with Data is easy

You can easily work with [Excel](https://adamtheautomator.com/powershell-excel/), [XML](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-xml) and [JSON](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json) data which makes working with APIs much easier.

# Some cool examples

Here are some cool examples that demonstrate the points above:

## Get top 3 largest files in a folder

```powershell
Get-Childitem 'C:\Windows\System32' | 
    Where Length -gt (10MB) | # Only files that are greater than (-gt) 10 MB (MB is a constant in PS!)
    Sort -Descending -Property Length | # Sort files by their length ascending
    Select -First 3 Name, Length # Only select name and length properties (projection)
```

### Output

```
Name                    Length
----                    ------
MRT.exe              131005360
nvcompiler.dll        40444864
WindowsCodecsRaw.dll  32612880
```

## Calling a REST API

In this example we call a JSON REST API and print a property

```powershell
$uri = 'https://cat-fact.herokuapp.com/facts/random' # random cat fact API
$fact = Invoke-RestMethod -Uri $uri
Write-Host $fact.text
```

### Output:

```
Cats make about 100 different sounds. Dogs make only about 10.
```

## Export all process information as an excel sheet

```powershell
Get-Process | Select-Object Company, Name, Handles | Export-Excel
```

### Result: 

| Company               | Name       | Handles |
| --------------------- | ---------- | ------- |
| Microsoft Corporation | Calculator | 537     |
| Google LLC            | chrome     | 449     |
| ...                   | ...        | ...     |

> Note: You'll have to install [ImportExcel](https://github.com/dfinke/ImportExcel) module for this example to work.

## Importing data from excel

Consider this excel sheet:

| **City**  | **Population** |
| --------- | -------------- |
| Erbil     | 1500000        |
| Sulaymani | 739182         |
| Duhok     | 1293000        |
| Kirkuk    | 1598000        |
| Halabja   | 245700         |

```powershell
# Get the average poluation of cities in Kurdistan:
Import-Excel 'F:\cities.xlsx' | Measure -Average -Property population | Select -Property Average
```

> Note: You'll have to install [ImportExcel](https://github.com/dfinke/ImportExcel) module for this example to work.
>
> Note 2: Data is from Wikipedia.

### Ouput:

```
1075176.4
```

While my preferred scripting language is Powershell, I strongly believe everyone should use whatever tools/languages they are productive in. There is no best language. Everyone has different preferences and that's okay.

If you're using Powershell on Windows, I suggest you read [this post](https://www.hanselman.com/blog/taking-your-powershell-prompt-to-the-next-level-with-windows-terminal-and-oh-my-posh-3) to make your experience even better.