%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address

const L1_CONTRACT_ADDRESS = (0xC1c54Da1676A16223474fB1557bE295959B20038)

@storage_var
func _totalSupply() -> (totalSupply: felt):
end

@storage_var
func _owners(token_id: felt) -> (res: felt):
end

@l1_handler
func mint{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    from_address : felt,
    to: felt
):
    # Make sure the message was sent by the intended L1 contract.
    assert from_address = L1_CONTRACT_ADDRESS
    _mint(to)

    return ()
end

func _mint{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    to: felt
):
    let (supply) = _totalSupply.read()
    _owners.write(supply, to)
    _totalSupply.write(supply + 1)
    return ()
end

@view
func totalSupply{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (totalSupply: felt):
    let (totalSupply : felt) = _totalSupply.read()
    return (totalSupply)
end

@view
func ownerOf{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(tokenId: felt) -> (owner: felt):
    let (res) = _owners.read(token_id=tokenId)
    return (res)
end