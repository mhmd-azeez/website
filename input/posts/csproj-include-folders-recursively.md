Title: How to include folders as link recursively in csproj files
Published: 10/13/2020
Tags:

 - dotnet
 - csharp
---

Suppose we have a folder called `dependencies` with this structure:

```
 - dependencies
   - child-folder
     - file.txt
     - file2.txt
   - file3.txt
```

If you want to add the entire folder as link and preserve the directory structure, you can use this inside your `.csproj` file:

```
<ItemGroup>
    <None Include="..\dependencies\**\*">
      <Link>dependencies\%(RecursiveDir)/%(FileName)%(Extension)</Link>
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </None>
</ItemGroup>
```

This will include `dependencies` folder inside your project along with all of its child folder and files.