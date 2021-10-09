import uvm_pck::*;

class env extends uvm_env;

    `uvm_component_utils(env)

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent)
    endfunction

    agent a0;
    scoreboard scbd0;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a0 = agent::type_id::create("a0", this);
        scbd0 = scoreboard:type_id::create("scbd0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a0.monitor_inst.monitor_aport.connect(sb0.m_analysis_imp);
    endfunction

endclass