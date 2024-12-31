module cetus::clmm_math {
    public fun compute_swap_step(
        arg0: u128,
        arg1: u128,
        arg2: u128,
        arg3: u64,
        arg4: u64,
        arg5: bool,
        arg6: bool
    ): (u64, u64, u128, u64) {
        if (arg2 == 0) {
            return (0, 0, arg1, 0)
        };
        if (arg5) {
            assert!(arg0 >= arg1, 5);
        } else {
            assert!(arg0 < arg1, 5);
        };
        let (v0, v1, v2, v3) = if (arg6) {
            let v4 = cetus::full_math_u64::mul_div_floor(arg3, 1000000 - arg4, 1000000);
            let v5 = get_delta_up_from_input_v2(arg0, arg1, arg2, arg5);
            let (v0, v2, v3) = if (v5 > (v4 as u256)) {
                (v4, arg3 - v4, get_next_sqrt_price_from_input(arg0, arg2, v4, arg5))
            } else {
                let v6 = (v5 as u64);
                (v6, cetus::full_math_u64::mul_div_ceil(v6, arg4, 1000000 - arg4), arg1)
            };
            (v0, (get_delta_down_from_output_v2(arg0, v3, arg2, arg5) as u64), v2, v3)
        } else {
            let v7 = get_delta_down_from_output_v2(arg0, arg1, arg2, arg5);
            let (v1, v3) = if (v7 > (arg3 as u256)) {
                (arg3, get_next_sqrt_price_from_output(arg0, arg2, arg3, arg5))
            } else {
                ((v7 as u64), arg1)
            };
            let v8 = (get_delta_up_from_input_v2(arg0, v3, arg2, arg5) as u64);
            (v8, v1, cetus::full_math_u64::mul_div_ceil(v8, arg4, 1000000 - arg4), v3)
        };
        (v0, v1, v3, v2)
    }

    public fun fee_rate_denominator(): u64 {
        1000000
    }

    public fun get_amount_by_liquidity(
        arg0: cetus::i64::I64,
        arg1: cetus::i64::I64,
        arg2: cetus::i64::I64,
        arg3: u128,
        arg4: u128,
        arg5: bool
    ): (u64, u64) {
        if (arg4 == 0) {
            return (0, 0)
        };
        if (cetus::i64::lt(arg2, arg0)) {
            (get_delta_a(
                cetus::tick_math::get_sqrt_price_at_tick(arg0),
                cetus::tick_math::get_sqrt_price_at_tick(arg1),
                arg4,
                arg5
            ), 0)
        } else if (cetus::i64::lt(arg2, arg1)) {
            (get_delta_a(arg3, cetus::tick_math::get_sqrt_price_at_tick(arg1), arg4, arg5), get_delta_b(
                cetus::tick_math::get_sqrt_price_at_tick(arg0),
                arg3,
                arg4,
                arg5
            ))
        } else {
            (0, get_delta_b(
                cetus::tick_math::get_sqrt_price_at_tick(arg0),
                cetus::tick_math::get_sqrt_price_at_tick(arg1),
                arg4,
                arg5
            ))
        }
    }

    public fun get_delta_a(arg0: u128, arg1: u128, arg2: u128, arg3: bool): u64 {
        let v0 = if (arg0 > arg1) {
            arg0 - arg1
        } else {
            arg1 - arg0
        };
        if (v0 == 0 || arg2 == 0) {
            return 0
        };
        let (v1, v2) = cetus::math_u256::checked_shlw(cetus::full_math_u128::full_mul_v2(arg2, v0));
        if (v2) {
            abort 3
        };
        (cetus::math_u256::div_round(v1, cetus::full_math_u128::full_mul_v2(arg0, arg1), arg3) as u64)
    }

    public fun get_delta_b(arg0: u128, arg1: u128, arg2: u128, arg3: bool): u64 {
        let v0 = if (arg0 > arg1) {
            arg0 - arg1
        } else {
            arg1 - arg0
        };
        if (v0 == 0 || arg2 == 0) {
            return 0
        };
        let v1 = cetus::full_math_u128::full_mul_v2(arg2, v0);
        if (arg3 && v1 & 18446744073709551615 > 0) {
            return (((v1 >> 64) + 1) as u64)
        };
        ((v1 >> 64) as u64)
    }

    public fun get_delta_down_from_output_v2(arg0: u128, arg1: u128, arg2: u128, arg3: bool): u256 {
        let v0 = if (arg0 > arg1) {
            arg0 - arg1
        } else {
            arg1 - arg0
        };
        if (v0 == 0 || arg2 == 0) {
            return 0
        };
        if (arg3) {
            cetus::full_math_u128::full_mul_v2(arg2, v0) >> 64
        } else {
            let (v2, v3) = cetus::math_u256::checked_shlw(cetus::full_math_u128::full_mul_v2(arg2, v0));
            if (v3) {
                abort 3
            };
            cetus::math_u256::div_round(v2, cetus::full_math_u128::full_mul_v2(arg0, arg1), false)
        }
    }

    public fun get_delta_up_from_input_v2(arg0: u128, arg1: u128, arg2: u128, arg3: bool): u256 {
        let v0 = if (arg0 > arg1) {
            arg0 - arg1
        } else {
            arg1 - arg0
        };
        if (v0 == 0 || arg2 == 0) {
            return 0
        };
        if (arg3) {
            let (v2, v3) = cetus::math_u256::checked_shlw(cetus::full_math_u128::full_mul_v2(arg2, v0));
            if (v3) {
                abort 3
            };
            cetus::math_u256::div_round(v2, cetus::full_math_u128::full_mul_v2(arg0, arg1), true)
        } else {
            let v4 = cetus::full_math_u128::full_mul_v2(arg2, v0);
            if (v4 & 18446744073709551615 > 0) {
                return (v4 >> 64) + 1
            };
            v4 >> 64
        }
    }

    public fun get_liquidity_from_a(arg0: u128, arg1: u128, arg2: u64, arg3: bool): u128 {
        let v0 = if (arg0 > arg1) {
            arg0 - arg1
        } else {
            arg1 - arg0
        };
        (cetus::math_u256::div_round(
            (cetus::full_math_u128::full_mul_v2(arg0, arg1) >> 64) * (arg2 as u256),
            (v0 as u256),
            arg3
        ) as u128)
    }

    public fun get_liquidity_from_amount(
        lower_index: cetus::i64::I64,
        upper_index: cetus::i64::I64,
        current_index: cetus::i64::I64,
        current_sqrt_price: u128,
        amount: u64,
        fix_amount_a: bool
    ): (u128, u64, u64) {
        let amount_a = 0;
        let amount_b = 0;
        let liquidity = if (fix_amount_a) {
            amount_a = amount;
            if (cetus::i64::lt(current_index, lower_index)) {
                get_liquidity_from_a(
                    cetus::tick_math::get_sqrt_price_at_tick(lower_index),
                    cetus::tick_math::get_sqrt_price_at_tick(
                        upper_index
                    ),
                    amount,
                    false
                )
            } else {
                assert!(cetus::i64::lt(current_index, upper_index), 6);
                let liquidity = get_liquidity_from_a(
                    current_sqrt_price,
                    cetus::tick_math::get_sqrt_price_at_tick(upper_index),
                    amount,
                    false);
                amount_b = get_delta_b(
                    current_sqrt_price,
                    cetus::tick_math::get_sqrt_price_at_tick(lower_index),
                    liquidity,
                    true
                );
                liquidity
            }
        } else {
            amount_b = amount;
            if (cetus::i64::gte(current_index, upper_index)) {
                get_liquidity_from_b(
                    cetus::tick_math::get_sqrt_price_at_tick(lower_index),
                    cetus::tick_math::get_sqrt_price_at_tick(
                        upper_index
                    ),
                    amount,
                    false
                )
            } else {
                assert!(cetus::i64::gte(current_index, lower_index), 6);
                let liquidity = get_liquidity_from_b(cetus::tick_math::get_sqrt_price_at_tick(lower_index),
                    current_sqrt_price, amount, false);
                amount_a = get_delta_a(
                    current_sqrt_price,
                    cetus::tick_math::get_sqrt_price_at_tick(upper_index),
                    liquidity,
                    true
                );
                liquidity
            }
        };
        (liquidity, amount_a, amount_b)
    }

    public fun get_liquidity_from_b(arg0: u128, arg1: u128, arg2: u64, arg3: bool): u128 {
        let v0 = if (arg0 > arg1) {
            arg0 - arg1
        } else {
            arg1 - arg0
        };
        (cetus::math_u256::div_round((arg2 as u256) << 64, (v0 as u256), arg3) as u128)
    }

    public fun get_next_sqrt_price_a_up(arg0: u128, arg1: u128, arg2: u64, arg3: bool): u128 {
        if (arg2 == 0) {
            return arg0
        };
        let (v0, v1) = cetus::math_u256::checked_shlw(cetus::full_math_u128::full_mul_v2(arg0, arg1));
        if (v1) {
            abort 3
        };
        let v2 = if (arg3) {
            (cetus::math_u256::div_round(
                v0,
                ((arg1 as u256) << 64) + cetus::full_math_u128::full_mul_v2(arg0, (arg2 as u128)),
                true
            ) as u128)
        } else {
            (cetus::math_u256::div_round(
                v0,
                ((arg1 as u256) << 64) - cetus::full_math_u128::full_mul_v2(arg0, (arg2 as u128)),
                true
            ) as u128)
        };
        if (v2 > cetus::tick_math::max_sqrt_price()) {
            abort 1
        };
        if (v2 < cetus::tick_math::min_sqrt_price()) {
            abort 2
        };
        v2
    }

    public fun get_next_sqrt_price_b_down(arg0: u128, arg1: u128, arg2: u64, arg3: bool): u128 {
        let v0 = if (arg3) {
            arg0 + cetus::math_u128::checked_div_round((arg2 as u128) << 64, arg1, !arg3)
        } else {
            arg0 - cetus::math_u128::checked_div_round((arg2 as u128) << 64, arg1, !arg3)
        };
        if (v0 > cetus::tick_math::max_sqrt_price()) {
            abort 1
        };
        if (v0 < cetus::tick_math::min_sqrt_price()) {
            abort 2
        };
        v0
    }

    public fun get_next_sqrt_price_from_input(arg0: u128, arg1: u128, arg2: u64, arg3: bool): u128 {
        if (arg3) {
            get_next_sqrt_price_a_up(arg0, arg1, arg2, true)
        } else {
            get_next_sqrt_price_b_down(arg0, arg1, arg2, true)
        }
    }

    public fun get_next_sqrt_price_from_output(arg0: u128, arg1: u128, arg2: u64, arg3: bool): u128 {
        if (arg3) {
            get_next_sqrt_price_b_down(arg0, arg1, arg2, false)
        } else {
            get_next_sqrt_price_a_up(arg0, arg1, arg2, false)
        }
    }

    // decompiled from Move bytecode v6
}

