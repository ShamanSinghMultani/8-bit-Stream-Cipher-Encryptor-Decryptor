module prng (
    input        rst_n,
    input        clk,
    input        load_seed,
    input  [7:0] seed_in,
    input        encrypt_en,
    output reg [7:0] prng
);

    // Default seed value
    localparam SEED = 8'hCD;

    // Feedback polynomial: x^8 + x^6 + x^5 + x^4 + 1
    wire feedback;
    assign feedback = prng[7] ^ prng[5] ^ prng[4] ^ prng[3];

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            prng <= SEED;                      // Reset with default seed
        else if (load_seed)
            prng <= seed_in;                   // Load new seed
        else if (encrypt_en)
            prng <= {prng[6:0], feedback};     // Shift left with feedback
    end

endmodule
