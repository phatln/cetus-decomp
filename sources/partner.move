module cetus::partner {
    struct AcceptReceiverEvent has drop, store {
        name: 0x1::string::String,
        receiver: address,
    }

    struct ClaimRefFeeEvent has drop, store {
        name: 0x1::string::String,
        receiver: address,
        coin_type: 0x1::type_info::TypeInfo,
        amount: u64,
    }

    struct CreateEvent has drop, store {
        partner_address: address,
        fee_rate: u64,
        name: 0x1::string::String,
        receiver: address,
        start_time: u64,
        end_time: u64,
    }

    struct Partner has store {
        metadata: PartnerMetadata,
        signer_capability: 0x1::account::SignerCapability,
    }

    struct PartnerMetadata has copy, drop, store {
        partner_address: address,
        receiver: address,
        pending_receiver: address,
        fee_rate: u64,
        start_time: u64,
        end_time: u64,
    }

    struct Partners has key {
        data: 0x1::table::Table<0x1::string::String, Partner>,
        create_events: 0x1::event::EventHandle<CreateEvent>,
        update_fee_rate_events: 0x1::event::EventHandle<UpdateFeeRateEvent>,
        update_time_events: 0x1::event::EventHandle<UpdateTimeEvent>,
        transfer_receiver_events: 0x1::event::EventHandle<TransferReceiverEvent>,
        accept_receiver_events: 0x1::event::EventHandle<AcceptReceiverEvent>,
        receive_ref_fee_events: 0x1::event::EventHandle<ReceiveRefFeeEvent>,
        claim_ref_fee_events: 0x1::event::EventHandle<ClaimRefFeeEvent>,
    }

    struct ReceiveRefFeeEvent has drop, store {
        name: 0x1::string::String,
        amount: u64,
        coin_type: 0x1::type_info::TypeInfo,
    }

    struct TransferReceiverEvent has drop, store {
        name: 0x1::string::String,
        old_receiver: address,
        new_receiver: address,
    }

    struct UpdateFeeRateEvent has drop, store {
        name: 0x1::string::String,
        old_fee_rate: u64,
        new_fee_rate: u64,
    }

    struct UpdateTimeEvent has drop, store {
        name: 0x1::string::String,
        start_time: u64,
        end_time: u64,
    }

    public fun accept_receiver(arg0: &signer, arg1: 0x1::string::String) acquires Partners {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<Partners>(@cetus);
        assert!(0x1::table::contains<0x1::string::String, Partner>(&v1.data, arg1), 3);
        let v2 = 0x1::table::borrow_mut<0x1::string::String, Partner>(&mut v1.data, arg1);
        assert!(v0 == v2.metadata.pending_receiver, 4);
        v2.metadata.receiver = v0;
        v2.metadata.pending_receiver = @0x0;
        let v3 = AcceptReceiverEvent{
            name     : arg1,
            receiver : v0,
        };
        0x1::event::emit_event<AcceptReceiverEvent>(&mut v1.accept_receiver_events, v3);
    }

    public fun claim_ref_fee<T0>(arg0: &signer, arg1: 0x1::string::String) acquires Partners {
        let v0 = borrow_global_mut<Partners>(@cetus);
        assert!(0x1::table::contains<0x1::string::String, Partner>(&v0.data, arg1), 3);
        let v1 = 0x1::table::borrow<0x1::string::String, Partner>(&v0.data, arg1);
        assert!(0x1::signer::address_of(arg0) == v1.metadata.receiver, 4);
        let v2 = 0x1::coin::balance<T0>(v1.metadata.partner_address);
        let v3 = 0x1::account::create_signer_with_capability(&v1.signer_capability);
        if (!0x1::coin::is_account_registered<T0>(0x1::signer::address_of(arg0))) {
            0x1::coin::register<T0>(arg0);
        };
        0x1::coin::deposit<T0>(v1.metadata.receiver, 0x1::coin::withdraw<T0>(&v3, v2));
        let v4 = ClaimRefFeeEvent{
            name      : arg1,
            receiver  : v1.metadata.receiver,
            coin_type : 0x1::type_info::type_of<T0>(),
            amount    : v2,
        };
        0x1::event::emit_event<ClaimRefFeeEvent>(&mut v0.claim_ref_fee_events, v4);
    }

    public fun create_partner(arg0: &signer, arg1: 0x1::string::String, arg2: u64, arg3: address, arg4: u64, arg5: u64) acquires Partners {
        assert!(arg5 > arg4, 5);
        assert!(arg5 > 0x1::timestamp::now_seconds(), 5);
        assert!(arg2 < 10000, 6);
        assert!(!0x1::string::is_empty(&arg1), 7);
        cetus::config::assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<Partners>(@cetus);
        assert!(!0x1::table::contains<0x1::string::String, Partner>(&v0.data, arg1), 2);
        let (v1, v2) = 0x1::account::create_resource_account(arg0, *0x1::string::bytes(&arg1));
        let v3 = v1;
        let v4 = 0x1::signer::address_of(&v3);
        let v5 = PartnerMetadata{
            partner_address  : v4,
            receiver         : arg3,
            pending_receiver : @0x0,
            fee_rate         : arg2,
            start_time       : arg4,
            end_time         : arg5,
        };
        let v6 = Partner{
            metadata          : v5,
            signer_capability : v2,
        };
        0x1::table::add<0x1::string::String, Partner>(&mut v0.data, arg1, v6);
        let v7 = CreateEvent{
            partner_address : v4,
            fee_rate        : arg2,
            name            : arg1,
            receiver        : arg3,
            start_time      : arg4,
            end_time        : arg5,
        };
        0x1::event::emit_event<CreateEvent>(&mut v0.create_events, v7);
    }

    public fun get_ref_fee_rate(arg0: 0x1::string::String) : u64 acquires Partners {
        let v0 = &borrow_global<Partners>(@cetus).data;
        if (!0x1::table::contains<0x1::string::String, Partner>(v0, arg0)) {
            return 0
        };
        let v1 = 0x1::table::borrow<0x1::string::String, Partner>(v0, arg0);
        let v2 = 0x1::timestamp::now_seconds();
        if (v1.metadata.start_time > v2 || v1.metadata.end_time <= v2) {
            return 0
        };
        v1.metadata.fee_rate
    }

    public fun initialize(arg0: &signer) {
        cetus::config::assert_initialize_authority(arg0);
        let v0 = Partners{
            data                     : 0x1::table::new<0x1::string::String, Partner>(),
            create_events            : 0x1::account::new_event_handle<CreateEvent>(arg0),
            update_fee_rate_events   : 0x1::account::new_event_handle<UpdateFeeRateEvent>(arg0),
            update_time_events       : 0x1::account::new_event_handle<UpdateTimeEvent>(arg0),
            transfer_receiver_events : 0x1::account::new_event_handle<TransferReceiverEvent>(arg0),
            accept_receiver_events   : 0x1::account::new_event_handle<AcceptReceiverEvent>(arg0),
            receive_ref_fee_events   : 0x1::account::new_event_handle<ReceiveRefFeeEvent>(arg0),
            claim_ref_fee_events     : 0x1::account::new_event_handle<ClaimRefFeeEvent>(arg0),
        };
        move_to<Partners>(arg0, v0);
    }

    public fun partner_fee_rate_denominator() : u64 {
        10000
    }

    public fun receive_ref_fee<T0>(arg0: 0x1::string::String, arg1: 0x1::coin::Coin<T0>) acquires Partners {
        let v0 = borrow_global_mut<Partners>(@cetus);
        assert!(0x1::table::contains<0x1::string::String, Partner>(&v0.data, arg0), 3);
        let v1 = 0x1::table::borrow<0x1::string::String, Partner>(&v0.data, arg0);
        if (!0x1::coin::is_account_registered<T0>(v1.metadata.partner_address)) {
            let v2 = 0x1::account::create_signer_with_capability(&v1.signer_capability);
            0x1::coin::register<T0>(&v2);
        };
        let v3 = 0x1::coin::value<T0>(&arg1);
        0x1::coin::deposit<T0>(v1.metadata.partner_address, arg1);
        let v4 = ReceiveRefFeeEvent{
            name      : arg0,
            amount    : v3,
            coin_type : 0x1::type_info::type_of<T0>(),
        };
        0x1::event::emit_event<ReceiveRefFeeEvent>(&mut v0.receive_ref_fee_events, v4);
    }

    public fun transfer_receiver(arg0: &signer, arg1: 0x1::string::String, arg2: address) acquires Partners {
        let v0 = borrow_global_mut<Partners>(@cetus);
        assert!(0x1::table::contains<0x1::string::String, Partner>(&v0.data, arg1), 3);
        let v1 = 0x1::table::borrow_mut<0x1::string::String, Partner>(&mut v0.data, arg1);
        assert!(0x1::signer::address_of(arg0) == v1.metadata.receiver, 4);
        v1.metadata.pending_receiver = arg2;
        let v2 = TransferReceiverEvent{
            name         : arg1,
            old_receiver : v1.metadata.receiver,
            new_receiver : arg2,
        };
        0x1::event::emit_event<TransferReceiverEvent>(&mut v0.transfer_receiver_events, v2);
    }

    public fun update_fee_rate(arg0: &signer, arg1: 0x1::string::String, arg2: u64) acquires Partners {
        assert!(arg2 < 10000, 6);
        cetus::config::assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<Partners>(@cetus);
        assert!(0x1::table::contains<0x1::string::String, Partner>(&v0.data, arg1), 3);
        let v1 = 0x1::table::borrow_mut<0x1::string::String, Partner>(&mut v0.data, arg1);
        v1.metadata.fee_rate = arg2;
        let v2 = UpdateFeeRateEvent{
            name         : arg1,
            old_fee_rate : v1.metadata.fee_rate,
            new_fee_rate : arg2,
        };
        0x1::event::emit_event<UpdateFeeRateEvent>(&mut v0.update_fee_rate_events, v2);
    }

    public fun update_time(arg0: &signer, arg1: 0x1::string::String, arg2: u64, arg3: u64) acquires Partners {
        assert!(arg3 > arg2, 5);
        assert!(arg3 > 0x1::timestamp::now_seconds(), 5);
        cetus::config::assert_protocol_authority(arg0);
        let v0 = borrow_global_mut<Partners>(@cetus);
        assert!(0x1::table::contains<0x1::string::String, Partner>(&v0.data, arg1), 3);
        let v1 = 0x1::table::borrow_mut<0x1::string::String, Partner>(&mut v0.data, arg1);
        v1.metadata.start_time = arg2;
        v1.metadata.end_time = arg3;
        let v2 = UpdateTimeEvent{
            name       : arg1,
            start_time : arg2,
            end_time   : arg3,
        };
        0x1::event::emit_event<UpdateTimeEvent>(&mut v0.update_time_events, v2);
    }

    // decompiled from Move bytecode v6
}

