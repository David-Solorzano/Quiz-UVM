import uvm_pkg::*;

class test extends uvm_test;
    `uvm_component_utils(test)

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    env e0;
    virtual if_dut vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e0 = env::type_id::create("e0", this);
        if(!uvm_config_db#(virtual if_dut)::get(this, "", "_if", vif))
            `uvm_fatal("Test", "Could not get vif")

        uvm_config_db#(virtual if_dut)::set(this, "e0.a0.*", "_if", vif);
    endfunction

    virtual task run_phase(uvm_phase phase);
    
        random_item_sequence random_seq = random_item_sequence::type_id::create("random_seq");
    	super.run_phase(phase);

        phase.raise_objection(this);
        // Reset
        apply_reset();
        #50;
        // Secuencia aleatoria

        random_seq.randomize();
        random_seq.start(e0.a0.sequencer_inst);
        #50;

        phase.drop_objection(this);
    endtask

    virtual task apply_reset();
        vif.rstn = 0;
        repeat(5) @(posedge vif.clk);
        vif.rstn = 1;
        repeat(5) @(posedge vif.clk);
    endtask

endclass
