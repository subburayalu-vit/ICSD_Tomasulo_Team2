module arf #(
    parameter int NUM_REGS = 32,
    parameter int DATA_W   = 32
) (
    input  logic clk,
    input  logic reset,
    input  logic cdb_valid,
    input  logic [4:0] cdb_dest,
    input  logic [DATA_W-1:0] cdb_data,
    input  logic [4:0] read_addr1,
    input  logic [4:0] read_addr2,
    output logic [DATA_W-1:0] read_data1,
    output logic [DATA_W-1:0] read_data2
);
    logic [DATA_W-1:0] reg_file [0:NUM_REGS-1];

    always_comb begin
        if (read_addr1 == 5'd0)
            read_data1 = '0;
        else
            read_data1 = reg_file[read_addr1];

        if (read_addr2 == 5'd0)
            read_data2 = '0;
        else
            read_data2 = reg_file[read_addr2];
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < NUM_REGS; i++)
                reg_file[i] <= '0;
        end else begin
            if (cdb_valid && cdb_dest != 5'd0)
                reg_file[cdb_dest] <= cdb_data;
        end
    end
endmodule
