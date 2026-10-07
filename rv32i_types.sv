package rv32i_types;

    // ============================================================
    // RV32I OPCODES
    // ============================================================

    localparam logic [6:0] OPCODE_R      = 7'b0110011;
    localparam logic [6:0] OPCODE_I_ALU  = 7'b0010011;
    localparam logic [6:0] OPCODE_I_LOAD = 7'b0000011;
    localparam logic [6:0] OPCODE_I_JALR = 7'b1100111;
    localparam logic [6:0] OPCODE_S      = 7'b0100011;
    localparam logic [6:0] OPCODE_B      = 7'b1100011;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;
    localparam logic [6:0] OPCODE_J      = 7'b1101111;


    // ============================================================
    // RSTag
    // ============================================================

    typedef enum logic [3:0] {
        NONE   = 4'd0,
        ALU1   = 4'd1,
        ALU2   = 4'd2,
        ALU3   = 4'd3,
        MUL1   = 4'd4,
        MUL2   = 4'd5,
        LOAD1  = 4'd6,
        LOAD2  = 4'd7,
        STORE1 = 4'd8,
        STORE2 = 4'd9
    } RSTag;


    // ============================================================
    // ALU OPERATION
    // ============================================================

    typedef enum logic [3:0] {
        ADD  = 4'd0,
        SUB  = 4'd1,
        SLL  = 4'd2,
        SLT  = 4'd3,
        SLTU = 4'd4,
        XOR  = 4'd5,
        SRL  = 4'd6,
        SRA  = 4'd7,
        OR   = 4'd8,
        AND  = 4'd9,
        NOP  = 4'd15
    } alu_op_t;


    // ============================================================
    // SIGN EXTEND
    // ============================================================

    function automatic logic [31:0] sign_extend(
        input logic [31:0] value,
        input integer from_bits
    );

        logic signed [31:0] temp;

        begin
            temp = $signed(value << (32 - from_bits));
            sign_extend = temp >>> (32 - from_bits);
        end

    endfunction


    // ============================================================
    // DECODED INSTRUCTION
    // ============================================================

    typedef struct packed {

        logic        valid;
        logic        supported;

        logic [31:0] pc;

        logic [6:0]  opcode;

        logic [4:0]  rd;
        logic [4:0]  rs1;
        logic [4:0]  rs2;

        logic [2:0]  funct3;
        logic [6:0]  funct7;

        logic [31:0] imm;

        alu_op_t     op_name;

    } DecodedInst;

endpackage