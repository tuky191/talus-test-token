module talus::test {
    use sui::coin::{Self, TreasuryCap};
    use sui::url;

    // ============================================================================
    // CONFIGURATION - Edit these values for test deployments
    // ============================================================================
    
    // Decimals: number of decimal places for the token
    // Default: 9 (same as SUI)
    const DECIMALS: u8 = 9;
    
    // Symbol: short ticker symbol (typically 3-6 characters)
    // Test example: b"TEST-TALUS" or b"TALUS-DEV"
    const SYMBOL: vector<u8> = b"TALUS-TEST";
    
    // Name: full token name
    // Test example: b"Talus Test Token"
    const NAME: vector<u8> = b"Talus Test Token";
    
    // Description: token description
    // Test example: Add warning for test tokens
    const DESCRIPTION: vector<u8> = b"Test token for Talus deployment verification - DO NOT USE IN PRODUCTION";
    
    // Icon URL: URL to token icon/logo
    const ICON_URL: vector<u8> = b"https://talus.network/us-icon.png";
    
    // ============================================================================
    // DO NOT EDIT BELOW THIS LINE
    // ============================================================================

    /// The TEST coin type marker (different from production US)
    public struct TEST has drop {}

    /// Module initializer - automatically called when package is published
    /// Creates the currency, mints initial supply, and transfers everything to publisher
    fun init(witness: TEST, ctx: &mut TxContext) {
        let icon_url = if (vector::length(&ICON_URL) == 0) {
            option::none()
        } else {
            option::some(url::new_unsafe_from_bytes(ICON_URL))
        };

        let (mut treasury, metadata) = coin::create_currency(
            witness,
            DECIMALS,
            SYMBOL,
            NAME,
            DESCRIPTION,
            icon_url,
            ctx
        );
        
        // Freeze the metadata object (standard practice)
        transfer::public_freeze_object(metadata);
        
        // Mint initial supply for testing
        // Using 10^19 base units (matching default TALUS_TOTAL_SUPPLY from deploy script)
        // With 9 decimals, this is 10^10 tokens (10 billion tokens)
        let initial_supply = coin::mint(&mut treasury, 10000000000000000000, ctx);
        
        // Transfer the initial coin to the publisher
        // The deployment script will split from this for faucet funding if needed
        transfer::public_transfer(initial_supply, tx_context::sender(ctx));
        
        // Transfer TreasuryCap to the publisher (for potential future minting)
        transfer::public_transfer(treasury, tx_context::sender(ctx));
    }
}
