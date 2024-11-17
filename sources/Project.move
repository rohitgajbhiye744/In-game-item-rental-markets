module MyModule::InGameItemRental {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a rentable item.
    struct RentalItem has store, key {
        owner: address,         // Address of the item owner
        price_per_rental: u64,  // Price for renting the item
        is_available: bool,     // Availability status of the item
    }

    /// Function to list an in-game item for rent with a specified price.
    public fun list_item_for_rent(owner: &signer, price_per_rental: u64) {
        let rental_item = RentalItem {
            owner: signer::address_of(owner),
            price_per_rental,
            is_available: true,
        };
        move_to(owner, rental_item);
    }

    /// Function for a user to rent a listed item.
    public fun rent_item(renter: &signer, item_owner: address, rental_price: u64) acquires RentalItem {
        let rental_item = borrow_global_mut<RentalItem>(item_owner);

        // Ensure the item is available for rent.
        assert!(rental_item.is_available, 1);  // Error code 1: Item unavailable
        // Ensure the rental price matches.
        assert!(rental_item.price_per_rental == rental_price, 2);  // Error code 2: Price mismatch

        // Transfer the rental price from the renter to the item's owner.
        let payment = coin::withdraw<AptosCoin>(renter, rental_price);
        coin::deposit<AptosCoin>(item_owner, payment);

        // Mark the item as unavailable for rent.
        rental_item.is_available = false;
    }
}
