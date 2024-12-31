module cetus::pool {
    #[event]
    struct AcceptRewardAuthEvent has drop, store {
        pool_address: address,
        index: u8,
        authority: address,
    }

    #[event]
    struct AddLiquidityEvent has drop, store {
        pool_address: address,
        tick_lower: cetus::i64::I64,
        tick_upper: cetus::i64::I64,
        liquidity: u128,
        amount_a: u64,
        amount_b: u64,
        index: u64,
    }

    #[event]
    struct AddLiquidityReceipt<phantom T0, phantom T1> {
        pool_address: address,
        amount_a: u64,
        amount_b: u64,
    }

    #[event]
    struct CalculatedSwapResult has copy, drop, store {
        amount_in: u64,
        amount_out: u64,
        fee_amount: u64,
        fee_rate: u64,
        after_sqrt_price: u128,
        is_exceed: bool,
        step_results: vector<SwapStepResult>,
    }

    #[event]
    struct ClosePositionEvent has drop, store {
        user: address,
        pool: address,
        index: u64,
    }

    #[event]
    struct CollectFeeEvent has drop, store {
        index: u64,
        user: address,
        pool_address: address,
        amount_a: u64,
        amount_b: u64,
    }

    #[event]
    struct CollectProtocolFeeEvent has drop, store {
        pool_address: address,
        amount_a: u64,
        amount_b: u64,
    }

    #[event]
    struct CollectRewardEvent has drop, store {
        pos_index: u64,
        user: address,
        pool_address: address,
        amount: u64,
        index: u8,
    }

    #[event]
    struct FlashSwapReceipt<phantom T0, phantom T1> {
        pool_address: address,
        a2b: bool,
        partner_name: 0x1::string::String,
        pay_amount: u64,
        ref_fee_amount: u64,
    }

    #[event]
    struct OpenPositionEvent has drop, store {
        user: address,
        pool: address,
        tick_lower: cetus::i64::I64,
        tick_upper: cetus::i64::I64,
        index: u64,
    }

    struct Pool<phantom T0, phantom T1> has key {
        index: u64,
        collection_name: 0x1::string::String,
        coin_a: 0x1::coin::Coin<T0>,
        coin_b: 0x1::coin::Coin<T1>,
        tick_spacing: u64,
        fee_rate: u64,
        liquidity: u128,
        current_sqrt_price: u128,
        current_tick_index: cetus::i64::I64,
        fee_growth_global_a: u128,
        fee_growth_global_b: u128,
        fee_protocol_coin_a: u64,
        fee_protocol_coin_b: u64,
        tick_indexes: 0x1::table::Table<u64, 0x1::bit_vector::BitVector>,
        ticks: 0x1::table::Table<cetus::i64::I64, Tick>,
        rewarder_infos: vector<Rewarder>,
        rewarder_last_updated_time: u64,
        positions: 0x1::table::Table<u64, Position>,
        position_index: u64,
        is_pause: bool,
        uri: 0x1::string::String,
        signer_cap: 0x1::account::SignerCapability,
    }

    struct Position has copy, drop, store {
        pool: address,
        index: u64,
        liquidity: u128,
        tick_lower_index: cetus::i64::I64,
        tick_upper_index: cetus::i64::I64,
        fee_growth_inside_a: u128,
        fee_owed_a: u64,
        fee_growth_inside_b: u128,
        fee_owed_b: u64,
        rewarder_infos: vector<PositionRewarder>,
    }

    struct PositionRewarder has copy, drop, store {
        growth_inside: u128,
        amount_owed: u64,
    }

    #[event]
    struct RemoveLiquidityEvent has drop, store {
        pool_address: address,
        tick_lower: cetus::i64::I64,
        tick_upper: cetus::i64::I64,
        liquidity: u128,
        amount_a: u64,
        amount_b: u64,
        index: u64,
    }

    struct Rewarder has copy, drop, store {
        coin_type: 0x1::type_info::TypeInfo,
        authority: address,
        pending_authority: address,
        emissions_per_second: u128,
        growth_global: u128,
    }

    #[event]
    struct SwapEvent has drop, store {
        atob: bool,
        pool_address: address,
        swap_from: address,
        partner: 0x1::string::String,
        amount_in: u64,
        amount_out: u64,
        ref_amount: u64,
        fee_amount: u64,
        vault_a_amount: u64,
        vault_b_amount: u64,
    }

    struct SwapResult has copy, drop {
        amount_in: u64,
        amount_out: u64,
        fee_amount: u64,
        ref_fee_amount: u64,
    }

    struct SwapStepResult has copy, drop, store {
        current_sqrt_price: u128,
        target_sqrt_price: u128,
        current_liquidity: u128,
        amount_in: u64,
        amount_out: u64,
        fee_amount: u64,
        remainer_amount: u64,
    }

    struct Tick has copy, drop, store {
        index: cetus::i64::I64,
        sqrt_price: u128,
        liquidity_net: cetus::i128::I128,
        liquidity_gross: u128,
        fee_growth_outside_a: u128,
        fee_growth_outside_b: u128,
        rewarders_growth_outside: vector<u128>,
    }

    #[event]
    struct TransferRewardAuthEvent has drop, store {
        pool_address: address,
        index: u8,
        old_authority: address,
        new_authority: address,
    }

    #[event]
    struct UpdateEmissionEvent has drop, store {
        pool_address: address,
        index: u8,
        emissions_per_second: u128,
    }

    #[event]
    struct UpdateFeeRateEvent has drop, store {
        pool_address: address,
        old_fee_rate: u64,
        new_fee_rate: u64,
    }

    public fun new<T0, T1>(
        arg0: &signer,
        arg1: u64,
        arg2: u128,
        arg3: u64,
        arg4: 0x1::string::String,
        arg5: 0x1::account::SignerCapability
    ): 0x1::string::String {
        assert!(0x1::type_info::type_of<T0>() != 0x1::type_info::type_of<T1>(), 37);
        // let v0 = cetus::position_nft::create_collection<T0, T1>(
        //     arg0,
        //     arg1,
        //     0x1::string::utf8(b"Cetus Liquidity Position"),
        //     arg4
        // );
        let v1 = Pool<T0, T1> {
            index: arg3,
            collection_name: 0x1::string::utf8(b"Pool"),
            coin_a: 0x1::coin::zero<T0>(),
            coin_b: 0x1::coin::zero<T1>(),
            tick_spacing: arg1,
            fee_rate: cetus::fee_tier::get_fee_rate(arg1),
            liquidity: 0,
            current_sqrt_price: arg2,
            current_tick_index: cetus::tick_math::get_tick_at_sqrt_price(arg2),
            fee_growth_global_a: 0,
            fee_growth_global_b: 0,
            fee_protocol_coin_a: 0,
            fee_protocol_coin_b: 0,
            tick_indexes: 0x1::table::new<u64, 0x1::bit_vector::BitVector>(),
            ticks: 0x1::table::new<cetus::i64::I64, Tick>(),
            rewarder_infos: 0x1::vector::empty<Rewarder>(),
            rewarder_last_updated_time: 0,
            positions: 0x1::table::new<u64, Position>(),
            position_index: 1,
            is_pause: false,
            uri: arg4,
            signer_cap: arg5,
        };
        move_to<Pool<T0, T1>>(arg0, v1);
        0x3::token::initialize_token_store(arg0);
        // cetus::position_nft::mint(arg0, arg0, arg3, 0, arg4, v0);
        // v0
        0x1::string::utf8(b"PoolCreated")
    }

    // public fun accept_rewarder_authority<T0, T1>(arg0: &signer, arg1: address, arg2: u8) acquires Pool {
    //     let v0 = 0x1::signer::address_of(arg0);
    //     let v1 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v1);
    //     assert!((arg2 as u64) < 0x1::vector::length<Rewarder>(&v1.rewarder_infos), 23);
    //     let v2 = 0x1::vector::borrow_mut<Rewarder>(&mut v1.rewarder_infos, (arg2 as u64));
    //     assert!(v2.pending_authority == v0, 26);
    //     v2.pending_authority = @0x0;
    //     v2.authority = v0;
    //     let v3 = AcceptRewardAuthEvent {
    //         pool_address: arg1,
    //         index: arg2,
    //         authority: v0,
    //     };
    //     0x1::event::emit_event<AcceptRewardAuthEvent>(&mut v1.accept_reward_auth_events, v3);
    // }

    public fun add_liqudity_pay_amount<T0, T1>(arg0: &AddLiquidityReceipt<T0, T1>): (u64, u64) {
        (arg0.amount_a, arg0.amount_b)
    }

    public fun add_liquidity<T0, T1>(
        pool_addr: address,
        delta_liquidity: u128,
        pos_index: u64
    ): AddLiquidityReceipt<T0, T1> acquires Pool {
        assert!(delta_liquidity != 0, 11);
        add_liquidity_internal<T0, T1>(pool_addr, pos_index, false, delta_liquidity, 0, false)
    }

    public fun add_liquidity_fix_coin<T0, T1>(
        pool_addr: address,
        amount: u64,
        fix_amount_a: bool,
        pos_index: u64
    ): AddLiquidityReceipt<T0, T1> acquires Pool {
        assert!(amount > 0, 6);
        add_liquidity_internal<T0, T1>(pool_addr, pos_index, true, 0, amount, fix_amount_a)
    }

    fun add_liquidity_internal<T0, T1>(
        pool_addr: address,
        pos_index: u64,
        is_fixed_amount: bool,
        delta_liquidity: u128,
        amount: u64,
        fix_amount_a: bool
    ): AddLiquidityReceipt<T0, T1> acquires Pool {
        let pool = borrow_global_mut<Pool<T0, T1>>(pool_addr);
        assert_status<T0, T1>(pool);
        update_rewarder<T0, T1>(pool);
        let (lower_index, upper_index) = get_position_tick_range_by_pool<T0, T1>(pool, pos_index);
        let (fee_growth_a, fee_growth_b) = get_fee_in_tick_range<T0, T1>(pool, lower_index, upper_index);
        let reward = get_reward_in_tick_range<T0, T1>(pool, lower_index, upper_index);
        let position = 0x1::table::borrow_mut<u64, Position>(&mut pool.positions, pos_index);
        update_position_fee_and_reward(
            position,
            fee_growth_a,
            fee_growth_b,
            reward,
        );
        let (amount_a, amount_b, delta_liquidity) = if (is_fixed_amount) {
            let (v9, v10, v11) = cetus::clmm_math::get_liquidity_from_amount(
                lower_index, upper_index, pool.current_tick_index, pool.current_sqrt_price, amount, fix_amount_a);
            (v10, v11, v9)
        } else {
            let (v12, v13) = cetus::clmm_math::get_amount_by_liquidity(lower_index,
                upper_index, pool.current_tick_index, pool.current_sqrt_price,
                delta_liquidity, true);
            (v12, v13, delta_liquidity)
        };
        update_position_liquidity(position, delta_liquidity, true);
        upsert_tick_by_liquidity<T0, T1>(pool, lower_index, delta_liquidity, true, false);
        upsert_tick_by_liquidity<T0, T1>(pool, upper_index, delta_liquidity, true, true);
        let (new_liquidity, overflow) = if (cetus::i64::gte(pool.current_tick_index, lower_index) && cetus::i64::lt(
            pool.current_tick_index,
            upper_index
        )) {
            cetus::math_u128::overflowing_add(pool.liquidity, delta_liquidity)
        } else {
            (pool.liquidity, false)
        };
        assert!(!overflow, 7);
        pool.liquidity = new_liquidity;
        let event = AddLiquidityEvent {
            pool_address: pool_addr,
            tick_lower: lower_index,
            tick_upper: upper_index,
            liquidity: delta_liquidity,
            amount_a,
            amount_b,
            index: pos_index,
        };
        0x1::event::emit(event);
        AddLiquidityReceipt<T0, T1> {
            pool_address: pool_addr,
            amount_a,
            amount_b,
        }
    }

    fun assert_status<T0, T1>(arg0: &Pool<T0, T1>) {
        cetus::config::assert_protocol_status();
        if (arg0.is_pause) {
            abort 32
        };
    }

    fun borrow_mut_tick_with_default(
        arg0: &mut 0x1::table::Table<u64, 0x1::bit_vector::BitVector>,
        arg1: &mut 0x1::table::Table<cetus::i64::I64, Tick>,
        arg2: u64,
        arg3: cetus::i64::I64
    ): &mut Tick {
        let (v0, v1) = tick_position(arg3, arg2);
        if (!0x1::table::contains<u64, 0x1::bit_vector::BitVector>(arg0, v0)) {
            0x1::table::add<u64, 0x1::bit_vector::BitVector>(arg0, v0, 0x1::bit_vector::new(1000));
        };
        0x1::bit_vector::set(0x1::table::borrow_mut<u64, 0x1::bit_vector::BitVector>(arg0, v0), v1);
        if (!0x1::table::contains<cetus::i64::I64, Tick>(arg1, arg3)) {
            0x1::table::borrow_mut_with_default<cetus::i64::I64, Tick>(arg1, arg3, default_tick(arg3))
        } else {
            0x1::table::borrow_mut<cetus::i64::I64, Tick>(arg1, arg3)
        }
    }

    fun borrow_tick<T0, T1>(pool: &Pool<T0, T1>, arg1: cetus::i64::I64): 0x1::option::Option<Tick> {
        let (v0, _) = tick_position(arg1, pool.tick_spacing);
        if (!0x1::table::contains<u64, 0x1::bit_vector::BitVector>(&pool.tick_indexes, v0)) {
            return 0x1::option::none<Tick>()
        };
        if (!0x1::table::contains<cetus::i64::I64, Tick>(&pool.ticks, arg1)) {
            return 0x1::option::none<Tick>()
        };
        0x1::option::some<Tick>(*0x1::table::borrow<cetus::i64::I64, Tick>(&pool.ticks, arg1))
    }

    // public fun calculate_swap_result<T0, T1>(arg0: address, arg1: bool, arg2: bool, arg3: u64) : CalculatedSwapResult acquires Pool {
    //     let v0 = borrow_global<Pool<T0, T1>>(arg0);
    //     let v1 = v0.current_sqrt_price;
    //     let v2 = v0.liquidity;
    //     let v3 = default_swap_result();
    //     let v4 = arg3;
    //     let v5 = v0.current_tick_index;
    //     let v6 = tick_max(v0.tick_spacing);
    //     let v7 = CalculatedSwapResult{
    //         amount_in        : 0,
    //         amount_out       : 0,
    //         fee_amount       : 0,
    //         fee_rate         : v0.fee_rate,
    //         after_sqrt_price : v0.current_sqrt_price,
    //         is_exceed        : false,
    //         step_results     : 0x1::vector::empty<SwapStepResult>(),
    //     };
    //     while (v4 > 0) {
    //         if (cetus::i64::gt(v5, v6) || cetus::i64::lt(v5, tick_min(v0.tick_spacing))) {
    //             v7.is_exceed = true;
    //             break
    //         };
    //         let v8 = get_next_tick_for_swap<T0, T1>(v0, v5, arg1, v6);
    //         if (0x1::option::is_none<Tick>(&v8)) {
    //             v7.is_exceed = true;
    //             break
    //         };
    //         let v9 = 0x1::option::destroy_some<Tick>(v8);
    //         let v10 = v9.sqrt_price;
    //         let (v11, v12, v13, v14) = cetus::clmm_math::compute_swap_step(v1, v10, v2, v4, v0.fee_rate, arg1, arg2);
    //         if (v11 != 0 || v14 != 0) {
    //             if (arg2) {
    //                 let v15 = check_sub_remainer_amount(v4, v11);
    //                 v4 = check_sub_remainer_amount(v15, v14);
    //             } else {
    //                 v4 = check_sub_remainer_amount(v4, v12);
    //             };
    //             let v16 = &mut v3;
    //             update_swap_result(v16, v11, v12, v14);
    //         };
    //         let v17 = SwapStepResult{
    //             current_sqrt_price : v1,
    //             target_sqrt_price  : v10,
    //             current_liquidity  : v2,
    //             amount_in          : v11,
    //             amount_out         : v12,
    //             fee_amount         : v14,
    //             remainer_amount    : v4,
    //         };
    //         0x1::vector::push_back<SwapStepResult>(&mut v7.step_results, v17);
    //         if (v13 == v9.sqrt_price) {
    //             v1 = v9.sqrt_price;
    //             let v18 = if (arg1) {
    //                 cetus::i128::neg(v9.liquidity_net)
    //             } else {
    //                 v9.liquidity_net
    //             };
    //             if (!cetus::i128::is_neg(v18)) {
    //                 let (v19, v20) = cetus::math_u128::overflowing_add(v2, cetus::i128::abs_u128(v18));
    //                 if (v20) {
    //                     abort 7
    //                 };
    //                 v2 = v19;
    //             } else {
    //                 let (v21, v22) = cetus::math_u128::overflowing_sub(v2, cetus::i128::abs_u128(v18));
    //                 if (v22) {
    //                     abort 8
    //                 };
    //                 v2 = v21;
    //             };
    //         } else {
    //             v1 = v13;
    //         };
    //         if (arg1) {
    //             v5 = cetus::i64::sub(v9.index, cetus::i64::from(1));
    //             continue
    //         };
    //         v5 = v9.index;
    //     };
    //     v7.amount_in = v3.amount_in;
    //     v7.amount_out = v3.amount_out;
    //     v7.fee_amount = v3.fee_amount;
    //     v7.after_sqrt_price = v1;
    //     v7
    // }

    // public fun check_position_authority<T0, T1>(arg0: &signer, arg1: address, arg2: u64) acquires Pool {
    //     let v0 = borrow_global<Pool<T0, T1>>(arg1);
    //     if (!0x1::table::contains<u64, Position>(&v0.positions, arg2)) {
    //         abort 29
    //     };
    //     assert!(
    //         0x3::token::balance_of(
    //             0x1::signer::address_of(arg0),
    //             0x3::token::create_token_id(
    //                 0x3::token::create_token_data_id(
    //                     0x1::account::get_signer_capability_address(&v0.signer_cap),
    //                     v0.collection_name,
    //                     cetus::position_nft::position_name(v0.index, arg2)
    //                 ),
    //                 0
    //             )
    //         ) == 1,
    //         28
    //     );
    // }

    fun check_sub_remainer_amount(arg0: u64, arg1: u64): u64 {
        let (v0, v1) = cetus::math_u64::overflowing_sub(arg0, arg1);
        if (v1) {
            abort 13
        };
        v0
    }

    public fun checked_close_position<T0, T1>(arg0: &signer, arg1: address, arg2: u64): bool acquires Pool {
        // check_position_authority<T0, T1>(arg0, arg1, arg2);
        let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
        assert_status<T0, T1>(v0);
        let v1 = 0x1::table::borrow<u64, Position>(&v0.positions, arg2);
        if (v1.liquidity != 0) {
            return false
        };
        if (v1.fee_owed_a > 0 || v1.fee_owed_b > 0) {
            return false
        };
        let v2 = 0;
        while (v2 < 3) {
            if (0x1::vector::borrow<PositionRewarder>(&v1.rewarder_infos, v2).amount_owed != 0) {
                return false
            };
            v2 = v2 + 1;
        };
        0x1::table::remove<u64, Position>(&mut v0.positions, arg2);
        let v3 = 0x1::account::create_signer_with_capability(&v0.signer_cap);
        let v4 = 0x1::signer::address_of(arg0);
        // cetus::position_nft::burn(&v3, v4, v0.collection_name, v0.index, arg2);
        let v5 = ClosePositionEvent {
            user: v4,
            pool: arg1,
            index: arg2,
        };
        0x1::event::emit(v5);
        true
    }

    // public fun collect_fee<T0, T1>(
    //     arg0: &signer,
    //     arg1: address,
    //     arg2: u64,
    //     arg3: bool
    // ): (0x1::coin::Coin<T0>, 0x1::coin::Coin<T1>) acquires Pool {
    //     check_position_authority<T0, T1>(arg0, arg1, arg2);
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v0);
    //     let v1 = if (arg3) {
    //         let (v2, v3) = get_position_tick_range_by_pool<T0, T1>(v0, arg2);
    //         let (v4, v5) = get_fee_in_tick_range<T0, T1>(v0, v2, v3);
    //         let v6 = 0x1::table::borrow_mut<u64, Position>(&mut v0.positions, arg2);
    //         update_position_fee(v6, v4, v5);
    //         v6
    //     } else {
    //         0x1::table::borrow_mut<u64, Position>(&mut v0.positions, arg2)
    //     };
    //     let v7 = v1.fee_owed_a;
    //     let v8 = v1.fee_owed_b;
    //     v1.fee_owed_a = 0;
    //     v1.fee_owed_b = 0;
    //     let v9 = CollectFeeEvent {
    //         index: arg2,
    //         user: 0x1::signer::address_of(arg0),
    //         pool_address: arg1,
    //         amount_a: v7,
    //         amount_b: v8,
    //     };
    //     0x1::event::emit_event<CollectFeeEvent>(&mut v0.collect_fee_events, v9);
    //     (0x1::coin::extract<T0>(&mut v0.coin_a, v7), 0x1::coin::extract<T1>(&mut v0.coin_b, v8))
    // }

    // public fun collect_protocol_fee<T0, T1>(
    //     arg0: &signer,
    //     arg1: address
    // ): (0x1::coin::Coin<T0>, 0x1::coin::Coin<T1>) acquires Pool {
    //     cetus::config::assert_protocol_fee_claim_authority(arg0);
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v0);
    //     let v1 = v0.fee_protocol_coin_a;
    //     let v2 = v0.fee_protocol_coin_b;
    //     v0.fee_protocol_coin_a = 0;
    //     v0.fee_protocol_coin_b = 0;
    //     let v3 = CollectProtocolFeeEvent {
    //         pool_address: arg1,
    //         amount_a: v1,
    //         amount_b: v2,
    //     };
    //     0x1::event::emit_event<CollectProtocolFeeEvent>(&mut v0.collect_protocol_fee_events, v3);
    //     (0x1::coin::extract<T0>(&mut v0.coin_a, v1), 0x1::coin::extract<T1>(&mut v0.coin_b, v2))
    // }

    // public fun collect_rewarder<T0, T1, T2>(
    //     arg0: &signer,
    //     arg1: address,
    //     arg2: u64,
    //     arg3: u8,
    //     arg4: bool
    // ): 0x1::coin::Coin<T2> acquires Pool {
    //     check_position_authority<T0, T1>(arg0, arg1, arg2);
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v0);
    //     update_rewarder<T0, T1>(v0);
    //     let v1 = if (arg4) {
    //         let (v2, v3) = get_position_tick_range_by_pool<T0, T1>(v0, arg2);
    //         let v4 = 0x1::table::borrow_mut<u64, Position>(&mut v0.positions, arg2);
    //         update_position_rewarder(v4, get_reward_in_tick_range<T0, T1>(v0, v2, v3));
    //         v4
    //     } else {
    //         0x1::table::borrow_mut<u64, Position>(&mut v0.positions, arg2)
    //     };
    //     let v5 = 0x1::account::create_signer_with_capability(&v0.signer_cap);
    //     let v6 = &mut 0x1::vector::borrow_mut<PositionRewarder>(&mut v1.rewarder_infos, (arg3 as u64)).amount_owed;
    //     let v7 = 0x1::coin::withdraw<T2>(&v5, *v6);
    //     *v6 = 0;
    //     let v8 = CollectRewardEvent {
    //         pos_index: arg2,
    //         user: 0x1::signer::address_of(arg0),
    //         pool_address: arg1,
    //         amount: 0x1::coin::value<T2>(&v7),
    //         index: arg3,
    //     };
    //     0x1::event::emit_event<CollectRewardEvent>(&mut v0.collect_reward_events, v8);
    //     v7
    // }

    // fun cross_tick_and_update_liquidity<T0, T1>(arg0: &mut Pool<T0, T1>, arg1: cetus::i64::I64, arg2: bool) {
    //     let v0 = 0x1::table::borrow_mut<cetus::i64::I64, Tick>(&mut arg0.ticks, arg1);
    //     let v1 = if (arg2) {
    //         cetus::i128::neg(v0.liquidity_net)
    //     } else {
    //         v0.liquidity_net
    //     };
    //     if (!cetus::i128::is_neg(v1)) {
    //         let (v2, v3) = cetus::math_u128::overflowing_add(arg0.liquidity, cetus::i128::abs_u128(v1));
    //         if (v3) {
    //             abort 7
    //         };
    //         arg0.liquidity = v2;
    //     } else {
    //         let (v4, v5) = cetus::math_u128::overflowing_sub(arg0.liquidity, cetus::i128::abs_u128(v1));
    //         if (v5) {
    //             abort 8
    //         };
    //         arg0.liquidity = v4;
    //     };
    //     v0.fee_growth_outside_a = cetus::math_u128::wrapping_sub(arg0.fee_growth_global_a, v0.fee_growth_outside_a);
    //     v0.fee_growth_outside_b = cetus::math_u128::wrapping_sub(arg0.fee_growth_global_b, v0.fee_growth_outside_b);
    //     let v6 = 0;
    //     while (v6 < 0x1::vector::length<Rewarder>(&arg0.rewarder_infos)) {
    //         *0x1::vector::borrow_mut<u128>(&mut v0.rewarders_growth_outside, v6) = cetus::math_u128::wrapping_sub(0x1::vector::borrow<Rewarder>(&arg0.rewarder_infos, v6).growth_global, *0x1::vector::borrow<u128>(&v0.rewarders_growth_outside, v6));
    //         v6 = v6 + 1;
    //     };
    // }

    // fun default_swap_result() : SwapResult {
    //     SwapResult{
    //         amount_in      : 0,
    //         amount_out     : 0,
    //         fee_amount     : 0,
    //         ref_fee_amount : 0,
    //     }
    // }

    fun default_tick(arg0: cetus::i64::I64): Tick {
        Tick {
            index: arg0,
            sqrt_price: cetus::tick_math::get_sqrt_price_at_tick(arg0),
            liquidity_net: cetus::i128::from(0),
            liquidity_gross: 0,
            fee_growth_outside_a: 0,
            fee_growth_outside_b: 0,
            rewarders_growth_outside: vector[0, 0, 0],
        }
    }

    public fun fetch_positions<T0, T1>(arg0: address, arg1: u64, arg2: u64): (u64, vector<Position>) acquires Pool {
        let v0 = borrow_global<Pool<T0, T1>>(arg0);
        let v1 = 0x1::vector::empty<Position>();
        let v2 = 0;
        while (v2 < arg2 && arg1 < v0.position_index) {
            if (0x1::table::contains<u64, Position>(&v0.positions, arg1)) {
                0x1::vector::push_back<Position>(&mut v1, *0x1::table::borrow<u64, Position>(&v0.positions, arg1));
                v2 = v2 + 1;
            };
            arg1 = arg1 + 1;
        };
        (arg1, v1)
    }

    public fun fetch_ticks<T0, T1>(
        arg0: address,
        arg1: u64,
        arg2: u64,
        arg3: u64
    ): (u64, u64, vector<Tick>) acquires Pool {
        let v0 = borrow_global_mut<Pool<T0, T1>>(arg0);
        let v1 = v0.tick_spacing;
        let v2 = arg1;
        let v3 = 0x1::vector::empty<Tick>();
        let v4 = arg2;
        let v5 = 0;
        while (v2 >= 0 && v2 <= tick_indexes_max(v1)) {
            if (0x1::table::contains<u64, 0x1::bit_vector::BitVector>(&v0.tick_indexes, v2)) {
                let v6 = 0x1::table::borrow<u64, 0x1::bit_vector::BitVector>(&v0.tick_indexes, v2);
                while (v4 >= 0 && v4 < 1000) {
                    if (0x1::bit_vector::is_index_set(v6, v4)) {
                        let v7 = v5 + 1;
                        v5 = v7;
                        0x1::vector::push_back<Tick>(
                            &mut v3,
                            *0x1::table::borrow<cetus::i64::I64, Tick>(
                                &v0.ticks,
                                cetus::i64::sub(cetus::i64::from((1000 * v2 + v4) * v1), tick_max(v1))
                            )
                        );
                        if (v7 == arg3) {
                            return (v2, v4, v3)
                        };
                    };
                    v4 = v4 + 1;
                };
                v4 = 0;
            };
            v2 = v2 + 1;
        };
        (v2, v4, v3)
    }

    // public fun flash_swap<T0, T1>(arg0: address, arg1: address, arg2: 0x1::string::String, arg3: bool, arg4: bool, arg5: u64, arg6: u128) : (0x1::coin::Coin<T0>, 0x1::coin::Coin<T1>, FlashSwapReceipt<T0, T1>) acquires Pool {
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg0);
    //     assert_status<T0, T1>(v0);
    //     update_rewarder<T0, T1>(v0);
    //     if (arg3) {
    //         assert!(v0.current_sqrt_price > arg6 && arg6 >= cetus::tick_math::min_sqrt_price(), 22);
    //     } else {
    //         assert!(v0.current_sqrt_price < arg6 && arg6 <= cetus::tick_math::max_sqrt_price(), 22);
    //     };
    //     let v1 = swap_in_pool<T0, T1>(v0, arg3, arg4, arg6, arg5, cetus::config::get_protocol_fee_rate(), cetus::partner::get_ref_fee_rate(arg2));
    //     let v2 = SwapEvent{
    //         atob           : arg3,
    //         pool_address   : arg0,
    //         swap_from      : arg1,
    //         partner        : arg2,
    //         amount_in      : v1.amount_in,
    //         amount_out     : v1.amount_out,
    //         ref_amount     : v1.ref_fee_amount,
    //         fee_amount     : v1.fee_amount,
    //         vault_a_amount : 0x1::coin::value<T0>(&v0.coin_a),
    //         vault_b_amount : 0x1::coin::value<T1>(&v0.coin_b),
    //     };
    //     0x1::event::emit_event<SwapEvent>(&mut v0.swap_events, v2);
    //     let (v3, v4) = if (arg3) {
    //         (0x1::coin::zero<T0>(), 0x1::coin::extract<T1>(&mut v0.coin_b, v1.amount_out))
    //     } else {
    //         (0x1::coin::extract<T0>(&mut v0.coin_a, v1.amount_out), 0x1::coin::zero<T1>())
    //     };
    //     let v5 = FlashSwapReceipt<T0, T1>{
    //         pool_address   : arg0,
    //         a2b            : arg3,
    //         partner_name   : arg2,
    //         pay_amount     : v1.amount_in + v1.fee_amount,
    //         ref_fee_amount : v1.ref_fee_amount,
    //     };
    //     (v3, v4, v5)
    // }

    fun get_fee_in_tick_range<T0, T1>(
        pool: &Pool<T0, T1>,
        lower_index: cetus::i64::I64,
        upper_index: cetus::i64::I64
    ): (u128, u128) {
        let lower_tick = borrow_tick<T0, T1>(pool, lower_index);
        let upper_tick = borrow_tick<T0, T1>(pool, upper_index);
        let current_tick = pool.current_tick_index;
        let (v3, v4) = if (0x1::option::is_none<Tick>(&lower_tick)) {
            (pool.fee_growth_global_a, pool.fee_growth_global_b)
        } else {
            let lower_tick = 0x1::option::borrow<Tick>(&lower_tick);
            if (cetus::i64::lt(current_tick, lower_index)) {
                (cetus::math_u128::wrapping_sub(
                    pool.fee_growth_global_a,
                    lower_tick.fee_growth_outside_a
                ), cetus::math_u128::wrapping_sub(
                    pool.fee_growth_global_b, lower_tick.fee_growth_outside_b))
            } else {
                (lower_tick.fee_growth_outside_a, lower_tick.fee_growth_outside_b)
            }
        };
        let (v6, v7) = if (0x1::option::is_none<Tick>(&upper_tick)) {
            (0, 0)
        } else {
            let upper_tick = 0x1::option::borrow<Tick>(&upper_tick);
            if (cetus::i64::lt(current_tick, upper_index)) {
                (upper_tick.fee_growth_outside_a, upper_tick.fee_growth_outside_b)
            } else {
                (cetus::math_u128::wrapping_sub(
                    pool.fee_growth_global_a,
                    upper_tick.fee_growth_outside_a
                ), cetus::math_u128::wrapping_sub(
                    pool.fee_growth_global_b, upper_tick.fee_growth_outside_b))
            }
        };
        (cetus::math_u128::wrapping_sub(
            cetus::math_u128::wrapping_sub(pool.fee_growth_global_a, v3),
            v6
        ), cetus::math_u128::wrapping_sub(cetus::math_u128::wrapping_sub(
            pool.fee_growth_global_b, v4), v7))
    }

    // fun get_next_tick_for_swap<T0, T1>(arg0: &Pool<T0, T1>, arg1: cetus::i64::I64, arg2: bool, arg3: cetus::i64::I64) : 0x1::option::Option<Tick> {
    //     let v0 = arg0.tick_spacing;
    //     let (v1, v2) = tick_position(arg1, v0);
    //     let v3 = v2;
    //     let v4 = v1;
    //     if (!arg2) {
    //         v3 = v2 + 1;
    //     };
    //     while (v4 >= 0 && v4 <= tick_indexes_max(v0)) {
    //         if (0x1::table::contains<u64, 0x1::bit_vector::BitVector>(&arg0.tick_indexes, v4)) {
    //             let v5 = 0x1::table::borrow<u64, 0x1::bit_vector::BitVector>(&arg0.tick_indexes, v4);
    //             while (v3 >= 0 && v3 < 1000) {
    //                 if (0x1::bit_vector::is_index_set(v5, v3)) {
    //                     return 0x1::option::some<Tick>(*0x1::table::borrow<cetus::i64::I64, Tick>(&arg0.ticks, cetus::i64::sub(cetus::i64::from((1000 * v4 + v3) * v0), arg3)))
    //                 };
    //                 if (arg2) {
    //                     if (v3 == 0) {
    //                         break
    //                     };
    //                     v3 = v3 - 1;
    //                     continue
    //                 };
    //                 v3 = v3 + 1;
    //             };
    //         };
    //         if (arg2) {
    //             if (v4 == 0) {
    //                 return 0x1::option::none<Tick>()
    //             };
    //             v3 = 1000 - 1;
    //             v4 = v4 - 1;
    //             continue
    //         };
    //         v3 = 0;
    //         v4 = v4 + 1;
    //     };
    //     0x1::option::none<Tick>()
    // }

    public fun get_pool_index<T0, T1>(arg0: address): u64 acquires Pool {
        borrow_global<Pool<T0, T1>>(arg0).index
    }

    public fun get_pool_liquidity<T0, T1>(arg0: address): u128 acquires Pool {
        if (!exists<Pool<T0, T1>>(arg0)) {
            abort 19
        };
        borrow_global<Pool<T0, T1>>(arg0).liquidity
    }

    public fun get_position<T0, T1>(arg0: address, arg1: u64): Position acquires Pool {
        let v0 = borrow_global<Pool<T0, T1>>(arg0);
        if (!0x1::table::contains<u64, Position>(&v0.positions, arg1)) {
            abort 29
        };
        *0x1::table::borrow<u64, Position>(&v0.positions, arg1)
    }

    public fun get_position_tick_range<T0, T1>(
        arg0: address,
        arg1: u64
    ): (cetus::i64::I64, cetus::i64::I64) acquires Pool {
        let v0 = borrow_global<Pool<T0, T1>>(arg0);
        if (!0x1::table::contains<u64, Position>(&v0.positions, arg1)) {
            abort 29
        };
        let v1 = 0x1::table::borrow<u64, Position>(&v0.positions, arg1);
        (v1.tick_lower_index, v1.tick_upper_index)
    }

    public fun get_position_tick_range_by_pool<T0, T1>(
        arg0: &Pool<T0, T1>,
        arg1: u64
    ): (cetus::i64::I64, cetus::i64::I64) {
        if (!0x1::table::contains<u64, Position>(&arg0.positions, arg1)) {
            abort 29
        };
        let v0 = 0x1::table::borrow<u64, Position>(&arg0.positions, arg1);
        (v0.tick_lower_index, v0.tick_upper_index)
    }

    fun get_reward_in_tick_range<T0, T1>(
        arg0: &Pool<T0, T1>,
        arg1: cetus::i64::I64,
        arg2: cetus::i64::I64
    ): vector<u128> {
        let v0 = borrow_tick<T0, T1>(arg0, arg1);
        let v1 = borrow_tick<T0, T1>(arg0, arg2);
        let v2 = arg0.current_tick_index;
        let v3 = 0x1::vector::empty<u128>();
        let v4 = 0;
        while (v4 < 0x1::vector::length<Rewarder>(&arg0.rewarder_infos)) {
            let v5 = 0x1::vector::borrow<Rewarder>(&arg0.rewarder_infos, v4).growth_global;
            let v6 = if (0x1::option::is_none<Tick>(&v0)) {
                v5
            } else if (cetus::i64::lt(v2, arg1)) {
                cetus::math_u128::wrapping_sub(
                    v5,
                    *0x1::vector::borrow<u128>(&0x1::option::borrow<Tick>(&v0).rewarders_growth_outside, v4)
                )
            } else {
                *0x1::vector::borrow<u128>(&0x1::option::borrow<Tick>(&v0).rewarders_growth_outside, v4)
            };
            let v7 = if (0x1::option::is_none<Tick>(&v1)) {
                0
            } else if (cetus::i64::lt(v2, arg2)) {
                *0x1::vector::borrow<u128>(&0x1::option::borrow<Tick>(&v1).rewarders_growth_outside, v4)
            } else {
                cetus::math_u128::wrapping_sub(
                    v5,
                    *0x1::vector::borrow<u128>(&0x1::option::borrow<Tick>(&v1).rewarders_growth_outside, v4)
                )
            };
            0x1::vector::push_back<u128>(
                &mut v3,
                cetus::math_u128::wrapping_sub(cetus::math_u128::wrapping_sub(v5, v6), v7)
            );
            v4 = v4 + 1;
        };
        v3
    }

    public fun get_rewarder_len<T0, T1>(arg0: address): u8 acquires Pool {
        (0x1::vector::length<Rewarder>(&borrow_global<Pool<T0, T1>>(arg0).rewarder_infos) as u8)
    }

    public fun get_tick_spacing<T0, T1>(arg0: address): u64 acquires Pool {
        if (!exists<Pool<T0, T1>>(arg0)) {
            abort 19
        };
        borrow_global<Pool<T0, T1>>(arg0).tick_spacing
    }

    // public fun initialize_rewarder<T0, T1, T2>(arg0: &signer, arg1: address, arg2: address, arg3: u64) acquires Pool {
    //     cetus::config::assert_protocol_authority(arg0);
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v0);
    //     let v1 = &mut v0.rewarder_infos;
    //     assert!(0x1::vector::length<Rewarder>(v1) == arg3 && arg3 < 3, 23);
    //     let v2 = Rewarder {
    //         coin_type: 0x1::type_info::type_of<T2>(),
    //         authority: arg2,
    //         pending_authority: @0x0,
    //         emissions_per_second: 0,
    //         growth_global: 0,
    //     };
    //     0x1::vector::push_back<Rewarder>(v1, v2);
    //     if (!0x1::coin::is_account_registered<T2>(arg1)) {
    //         let v3 = 0x1::account::create_signer_with_capability(&v0.signer_cap);
    //         0x1::coin::register<T2>(&v3);
    //     };
    // }

    fun new_empty_position(arg0: address, arg1: cetus::i64::I64, arg2: cetus::i64::I64, arg3: u64): Position {
        let v0 = PositionRewarder {
            growth_inside: 0,
            amount_owed: 0,
        };
        let v1 = PositionRewarder {
            growth_inside: 0,
            amount_owed: 0,
        };
        let v2 = PositionRewarder {
            growth_inside: 0,
            amount_owed: 0,
        };
        let v3 = 0x1::vector::empty<PositionRewarder>();
        let v4 = &mut v3;
        0x1::vector::push_back<PositionRewarder>(v4, v0);
        0x1::vector::push_back<PositionRewarder>(v4, v1);
        0x1::vector::push_back<PositionRewarder>(v4, v2);
        Position {
            pool: arg0,
            index: arg3,
            liquidity: 0,
            tick_lower_index: arg1,
            tick_upper_index: arg2,
            fee_growth_inside_a: 0,
            fee_owed_a: 0,
            fee_growth_inside_b: 0,
            fee_owed_b: 0,
            rewarder_infos: v3,
        }
    }

    public fun open_position<T0, T1>(
        arg0: &signer,
        arg1: address,
        arg2: cetus::i64::I64,
        arg3: cetus::i64::I64
    ): u64 acquires Pool {
        assert!(cetus::i64::lt(arg2, arg3), 30);
        let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
        assert_status<T0, T1>(v0);
        assert!(cetus::tick_math::is_valid_index(arg2, v0.tick_spacing), 30);
        assert!(cetus::tick_math::is_valid_index(arg3, v0.tick_spacing), 30);
        0x1::table::add<u64, Position>(
            &mut v0.positions,
            v0.position_index,
            new_empty_position(arg1, arg2, arg3, v0.position_index)
        );
        let v1 = 0x1::account::create_signer_with_capability(&v0.signer_cap);
        // cetus::position_nft::mint(arg0, &v1, v0.index, v0.position_index, v0.uri, v0.collection_name);
        let v2 = OpenPositionEvent {
            user: 0x1::signer::address_of(arg0),
            pool: arg1,
            tick_lower: arg2,
            tick_upper: arg3,
            index: v0.position_index,
        };
        0x1::event::emit(v2);
        v0.position_index = v0.position_index + 1;
        v0.position_index
    }

    public fun pause<T0, T1>(arg0: &signer, arg1: address) acquires Pool {
        cetus::config::assert_protocol_status();
        cetus::config::assert_protocol_authority(arg0);
        borrow_global_mut<Pool<T0, T1>>(arg1).is_pause = true;
    }

    public fun remove_liquidity<T0, T1>(
        arg0: &signer,
        arg1: address,
        arg2: u128,
        arg3: u64
    ): (0x1::coin::Coin<T0>, 0x1::coin::Coin<T1>) acquires Pool {
        assert!(arg2 != 0, 11);
        // check_position_authority<T0, T1>(arg0, arg1, arg3);
        let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
        assert_status<T0, T1>(v0);
        update_rewarder<T0, T1>(v0);
        let (v1, v2) = get_position_tick_range_by_pool<T0, T1>(v0, arg3);
        let (v3, v4) = get_fee_in_tick_range<T0, T1>(v0, v1, v2);
        let reward = get_reward_in_tick_range<T0, T1>(v0, v1, v2);
        let v5 = 0x1::table::borrow_mut<u64, Position>(&mut v0.positions, arg3);
        update_position_fee_and_reward(v5, v3, v4, reward);
        update_position_liquidity(v5, arg2, false);
        upsert_tick_by_liquidity<T0, T1>(v0, v1, arg2, false, false);
        upsert_tick_by_liquidity<T0, T1>(v0, v2, arg2, false, true);
        let (v6, v7) = cetus::clmm_math::get_amount_by_liquidity(
            v1,
            v2,
            v0.current_tick_index,
            v0.current_sqrt_price,
            arg2,
            false
        );
        let (v8, v9) = if (cetus::i64::lte(v1, v0.current_tick_index) && cetus::i64::lt(v0.current_tick_index, v2)) {
            cetus::math_u128::overflowing_sub(v0.liquidity, arg2)
        } else {
            (v0.liquidity, false)
        };
        if (v9) {
            abort 7
        };
        v0.liquidity = v8;
        let v10 = RemoveLiquidityEvent {
            pool_address: arg1,
            tick_lower: v1,
            tick_upper: v2,
            liquidity: arg2,
            amount_a: v6,
            amount_b: v7,
            index: arg3,
        };
        0x1::event::emit(v10);
        (0x1::coin::extract<T0>(&mut v0.coin_a, v6), 0x1::coin::extract<T1>(&mut v0.coin_b, v7))
    }

    fun remove_tick<T0, T1>(arg0: &mut Pool<T0, T1>, arg1: cetus::i64::I64) {
        let (v0, v1) = tick_position(arg1, arg0.tick_spacing);
        if (!0x1::table::contains<u64, 0x1::bit_vector::BitVector>(&arg0.tick_indexes, v0)) {
            abort 9
        };
        0x1::bit_vector::unset(0x1::table::borrow_mut<u64, 0x1::bit_vector::BitVector>(&mut arg0.tick_indexes, v0), v1);
        if (!0x1::table::contains<cetus::i64::I64, Tick>(&arg0.ticks, arg1)) {
            abort 10
        };
        0x1::table::remove<cetus::i64::I64, Tick>(&mut arg0.ticks, arg1);
    }

    public fun repay_add_liquidity<T0, T1>(
        arg0: 0x1::coin::Coin<T0>,
        arg1: 0x1::coin::Coin<T1>,
        arg2: AddLiquidityReceipt<T0, T1>
    ) acquires Pool {
        let AddLiquidityReceipt<T0, T1> {
            pool_address: v0,
            amount_a: v1,
            amount_b: v2,
        } = arg2;
        assert!(0x1::coin::value<T0>(&arg0) == v1, 6);
        assert!(0x1::coin::value<T1>(&arg1) == v2, 6);
        let v3 = borrow_global_mut<Pool<T0, T1>>(v0);
        0x1::coin::merge<T0>(&mut v3.coin_a, arg0);
        0x1::coin::merge<T1>(&mut v3.coin_b, arg1);
    }

    // public fun repay_flash_swap<T0, T1>(
    //     arg0: 0x1::coin::Coin<T0>,
    //     arg1: 0x1::coin::Coin<T1>,
    //     arg2: FlashSwapReceipt<T0, T1>
    // ) acquires Pool {
    //     let FlashSwapReceipt<T0, T1> {
    //         pool_address: v0,
    //         a2b: v1,
    //         partner_name: v2,
    //         pay_amount: v3,
    //         ref_fee_amount: v4,
    //     } = arg2;
    //     let v5 = borrow_global_mut<Pool<T0, T1>>(v0);
    //     if (v1) {
    //         assert!(0x1::coin::value<T0>(&arg0) == v3, 6);
    //         if (v4 > 0) {
    //             cetus::partner::receive_ref_fee<T0>(v2, 0x1::coin::extract<T0>(&mut arg0, v4));
    //         };
    //         0x1::coin::merge<T0>(&mut v5.coin_a, arg0);
    //         0x1::coin::destroy_zero<T1>(arg1);
    //     } else {
    //         assert!(0x1::coin::value<T1>(&arg1) == v3, 6);
    //         if (v4 > 0) {
    //             cetus::partner::receive_ref_fee<T1>(v2, 0x1::coin::extract<T1>(&mut arg1, v4));
    //         };
    //         0x1::coin::merge<T1>(&mut v5.coin_b, arg1);
    //         0x1::coin::destroy_zero<T0>(arg0);
    //     };
    // }

    public fun reset_init_price_v2<T0, T1>(arg0: &signer, arg1: address, arg2: u128) acquires Pool {
        cetus::config::assert_reset_init_price_authority(arg0);
        let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
        assert!(
            arg2 > cetus::tick_math::get_sqrt_price_at_tick(
                tick_min(v0.tick_spacing)
            ) && arg2 < cetus::tick_math::get_sqrt_price_at_tick(tick_max(v0.tick_spacing)),
            38
        );
        assert!(v0.position_index == 1, 33);
        v0.current_sqrt_price = arg2;
        v0.current_tick_index = cetus::tick_math::get_tick_at_sqrt_price(arg2);
    }

    fun rewarder_growth_globals(arg0: vector<Rewarder>): vector<u128> {
        let v0 = vector[0, 0, 0];
        let v1 = 0;
        while (v1 < 0x1::vector::length<Rewarder>(&arg0)) {
            *0x1::vector::borrow_mut<u128>(&mut v0, v1) = 0x1::vector::borrow<Rewarder>(&arg0, v1).growth_global;
            v1 = v1 + 1;
        };
        v0
    }

    // fun swap_in_pool<T0, T1>(arg0: &mut Pool<T0, T1>, arg1: bool, arg2: bool, arg3: u128, arg4: u64, arg5: u64, arg6: u64) : SwapResult {
    //     let v0 = default_swap_result();
    //     let v1 = arg0.current_tick_index;
    //     let v2 = tick_max(arg0.tick_spacing);
    //     while (arg4 > 0 && arg0.current_sqrt_price != arg3) {
    //         if (cetus::i64::gt(v1, v2) || cetus::i64::lt(v1, tick_min(arg0.tick_spacing))) {
    //             abort 12
    //         };
    //         let v3 = get_next_tick_for_swap<T0, T1>(arg0, v1, arg1, v2);
    //         if (0x1::option::is_none<Tick>(&v3)) {
    //             abort 12
    //         };
    //         let v4 = 0x1::option::destroy_some<Tick>(v3);
    //         let v5 = if (arg1) {
    //             cetus::math_u128::max(arg3, v4.sqrt_price)
    //         } else {
    //             cetus::math_u128::min(arg3, v4.sqrt_price)
    //         };
    //         let (v6, v7, v8, v9) = cetus::clmm_math::compute_swap_step(arg0.current_sqrt_price, v5, arg0.liquidity, arg4, arg0.fee_rate, arg1, arg2);
    //         if (v6 != 0 || v9 != 0) {
    //             if (arg2) {
    //                 let v10 = check_sub_remainer_amount(arg4, v6);
    //                 arg4 = check_sub_remainer_amount(v10, v9);
    //             } else {
    //                 arg4 = check_sub_remainer_amount(arg4, v7);
    //             };
    //             let v11 = &mut v0;
    //             update_swap_result(v11, v6, v7, v9);
    //             let v12 = update_pool_fee<T0, T1>(arg0, v9, arg6, arg5, arg1);
    //             v0.ref_fee_amount = v12;
    //         };
    //         if (v8 == v4.sqrt_price) {
    //             arg0.current_sqrt_price = v4.sqrt_price;
    //             let v13 = if (arg1) {
    //                 cetus::i64::sub(v4.index, cetus::i64::from(1))
    //             } else {
    //                 v4.index
    //             };
    //             arg0.current_tick_index = v13;
    //             cross_tick_and_update_liquidity<T0, T1>(arg0, v4.index, arg1);
    //         } else {
    //             arg0.current_sqrt_price = v8;
    //             arg0.current_tick_index = cetus::tick_math::get_tick_at_sqrt_price(v8);
    //         };
    //         if (arg1) {
    //             v1 = cetus::i64::sub(v4.index, cetus::i64::from(1));
    //             continue
    //         };
    //         v1 = v4.index;
    //     };
    //     v0
    // }

    // public fun swap_pay_amount<T0, T1>(arg0: &FlashSwapReceipt<T0, T1>) : u64 {
    //     arg0.pay_amount
    // }

    fun tick_indexes_index(arg0: cetus::i64::I64, arg1: u64): u64 {
        let v0 = cetus::i64::sub(arg0, tick_min(arg1));
        if (cetus::i64::is_neg(v0)) {
            abort 1
        };
        cetus::i64::as_u64(v0) / arg1 * 1000
    }

    fun tick_indexes_max(arg0: u64): u64 {
        cetus::tick_math::tick_bound() * 2 / arg0 * 1000 + 1
    }

    fun tick_max(arg0: u64): cetus::i64::I64 {
        let v0 = cetus::tick_math::max_tick();
        cetus::i64::sub(v0, cetus::i64::mod(v0, cetus::i64::from(arg0)))
    }

    fun tick_min(arg0: u64): cetus::i64::I64 {
        let v0 = cetus::tick_math::min_tick();
        cetus::i64::sub(v0, cetus::i64::mod(v0, cetus::i64::from(arg0)))
    }

    fun tick_offset(arg0: u64, arg1: u64, arg2: cetus::i64::I64): u64 {
        (cetus::i64::as_u64(cetus::i64::add(arg2, tick_max(arg1))) - arg0 * arg1 * 1000) / arg1
    }

    fun tick_position(arg0: cetus::i64::I64, arg1: u64): (u64, u64) {
        let v0 = tick_indexes_index(arg0, arg1);
        (v0, (cetus::i64::as_u64(cetus::i64::add(arg0, tick_max(arg1))) - v0 * arg1 * 1000) / arg1)
    }

    // public fun transfer_rewarder_authority<T0, T1>(
    //     arg0: &signer,
    //     arg1: address,
    //     arg2: u8,
    //     arg3: address
    // ) acquires Pool {
    //     let v0 = 0x1::signer::address_of(arg0);
    //     let v1 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v1);
    //     assert!((arg2 as u64) < 0x1::vector::length<Rewarder>(&v1.rewarder_infos), 23);
    //     let v2 = 0x1::vector::borrow_mut<Rewarder>(&mut v1.rewarder_infos, (arg2 as u64));
    //     assert!(v2.authority == v0, 26);
    //     v2.pending_authority = arg3;
    //     let v3 = TransferRewardAuthEvent {
    //         pool_address: arg1,
    //         index: arg2,
    //         old_authority: v0,
    //         new_authority: arg3,
    //     };
    //     0x1::event::emit_event<TransferRewardAuthEvent>(&mut v1.transfer_reward_auth_events, v3);
    // }

    public fun unpause<T0, T1>(arg0: &signer, arg1: address) acquires Pool {
        cetus::config::assert_protocol_status();
        cetus::config::assert_protocol_authority(arg0);
        borrow_global_mut<Pool<T0, T1>>(arg1).is_pause = false;
    }

    // public fun update_emission<T0, T1, T2>(arg0: &signer, arg1: address, arg2: u8, arg3: u128) acquires Pool {
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v0);
    //     update_rewarder<T0, T1>(v0);
    //     assert!((arg2 as u64) < 0x1::vector::length<Rewarder>(&v0.rewarder_infos), 23);
    //     let v1 = 0x1::vector::borrow_mut<Rewarder>(&mut v0.rewarder_infos, (arg2 as u64));
    //     assert!(0x1::signer::address_of(arg0) == v1.authority, 26);
    //     assert!(v1.coin_type == 0x1::type_info::type_of<T2>(), 25);
    //     assert!(0x1::coin::balance<T2>(arg1) >= (cetus::full_math_u128::mul_shr(86400, arg3, 64) as u64), 24);
    //     v1.emissions_per_second = arg3;
    //     let v2 = UpdateEmissionEvent {
    //         pool_address: arg1,
    //         index: arg2,
    //         emissions_per_second: arg3,
    //     };
    //     0x1::event::emit_event<UpdateEmissionEvent>(&mut v0.update_emission_events, v2);
    // }

    // public fun update_fee_rate<T0, T1>(arg0: &signer, arg1: address, arg2: u64) acquires Pool {
    //     if (arg2 > cetus::fee_tier::max_fee_rate()) {
    //         abort 17
    //     };
    //     cetus::config::assert_protocol_authority(arg0);
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     assert_status<T0, T1>(v0);
    //     v0.fee_rate = arg2;
    //     let v1 = UpdateFeeRateEvent {
    //         pool_address: arg1,
    //         old_fee_rate: v0.fee_rate,
    //         new_fee_rate: arg2,
    //     };
    //     0x1::event::emit_event<UpdateFeeRateEvent>(&mut v0.update_fee_rate_events, v1);
    // }

    fun update_pool_fee<T0, T1>(arg0: &mut Pool<T0, T1>, arg1: u64, arg2: u64, arg3: u64, arg4: bool): u64 {
        let v0 = cetus::full_math_u64::mul_div_ceil(arg1, arg3, 10000);
        let v1 = arg1 - v0;
        let v2 = if (arg2 == 0) {
            0
        } else {
            cetus::full_math_u64::mul_div_floor(v0, arg2, 10000)
        };
        if (arg4) {
            arg0.fee_protocol_coin_a = cetus::math_u64::wrapping_add(arg0.fee_protocol_coin_a, v0 - v2);
        } else {
            arg0.fee_protocol_coin_b = cetus::math_u64::wrapping_add(arg0.fee_protocol_coin_b, v0 - v2);
        };
        if (v1 == 0 || arg0.liquidity == 0) {
            return v2
        };
        if (arg4) {
            arg0.fee_growth_global_a = cetus::math_u128::wrapping_add(
                arg0.fee_growth_global_a,
                ((v1 as u128) << 64) / arg0.liquidity
            );
        } else {
            arg0.fee_growth_global_b = cetus::math_u128::wrapping_add(
                arg0.fee_growth_global_b,
                ((v1 as u128) << 64) / arg0.liquidity
            );
        };
        v2
    }

    // public fun update_pool_uri<T0, T1>(arg0: &signer, arg1: address, arg2: 0x1::string::String) acquires Pool {
    //     assert!(!0x1::string::is_empty(&arg2), 41);
    //     assert!(cetus::config::allow_set_position_nft_uri(arg0), 40);
    //     let v0 = borrow_global_mut<Pool<T0, T1>>(arg1);
    //     let v1 = 0x1::account::create_signer_with_capability(&v0.signer_cap);
    //     cetus::position_nft::mutate_collection_uri(&v1, v0.collection_name, arg2);
    //     v0.uri = arg2;
    // }

    fun update_position_fee(arg0: &mut Position, arg1: u128, arg2: u128) {
        let (v0, v1) = cetus::math_u64::overflowing_add(
            arg0.fee_owed_a,
            (cetus::full_math_u128::mul_shr(
                arg0.liquidity,
                cetus::math_u128::wrapping_sub(arg1, arg0.fee_growth_inside_a),
                64
            ) as u64)
        );
        let (v2, v3) = cetus::math_u64::overflowing_add(
            arg0.fee_owed_b,
            (cetus::full_math_u128::mul_shr(
                arg0.liquidity,
                cetus::math_u128::wrapping_sub(arg2, arg0.fee_growth_inside_b),
                64
            ) as u64)
        );
        assert!(!v1, 35);
        assert!(!v3, 35);
        arg0.fee_owed_a = v0;
        arg0.fee_owed_b = v2;
        arg0.fee_growth_inside_a = arg1;
        arg0.fee_growth_inside_b = arg2;
    }

    fun update_position_fee_and_reward(arg0: &mut Position, arg1: u128, arg2: u128, arg3: vector<u128>) {
        update_position_fee(arg0, arg1, arg2);
        update_position_rewarder(arg0, arg3);
    }

    fun update_position_liquidity(arg0: &mut Position, delta_liquidity: u128, arg2: bool) {
        if (delta_liquidity == 0) {
            return
        };
        let (v0, v1) = if (arg2) {
            cetus::math_u128::overflowing_add(arg0.liquidity, delta_liquidity)
        } else {
            cetus::math_u128::overflowing_sub(arg0.liquidity, delta_liquidity)
        };
        assert!(!v1, 36);
        arg0.liquidity = v0;
    }

    fun update_position_rewarder(arg0: &mut Position, arg1: vector<u128>) {
        let v0 = 0;
        while (v0 < 0x1::vector::length<u128>(&arg1)) {
            let v1 = *0x1::vector::borrow<u128>(&arg1, v0);
            let v2 = 0x1::vector::borrow_mut<PositionRewarder>(&mut arg0.rewarder_infos, v0);
            v2.growth_inside = v1;
            let (v3, v4) = cetus::math_u64::overflowing_add(
                v2.amount_owed,
                (cetus::full_math_u128::mul_shr(
                    cetus::math_u128::wrapping_sub(v1, v2.growth_inside),
                    arg0.liquidity,
                    64
                ) as u64)
            );
            assert!(!v4, 34);
            v2.amount_owed = v3;
            v0 = v0 + 1;
        };
    }

    fun update_rewarder<T0, T1>(arg0: &mut Pool<T0, T1>) {
        let v0 = 0x1::timestamp::now_seconds();
        let v1 = arg0.rewarder_last_updated_time;
        arg0.rewarder_last_updated_time = v0;
        assert!(v1 <= v0, 27);
        if (arg0.liquidity == 0 || v0 == v1) {
            return
        };
        let v2 = 0;
        while (v2 < 0x1::vector::length<Rewarder>(&arg0.rewarder_infos)) {
            0x1::vector::borrow_mut<Rewarder>(
                &mut arg0.rewarder_infos,
                v2
            ).growth_global = 0x1::vector::borrow<Rewarder>(
                &arg0.rewarder_infos,
                v2
            ).growth_global + cetus::full_math_u128::mul_div_floor(
                ((v0 - v1) as u128),
                0x1::vector::borrow<Rewarder>(&arg0.rewarder_infos, v2).emissions_per_second,
                arg0.liquidity
            );
            v2 = v2 + 1;
        };
    }

    fun update_swap_result(arg0: &mut SwapResult, arg1: u64, arg2: u64, arg3: u64) {
        let (v0, v1) = cetus::math_u64::overflowing_add(arg0.amount_in, arg1);
        if (v1) {
            abort 14
        };
        let (v2, v3) = cetus::math_u64::overflowing_add(arg0.amount_out, arg2);
        if (v3) {
            abort 15
        };
        let (v4, v5) = cetus::math_u64::overflowing_add(arg0.fee_amount, arg3);
        if (v5) {
            abort 16
        };
        arg0.amount_out = v2;
        arg0.amount_in = v0;
        arg0.fee_amount = v4;
    }

    fun upsert_tick_by_liquidity<T0, T1>(
        arg0: &mut Pool<T0, T1>,
        arg1: cetus::i64::I64,
        arg2: u128,
        arg3: bool,
        arg4: bool
    ) {
        let v0 = &mut arg0.tick_indexes;
        let v1 = &mut arg0.ticks;
        let v2 = borrow_mut_tick_with_default(v0, v1, arg0.tick_spacing, arg1);
        if (arg2 == 0) {
            return
        };
        let (v3, v4) = if (arg3) {
            cetus::math_u128::overflowing_add(v2.liquidity_gross, arg2)
        } else {
            cetus::math_u128::overflowing_sub(v2.liquidity_gross, arg2)
        };
        if (v4) {
            abort 7
        };
        if (v3 == 0) {
            remove_tick<T0, T1>(arg0, arg1);
            return
        };
        let (v5, v6, v7) = if (v2.liquidity_gross == 0) {
            if (cetus::i64::gte(arg0.current_tick_index, arg1)) {
                (arg0.fee_growth_global_a, arg0.fee_growth_global_b, rewarder_growth_globals(arg0.rewarder_infos))
            } else {
                (0, 0, vector[0, 0, 0])
            }
        } else {
            (v2.fee_growth_outside_a, v2.fee_growth_outside_b, v2.rewarders_growth_outside)
        };
        let (v8, v9) = if (arg3) {
            let (v10, v11) = if (arg4) {
                let (v12, v13) = cetus::i128::overflowing_sub(v2.liquidity_net, cetus::i128::from(arg2));
                (v13, v12)
            } else {
                let (v14, v15) = cetus::i128::overflowing_add(v2.liquidity_net, cetus::i128::from(arg2));
                (v15, v14)
            };
            (v11, v10)
        } else if (arg4) {
            cetus::i128::overflowing_add(v2.liquidity_net, cetus::i128::from(arg2))
        } else {
            cetus::i128::overflowing_sub(v2.liquidity_net, cetus::i128::from(arg2))
        };
        if (v9) {
            abort 7
        };
        v2.liquidity_gross = v3;
        v2.liquidity_net = v8;
        v2.fee_growth_outside_a = v5;
        v2.fee_growth_outside_b = v6;
        v2.rewarders_growth_outside = v7;
    }

    // decompiled from Move bytecode v6
}

