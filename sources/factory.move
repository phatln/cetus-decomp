module tap::factory {
    #[event]
    struct CreatePoolEvent has drop, store {
        creator: address,
        pool_address: address,
        position_collection_name: 0x1::string::String,
        coin_type_a: 0x1::type_info::TypeInfo,
        coin_type_b: 0x1::type_info::TypeInfo,
        tick_spacing: u64,
    }

    struct PoolId has copy, drop, store {
        coin_type_a: 0x1::type_info::TypeInfo,
        coin_type_b: 0x1::type_info::TypeInfo,
        tick_spacing: u64,
    }

    struct PoolOwner has key {
        signer_capability: 0x1::account::SignerCapability,
    }

    struct Pools has key {
        data: 0x1::simple_map::SimpleMap<PoolId, address>,
        index: u64,
    }

    public fun create_pool<T0, T1>(arg0: &signer, arg1: u64, arg2: u128, arg3: 0x1::string::String) : address acquires PoolOwner, Pools {
        tap::config::assert_pool_create_authority(arg0);
        let v0 = if (0x1::string::length(&arg3) == 0 || !tap::config::allow_set_position_nft_uri(arg0)) {
            0x1::string::utf8(b"https://edbz27ws6curuggjavd2ojwm4td2se5x53elw2rbo3rwwnshkukq.arweave.net/IMOdftLwqRoYyQVHpybM5MepE7fuyLtqIXbjazZHVRU")
        } else {
            arg3
        };
        assert!(arg2 >= tap::tick_math::min_sqrt_price() && arg2 <= tap::tick_math::max_sqrt_price(), 2);
        let v1 = new_pool_id<T0, T1>(arg1);
        let v2 = 0x1::account::create_signer_with_capability(&borrow_global<PoolOwner>(@tap).signer_capability);
        let v3 = new_pool_seed<T0, T1>(arg1);
        let (v4, v5) = 0x1::account::create_resource_account(&v2, 0x1::bcs::to_bytes<PoolId>(&v3));
        let v6 = v4;
        let v7 = 0x1::signer::address_of(&v6);
        let v8 = borrow_global_mut<Pools>(@tap);
        v8.index = v8.index + 1;
        assert!(!0x1::simple_map::contains_key<PoolId, address>(&v8.data, &v1), 1);
        0x1::simple_map::add<PoolId, address>(&mut v8.data, v1, v7);
        let v9 = CreatePoolEvent{
            creator                  : 0x1::signer::address_of(arg0),
            pool_address             : v7,
            position_collection_name : tap::pool::new<T0, T1>(&v6, arg1, arg2, v8.index, v0, v5),
            coin_type_a              : 0x1::type_info::type_of<T0>(),
            coin_type_b              : 0x1::type_info::type_of<T1>(),
            tick_spacing             : arg1,
        };
        0x1::event::emit(v9);
        v7
    }

    public fun get_pool<T0, T1>(arg0: u64) : 0x1::option::Option<address> acquires Pools {
        let v0 = borrow_global<Pools>(@tap);
        let v1 = new_pool_id<T0, T1>(arg0);
        if (0x1::simple_map::contains_key<PoolId, address>(&v0.data, &v1)) {
            return 0x1::option::some<address>(*0x1::simple_map::borrow<PoolId, address>(&v0.data, &v1))
        };
        0x1::option::none<address>()
    }

    fun init_module(arg0: &signer) {
        let v0 = Pools{
            data               : 0x1::simple_map::create<PoolId, address>(),
            index              : 0,
        };
        move_to<Pools>(arg0, v0);
        let (_, v2) = 0x1::account::create_resource_account(arg0, b"CetusPoolOwner");
        let v3 = PoolOwner{signer_capability: v2};
        move_to<PoolOwner>(arg0, v3);
        tap::config::initialize(arg0);
        tap::fee_tier::initialize(arg0);
        // tap::partner::initialize(arg0);
    }

    fun new_pool_id<T0, T1>(arg0: u64) : PoolId {
        PoolId{
            coin_type_a  : 0x1::type_info::type_of<T0>(),
            coin_type_b  : 0x1::type_info::type_of<T1>(),
            tick_spacing : arg0,
        }
    }

    fun new_pool_seed<T0, T1>(arg0: u64) : PoolId {
        let v0 = tap::utils::compare_coin<T0, T1>();
        if (0x1::comparator::is_smaller_than(&v0)) {
            PoolId{coin_type_a: 0x1::type_info::type_of<T0>(), coin_type_b: 0x1::type_info::type_of<T1>(), tick_spacing: arg0}
        } else {
            PoolId{coin_type_a: 0x1::type_info::type_of<T1>(), coin_type_b: 0x1::type_info::type_of<T0>(), tick_spacing: arg0}
        }
    }

    // decompiled from Move bytecode v6
}

