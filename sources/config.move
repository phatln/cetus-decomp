module cetus::config {
    struct AcceptAuthEvent has drop, store {
        old_auth: address,
        new_auth: address,
    }

    struct ClmmACL has key {
        acl: cetus::acl::ACL,
    }

    struct GlobalConfig has key {
        protocol_authority: address,
        protocol_pending_authority: address,
        protocol_fee_claim_authority: address,
        pool_create_authority: address,
        protocol_fee_rate: u64,
        is_pause: bool,
        transfer_auth_events: 0x1::event::EventHandle<TransferAuthEvent>,
        accept_auth_events: 0x1::event::EventHandle<AcceptAuthEvent>,
        update_claim_auth_events: 0x1::event::EventHandle<UpdateClaimAuthEvent>,
        update_pool_create_events: 0x1::event::EventHandle<UpdatePoolCreateEvent>,
        update_fee_rate_events: 0x1::event::EventHandle<UpdateFeeRateEvent>,
    }

    struct TransferAuthEvent has drop, store {
        old_auth: address,
        new_auth: address,
    }

    struct UpdateClaimAuthEvent has drop, store {
        old_auth: address,
        new_auth: address,
    }

    struct UpdateFeeRateEvent has drop, store {
        old_fee_rate: u64,
        new_fee_rate: u64,
    }

    struct UpdatePoolCreateEvent has drop, store {
        old_auth: address,
        new_auth: address,
    }

    public fun add_role(arg0: &signer, arg1: address, arg2: u8) acquires ClmmACL, GlobalConfig {
        assert!(arg2 == 1 || arg2 == 2, 5);
        assert_protocol_authority(arg0);
        cetus::acl::add_role(&mut borrow_global_mut<ClmmACL>(@cetus).acl, arg1, arg2);
    }

    public fun remove_role(arg0: &signer, arg1: address, arg2: u8) acquires ClmmACL, GlobalConfig {
        assert!(arg2 == 1 || arg2 == 2, 5);
        assert_protocol_authority(arg0);
        cetus::acl::remove_role(&mut borrow_global_mut<ClmmACL>(@cetus).acl, arg1, arg2);
    }

    public fun accept_protocol_authority(arg0: &signer) acquires GlobalConfig {
        let v0 = borrow_global_mut<GlobalConfig>(@cetus);
        assert!(v0.protocol_pending_authority == 0x1::signer::address_of(arg0), 1);
        v0.protocol_authority = 0x1::signer::address_of(arg0);
        v0.protocol_pending_authority = @0x0;
        let v1 = AcceptAuthEvent{
            old_auth : v0.protocol_authority,
            new_auth : v0.protocol_authority,
        };
        0x1::event::emit_event<AcceptAuthEvent>(&mut v0.accept_auth_events, v1);
    }

    public fun allow_set_position_nft_uri(arg0: &signer) : bool acquires ClmmACL {
        cetus::acl::has_role(&borrow_global<ClmmACL>(@cetus).acl, 0x1::signer::address_of(arg0), 1)
    }

    public fun assert_initialize_authority(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @cetus, 1);
    }

    public fun assert_pool_create_authority(arg0: &signer) acquires GlobalConfig {
        let v0 = borrow_global<GlobalConfig>(@cetus);
        assert!(v0.pool_create_authority == 0x1::signer::address_of(arg0) || v0.pool_create_authority == @0x0, 1);
    }

    public fun assert_protocol_authority(arg0: &signer) acquires GlobalConfig {
        assert!(borrow_global<GlobalConfig>(@cetus).protocol_authority == 0x1::signer::address_of(arg0), 1);
    }

    public fun assert_protocol_fee_claim_authority(arg0: &signer) acquires GlobalConfig {
        assert!(borrow_global<GlobalConfig>(@cetus).protocol_fee_claim_authority == 0x1::signer::address_of(arg0), 1);
    }

    public fun assert_protocol_status() acquires GlobalConfig {
        if (borrow_global<GlobalConfig>(@cetus).is_pause) {
            abort 4
        };
    }

    public fun assert_reset_init_price_authority(arg0: &signer) acquires ClmmACL {
        if (!cetus::acl::has_role(&borrow_global<ClmmACL>(@cetus).acl, 0x1::signer::address_of(arg0), 2)) {
            abort 1
        };
    }

    public fun get_protocol_fee_rate() : u64 acquires GlobalConfig {
        borrow_global<GlobalConfig>(@cetus).protocol_fee_rate
    }

    public fun init_clmm_acl(arg0: &signer) {
        assert_initialize_authority(arg0);
        let v0 = ClmmACL{acl: cetus::acl::new()};
        move_to<ClmmACL>(arg0, v0);
    }

    public fun initialize(arg0: &signer) {
        assert_initialize_authority(arg0);
        let v0 = @cetus;
        let v1 = GlobalConfig{
            protocol_authority           : v0,
            protocol_pending_authority   : @0x0,
            protocol_fee_claim_authority : v0,
            pool_create_authority        : @0x0,
            protocol_fee_rate            : 2000,
            is_pause                     : false,
            transfer_auth_events         : 0x1::account::new_event_handle<TransferAuthEvent>(arg0),
            accept_auth_events           : 0x1::account::new_event_handle<AcceptAuthEvent>(arg0),
            update_claim_auth_events     : 0x1::account::new_event_handle<UpdateClaimAuthEvent>(arg0),
            update_pool_create_events    : 0x1::account::new_event_handle<UpdatePoolCreateEvent>(arg0),
            update_fee_rate_events       : 0x1::account::new_event_handle<UpdateFeeRateEvent>(arg0),
        };
        move_to<GlobalConfig>(arg0, v1);
    }

    public fun pause(arg0: &signer) acquires GlobalConfig {
        assert_protocol_authority(arg0);
        borrow_global_mut<GlobalConfig>(@cetus).is_pause = true;
    }

    public fun transfer_protocol_authority(arg0: &signer, arg1: address) acquires GlobalConfig {
        assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<GlobalConfig>(@cetus);
        v0.protocol_pending_authority = arg1;
        let v1 = TransferAuthEvent{
            old_auth : v0.protocol_authority,
            new_auth : arg1,
        };
        0x1::event::emit_event<TransferAuthEvent>(&mut v0.transfer_auth_events, v1);
    }

    public fun unpause(arg0: &signer) acquires GlobalConfig {
        assert_protocol_authority(arg0);
        borrow_global_mut<GlobalConfig>(@cetus).is_pause = false;
    }

    public fun update_pool_create_authority(arg0: &signer, arg1: address) acquires GlobalConfig {
        assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<GlobalConfig>(@cetus);
        v0.pool_create_authority = arg1;
        let v1 = UpdatePoolCreateEvent{
            old_auth : v0.pool_create_authority,
            new_auth : v0.pool_create_authority,
        };
        0x1::event::emit_event<UpdatePoolCreateEvent>(&mut v0.update_pool_create_events, v1);
    }

    public fun update_protocol_fee_claim_authority(arg0: &signer, arg1: address) acquires GlobalConfig {
        assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<GlobalConfig>(@cetus);
        v0.protocol_fee_claim_authority = arg1;
        let v1 = UpdateClaimAuthEvent{
            old_auth : v0.protocol_fee_claim_authority,
            new_auth : v0.protocol_fee_claim_authority,
        };
        0x1::event::emit_event<UpdateClaimAuthEvent>(&mut v0.update_claim_auth_events, v1);
    }

    public fun update_protocol_fee_rate(arg0: &signer, arg1: u64) acquires GlobalConfig {
        assert_protocol_authority(arg0);
        assert!(arg1 <= 3000, 3);
        let v0 = borrow_global_mut<GlobalConfig>(@cetus);
        v0.protocol_fee_rate = arg1;
        let v1 = UpdateFeeRateEvent{
            old_fee_rate : v0.protocol_fee_rate,
            new_fee_rate : arg1,
        };
        0x1::event::emit_event<UpdateFeeRateEvent>(&mut v0.update_fee_rate_events, v1);
    }

    // decompiled from Move bytecode v6
}

