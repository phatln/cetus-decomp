module cetus::utils {
    public fun compare_coin<T0, T1>() : 0x1::comparator::Result {
        let v0 = 0x1::type_info::type_of<T0>();
        let v1 = 0x1::type_info::type_of<T1>();
        0x1::comparator::compare<0x1::type_info::TypeInfo>(&v0, &v1)
    }

    public fun str(arg0: u64) : 0x1::string::String {
        if (arg0 == 0) {
            return 0x1::string::utf8(b"0")
        };
        let v0 = 0x1::vector::empty<u8>();
        while (arg0 > 0) {
            let v1 = ((arg0 % 10) as u8);
            arg0 = arg0 / 10;
            0x1::vector::push_back<u8>(&mut v0, v1 + 48);
        };
        0x1::vector::reverse<u8>(&mut v0);
        0x1::string::utf8(v0)
    }

    // decompiled from Move bytecode v6
}

