# Tomasulo RAT + ARF — spec-faithful RTL and UVM verification

Source of truth: **Tomasulo Engine – Block Specification Sheet, Rev 1.0**.

This package implements only the requested RAT/ARF scope plus a small integration wrapper used to verify the specified RAT-qualified ARF write path.

## RTL
- `rv32i_types_pkg.sv` — RSTag enum exactly matching the specification.
- `rat.sv` — RAT interface and behavior from §6.
- `arf.sv` — ARF interface and behavior from §7.
- `rat_arf_subsystem.sv` — test/integration wrapper. It drives `ARF.cdb_valid = CDB.cdb_valid & RAT.cdb_match`, exactly as required by the spec's WAW protection decision.

## UVM
- `rat_arf_if.sv` — clocking interface.
- `rat_arf_uvm_pkg.sv` — sequence item, driver, monitor, scoreboard, environment, directed and random sequences, test.
- `tb_top.sv` — DUT and UVM top.

## Verification intent
The directed sequence checks:
1. reset clears RAT and ARF;
2. rename and combinational lookup;
3. CDB match and clear;
4. same-cycle clear + rename, with rename winning;
5. x0 protection;
6. WAW protection through `cdb_match`-qualified ARF write.

The random sequence runs 500 additional legal cycles against a cycle-accurate reference model.

## Simulator status
No open-source SystemVerilog/UVM simulator (e.g. Icarus Verilog, Verilator, or commercial simulator) is installed in the current execution environment, so an actual HDL compile/run could not be performed here. The files are structured for a UVM-capable simulator. Do not treat the RTL as simulator-compiled in this environment.

For a UVM simulator, compile in this order:
1. `rv32i_types_pkg.sv`
2. `rat.sv`
3. `arf.sv`
4. `rat_arf_subsystem.sv`
5. `rat_arf_if.sv`
6. `rat_arf_uvm_pkg.sv`
7. `tb_top.sv`

Run with UVM test `rat_arf_test`.
