Title: A more useful `tree`
Published: 09/25/2025
Tags:

 - linux
---

While Linux does have the `tree` command, if you're doing programming, you probably don't want results in folders like `node_modules`, `dist`, etc..., so here is a useful little alias I have in my `~/.bash_aliases`:

```bash
# tree alias that excludes common directories
treen() {
    local ignore='node_modules|__pycache__|*.pyc|.git|.next|dist|build|
    coverage|.cache|.venv|venv|bin|obj|packages|.vs|*.user|*.suo'
    local args=(-I "$ignore")
    if [ $# -gt 0 ]; then
        args+=(-P "$1" --prune)
        shift
    fi
    command tree "${args[@]}" "$@"
}
```

You can use it like so: `treen **/*.ts`

Example:

With `treen`:
```
mo@mo-x1:~/work/dylibso/js-sdk$ treen
.
├── benches
│   ├── deno
│   │   └── main.ts
│   └── node
│       ├── main.js
│       ├── package.json
│       └── package-lock.json
├── DEVELOPING.md
├── examples
│   ├── deno.ts
│   ├── index.html
│   └── node.js
├── jsr.json
├── justfile
├── LICENSE
├── package.json
├── package-lock.json
├── playwright.config.js
├── README.md
├── src
│   ├── background-plugin.ts
│   ├── call-context.ts
│   ├── foreground-plugin.ts
│   ├── http-context.ts
│   ├── interfaces.ts
│   ├── manifest.ts
│   ├── mod.test.ts
│   ├── mod.ts
│   ├── polyfills
│   │   ├── browser-capabilities.ts
│   │   ├── browser-fs.ts
│   │   ├── browser-wasi.ts
│   │   ├── bun-capabilities.ts
│   │   ├── bun-response-to-module.ts
│   │   ├── bun-worker-url.ts
│   │   ├── deno-capabilities.ts
│   │   ├── deno-minimatch.ts
│   │   ├── deno-wasi.ts
│   │   ├── host-node-worker_threads.ts
│   │   ├── node-capabilities.ts
│   │   ├── node-fs.ts
│   │   ├── node-minimatch.ts
│   │   ├── node-wasi.ts
│   │   ├── response-to-module.ts
│   │   └── worker-node-worker_threads.ts
│   ├── worker.ts
│   └── worker-url.ts
├── tests
│   ├── data
│   │   └── test.txt
│   └── playwright.test.js
├── tree.txt
├── tsconfig.json
├── types
│   └── deno
│       └── index.d.ts
└── wasm
    ├── 02-var-reflected.wasm
    ├── alloc.wasm
    ├── circular-lhs.wasm
    ├── circular-rhs.wasm
    ├── circular.wasm
    ├── code-functions.wasm
    ├── code.wasm
    ├── config.wasm
    ├── consume.wasm
    ├── corpus
    │   ├── 00-circular-lhs.wat
    │   ├── 01-circular-rhs.wat
    │   ├── 02-var-reflected.wat
    │   ├── circular.wat
    │   ├── fs-link.wat
    │   ├── loop-forever-init.wat
    │   └── loop-forever.wat
    ├── exit.wasm
    ├── fail.wasm
    ├── fs-link.wasm
    ├── fs.wasm
    ├── hello_haskell.wasm
    ├── hello.wasm
    ├── http_headers.wasm
    ├── http.wasm
    ├── input_offset.wasm
    ├── log.wasm
    ├── loop-forever-init.wasm
    ├── loop-forever.wasm
    ├── memory.wasm
    ├── reflect.wasm
    ├── sleep.wasm
    ├── upper.wasm
    ├── var.wasm
    └── wasistdout.wasm

13 directories, 80 files
mo@mo-x1:~/work/dylibso/js-sdk$ 
```

With `tree`:
```
.
├── benches
│   ├── deno
│   │   └── main.ts
│   └── node
│       ├── main.js
│       ├── package.json
│       └── package-lock.json
├── DEVELOPING.md
├── examples
│   ├── deno.ts
│   ├── index.html
│   └── node.js
├── jsr.json
├── justfile
├── LICENSE
├── node_modules
│   ├── @aashutoshrathi
│   │   └── word-wrap
│   │       ├── index.d.ts
│   │       ├── index.js
│   │       ├── LICENSE
│   │       ├── package.json
│   │       └── README.md
│   ├── acorn
│   │   ├── bin
│   │   │   └── acorn
│   │   ├── CHANGELOG.md
│   │   ├── dist
│   │   │   ├── acorn.d.mts
│   │   │   ├── acorn.d.ts
│   │   │   ├── acorn.js
│   │   │   ├── acorn.mjs
│   │   │   └── bin.js
│   │   ├── LICENSE
│   │   ├── package.json
│   │   └── README.md
│   ├── acorn-jsx
│   │   ├── index.d.ts
│   │   ├── index.js
│   │   ├── LICENSE
│   │   ├── package.json
│   │   ├── README.md
│   │   └── xhtml.js
│   ├── ajv
│   │   ├── dist
│   │   │   ├── ajv.bundle.js
│   │   │   ├── ajv.min.js
│   │   │   └── ajv.min.js.map
│   │   ├── lib
│   │   │   ├── ajv.d.ts
│   │   │   ├── ajv.js
│   │   │   ├── cache.js
│   │   │   ├── compile
│   │   │   │   ├── async.js
│   │   │   │   ├── equal.js
│   │   │   │   ├── error_classes.js
│   │   │   │   ├── formats.js
│   │   │   │   ├── index.js
│   │   │   │   ├── resolve.js
│   │   │   │   ├── rules.js
│   │   │   │   ├── schema_obj.js
│   │   │   │   ├── ucs2length.js
│   │   │   │   └── util.js
│   │   │   ├── data.js
│   │   │   ├── definition_schema.js
│   │   │   ├── dot
│   │   │   │   ├── allOf.jst
│   │   │   │   ├── anyOf.jst
│   │   │   │   ├── coerce.def
│   │   │   │   ├── comment.jst
│   │   │   │   ├── const.jst
│   │   │   │   ├── contains.jst
│   │   │   │   ├── custom.jst
│   │   │   │   ├── defaults.def
│   │   │   │   ├── definitions.def
│   │   │   │   ├── dependencies.jst
│   │   │   │   ├── enum.jst
│   │   │   │   ├── errors.def
│   │   │   │   ├── format.jst
│   │   │   │   ├── if.jst
│   │   │   │   ├── items.jst
│   │   │   │   ├── _limitItems.jst
│   │   │   │   ├── _limit.jst
│   │   │   │   ├── _limitLength.jst
│   │   │   │   ├── _limitProperties.jst
│   │   │   │   ├── missing.def
│   │   │   │   ├── multipleOf.jst
│   │   │   │   ├── not.jst
│   │   │   │   ├── oneOf.jst
│   │   │   │   ├── pattern.jst
│   │   │   │   ├── properties.jst
│   │   │   │   ├── propertyNames.jst
│   │   │   │   ├── ref.jst
│   │   │   │   ├── required.jst
│   │   │   │   ├── uniqueItems.jst
│   │   │   │   └── validate.jst
│   │   │   ├── dotjs
│   │   │   │   ├── allOf.js
│   │   │   │   ├── anyOf.js
│   │   │   │   ├── comment.js
│   │   │   │   ├── const.js
│   │   │   │   ├── contains.js
│   │   │   │   ├── custom.js
│   │   │   │   ├── dependencies.js
│   │   │   │   ├── enum.js
│   │   │   │   ├── format.js
│   │   │   │   ├── if.js
│   │   │   │   ├── index.js
│   │   │   │   ├── items.js
│   │   │   │   ├── _limitItems.js
│   │   │   │   ├── _limit.js
│   │   │   │   ├── _limitLength.js
│   │   │   │   ├── _limitProperties.js
│   │   │   │   ├── multipleOf.js
│   │   │   │   ├── not.js
│   │   │   │   ├── oneOf.js
│   │   │   │   ├── pattern.js
│   │   │   │   ├── properties.js
│   │   │   │   ├── propertyNames.js
│   │   │   │   ├── README.md
│   │   │   │   ├── ref.js
│   │   │   │   ├── required.js
│   │   │   │   ├── uniqueItems.js
│   │   │   │   └── validate.js
│   │   │   ├── keyword.js
│   │   │   └── refs
│   │   │       ├── data.json
│   │   │       ├── json-schema-draft-04.json
│   │   │       ├── json-schema-draft-06.json
│   │   │       ├── json-schema-draft-07.json
│   │   │       └── json-schema-secure.json

... A million files later ...

│   └── yocto-queue
│       ├── index.d.ts
│       ├── index.js
│       ├── license
│       ├── package.json
│       └── readme.md
├── package.json
├── package-lock.json
├── playwright.config.js
├── README.md
├── src
│   ├── background-plugin.ts
│   ├── call-context.ts
│   ├── foreground-plugin.ts
│   ├── http-context.ts
│   ├── interfaces.ts
│   ├── manifest.ts
│   ├── mod.test.ts
│   ├── mod.ts
│   ├── polyfills
│   │   ├── browser-capabilities.ts
│   │   ├── browser-fs.ts
│   │   ├── browser-wasi.ts
│   │   ├── bun-capabilities.ts
│   │   ├── bun-response-to-module.ts
│   │   ├── bun-worker-url.ts
│   │   ├── deno-capabilities.ts
│   │   ├── deno-minimatch.ts
│   │   ├── deno-wasi.ts
│   │   ├── host-node-worker_threads.ts
│   │   ├── node-capabilities.ts
│   │   ├── node-fs.ts
│   │   ├── node-minimatch.ts
│   │   ├── node-wasi.ts
│   │   ├── response-to-module.ts
│   │   └── worker-node-worker_threads.ts
│   ├── worker.ts
│   └── worker-url.ts
├── tests
│   ├── data
│   │   └── test.txt
│   └── playwright.test.js
├── tree.txt
├── tsconfig.json
├── types
│   └── deno
│       └── index.d.ts
└── wasm
    ├── 02-var-reflected.wasm
    ├── alloc.wasm
    ├── circular-lhs.wasm
    ├── circular-rhs.wasm
    ├── circular.wasm
    ├── code-functions.wasm
    ├── code.wasm
    ├── config.wasm
    ├── consume.wasm
    ├── corpus
    │   ├── 00-circular-lhs.wat
    │   ├── 01-circular-rhs.wat
    │   ├── 02-var-reflected.wat
    │   ├── circular.wat
    │   ├── fs-link.wat
    │   ├── loop-forever-init.wat
    │   └── loop-forever.wat
    ├── exit.wasm
    ├── fail.wasm
    ├── fs-link.wasm
    ├── fs.wasm
    ├── hello_haskell.wasm
    ├── hello.wasm
    ├── http_headers.wasm
    ├── http.wasm
    ├── input_offset.wasm
    ├── log.wasm
    ├── loop-forever-init.wasm
    ├── loop-forever.wasm
    ├── memory.wasm
    ├── reflect.wasm
    ├── sleep.wasm
    ├── upper.wasm
    ├── var.wasm
    └── wasistdout.wasm

874 directories, 8134 files
```

P.S: I don't really remember what `n` stands for in `treen` anymore. Must have meant something when I first wrote the alias

Update 1: I realized using a function would be better than an alias, as you can still use the glob filtering and -I param. The old alias was:
```bash
treen() {
    local ignore='node_modules|__pycache__|*.pyc|.git|.next|dist|build|
    coverage|.cache|.venv|venv|bin|obj|packages|.vs|*.user|*.suo'
    local args=(-I "$ignore")
    if [ $# -gt 0 ]; then
        args+=(-P "$1" --prune)
        shift
    fi
    command tree "${args[@]}" "$@"
}
```
