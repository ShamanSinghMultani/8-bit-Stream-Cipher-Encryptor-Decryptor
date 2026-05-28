module top_encrypt_golden (
    input        rst_n,
    input        clk,
    input        load_seed,
    input  [7:0] seed_in,
    input        encrypt_en,
    input  [7:0] data_in,
    output reg [7:0] data_out
);

    // Default PRNG seed
    localparam SEED = 8'hCD;

    // Internal signals
    reg encrypt_en_dly;
    reg [7:0] data_in_dly;
    reg [7:0] prng;

    // ---------------------------------------------------
    // Polynomial function for PRNG feedback (LFSR logic)
    // x^8 + x^6 + x^5 + x^4 + 1
    // ---------------------------------------------------
    function [7:0] poly(input [7:0] data_in);
        reg feedback;
        begin
            feedback = data_in[7] ^ data_in[5] ^ data_in[4] ^ data_in[3];
            poly = {data_in[6:0], feedback};
        end
    endfunction

    // ---------------------------------------------------
    // PRNG logic (seed load + feedback)
    // ---------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            prng <= SEED;                  // Default seed after reset
        else if (load_seed)
            prng <= seed_in;               // Load new seed
        else if (encrypt_en)
            prng <= poly(prng);            // Generate next pseudo-random byte
    end

    // ---------------------------------------------------
    // Encrypt input data using PRNG (XOR stream cipher)
    // ---------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            encrypt_en_dly <= 1'b0;
            data_in_dly    <= 8'b0;
            data_out       <= 8'b0;
        end else begin
            encrypt_en_dly <= encrypt_en;
            data_in_dly    <= data_in;

            if (encrypt_en_dly)
                data_out <= prng ^ data_in_dly;  // XOR encryption/decryption
        end
    end

endmodule
