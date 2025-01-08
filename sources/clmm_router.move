module tap::clmm_router {
    public entry fun swap<T0, T1>(
        signer: &signer,
        pool_addr: address,
        a2b: bool,
        by_amount_in: bool,
        amount: u64,
        amount_limit: u64,
        sqrt_price: u128,
        partner_name: 0x1::string::String
    ) {
        let signer_addr = 0x1::signer::address_of(signer);
        let (coin_a, coin_b, flash_swap_receipt) = tap::pool::flash_swap<T0, T1>(
            pool_addr,
            signer_addr,
            partner_name,
            a2b,
            by_amount_in,
            amount,
            sqrt_price
        );
        let pay_amount = tap::pool::swap_pay_amount<T0, T1>(&flash_swap_receipt);
        let amount_in = if (a2b) {
            value<T1>(&coin_b)
        } else {
            value<T0>(&coin_a)
        };

        print(&format4(&b"bai={} pa{} ai={} al={}", by_amount_in, pay_amount, amount_in, amount_limit));

        if (by_amount_in) {
            assert!(pay_amount == amount, 7);
            assert!(amount_in >= amount_limit, 2);
        } else {
            assert!(amount_in == amount, 7);
            assert!(pay_amount <= amount_limit, 1);
        };
        if (a2b) {
            if (!is_account_registered<T1>(signer_addr)) {
                register<T1>(signer);
            };
            destroy_zero<T0>(coin_a);
            deposit<T1>(signer_addr, coin_b);
            tap::pool::repay_flash_swap<T0, T1>(
                withdraw<T0>(signer, pay_amount),
                zero<T1>(),
                flash_swap_receipt
            );
        } else {
            if (!is_account_registered<T0>(signer_addr)) {
                register<T0>(signer);
            };
            destroy_zero<T1>(coin_b);
            deposit<T0>(signer_addr, coin_a);
            tap::pool::repay_flash_swap<T0, T1>(
                zero<T0>(),
                withdraw<T1>(signer, pay_amount),
                flash_swap_receipt
            );
        };
    }

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
            tap::pool::open_position<T0, T1>(
                signer,
                pool_addr,
                integer_mate::i64::from_u64(tick_lower),
                integer_mate::i64::from_u64(
                    tick_upper
                )
            )
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

    public entry fun remove_liquidity<T0, T1>(
        arg0: &signer,
        arg1: address,
        arg2: u128,
        arg3: u64,
        arg4: u64,
        arg5: u64,
        arg6: bool
    ) {
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
            tap::pool::open_position<T0, T1>(
                signer,
                pool_addr,
                integer_mate::i64::from_u64(lower_tick_index),
                integer_mate::i64::from_u64(
                    upper_tick_index
                )
            )
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
        print(&add_lq_receipt);
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

    use aptos_std::debug::print;
    use aptos_std::string_utils::{format3, format4};
    use aptos_framework::coin::{value, is_account_registered, register, destroy_zero, deposit, withdraw, zero};
    #[test_only]
    use std::signer;
    #[test_only]
    use std::string;
    #[test_only]
    use std::string::utf8;
    #[test_only]
    use aptos_std::type_info::{type_of, struct_name};
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::coin::{
        initialize,
        mint,
        BurnCapability,
        FreezeCapability,
        MintCapability
    };
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use tap::pool;

    #[test_only]
    fun init_module_for_test(signer: &signer) {
        tap::factory::init_module_for_test(signer);
        let aptos_account = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&aptos_account);

        tap::config::init_clmm_acl(signer);
        tap::fee_tier::add_fee_tier(signer, 2, 100);
        tap::fee_tier::add_fee_tier(signer, 60, 10000);
    }

    #[test_only]
    struct CoinA {}

    #[test_only]
    struct CoinB {}

    #[test_only]
    struct FakeMoneyCapabilities<phantom FakeMoney> has key {
        burn_cap: BurnCapability<FakeMoney>,
        freeze_cap: FreezeCapability<FakeMoney>,
        mint_cap: MintCapability<FakeMoney>,
    }

    #[test_only]
    fun create_fake_money<FakeMoney>(
        signer: &signer,
        decimals: u8,
        amount: u64,
    ) {
        let type_info = type_of<FakeMoney>();

        let (burn_cap, freeze_cap, mint_cap) = initialize<FakeMoney>(
            signer,
            string::utf8(struct_name(&type_info)),
            string::utf8(struct_name(&type_info)),
            decimals,
            false
        );
        register<FakeMoney>(signer);
        let coins_minted = mint<FakeMoney>(amount, &mint_cap);
        deposit(signer::address_of(signer), coins_minted);
        move_to(signer, FakeMoneyCapabilities {
            burn_cap,
            freeze_cap,
            mint_cap,
        })
    }

    #[test_only]
    fun create_pool_for_test<A, B>(
        signer: &signer,
        tick_spacing: u64,
        curr_sqrt_price: u128
    ): address {
        tap::factory::create_pool<A, B>(signer, tick_spacing, curr_sqrt_price, string::utf8(b""))
    }

    #[test]
    fun create_pool_success() {
        let signer = &account::create_account_for_test(@tap);
        init_module_for_test(signer);
        create_pool_for_test<CoinA, CoinB>(signer, 60, 5919272212378807452);
    }

    #[test]
    fun add_liquidity_pool_success() {
        let signer = &account::create_account_for_test(@tap);
        init_module_for_test(signer);
        let pool_addr = create_pool_for_test<CoinA, CoinB>(signer, 2, 18448098543978665152);

        create_fake_money<CoinA>(signer, 6, 1_000_000_000000); // whUSDC
        create_fake_money<CoinB>(signer, 6, 1_000_000_000000); // lzUSDC
        add_liquidity_fix_token<CoinA, CoinB>(signer, pool_addr,
            10155_000,
            10157_000,
            true,
            18446744073709107980,
            443636,
            true,
            0);
    }

    #[test]
    fun swap_success() {
        let signer = &account::create_account_for_test(@tap);
        init_module_for_test(signer);
        let pool_addr = create_pool_for_test<CoinA, CoinB>(signer, 2, 18448098543978665152);

        create_fake_money<CoinA>(signer, 6, 1_000_000_000000); // whUSDC
        create_fake_money<CoinB>(signer, 6, 1_000_000_000000); // lzUSDC
        add_liquidity_fix_token<CoinA, CoinB>(signer, pool_addr,
            10155_000,
            10157_000,
            true,
            18446744073709107980,
            443636,
            true,
            0);

        swap<CoinA, CoinB>(
            signer,
            pool_addr,
            true,
            true,
            10155,
            10103,
            4295048016,
            utf8(b"")
        );
    }

    #[test]
    fun test_indexes() {
        pool::test_indexes(100);
    }
}

