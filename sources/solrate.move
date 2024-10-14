module solrate::review_store {
    use std::signer;
    use std::string::{Self};
    use aptos_framework::object::{Self, ObjectCore};
    use aptos_framework::event;
    #[test_only]
    use std::debug;

    //:!:>resource
    struct ReviewHolder has key, store, copy {
        reviewer_account: address,
        contract_address: address,
        review_url: string::String,
        zk_proof_url: string::String,
    }

    #[event]
    struct ReviewStore has key, store, drop {
        reviewer_account: address,
        contract_address: address,
        review_url: string::String,
        zk_proof_url: string::String,
    }

    /// There is no review present
    const ENO_REVIEW: u64 = 0;

    public entry fun store_review(caller: &signer, reviewer: address, contract: address, review: string::String, zk_proof: string::String) {
        let caller_address = signer::address_of(caller);
        let constructor_ref = object::create_object(caller_address);
        let object_signer = object::generate_signer(&constructor_ref);

        move_to(&object_signer, ReviewHolder {
            reviewer_account: reviewer,
            contract_address: contract,
            review_url: review,
            zk_proof_url: zk_proof,
        });

        let object = object::object_from_constructor_ref<ObjectCore>(&constructor_ref);
        object::transfer(caller, object, contract);

        event::emit (ReviewStore {
            reviewer_account: reviewer,
            contract_address: contract,
            review_url: review,
            zk_proof_url: zk_proof,
        });
    }

    #[test(account = @0x1,reviewer = @0x2,contract = @0x3)]
    public entry fun test_store_review(account: signer, reviewer: address, contract: address) {
        let review: string::String = string::utf8(b"Review");
        let zk_proof: string::String = string::utf8(b"ipfs://zk_proof...");
        debug::print(&review);

        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        store_review(&account, reviewer, contract, review, zk_proof);
    }
}