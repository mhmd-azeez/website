---
title: "Use C# Source Generators to make all of your methods async!"
date: 2020-05-05
slug: "csharp-source-generators"
tags: ["csharp", "source-generators"]
---
C# Source Generators is a C# 9 feature that lets your generate source code during build. For more information read the [announcement blog post](https://devblogs.microsoft.com/dotnet/introducing-c-source-generators/) on .NET blog.

> NOTE: If it's not clear, this post is satire. Don't use any of the code or suggestions in production.

Have you ever had problems with app speed? Well, the easiest way to speed up your app is to make your methods async. And the easiest way of making your methods async is by using `Task.Run`.

For example, if we had a method like this:

```csharp
static void PrintNumber(int number)
{
    Console.WriteLine(number);
}
```

Let's assume that `PrintNumber` is slow and we want to speed it up, what do we do? We stick it in Task.Run and voila! all of our problems are solved!

```csharp
static Task PrintNumberAsync(int number)
{
    return Task.Run(() => PrintNumber(number));
}
```

Okay, how are c# source generators useful here? Well, we can write a source generator that turns all of your methods async just by applying a simple attribute!

```csharp
partial class Program
{
    static async Task Main(string[] args)
    {
       await PrintNumberAsync(42);
    }

    [Asyncify]
    static void PrintNumber(int number)
    {
        Console.WriteLine(number);
    }
}
```

Notice how `Main` calls `PrintNumberAsync` without us needing to define it? That's because there is a source generator that generates the async version of any method that's decorated with the `Asyncify` attribute.

The source generator is very simple but a little verbose, so I don't include the source code here. But it's available on [GitHub](https://github.com/encrypt0r/FunWithSourceGenerators).

The basic idea is that our source generator asks for any method that has our specific attribute (`Asyncify`) applied to it.

It then groups the methods by their class, for each class it creates another partial class that contains the async versions for the specified methods.

Here is how we generate each method:

```csharp
private void ProcessMethod(StringBuilder source, IMethodSymbol methodSymbol)
{
    // SayHello => SayHelloAsync
    string asyncMethodName = $"{methodSymbol.Name}Async";

    var staticModifier = methodSymbol.IsStatic ? "static" : string.Empty;

    // void => Task, bool => Task<bool>
    var asyncReturnType = methodSymbol.ReturnType.Name == "Void" ? 
                          "Task" :
                          $"Task<{methodSymbol.ReturnType.Name}>";

    // int number, string name
    var parameters = string.Join(",", methodSymbol.Parameters.Select(p => $"{p.Type} {p.Name}"));
    // number, name
    var arguments = string.Join(",", methodSymbol.Parameters.Select(p => p.Name));

    source.Append($@"
public {staticModifier} {asyncReturnType} {asyncMethodName}({parameters})
{{
    return Task.Run(() => {methodSymbol.Name}({arguments}));
}}
");
}
```

Because C# Source Generators are part of build, we get a lot metadata (like [IMethodSymbol](https://docs.microsoft.com/en-us/dotnet/api/microsoft.codeanalysis.imethodsymbol?view=roslyn-dotnet)) about all of the classes, methods, fields, etc. It's like reflection, but in compile time. If you have experience with Analyzers it's very similar because they are both based on Roslyn. But unlike Analyzers, C# Source Generators emit code using strings, not syntax tree deltas. To be honest, I like the string approach. It's a lot more friendly. However, it can get hard to maintain for complicated scenarios.

To make our source generator even more useful, we can modify it so that we can apply the `Asyncify` attribute on a class and all of the methods of the class get asyncified! I'll leave that as an exercise.