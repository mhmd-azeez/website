---
title: "Generating C# bindings for native libraries by using ChatGPT"
date: 2022-12-17
slug: "chat-gpt-csharp-bindings"
tags: ["csharp", "native"]
---
One of the most boring and tedious work in wrapping native libraries in C# is writing the DllImport functions.
Fortunatley, Large Language Models like ChatGPT has become powerful enough to be able to generate C# bindings from a C header file.
Or at the very least, they give you a good foundation that you can tweak and improve upon.

> This post is part of the C# advent calendar 2022, for other articles in this collection see [C# Advent Calendar 2022](https://csadvent.christmas/).

Here is an example where I ask ChatGPT to give me a C# binding for [Extism](https://extism.org/)'s SDK:

My promopt:
```
Convert this header file to C# DllImport functions

typedef int32_t ExtismPlugin;

typedef uint64_t ExtismSize;

ExtismPlugin extism_plugin_register(const uint8_t *wasm, ExtismSize wasm_size, bool with_wasi);

bool extism_plugin_update(ExtismPlugin index,
                          const uint8_t *wasm,
                          ExtismSize wasm_size,
                          bool with_wasi);

bool extism_plugin_config(ExtismPlugin plugin, const uint8_t *json, ExtismSize json_size);

bool extism_function_exists(ExtismPlugin plugin, const char *func_name);

int32_t extism_call(ExtismPlugin plugin_id,
                    const char *func_name,
                    const uint8_t *data,
                    ExtismSize data_len);

const char *extism_error(ExtismPlugin plugin);

ExtismSize extism_output_length(ExtismPlugin plugin);

void extism_output_get(ExtismPlugin plugin, uint8_t *buf, ExtismSize len);

bool extism_log_file(const char *filename, const char *log_level);

const char *extism_version();
```

ChatGPT's response:
```
using System;
using System.Runtime.InteropServices;

public static class ExtismNative
{
    // The DllImport attribute specifies the library to import and the function to call
    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern int extism_plugin_register(byte[] wasm, ulong wasm_size, bool with_wasi);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool extism_plugin_update(int index, byte[] wasm, ulong wasm_size, bool with_wasi);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool extism_plugin_config(int plugin, byte[] json, ulong json_size);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool extism_function_exists(int plugin, string func_name);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern int extism_call(int plugin_id, string func_name, byte[] data, ulong data_len);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr extism_error(int plugin);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern ulong extism_output_length(int plugin);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern void extism_output_get(int plugin, byte[] buf, ulong len);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool extism_log_file(string filename, string log_level);

    [DllImport("extism", CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr extism_version();
}
```

Please note that it generates a slightly different response every time you ask it, but the general idea is the same. While it's not perfect,
it's definitely better than starting form scratch. I took the response from ChatGPT and tweaked the response a bit to write 
[this handcrafted version](https://github.com/extism/extism/blob/dd0c5757da43b6d12e8e51fcad9f8f0409280b2b/dotnet/src/Extism.Sdk/LibExtism.cs).
