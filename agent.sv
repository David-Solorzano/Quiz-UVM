import uvm_pkg::*;
// Item de secuencia

class transaction_item extends uvm_sequence_item;
    rand bit rstn;
    rand bit in;
    bit out;

    //`uvm_object_utils_begin(transaction_item)
    //    `uvm_field_int(rstn, UVM_DEFAULT)
    //    `uvm_field_int(in, UVM_DEFAULT)
    //`uvm_object_utils_end

    constraint c1 {rstn dist {0:=2, 1:=98};}

    function new(string name = "transaction_item");
        super.new(name);
    endfunction

endclass

// Secuencias disponibles

class random_item_sequence extends uvm_sequence;
    `uvm_object_utils(random_item_sequence)

    rand int num_items;

    constraint total_items {0 < num_items; num_items < 30;}

    function new(string name = "random_item_sequence");
        super.new(name);
    endfunction

    virtual task body();
        for(int i; i<num_items; i++) begin
            transaction_item item = transaction_item::type_id::create("item");
            start_item(item);
            item.randomize();
            `uvm_info("SEQ", $sformatf("New item:"), UVM_LOW)
            item.print();
            finish_item(item);
        end
        `uvm_info("SEQ", $sformatf("Done generating %d items", num_items), UVM_LOW)
    endtask
endclass

class spec_item_sequence extends uvm_sequence;
    `uvm_object_utils(spec_item_sequence)

    bit array [];

    function new(string name = "spec_item_sequence");
        super.new(name);
    endfunction

    virtual task write_sequence(input bit array []);
        foreach (array[i]) begin
            transaction_item item = transaction_item::type_id::create("item");
            start_item(item);
            item.in = array[i];
            item.rstn = 1;
            `uvm_info("SEQ", $sformatf("New item:"), UVM_LOW)
            item.print();
            finish_item(item);
        end
        
    endtask
endclass

class driver extends uvm_driver #(transaction_item);
    `uvm_component_utils(driver)

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual if_dut vif;

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config#(virtual if_dut)::get(this, "", "_if", vif))
            `uvm_fatal("Driver", "Could not get vif")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            transaction_item item;
            seq_item_port.get_next_item(item);
            driver_item(item)

        end
    endtask

    virtual task driver_item(transaction_item d_item);
        vif.in = d_item.in;
        vif.rstn = d_item.rstn;
        @(posedge vif.clk);
    endtask
endclass

class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analisys_port #(transaction_item) monitor_aport;
    virtual if_dut vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config#(virtual if_dut)::get(this, "", "_if", vif))
            `uvm_fatal("Monitor", "Could not get vif")

        monitor_aport = new("monitor_aport", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            @(posedge vif.clk);

            transaction_item m_item = new;
            item.in = vif.in;
            item.rstn = vif.rstn;
            item.out = vif.out;
            monitor_aport.write(item);
            `uvm_info("Monitor", $sformatf("Transaction created"), UVM_LOW)
        end
    endtask
endclass

class agent extends uvm_agent;
    `uvm_component_utils(agent)

    function new(string name = "agent", uvm_component parent = null);
        super.ner(name, parent);
    endfunction

    driver driver_inst;
    monitor monitor_inst;
    uvm_sequencer #(transaction_item) sequencer_inst;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        driver_inst = driver::type_id::create("driver_inst", this);
        monitor_inst = monitor::type_id::create("monitor_inst", this);
        sequencer_inst = uvm_sequencer #(transaction_item)::type_id::create("sequencer_inst", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
    endfunction
endclass