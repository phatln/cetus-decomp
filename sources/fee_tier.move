module cetus::fee_tier {
    #[event]
    struct AddEvent has drop, store {
        tick_spacing: u64,
        fee_rate: u64,
    }

    #[event]
    struct DeleteEvent has drop, store {
        tick_spacing: u64,
    }

    struct FeeTier has copy, drop, store {
        tick_spacing: u64,
        fee_rate: u64,
    }

    struct FeeTiers has key {
        fee_tiers: 0x1::simple_map::SimpleMap<u64, FeeTier>,
    }

    #[event]
    struct UpdateEvent has drop, store {
        tick_spacing: u64,
        old_fee_rate: u64,
        new_fee_rate: u64,
    }

    public fun add_fee_tier(arg0: &signer, arg1: u64, arg2: u64) acquires FeeTiers {
        assert!(arg2 <= 200000, 4);
        cetus::config::assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<FeeTiers>(@cetus);
        assert!(!0x1::simple_map::contains_key<u64, FeeTier>(&v0.fee_tiers, &arg1), 1);
        let v1 = FeeTier{
            tick_spacing : arg1,
            fee_rate     : arg2,
        };
        0x1::simple_map::add<u64, FeeTier>(&mut v0.fee_tiers, arg1, v1);
        let v2 = AddEvent{
            tick_spacing : arg1,
            fee_rate     : arg2,
        };
        0x1::event::emit(v2);
    }

    public fun delete_fee_tier(arg0: &signer, arg1: u64) acquires FeeTiers {
        cetus::config::assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<FeeTiers>(@cetus);
        assert!(0x1::simple_map::contains_key<u64, FeeTier>(&v0.fee_tiers, &arg1), 2);
        0x1::simple_map::remove<u64, FeeTier>(&mut v0.fee_tiers, &arg1);
        let v1 = DeleteEvent{tick_spacing: arg1};
        0x1::event::emit(v1);
    }

    public fun get_fee_rate(arg0: u64) : u64 acquires FeeTiers {
        let v0 = &borrow_global<FeeTiers>(@cetus).fee_tiers;
        assert!(0x1::simple_map::contains_key<u64, FeeTier>(v0, &arg0), 2);
        0x1::simple_map::borrow<u64, FeeTier>(v0, &arg0).fee_rate
    }

    public fun initialize(arg0: &signer) {
        cetus::config::assert_initialize_authority(arg0);
        let v0 = FeeTiers{
            fee_tiers     : 0x1::simple_map::create<u64, FeeTier>(),
        };
        move_to<FeeTiers>(arg0, v0);
    }

    public fun max_fee_rate() : u64 {
        200000
    }

    public fun update_fee_tier(arg0: &signer, arg1: u64, arg2: u64) acquires FeeTiers {
        assert!(arg2 <= 200000, 4);
        cetus::config::assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<FeeTiers>(@cetus);
        assert!(0x1::simple_map::contains_key<u64, FeeTier>(&v0.fee_tiers, &arg1), 2);
        let v1 = 0x1::simple_map::borrow_mut<u64, FeeTier>(&mut v0.fee_tiers, &arg1);
        v1.fee_rate = arg2;
        let v2 = UpdateEvent{
            tick_spacing : arg1,
            old_fee_rate : v1.fee_rate,
            new_fee_rate : arg2,
        };
        0x1::event::emit(v2);
    }
}

