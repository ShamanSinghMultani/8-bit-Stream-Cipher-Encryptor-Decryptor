`timescale 1us/1ns
module tb_encrypt;

    // Testbench variables
    reg clk = 0;
    reg rst_n;

    reg load_seed;
    reg [7:0] seed_in;
    reg encrypt_en;
    reg [7:0] data_in;

    wire [7:0] data_out;
    wire [7:0] data_out_ref;

    // Parameters
    parameter HALF_PERIOD = 0.5;
    integer i;
    integer success_count = 0;
    integer test_count    = 0;
    integer error_count   = 0;

    // Instantiate DUT
    top_encrypt ENCRYPT_MODULE (
        .rst_n(rst_n),
        .clk(clk),
        .load_seed(load_seed),
        .seed_in(seed_in),
        .encrypt_en(encrypt_en),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Instantiate Reference (Golden) Module
    top_encrypt_golden ENCRYPT_MODULE_REF (
        .rst_n(rst_n),
        .clk(clk),
        .load_seed(load_seed),
        .seed_in(seed_in),
        .encrypt_en(encrypt_en),
        .data_in(data_in),
        .data_out(data_out_ref)
    );

    // Clock generation
    always #HALF_PERIOD clk = ~clk;

    // ------------------------------
    // Main stimulus
    // ------------------------------
    initial begin
        rst_n = 0;
        load_seed = 0;
        seed_in = 0;
        data_in = 0;
        encrypt_en = 0;

        #20;
        rst_n = 1;

        // Encrypt the word "Redapple."
        @(posedge clk);
        encrypt_data("R"); validate_data();
        encrypt_data("e"); validate_data();
        encrypt_data("d"); validate_data();
        encrypt_data(" "); validate_data();
        encrypt_data("a"); validate_data();
        encrypt_data("p"); validate_data();
        encrypt_data("p"); validate_data();
        encrypt_data("l"); validate_data();
        encrypt_data("e"); validate_data();
        encrypt_data("."); validate_data();

        // Reload PRNG with new seed
        #20;
        load_new_seed(8'hCD);

        encrypt_data(8'hC8); validate_data();
        encrypt_data(8'h50); validate_data();
        encrypt_data(8'h0E); validate_data();
        encrypt_data(8'hF4); validate_data();
        encrypt_data(8'hC9); validate_data();
        encrypt_data(8'h21); validate_data();
        encrypt_data(8'hD3); validate_data();
        encrypt_data(8'h2A); validate_data();
        encrypt_data(8'hE9); validate_data();
        encrypt_data(8'h36); validate_data();

        // Display final test results
        if (error_count == 0)
            $display("%0t TEST PASS: total=%0d, passed=%0d, failed=%0d",
                     $time, test_count, success_count, error_count);
        else
            $display("%0t TEST FAIL: total=%0d, passed=%0d, failed=%0d",
                     $time, test_count, success_count, error_count);

        #40;
        $stop;
    end

    // ------------------------------
    // Task: Load new PRNG seed
    // ------------------------------
    task load_new_seed;
        input [7:0] seed;
        begin
            @(posedge clk);
            load_seed = 1;
            seed_in = seed;
            @(posedge clk);
            load_seed = 0;
        end
    endtask

    // ------------------------------
    // Task: Encrypt one byte of data
    // ------------------------------
    task encrypt_data;
        input [7:0] data;
        begin
            @(posedge clk);
            encrypt_en = 1;
            data_in = data;
            @(posedge clk);
            encrypt_en = 0;
        end
    endtask

    // ------------------------------
    // Task: Validate DUT vs Golden
    // ------------------------------
    task validate_data;
        begin
            @(posedge clk);
            @(negedge clk);

            test_count = test_count + 1;

            if (data_out_ref === data_out) begin
                $display("%0t TEST %0d PASS: REF=%02x DUT=%02x",
                         $time, test_count, data_out_ref, data_out);
                success_count = success_count + 1;
            end else begin
                $display("%0t TEST %0d FAIL: REF=%02x DUT=%02x",
                         $time, test_count, data_out_ref, data_out);
                error_count = error_count + 1;
            end
        end
    endtask

endmodule

