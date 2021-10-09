import uvm_pck::*;

class scoreboard extends uvm_scoreboard;
    `uvm_object_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp #(transaction_item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp");
    endfunction

    int n_misses = 0;
    int n_matches = 0;

    bit [3:0] current_sequence = 4'b0; 

    virtual function write(transaction_item t);
        if(!t.rstn) begin
            current_sequence = 4'b0;
        end else begin
            current_sequence = current_sequence << 1;
            current_sequence[0] = t.in;
        end

        if(out == (current_sequence==4'b1011)) begin
            n_matches++;
            `uvm_info("SCOREBOARD", $sformatf("PASS Current Sequence = %b out = %b", current_sequence, out), UVM_MEDIUM)
        end
        else begin
            n_misses++;
            `uvm_error("SCOREBOARD", $sformatf("PASS Current Sequence = %b out = %b", current_sequence, out))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", $sformatf("\n Matches = %d\n Misses = %d\n", n_matches, n_misses), UVM_FULL)
    endfunction
endclass