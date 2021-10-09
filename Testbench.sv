import uvm_pkg::*;

`include "detector_secuencia.sv"
`include "interface.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "enviroment.sv"
`include "test.sv"


module Testbench;
    

    reg clk;

    if_dut _if;
    
    // Generacion de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    

    det_1011 DUT(
        .clk(_if.clk),
        .rstn(_if.rstn),
        .in(_if.in),
        .out(_if.out)
    );

    initial begin
    uvm_top.enable_print_topology = 1;
    uvm_top.finish_on_completion  = 1;

    uvm_top.set_report_verbosity_level(UVM_HIGH);

    uvm_config_db #(virtual if_dut)::set(null, "uvm_test_top", "_if", _if);
    run_test("base_test");
    end


    
endmodule