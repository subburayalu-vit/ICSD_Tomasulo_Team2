
module tomasulo_core (
    input  rv32i_types::DecodedInst decoded_inst,

    // RAT lookup results
    input  logic [3:0] rat_tag1,
    input  logic [3:0] rat_tag2,

    // ARF read results
    input  logic [31:0] arf_read_data1,
    input  logic [31:0] arf_read_data2,

    // Reservation Station interface
    input  logic        rs_has_free,
    input  logic [3:0]  rs_free_tag,

    output logic        rs_alloc_en,
    output logic [3:0]  rs_alloc_op,
    output logic [31:0] rs_alloc_Vj,
    output logic [31:0] rs_alloc_Vk,
    output logic [3:0]  rs_alloc_Qj,
    output logic [3:0]  rs_alloc_Qk,
    output logic [4:0]  rs_alloc_dest,

    // RAT issue interface
    output logic        issue_en,
    output logic [4:0]  issue_dest,
    output logic [3:0]  issue_tag,

    // RAT and ARF lookup addresses
    output logic [4:0]  lookup_reg1,
    output logic [4:0]  lookup_reg2,

    // Common Data Bus
    input  logic        cdb_valid,
    input  logic [3:0]  cdb_tag,
    input  logic [31:0] cdb_data,

    // Frontend control
    output logic        stall_frontend
);

    import rv32i_types::*;

    // Internal operand-resolution signals
    logic [31:0] operand1_value;
    logic [31:0] operand2_value;
    logic [3:0]  operand1_tag;
    logic [3:0]  operand2_tag;

    logic issuable;

    // Tag encodings from the shared package
    localparam logic [3:0] TAG_NONE = 4'd0;

    // Check whether this instruction may be issued.
    always_comb begin
        issuable = decoded_inst.valid &&
                   decoded_inst.supported &&
                   (decoded_inst.rd != 5'd0);
    end

    // Source-register lookup addresses.
    always_comb begin
        lookup_reg1 = decoded_inst.rs1;
        lookup_reg2 = decoded_inst.rs2;
    end

    // Resolve operand 1.
    always_comb begin
        operand1_value = 32'd0;
        operand1_tag   = TAG_NONE;

        if (decoded_inst.opcode == OPCODE_LUI) begin
            operand1_value = 32'd0;
        end
        else if (decoded_inst.opcode == OPCODE_AUIPC) begin
            operand1_value = decoded_inst.pc;
        end
        else if (decoded_inst.rs1 == 5'd0) begin
            operand1_value = 32'd0;
        end
        else if (rat_tag1 == TAG_NONE) begin
            operand1_value = arf_read_data1;
        end
        else if (cdb_valid && (rat_tag1 == cdb_tag)) begin
            operand1_value = cdb_data;
        end
        else begin
            operand1_value = 32'd0;
            operand1_tag   = rat_tag1;
        end
    end

    // Resolve operand 2.
    always_comb begin
        operand2_value = 32'd0;
        operand2_tag   = TAG_NONE;

        if (decoded_inst.opcode == OPCODE_R) begin
            if (decoded_inst.rs2 == 5'd0) begin
                operand2_value = 32'd0;
            end
            else if (rat_tag2 == TAG_NONE) begin
                operand2_value = arf_read_data2;
            end
            else if (cdb_valid && (rat_tag2 == cdb_tag)) begin
                operand2_value = cdb_data;
            end
            else begin
                operand2_value = 32'd0;
                operand2_tag   = rat_tag2;
            end
        end
        else begin
            // Immediate operand for I-type, LUI, and AUIPC.
            operand2_value = decoded_inst.imm;
            operand2_tag   = TAG_NONE;
        end
    end

    
    // Issue and reservation-station allocation controls.
    always_comb begin
        rs_alloc_en   = issuable && rs_has_free;
        issue_en      = rs_alloc_en;
        stall_frontend = issuable && !rs_has_free;

        // Safe defaults when no instruction is issued.
        rs_alloc_op   = 4'd15;  // NOP
        rs_alloc_Vj   = 32'd0;
        rs_alloc_Vk   = 32'd0;
        rs_alloc_Qj   = 4'd0;
        rs_alloc_Qk   = 4'd0;
        rs_alloc_dest = 5'd0;

        issue_dest    = 5'd0;
        issue_tag     = 4'd0;

        if (rs_alloc_en) begin
            rs_alloc_op   = decoded_inst.op_name;
            rs_alloc_Vj   = operand1_value;
            rs_alloc_Vk   = operand2_value;
            rs_alloc_Qj   = operand1_tag;
            rs_alloc_Qk   = operand2_tag;
            rs_alloc_dest = decoded_inst.rd;

            issue_dest    = decoded_inst.rd;
            issue_tag     = rs_free_tag;
        end
    end


endmodule
