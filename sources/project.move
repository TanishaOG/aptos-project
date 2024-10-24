module EducationInvestmentFund::Fund {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::string::String;

    /// Struct representing an educational startup.
    struct Startup has store, key {
        name: String,         // Name of the startup
        total_funds: u64,    // Total funds raised for the startup
        funding_goal: u64,    // Funding goal for the startup
        funding_end_time: u64 // Time until funding is closed
    }

    /// Function to create a new educational startup with a funding goal.
    public fun create_startup(owner: &signer, name: String, funding_goal: u64, funding_duration: u64) {
        let startup = Startup {
            name,
            total_funds: 0,
            funding_goal,
            funding_end_time: aptos_framework::timestamp::now_seconds() + funding_duration,
        };
        move_to(owner, startup);
    }

    /// Function for users to invest in an educational startup.
    public fun invest_in_startup(investor: &signer, startup_owner: address, amount: u64) acquires Startup {
        let startup = borrow_global_mut<Startup>(startup_owner);

        // Check if the investment is still open
        assert!(aptos_framework::timestamp::now_seconds() <= startup.funding_end_time, 2); // Investment closed

        // Check if the investment does not exceed the funding goal
        assert!(startup.total_funds + amount <= startup.funding_goal, 3); // Exceeds funding goal

        // Transfer investment amount from the investor to the startup owner
        let investment_coins = coin::withdraw<AptosCoin>(investor, amount);
        coin::deposit<AptosCoin>(startup_owner, investment_coins);

        // Update the total funds raised for the startup
        startup.total_funds = startup.total_funds + amount;
    }

    /// Function to get the startup information.
    public fun get_startup_info(startup_owner: address): (String, u64, u64) acquires Startup {
        let startup = borrow_global<Startup>(startup_owner);
        (startup.name, startup.total_funds, startup.funding_goal)
    }
}
