# Add liquidity
## Add liquidity
## Add liquidity fix 

# Step to deploy this package
Using the same address for deploying `integer-mate` and `tap`.
## Deploy `integer-mate`
Clone it: https://github.com/phatln/integer-mate 
Modify Move.toml > `intefer_mate` to your deploying address.
Run:
```
aptos move publish --dev
```

## Deploy `tap`
```
aptos move publish --dev --named-addresses tap=default,integer_mate=default
```
