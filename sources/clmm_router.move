module tap::clmm_router {
    // public entry fun swap<T0, T1>(arg0: &signer, arg1: address, arg2: bool, arg3: bool, arg4: u64, arg5: u64, arg6: u128, arg7: 0x1::string::String) {
    //     let v0 = 0x1::signer::address_of(arg0);
    //     let (v1, v2, v3) = tap::pool::flash_swap<T0, T1>(arg1, v0, arg7, arg2, arg3, arg4, arg6);
    //     let v4 = v3;
    //     let v5 = v2;
    //     let v6 = v1;
    //     let v7 = tap::pool::swap_pay_amount<T0, T1>(&v4);
    //     let v8 = if (arg2) {
    //         0x1::coin::value<T1>(&v5)
    //     } else {
    //         0x1::coin::value<T0>(&v6)
    //     };
    //     if (arg3) {
    //         assert!(v7 == arg4, 7);
    //         assert!(v8 >= arg5, 2);
    //     } else {
    //         assert!(v8 == arg4, 7);
    //         assert!(v7 <= arg5, 1);
    //     };
    //     if (arg2) {
    //         if (!0x1::coin::is_account_registered<T1>(v0)) {
    //             0x1::coin::register<T1>(arg0);
    //         };
    //         0x1::coin::destroy_zero<T0>(v6);
    //         0x1::coin::deposit<T1>(v0, v5);
    //         tap::pool::repay_flash_swap<T0, T1>(0x1::coin::withdraw<T0>(arg0, v7), 0x1::coin::zero<T1>(), v4);
    //     } else {
    //         if (!0x1::coin::is_account_registered<T0>(v0)) {
    //             0x1::coin::register<T0>(arg0);
    //         };
    //         0x1::coin::destroy_zero<T1>(v5);
    //         0x1::coin::deposit<T0>(v0, v6);
    //         tap::pool::repay_flash_swap<T0, T1>(0x1::coin::zero<T0>(), 0x1::coin::withdraw<T1>(arg0, v7), v4);
    //     };
    // }

    public entry fun accept_protocol_authority(arg0: &signer) {
        tap::config::accept_protocol_authority(arg0);
    }

    public entry fun add_role(arg0: &signer, arg1: address, arg2: u8) {
        tap::config::add_role(arg0, arg1, arg2);
    }

    public entry fun init_clmm_acl(arg0: &signer) {
        tap::config::init_clmm_acl(arg0);
    }

    public entry fun pause(arg0: &signer) {
        tap::config::pause(arg0);
    }

    public entry fun remove_role(arg0: &signer, arg1: address, arg2: u8) {
        tap::config::remove_role(arg0, arg1, arg2);
    }

    // public entry fun transfer_protocol_authority(arg0: &signer, arg1: address) {
    //     tap::config::transfer_protocol_authority(arg0, arg1);
    // }

    public entry fun unpause(arg0: &signer) {
        tap::config::unpause(arg0);
    }

    // public entry fun update_pool_create_authority(arg0: &signer, arg1: address) {
    //     tap::config::update_pool_create_authority(arg0, arg1);
    // }

    // public entry fun update_protocol_fee_claim_authority(arg0: &signer, arg1: address) {
    //     tap::config::update_protocol_fee_claim_authority(arg0, arg1);
    // }

    public entry fun update_protocol_fee_rate(arg0: &signer, arg1: u64) {
        tap::config::update_protocol_fee_rate(arg0, arg1);
    }

    public entry fun create_pool<T0, T1>(arg0: &signer, arg1: u64, arg2: u128, arg3: 0x1::string::String) {
        tap::factory::create_pool<T0, T1>(arg0, arg1, arg2, arg3);
    }

    public entry fun add_fee_tier(arg0: &signer, arg1: u64, arg2: u64) {
        tap::fee_tier::add_fee_tier(arg0, arg1, arg2);
    }

    public entry fun delete_fee_tier(arg0: &signer, arg1: u64) {
        tap::fee_tier::delete_fee_tier(arg0, arg1);
    }

    public entry fun update_fee_tier(arg0: &signer, arg1: u64, arg2: u64) {
        tap::fee_tier::update_fee_tier(arg0, arg1, arg2);
    }

    // public entry fun claim_ref_fee<T0>(arg0: &signer, arg1: 0x1::string::String) {
    //     tap::partner::claim_ref_fee<T0>(arg0, arg1);
    // }
    //
    // public entry fun create_partner(arg0: &signer, arg1: 0x1::string::String, arg2: u64, arg3: address, arg4: u64, arg5: u64) {
    //     tap::partner::create_partner(arg0, arg1, arg2, arg3, arg4, arg5);
    // }

    // public entry fun update_fee_rate<T0, T1>(arg0: &signer, arg1: address, arg2: u64) {
    //     tap::pool::update_fee_rate<T0, T1>(arg0, arg1, arg2);
    // }

    // public entry fun accept_rewarder_authority<T0, T1>(arg0: &signer, arg1: address, arg2: u8) {
    //     tap::pool::accept_rewarder_authority<T0, T1>(arg0, arg1, arg2);
    // }

    public entry fun add_liquidity<T0, T1>(
        signer: &signer,
        pool_addr: address,
        delta_liquidity: u128,
        max_amount_a: u64,
        max_amount_b: u64,
        tick_lower: u64,
        tick_upper: u64,
        is_open: bool,
        index: u64) {
        let pos_index = if (is_open) {
            tap::pool::open_position<T0, T1>(signer, pool_addr, integer_mate::i64::from_u64(tick_lower), integer_mate::i64::from_u64(
                tick_upper
            ))
        } else {
            // tap::pool::check_position_authority<T0, T1>(signer, pool_addr, index);
            let (lower_index, upper_index) = tap::pool::get_position_tick_range<T0, T1>(pool_addr, index);
            assert!(integer_mate::i64::eq(integer_mate::i64::from_u64(tick_lower), lower_index), 3);
            assert!(integer_mate::i64::eq(integer_mate::i64::from_u64(tick_upper), upper_index), 3);
            index
        };
        let add_lq_receipt = tap::pool::add_liquidity<T0, T1>(pool_addr, delta_liquidity, pos_index);
        let (v4, v5) = tap::pool::add_liqudity_pay_amount<T0, T1>(&add_lq_receipt);
        assert!(v4 <= max_amount_a, 1);
        assert!(v5 <= max_amount_b, 1);
        let v6 = if (v4 > 0) {
            0x1::coin::withdraw<T0>(signer, v4)
        } else {
            0x1::coin::zero<T0>()
        };
        let v7 = if (v5 > 0) {
            0x1::coin::withdraw<T1>(signer, v5)
        } else {
            0x1::coin::zero<T1>()
        };
        tap::pool::repay_add_liquidity<T0, T1>(v6, v7, add_lq_receipt);
    }

    // public entry fun collect_fee<T0, T1>(arg0: &signer, arg1: address, arg2: u64) {
    //     let v0 = 0x1::signer::address_of(arg0);
    //     let (v1, v2) = tap::pool::collect_fee<T0, T1>(arg0, arg1, arg2, true);
    //     if (!0x1::coin::is_account_registered<T0>(v0)) {
    //         0x1::coin::register<T0>(arg0);
    //     };
    //     if (!0x1::coin::is_account_registered<T1>(v0)) {
    //         0x1::coin::register<T1>(arg0);
    //     };
    //     0x1::coin::deposit<T0>(v0, v1);
    //     0x1::coin::deposit<T1>(v0, v2);
    // }

    // public entry fun collect_protocol_fee<T0, T1>(arg0: &signer, arg1: address) {
    //     let v0 = 0x1::signer::address_of(arg0);
    //     let (v1, v2) = tap::pool::collect_protocol_fee<T0, T1>(arg0, arg1);
    //     if (!0x1::coin::is_account_registered<T0>(v0)) {
    //         0x1::coin::register<T0>(arg0);
    //     };
    //     if (!0x1::coin::is_account_registered<T1>(v0)) {
    //         0x1::coin::register<T1>(arg0);
    //     };
    //     0x1::coin::deposit<T0>(v0, v1);
    //     0x1::coin::deposit<T1>(v0, v2);
    // }

    // public entry fun collect_rewarder<T0, T1, T2>(arg0: &signer, arg1: address, arg2: u8, arg3: u64) {
    //     let v0 = 0x1::signer::address_of(arg0);
    //     if (!0x1::coin::is_account_registered<T2>(v0)) {
    //         0x1::coin::register<T2>(arg0);
    //     };
    //     0x1::coin::deposit<T2>(v0, tap::pool::collect_rewarder<T0, T1, T2>(arg0, arg1, arg3, arg2, true));
    // }

    // public entry fun initialize_rewarder<T0, T1, T2>(arg0: &signer, arg1: address, arg2: address, arg3: u64) {
    //     tap::pool::initialize_rewarder<T0, T1, T2>(arg0, arg1, arg2, arg3);
    // }

    public entry fun remove_liquidity<T0, T1>(arg0: &signer, arg1: address, arg2: u128, arg3: u64, arg4: u64, arg5: u64, arg6: bool) {
        let (v0, v1) = tap::pool::remove_liquidity<T0, T1>(arg0, arg1, arg2, arg5);
        let v2 = v1;
        let v3 = v0;
        assert!(0x1::coin::value<T0>(&v3) >= arg3, 2);
        assert!(0x1::coin::value<T1>(&v2) >= arg4, 2);
        let v4 = 0x1::signer::address_of(arg0);
        if (!0x1::coin::is_account_registered<T0>(v4)) {
            0x1::coin::register<T0>(arg0);
        };
        if (!0x1::coin::is_account_registered<T1>(v4)) {
            0x1::coin::register<T1>(arg0);
        };
        0x1::coin::deposit<T0>(v4, v3);
        0x1::coin::deposit<T1>(v4, v2);
        // let (v5, v6) = tap::pool::collect_fee<T0, T1>(arg0, arg1, arg5, false);
        // 0x1::coin::deposit<T0>(v4, v5);
        // 0x1::coin::deposit<T1>(v4, v6);
        if (arg6) {
            tap::pool::checked_close_position<T0, T1>(arg0, arg1, arg5);
        };
    }

    // public entry fun transfer_rewarder_authority<T0, T1>(arg0: &signer, arg1: address, arg2: u8, arg3: address) {
    //     tap::pool::transfer_rewarder_authority<T0, T1>(arg0, arg1, arg2, arg3);
    // }

    // public entry fun update_pool_uri<T0, T1>(arg0: &signer, arg1: address, arg2: 0x1::string::String) {
    //     tap::pool::update_pool_uri<T0, T1>(arg0, arg1, arg2);
    // }

    // public entry fun accept_partner_receiver(arg0: &signer, arg1: 0x1::string::String) {
    //     tap::partner::accept_receiver(arg0, arg1);
    // }

    public entry fun add_liquidity_fix_token<T0, T1>(
        signer: &signer,
        pool_addr: address,
        amount_a: u64,
        amount_b: u64,
        fix_amount_a: bool,
        lower_tick_index: u64,
        upper_tick_index: u64,
        is_open: bool,
        index: u64) {
        let pos_index = if (is_open) {
            tap::pool::open_position<T0, T1>(signer, pool_addr, integer_mate::i64::from_u64(lower_tick_index), integer_mate::i64::from_u64(
                upper_tick_index
            ))
        } else {
            // tap::pool::check_position_authority<T0, T1>(signer, pool_addr, index);
            let (lower_index, upper_index) = tap::pool::get_position_tick_range<T0, T1>(pool_addr, index);
            assert!(integer_mate::i64::eq(integer_mate::i64::from_u64(lower_tick_index), lower_index), 3);
            assert!(integer_mate::i64::eq(integer_mate::i64::from_u64(upper_tick_index), upper_index), 3);
            index
        };
        let amount = if (fix_amount_a) {
            amount_a
        } else {
            amount_b
        };
        let add_lq_receipt = tap::pool::add_liquidity_fix_coin<T0, T1>(pool_addr, amount, fix_amount_a, pos_index);
        let (v5, v6) = tap::pool::add_liqudity_pay_amount<T0, T1>(&add_lq_receipt);
        if (fix_amount_a) {
            assert!(amount_a == v5 && v6 <= amount_b, 1);
        } else {
            assert!(amount_b == v6 && v5 <= amount_a, 1);
        };
        let v7 = if (v5 > 0) {
            0x1::coin::withdraw<T0>(signer, v5)
        } else {
            0x1::coin::zero<T0>()
        };
        let v8 = if (v6 > 0) {
            0x1::coin::withdraw<T1>(signer, v6)
        } else {
            0x1::coin::zero<T1>()
        };
        tap::pool::repay_add_liquidity<T0, T1>(v7, v8, add_lq_receipt);
    }

    public entry fun close_position<T0, T1>(arg0: &signer, arg1: address, arg2: u64) {
        if (!tap::pool::checked_close_position<T0, T1>(arg0, arg1, arg2)) {
            abort 9
        };
    }

    // public entry fun pause_pool<T0, T1>(arg0: &signer, arg1: address) {
    //     tap::pool::pause<T0, T1>(arg0, arg1);
    // }

    // public entry fun transfer_partner_receiver(arg0: &signer, arg1: 0x1::string::String, arg2: address) {
    //     tap::partner::transfer_receiver(arg0, arg1, arg2);
    // }

    // public entry fun unpause_pool<T0, T1>(arg0: &signer, arg1: address) {
    //     tap::pool::unpause<T0, T1>(arg0, arg1);
    // }

    // public entry fun update_partner_fee_rate(arg0: &signer, arg1: 0x1::string::String, arg2: u64) {
    //     tap::partner::update_fee_rate(arg0, arg1, arg2);
    // }

    // public entry fun update_partner_time(arg0: &signer, arg1: 0x1::string::String, arg2: u64, arg3: u64) {
    //     tap::partner::update_time(arg0, arg1, arg2, arg3);
    // }

    // public entry fun update_rewarder_emission<T0, T1, T2>(arg0: &signer, arg1: address, arg2: u8, arg3: u128) {
    //     tap::pool::update_emission<T0, T1, T2>(arg0, arg1, arg2, arg3);
    // }

    // decompiled from Move bytecode v6
}

