import uvm_pkg::*;
// Item de secuencia

class transaction_item extends uvm_sequence_item;
    rand bit rstn;
    rand bit in;
    bit out;

    `uvm_object_utils_begin(transaction_item)
        `uvm_field_int(rstn, UVM_DEFAULT)
        `uvm_field_int(in, UVM_DEFAULT)
	`uvm_field_int(out, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint c1 {rstn dist {0:=2, 1:=98};}

    function new(string name = "transaction_item");
        super.new(name);
    endfunction

endclass

// Secuencias disponibles
// Secuancia de transacciones aleatorias
class random_item_sequence extends uvm_sequence;
    `uvm_object_utils(random_item_sequence)

    rand int num_items;

    constraint total_items {20 < num_items; num_items < 50;}

    function new(string name = "random_item_sequence");
        super.new(name);
    endfunction

    virtual task body();
		// Entre 50 y 20 items aleatorios
        for(int i; i<num_items; i++) begin
            transaction_item item = transaction_item::type_id::create("item");
            start_item(item);
            item.randomize();
            `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
            finish_item(item);
        end
        `uvm_info("SEQ", $sformatf("Done generating %2d random items", num_items), UVM_LOW)
    endtask
endclass

// Secuancia especifica
class spec_item_sequence extends uvm_sequence;
    `uvm_object_utils(spec_item_sequence)
	
	// Arreglo de tamaño variable
    bit array [];

    function new(string name = "spec_item_sequence");
        super.new(name);
    endfunction
	
    virtual task body();
		// Se envia cada elemento del arreglo
        foreach (array[i]) begin
            transaction_item item = transaction_item::type_id::create("item");
            start_item(item);
            item.in = array[i];
            item.rstn = 1;
            `uvm_info("SEQ", $sformatf("\nNew spec item: \n %s", item.sprint()), UVM_MEDIUM)
            finish_item(item);
        end
        
    endtask
endclass

// Driver
class driver extends uvm_driver #(transaction_item);
    `uvm_component_utils(driver)

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual if_dut vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual if_dut)::get(this, "", "_if", vif))
            `uvm_fatal("Driver", "Could not get vif")
    endfunction
	
	// Cada transaccion que recibe
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            transaction_item item;
            seq_item_port.get_next_item(item);
            driver_item(item);
	    seq_item_port.item_done();

        end
    endtask
	
	// La señal en base al seq_item
    virtual task driver_item(transaction_item d_item);
        vif.in = d_item.in;
        vif.rstn = d_item.rstn;
		// Se espera al reloj para sincronizacion
        @(posedge vif.clk);
    endtask
endclass

// Monitor
class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    uvm_analysis_port #(transaction_item) monitor_aport;
    virtual if_dut vif;

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual if_dut)::get(this, "", "_if", vif))
            `uvm_fatal("Monitor", "Could not get vif")

        monitor_aport = new("monitor_aport", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
	
        transaction_item m_item = new;
	
    	super.run_phase(phase);

        forever begin
			// Cada flanco positivo se genera transaccion con datos actuales
            @(posedge vif.clk);

            m_item.in = vif.in;
            m_item.rstn = vif.rstn;
            m_item.out = vif.out;
            monitor_aport.write(m_item);
            `uvm_info("Monitor", $sformatf("\nTransaction created\n%s",m_item.sprint()), UVM_MEDIUM)
        end
    endtask
endclass

// Agente
class agent extends uvm_agent;
    `uvm_component_utils(agent)
    
    driver driver_inst;
    monitor monitor_inst;
    uvm_sequencer #(transaction_item) sequencer_inst;

    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		//Driver
        driver_inst = driver::type_id::create("driver_inst", this);
		//Monitor
        monitor_inst = monitor::type_id::create("monitor_inst", this);
		//Secuenciador
        sequencer_inst = uvm_sequencer #(transaction_item)::type_id::create("sequencer_inst", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
    endfunction
endclass
