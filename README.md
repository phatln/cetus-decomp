# Project structure
```
/
  tap/
    Move.toml
  integer-mate/
    Move.toml
```

`tap/Move.toml`
```
[package]
name = "Tap"
...


[addresses]

[dev-addresses]


[dependencies.IntegerMate]
local = "../integer-mate"
addr_subst = { "integer_mate" = "_" }
```

`integer-mate/Move.toml`
```
[package]
name = 'IntegerMate'
version = '1.0.0'

[addresses]
std = "0x1"
aptos_std = "0x1"
aptos_framework = "0x1"

[dev-addresses]

[dependencies.MoveStdlib]
git = "https://github.com/aptos-labs/aptos-framework.git"
rev = "mainnet"
subdir = "move-stdlib"
```

# How to run commands
```
aptos move test --dev --named-addresses integer_mate=default,tap=default
aptos move build --dev --named-addresses integer_mate=default,tap=default
```
Note: you have to run `aptos init` to init `default` account to be used in commands.
