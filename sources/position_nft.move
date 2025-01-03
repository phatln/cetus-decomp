module cetus::position_nft {
    public fun create_collection<T0, T1>(arg0: &signer, arg1: u64, arg2: 0x1::string::String, arg3: 0x1::string::String) : 0x1::string::String {
        let v0 = collection_name<T0, T1>(arg1);
        let v1 = 0x1::vector::empty<bool>();
        0x1::vector::push_back<bool>(&mut v1, true);
        0x1::vector::push_back<bool>(&mut v1, true);
        0x1::vector::push_back<bool>(&mut v1, true);
        0x3::token::create_collection(arg0, v0, arg2, arg3, 0, v1);
        v0
    }

    public fun burn(arg0: &signer, arg1: address, arg2: 0x1::string::String, arg3: u64, arg4: u64) {
        0x3::token::burn_by_creator(arg0, arg1, arg2, position_name(arg3, arg4), 0, 1);
    }

    public fun collection_name<T0, T1>(arg0: u64) : 0x1::string::String {
        let v0 = 0x1::string::utf8(b"Cetus Position | ");
        0x1::string::append(&mut v0, 0x1::coin::symbol<T0>());
        0x1::string::append_utf8(&mut v0, b"-");
        0x1::string::append(&mut v0, 0x1::coin::symbol<T1>());
        0x1::string::append_utf8(&mut v0, b"_tick(");
        0x1::string::append(&mut v0, cetus::utils::str(arg0));
        0x1::string::append_utf8(&mut v0, b")");
        v0
    }

    public fun mint(arg0: &signer, arg1: &signer, arg2: u64, arg3: u64, arg4: 0x1::string::String, arg5: 0x1::string::String) {
        let v0 = position_name(arg2, arg3);
        let v1 = 0x1::vector::empty<0x1::string::String>();
        let v2 = &mut v1;
        0x1::vector::push_back<0x1::string::String>(v2, 0x1::string::utf8(b"index"));
        0x1::vector::push_back<0x1::string::String>(v2, 0x1::string::utf8(b"TOKEN_BURNABLE_BY_CREATOR"));
        let v3 = true;
        let v4 = 0x1::vector::empty<vector<u8>>();
        let v5 = &mut v4;
        0x1::vector::push_back<vector<u8>>(v5, 0x1::bcs::to_bytes<u64>(&arg3));
        0x1::vector::push_back<vector<u8>>(v5, 0x1::bcs::to_bytes<bool>(&v3));
        let v6 = 0x1::vector::empty<0x1::string::String>();
        let v7 = &mut v6;
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"bool"));
        0x3::token::create_token_script(arg1, arg5, v0, 0x1::string::utf8(b""), 1, 1, arg4, 0x1::signer::address_of(arg1), 1000000, 0, vector[false, false, false, false, true], v1, v4, v6);
        0x3::token::direct_transfer_script(arg1, arg0, 0x1::signer::address_of(arg1), arg5, v0, 0, 1);
    }

    public fun mutate_collection_uri(arg0: &signer, arg1: 0x1::string::String, arg2: 0x1::string::String) {
    }

    public fun position_name(arg0: u64, arg1: u64) : 0x1::string::String {
        let v0 = 0x1::string::utf8(b"Cetus LP | Pool");
        0x1::string::append(&mut v0, cetus::utils::str(arg0));
        0x1::string::append_utf8(&mut v0, b"-");
        0x1::string::append(&mut v0, cetus::utils::str(arg1));
        v0
    }

    // decompiled from Move bytecode v6
}

