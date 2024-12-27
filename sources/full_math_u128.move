module cetus::full_math_u128 {
    public fun full_mul(arg0: u128, arg1: u128) : cetus::u256::U256 {
        let (v0, v1) = cetus::math_u128::full_mul(arg0, arg1);
        cetus::u256::new(cetus::math_u128::lo(v0), cetus::math_u128::hi(v0), cetus::math_u128::lo(v1), cetus::math_u128::hi(v1))
    }

    public fun full_mul_v2(arg0: u128, arg1: u128) : u256 {
        (arg0 as u256) * (arg1 as u256)
    }

    public fun mul_div_ceil(arg0: u128, arg1: u128, arg2: u128) : u128 {
        (((full_mul_v2(arg0, arg1) + (arg2 as u256) - 1) / (arg2 as u256)) as u128)
    }

    public fun mul_div_floor(arg0: u128, arg1: u128, arg2: u128) : u128 {
        ((full_mul_v2(arg0, arg1) / (arg2 as u256)) as u128)
    }

    public fun mul_div_round(arg0: u128, arg1: u128, arg2: u128) : u128 {
        (((full_mul_v2(arg0, arg1) + ((arg2 as u256) >> 1)) / (arg2 as u256)) as u128)
    }

    public fun mul_shl(arg0: u128, arg1: u128, arg2: u8) : u128 {
        ((full_mul_v2(arg0, arg1) << arg2) as u128)
    }

    public fun mul_shr(arg0: u128, arg1: u128, arg2: u8) : u128 {
        ((full_mul_v2(arg0, arg1) >> arg2) as u128)
    }

    // decompiled from Move bytecode v6
}

