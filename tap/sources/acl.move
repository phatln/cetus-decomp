module tap::acl {
    struct ACL has store {
        permissions: 0x1::table::Table<address, u128>,
    }

    public fun new() : ACL {
        ACL{permissions: 0x1::table::new<address, u128>()}
    }

    public fun add_role(arg0: &mut ACL, arg1: address, arg2: u8) {
        assert!(arg2 < 128, 0x1::error::invalid_argument(0));
        if (0x1::table::contains<address, u128>(&arg0.permissions, arg1)) {
            let v0 = 0x1::table::borrow_mut<address, u128>(&mut arg0.permissions, arg1);
            *v0 = *v0 | 1 << arg2;
        } else {
            0x1::table::add<address, u128>(&mut arg0.permissions, arg1, 1 << arg2);
        };
    }

    public fun has_role(arg0: &ACL, arg1: address, arg2: u8) : bool {
        assert!(arg2 < 128, 0x1::error::invalid_argument(0));
        0x1::table::contains<address, u128>(&arg0.permissions, arg1) && *0x1::table::borrow<address, u128>(&arg0.permissions, arg1) & 1 << arg2 > 0
    }

    public fun remove_role(arg0: &mut ACL, arg1: address, arg2: u8) {
        assert!(arg2 < 128, 0x1::error::invalid_argument(0));
        if (0x1::table::contains<address, u128>(&arg0.permissions, arg1)) {
            let v0 = 0x1::table::borrow_mut<address, u128>(&mut arg0.permissions, arg1);
            *v0 = *v0 - (1 << arg2);
        };
    }

    public fun set_roles(arg0: &mut ACL, arg1: address, arg2: u128) {
        if (0x1::table::contains<address, u128>(&arg0.permissions, arg1)) {
            *0x1::table::borrow_mut<address, u128>(&mut arg0.permissions, arg1) = arg2;
        } else {
            0x1::table::add<address, u128>(&mut arg0.permissions, arg1, arg2);
        };
    }
}

