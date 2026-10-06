package rat_arf_uvm_pkg;
  import uvm_pkg::*;
  import rv32i_types_pkg::*;
  `include "uvm_macros.svh"

  class rat_arf_item extends uvm_sequence_item;
    rand bit reset;
    rand bit issue_en;
    rand bit [4:0] issue_dest;
    rand RSTag issue_tag;
    rand bit cdb_valid;
    rand RSTag cdb_tag;
    rand bit [4:0] cdb_dest;
    rand bit [31:0] cdb_data;
    rand bit [4:0] lookup_reg1;
    rand bit [4:0] lookup_reg2;

    RSTag tag1;
    RSTag tag2;
    bit cdb_match;
    bit [31:0] read_data1;
    bit [31:0] read_data2;

    `uvm_object_utils_begin(rat_arf_item)
      `uvm_field_int(reset, UVM_DEFAULT)
      `uvm_field_int(issue_en, UVM_DEFAULT)
      `uvm_field_int(issue_dest, UVM_DEFAULT)
      `uvm_field_enum(RSTag, issue_tag, UVM_DEFAULT)
      `uvm_field_int(cdb_valid, UVM_DEFAULT)
      `uvm_field_enum(RSTag, cdb_tag, UVM_DEFAULT)
      `uvm_field_int(cdb_dest, UVM_DEFAULT)
      `uvm_field_int(cdb_data, UVM_DEFAULT)
      `uvm_field_int(lookup_reg1, UVM_DEFAULT)
      `uvm_field_int(lookup_reg2, UVM_DEFAULT)
      `uvm_field_enum(RSTag, tag1, UVM_DEFAULT)
      `uvm_field_enum(RSTag, tag2, UVM_DEFAULT)
      `uvm_field_int(cdb_match, UVM_DEFAULT)
      `uvm_field_int(read_data1, UVM_DEFAULT)
      `uvm_field_int(read_data2, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name="rat_arf_item");
      super.new(name);
    endfunction
  endclass

  class rat_arf_driver extends uvm_driver #(rat_arf_item);
    `uvm_component_utils(rat_arf_driver)
    virtual rat_arf_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual rat_arf_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "rat_arf_if not found")
    endfunction

    task run_phase(uvm_phase phase);
      rat_arf_item tr;
      forever begin
        seq_item_port.get_next_item(tr);
        @(vif.drv_cb);
        vif.drv_cb.reset       <= tr.reset;
        vif.drv_cb.issue_en    <= tr.issue_en;
        vif.drv_cb.issue_dest  <= tr.issue_dest;
        vif.drv_cb.issue_tag   <= tr.issue_tag;
        vif.drv_cb.cdb_valid   <= tr.cdb_valid;
        vif.drv_cb.cdb_tag     <= tr.cdb_tag;
        vif.drv_cb.cdb_dest    <= tr.cdb_dest;
        vif.drv_cb.cdb_data    <= tr.cdb_data;
        vif.drv_cb.lookup_reg1 <= tr.lookup_reg1;
        vif.drv_cb.lookup_reg2 <= tr.lookup_reg2;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class rat_arf_monitor extends uvm_monitor;
    `uvm_component_utils(rat_arf_monitor)
    virtual rat_arf_if vif;
    uvm_analysis_port #(rat_arf_item) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual rat_arf_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "rat_arf_if not found")
    endfunction

    task run_phase(uvm_phase phase);
      rat_arf_item tr;
      forever begin
        @(vif.mon_cb);
        tr = rat_arf_item::type_id::create("tr");
        tr.reset       = vif.mon_cb.reset;
        tr.issue_en    = vif.mon_cb.issue_en;
        tr.issue_dest  = vif.mon_cb.issue_dest;
        tr.issue_tag   = vif.mon_cb.issue_tag;
        tr.cdb_valid   = vif.mon_cb.cdb_valid;
        tr.cdb_tag     = vif.mon_cb.cdb_tag;
        tr.cdb_dest    = vif.mon_cb.cdb_dest;
        tr.cdb_data    = vif.mon_cb.cdb_data;
        tr.lookup_reg1 = vif.mon_cb.lookup_reg1;
        tr.lookup_reg2 = vif.mon_cb.lookup_reg2;
        tr.tag1        = vif.mon_cb.tag1;
        tr.tag2        = vif.mon_cb.tag2;
        tr.cdb_match   = vif.mon_cb.cdb_match;
        tr.read_data1  = vif.mon_cb.read_data1;
        tr.read_data2  = vif.mon_cb.read_data2;
        ap.write(tr);
      end
    endtask
  endclass

  class rat_arf_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(rat_arf_scoreboard)
    uvm_analysis_imp #(rat_arf_item, rat_arf_scoreboard) imp;
    RSTag model_rat[32];
    bit [31:0] model_arf[32];

    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
      reset_model();
    endfunction

    function void reset_model();
      for (int i=0;i<32;i++) begin
        model_rat[i] = TAG_NONE;
        model_arf[i] = 32'd0;
      end
    endfunction

    function void write(rat_arf_item tr);
      RSTag exp_t1, exp_t2;
      bit exp_match;
      bit [31:0] exp_d1, exp_d2;

      // Outputs are observed before the clock edge updates state.
      exp_t1 = (tr.lookup_reg1 == 0) ? TAG_NONE : model_rat[tr.lookup_reg1];
      exp_t2 = (tr.lookup_reg2 == 0) ? TAG_NONE : model_rat[tr.lookup_reg2];
      exp_match = 0;
      if (tr.cdb_valid) begin
        for (int i=1;i<32;i++)
          if (model_rat[i] == tr.cdb_tag) exp_match = 1;
      end
      exp_d1 = (tr.lookup_reg1 == 0) ? 32'd0 : model_arf[tr.lookup_reg1];
      exp_d2 = (tr.lookup_reg2 == 0) ? 32'd0 : model_arf[tr.lookup_reg2];

      if (tr.tag1 !== exp_t1) `uvm_error("RAT", $sformatf("tag1 exp=%0d got=%0d", exp_t1, tr.tag1))
      if (tr.tag2 !== exp_t2) `uvm_error("RAT", $sformatf("tag2 exp=%0d got=%0d", exp_t2, tr.tag2))
      if (tr.cdb_match !== exp_match) `uvm_error("RAT", $sformatf("cdb_match exp=%0b got=%0b", exp_match, tr.cdb_match))
      if (tr.read_data1 !== exp_d1) `uvm_error("ARF", $sformatf("read_data1 exp=%08h got=%08h", exp_d1, tr.read_data1))
      if (tr.read_data2 !== exp_d2) `uvm_error("ARF", $sformatf("read_data2 exp=%08h got=%08h", exp_d2, tr.read_data2))

      // Synchronous state update model. Rename is applied after clear, so it wins.
      if (tr.reset) begin
        for (int i=0;i<32;i++) begin
          model_rat[i] = TAG_NONE;
          model_arf[i] = 32'd0;
        end
      end else begin
        for (int i=1;i<32;i++)
          if (tr.cdb_valid && model_rat[i] == tr.cdb_tag) model_rat[i] = TAG_NONE;
        if (tr.issue_en && tr.issue_dest != 0) model_rat[tr.issue_dest] = tr.issue_tag;
        model_rat[0] = TAG_NONE;
        if (tr.cdb_valid && exp_match && tr.cdb_dest != 0)
          model_arf[tr.cdb_dest] = tr.cdb_data;
        model_arf[0] = 32'd0;
      end
    endfunction
  endclass

  class rat_arf_env extends uvm_env;
    `uvm_component_utils(rat_arf_env)
    uvm_sequencer #(rat_arf_item) seqr;
    rat_arf_driver drv;
    rat_arf_monitor mon;
    rat_arf_scoreboard sb;

    function new(string name, uvm_component parent); super.new(name,parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      seqr = uvm_sequencer#(rat_arf_item)::type_id::create("seqr", this);
      drv  = rat_arf_driver::type_id::create("drv", this);
      mon  = rat_arf_monitor::type_id::create("mon", this);
      sb   = rat_arf_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      drv.seq_item_port.connect(seqr.seq_item_export);
      mon.ap.connect(sb.imp);
    endfunction
  endclass

  class rat_arf_base_seq extends uvm_sequence #(rat_arf_item);
    `uvm_object_utils(rat_arf_base_seq)
    function new(string name="rat_arf_base_seq"); super.new(name); endfunction

    task drive_cycle(bit rst=0, bit ien=0, bit [4:0] dest=0, RSTag itag=TAG_NONE,
                     bit cv=0, RSTag ctag=TAG_NONE, bit [4:0] cdest=0, bit [31:0] data=0,
                     bit [4:0] l1=0, bit [4:0] l2=0);
      rat_arf_item tr = rat_arf_item::type_id::create("tr");
      start_item(tr);
      tr.reset=rst; tr.issue_en=ien; tr.issue_dest=dest; tr.issue_tag=itag;
      tr.cdb_valid=cv; tr.cdb_tag=ctag; tr.cdb_dest=cdest; tr.cdb_data=data;
      tr.lookup_reg1=l1; tr.lookup_reg2=l2;
      finish_item(tr);
    endtask
  endclass

  class rat_arf_directed_seq extends rat_arf_base_seq;
    `uvm_object_utils(rat_arf_directed_seq)
    function new(string name="rat_arf_directed_seq"); super.new(name); endfunction

    task body();
      // Reset cycle.
      drive_cycle(1,0,0,TAG_NONE,0,TAG_NONE,0,0,0,0);
      drive_cycle(0,0,0,TAG_NONE,0,TAG_NONE,0,0,0,0);

      // Rename x5 -> ALU1; lookup must be visible after the edge.
      drive_cycle(0,1,5,TAG_ALU1,0,TAG_NONE,0,0,5,0);
      drive_cycle(0,0,0,TAG_NONE,0,TAG_NONE,0,0,5,0);

      // Rename x6 -> ALU2.
      drive_cycle(0,1,6,TAG_ALU2,0,TAG_NONE,0,0,6,0);
      drive_cycle(0,0,0,TAG_NONE,0,TAG_NONE,0,0,6,0);

      // CDB ALU1: match should be true before edge, then x5 clears.
      drive_cycle(0,0,0,TAG_NONE,1,TAG_ALU1,5,32'h1111_2222,5,6);
      drive_cycle(0,0,0,TAG_NONE,0,TAG_NONE,0,0,5,6);

      // Same-cycle clear + rename on x6. Rename must win.
      drive_cycle(0,1,6,TAG_ALU3,1,TAG_ALU2,6,32'hAAAA_5555,6,0);
      drive_cycle(0,0,0,TAG_NONE,0,TAG_NONE,0,0,6,0);

      // x0 must never rename and must always read NONE/0.
      drive_cycle(0,1,0,TAG_ALU1,0,TAG_NONE,0,0,0,0);
      drive_cycle(0,0,0,TAG_NONE,0,TAG_NONE,0,0,0,0);

      // WAW: x7 older ALU1 then younger ALU2. Older CDB must not write ARF.
      drive_cycle(0,1,7,TAG_ALU1,0,TAG_NONE,0,0,7,0);
      drive_cycle(0,1,7,TAG_ALU2,0,TAG_NONE,0,0,7,0);
      drive_cycle(0,0,0,TAG_NONE,1,TAG_ALU1,7,32'h1111_1111,7,0);
      drive_cycle(0,0,0,TAG_NONE,1,TAG_ALU2,7,32'h2222_2222,7,0);
      drive_cycle(0,0,0,TAG_NONE,0,TAG_NONE,0,0,7,0);

      `uvm_info("SEQ", "Directed RAT/ARF scenarios completed", UVM_LOW)
    endtask
  endclass

  class rat_arf_random_seq extends rat_arf_base_seq;
    `uvm_object_utils(rat_arf_random_seq)
    function new(string name="rat_arf_random_seq"); super.new(name); endfunction

    task body();
      repeat (500) begin
        rat_arf_item tr = rat_arf_item::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize() with {
          reset dist {0:=19,1:=1};
          issue_dest inside {[0:31]};
          cdb_dest inside {[0:31]};
          lookup_reg1 inside {[0:31]};
          lookup_reg2 inside {[0:31]};
          issue_tag inside {TAG_ALU1,TAG_ALU2,TAG_ALU3};
          issue_en -> issue_dest != 0;
          cdb_tag inside {TAG_ALU1,TAG_ALU2,TAG_ALU3};
        });
        finish_item(tr);
      end
      `uvm_info("SEQ", "500 random cycles completed", UVM_LOW)
    endtask
  endclass

  class rat_arf_test extends uvm_test;
    `uvm_component_utils(rat_arf_test)
    rat_arf_env env;

    function new(string name, uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = rat_arf_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      rat_arf_directed_seq dseq;
      rat_arf_random_seq rseq;
      phase.raise_objection(this);
      dseq = rat_arf_directed_seq::type_id::create("dseq");
      dseq.start(env.seqr);
      rseq = rat_arf_random_seq::type_id::create("rseq");
      rseq.start(env.seqr);
      repeat (3) @(env.drv.vif.clk);
      phase.drop_objection(this);
    endtask
  endclass
endpackage
