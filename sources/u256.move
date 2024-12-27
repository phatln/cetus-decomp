module cetus::u256 {
    struct U256 has copy, drop, store {
        n0: u64,
        n1: u64,
        n2: u64,
        n3: u64,
    }

    public fun hi_u128(arg0: U256) : u128 {
        ((arg0.n3 as u128) << 64) + (arg0.n2 as u128)
    }

    public fun add(arg0: U256, arg1: U256) : U256 {
        let (v0, v1) = cetus::math_u64::carry_add(arg0.n0, arg1.n0, 0);
        let (v2, v3) = cetus::math_u64::carry_add(arg0.n1, arg1.n1, v1);
        let (v4, v5) = cetus::math_u64::carry_add(arg0.n2, arg1.n2, v3);
        let (v6, v7) = cetus::math_u64::carry_add(arg0.n3, arg1.n3, v5);
        assert!(v7 == 0, 0x1::error::invalid_argument(0));
        U256{
            n0 : v0,
            n1 : v2,
            n2 : v4,
            n3 : v6,
        }
    }

    public fun as_u128(arg0: U256) : u128 {
        assert!(arg0.n3 == 0 && arg0.n2 == 0, 0x1::error::invalid_argument(0));
        cetus::math_u128::from_lo_hi(arg0.n0, arg0.n1)
    }

    public fun as_u64(arg0: U256) : u64 {
        assert!(arg0.n3 == 0 && arg0.n2 == 0 && arg0.n1 == 0, 0x1::error::invalid_argument(0));
        arg0.n0
    }

    fun bits(arg0: &U256) : u64 {
        let v0 = 1;
        while (v0 < 4) {
            let v1 = get(arg0, 4 - v0);
            if (v1 > 0) {
                return 64 * ((4 - v0 + 1) as u64) - (leading_zeros_u64(v1) as u64)
            };
            v0 = v0 + 1;
        };
        64 - (leading_zeros_u64(get(arg0, 0)) as u64)
    }

    public fun checked_as_u128(arg0: U256) : (u128, bool) {
        if (arg0.n3 != 0 || arg0.n2 != 0) {
            return (0, true)
        };
        (cetus::math_u128::from_lo_hi(arg0.n0, arg0.n1), false)
    }

    public fun checked_as_u64(arg0: U256) : (u64, bool) {
        if (arg0.n3 != 0 || arg0.n2 != 0 || arg0.n1 != 0) {
            return (0, true)
        };
        (arg0.n0, false)
    }

    public fun checked_div_round(arg0: U256, arg1: U256, arg2: bool) : U256 {
        let (v0, v1) = div_mod(arg0, arg1);
        if (arg2 && gt(v1, zero())) {
            return add(v0, from(1))
        };
        v0
    }

    public fun checked_shlw(arg0: U256) : (U256, bool) {
        if (arg0.n3 > 0) {
            return (zero(), true)
        };
        (shlw(arg0), false)
    }

    public fun cmp(arg0: U256, arg1: U256) : u8 {
        let v0 = 4;
        while (v0 > 0) {
            v0 = v0 - 1;
            let v1 = get(&arg0, v0);
            let v2 = get(&arg1, v0);
            if (v1 != v2) {
                if (v1 < v2) {
                    return 0
                };
                return 2
            };
        };
        1
    }

    public fun div(arg0: U256, arg1: U256) : U256 {
        let (v0, _) = div_mod(arg0, arg1);
        v0
    }

    public fun div_mod(arg0: U256, arg1: U256) : (U256, U256) {
        let v0 = zero();
        let v1 = bits(&arg0);
        let v2 = bits(&arg1);
        assert!(v2 != 0, 1);
        if (v1 < v2) {
            return (v0, arg0)
        };
        let v3 = v1 - v2;
        let v4 = arg1;
        arg1 = shl(v4, (v3 as u8));
        loop {
            if (gte(arg0, arg1)) {
                let v5 = v3 / 64;
                let v6 = &mut v0;
                set(v6, (v5 as u8), get(&v0, (v5 as u8)) | 1 << ((v3 % 64) as u8));
                let v7 = arg0;
                arg0 = sub(v7, arg1);
            };
            let v8 = arg1;
            arg1 = shr(v8, 1);
            if (v3 == 0) {
                break
            };
            v3 = v3 - 1;
        };
        (v0, arg0)
    }

    public fun eq(arg0: U256, arg1: U256) : bool {
        cmp(arg0, arg1) == 1
    }

    public fun from(arg0: u128) : U256 {
        U256{
            n0 : ((arg0 & 18446744073709551615) as u64),
            n1 : ((arg0 >> 64) as u64),
            n2 : 0,
            n3 : 0,
        }
    }

    public fun get(arg0: &U256, arg1: u8) : u64 {
        if (arg1 == 0) {
            arg0.n0
        } else if (arg1 == 1) {
            arg0.n1
        } else if (arg1 == 2) {
            arg0.n2
        } else {
            assert!(arg1 == 3, 0);
            arg0.n3
        }
    }

    public fun gt(arg0: U256, arg1: U256) : bool {
        cmp(arg0, arg1) == 2
    }

    public fun gte(arg0: U256, arg1: U256) : bool {
        cmp(arg0, arg1) >= 1
    }

    fun leading_zeros_u64(arg0: u64) : u8 {
        if (arg0 == 0) {
            return 64
        };
        if (arg0 >> 32 == 0) {
            let v1 = 32;
            while (v1 >= 1) {
                if ((arg0 & 4294967295) >> v1 - 1 & 1 != 0) {
                    break
                };
                v1 = v1 - 1;
            };
            32 - v1 + 32
        } else {
            let v2 = 64;
            while (v2 >= 1) {
                if (arg0 >> v2 - 1 & 1 != 0) {
                    break
                };
                v2 = v2 - 1;
            };
            64 - v2
        }
    }

    public fun lo_u128(arg0: U256) : u128 {
        ((arg0.n1 as u128) << 64) + (arg0.n0 as u128)
    }

    public fun lt(arg0: U256, arg1: U256) : bool {
        cmp(arg0, arg1) == 0
    }

    public fun lte(arg0: U256, arg1: U256) : bool {
        cmp(arg0, arg1) <= 1
    }

    public fun mul(arg0: U256, arg1: U256) : U256 {
        let v0 = zero();
        let v1 = num_words(arg0);
        let v2 = 0;
        while (v2 < num_words(arg1)) {
            let v3 = 0;
            let v4 = 0;
            while (v4 < v1) {
                if (v4 + v2 < 4) {
                    let v5 = cetus::math_u128::wrapping_add(cetus::math_u128::wrapping_add(cetus::math_u128::wrapping_mul((get(&arg0, v4) as u128), (get(&arg1, v2) as u128)), (get(&v0, v4 + v2) as u128)), v3);
                    let v6 = &mut v0;
                    set(v6, v4 + v2, cetus::math_u128::lo(v5));
                    v3 = cetus::math_u128::hi_u128(v5);
                };
                v4 = v4 + 1;
            };
            if (v2 + v1 < 4) {
                let v7 = &mut v0;
                set(v7, v2 + v1, (v3 as u64));
            };
            v2 = v2 + 1;
        };
        v0
    }

    public fun new(arg0: u64, arg1: u64, arg2: u64, arg3: u64) : U256 {
        U256{
            n0 : arg0,
            n1 : arg1,
            n2 : arg2,
            n3 : arg3,
        }
    }

    fun num_words(arg0: U256) : u8 {
        let v0 = 0;
        let v1 = v0;
        if (arg0.n0 > 0) {
            v1 = v0 + 1;
        };
        if (arg0.n1 > 0) {
            v1 = v1 + 1;
        };
        if (arg0.n2 > 0) {
            v1 = v1 + 1;
        };
        if (arg0.n3 > 0) {
            v1 = v1 + 1;
        };
        v1
    }

    fun set(arg0: &mut U256, arg1: u8, arg2: u64) {
        if (arg1 == 0) {
            arg0.n0 = arg2;
        } else if (arg1 == 1) {
            arg0.n1 = arg2;
        } else if (arg1 == 2) {
            arg0.n2 = arg2;
        } else {
            assert!(arg1 == 3, 0);
            arg0.n3 = arg2;
        };
    }

    public fun shl(arg0: U256, arg1: u8) : U256 {
        let v0 = arg0;
        let v1 = arg1;
        while (v1 >= 64) {
            let v2 = v0;
            v0 = shlw(v2);
            v1 = v1 - 64;
        };
        if (v1 == 0) {
            return v0
        };
        v0.n3 = v0.n3 << v1 | v0.n2 >> 64 - v1;
        v0.n2 = v0.n2 << v1 | v0.n1 >> 64 - v1;
        v0.n1 = v0.n1 << v1 | v0.n0 >> 64 - v1;
        v0.n0 = v0.n0 << v1;
        v0
    }

    public fun shlw(arg0: U256) : U256 {
        U256{
            n0 : 0,
            n1 : arg0.n0,
            n2 : arg0.n1,
            n3 : arg0.n2,
        }
    }

    public fun shr(arg0: U256, arg1: u8) : U256 {
        let v0 = arg0;
        let v1 = arg1;
        while (v1 >= 64) {
            let v2 = v0;
            v0 = shrw(v2);
            v1 = v1 - 64;
        };
        if (v1 == 0) {
            return v0
        };
        v0.n0 = v0.n0 >> v1 | v0.n1 << 64 - v1;
        v0.n1 = v0.n1 >> v1 | v0.n2 << 64 - v1;
        v0.n2 = v0.n2 >> v1 | v0.n3 << 64 - v1;
        v0.n3 = v0.n3 >> v1;
        v0
    }

    public fun shrw(arg0: U256) : U256 {
        U256{
            n0 : arg0.n1,
            n1 : arg0.n2,
            n2 : arg0.n3,
            n3 : 0,
        }
    }

    public fun sub(arg0: U256, arg1: U256) : U256 {
        let (v0, v1) = cetus::math_u64::overflowing_sub(arg0.n0, arg1.n0);
        let v2 = if (v1) {
            1
        } else {
            0
        };
        let (v3, v4) = cetus::math_u64::overflowing_sub(arg0.n1, arg1.n1);
        let (v5, v6) = cetus::math_u64::overflowing_sub(v3, v2);
        let v7 = if (v4 || v6) {
            1
        } else {
            0
        };
        let (v8, v9) = cetus::math_u64::overflowing_sub(arg0.n2, arg1.n2);
        let (v10, v11) = cetus::math_u64::overflowing_sub(v8, v7);
        let v12 = if (v9 || v11) {
            1
        } else {
            0
        };
        let (v13, v14) = cetus::math_u64::overflowing_sub(arg0.n3, arg1.n3);
        let (v15, v16) = cetus::math_u64::overflowing_sub(v13, v12);
        let v17 = if (v14 || v16) {
            1
        } else {
            0
        };
        assert!(v17 == 0, 0x1::error::invalid_argument(0));
        U256{
            n0 : v0,
            n1 : v5,
            n2 : v10,
            n3 : v15,
        }
    }

    public fun zero() : U256 {
        U256{
            n0 : 0,
            n1 : 0,
            n2 : 0,
            n3 : 0,
        }
    }

    // decompiled from Move bytecode v6
}

