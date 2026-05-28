module top_encrypt (
    input        rst_n,
    input        clk,
    input        load_seed,
    input  [7:0] seed_in,
    input        encrypt_en,
    input  [7:0] data_in,
    output reg [7:0] data_out
);

    // Internal signals
    reg        encrypt_en_dly;
    reg [7:0]  data_in_dly;
    wire [7:0] prng;

    // Instantiate PRNG module
    prng PRNG (
        .rst_n(rst_n),
        .clk(clk),
        .load_seed(load_seed),
        .seed_in(seed_in),
        .encrypt_en(encrypt_en),
        .prng(prng)
    );

    // Delay encrypt_en and data_in by one clock cycle
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            encrypt_en_dly <= 1'b0;
            data_in_dly    <= 8'b0;
        end else begin
            encrypt_en_dly <= encrypt_en;
            data_in_dly    <= data_in;
        end
    end

    // Encrypt or decrypt data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 8'b0;
        else if (encrypt_en_dly)
            data_out <= prng ^ data_in_dly;  // XOR encryption/decryption
    end

endmodule
