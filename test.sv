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
		// Se toma interfaz
        if(!uvm_config_db#(virtual if_dut)::get(this, "", "_if", vif))
            `uvm_fatal("Test", "Could not get vif")

        uvm_config_db#(virtual if_dut)::set(this, "e0.a0.*", "_if", vif);
    endfunction

    virtual task run_phase(uvm_phase phase);
    
    random_item_sequence random_seq = random_item_sequence::type_id::create("random_seq");
	spec_item_sequence spec_seq = spec_item_sequence::type_id::create("spec_seq");

    super.run_phase(phase);

    phase.raise_objection(this);
    // Reset
    apply_reset();
    #20;
        // Secuencia aleatoria

    random_seq.randomize();
    random_seq.start(e0.a0.sequencer_inst);
    #20;
		
	// Secuencia aleatoria
	random_seq.randomize();
	random_seq.start(e0.a0.sequencer_inst);
	#20;
	
	// Secuencia específica de 011011010
	spec_seq.array = {0, 1, 1, 0, 1, 1, 0, 1, 0};
	spec_seq.start(e0.a0.sequencer_inst);
	#20;
	
	// Secuencia específica de 101011100
	spec_seq.array = {1, 0, 1, 0, 1, 1, 1, 0, 0};
	spec_seq.start(e0.a0.sequencer_inst);
	#20;
	
	// Secuencia específica de 111011011
	spec_seq.array = {1, 1, 1, 0, 1, 1, 0, 1, 1};
	spec_seq.start(e0.a0.sequencer_inst);
	#20;
	
	// Secuencia aleatoria
	random_seq.randomize();
	random_seq.start(e0.a0.sequencer_inst);
	#20

     phase.drop_objection(this);
    endtask

	// Task para aplicar reset
    virtual task apply_reset();
        vif.rstn = 0;
        repeat(5) @(posedge vif.clk);
        vif.rstn = 1;
        repeat(5) @(posedge vif.clk);
    endtask

endclass
