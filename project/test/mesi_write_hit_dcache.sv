//=====================================================================
// Project: 4 core MESI cache design
// File Name: mesi_write_hit_dcache.sv
// Description: Test for MESI write after read (E -> M) and (S -> M) to D-cache
// Modifiers: Quy Van
//=====================================================================

class mesi_write_hit_dcache extends base_test;

    //component macro
    `uvm_component_utils(mesi_write_hit_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mesi_write_hit_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mesi_write_hit_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : mesi_write_hit_dcache


// Sequence for a read-miss on I-cache
class mesi_write_hit_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mesi_write_hit_dcache_seq)

    cpu_transaction_c trans;
    bit [`ADDR_WID_LV1-1:0] set_addr[5];
    rand bit [`DATA_WID_LV1-1:0] rand_data;

    //constructor
    function new (string name="mesi_write_hit_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        set_addr = '{32'h4000_0000, 32'h4001_0000, 32'h4002_0000, 32'h4003_0000, 32'h4004_0000};
    //Write Hit -> Exclusive State
        //READ Miss 1 cpu to make E state
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        
        //WRITE hit cpu0 with the same addr => WRITE Hit Exclusive State
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0]; data == rand_data;})


    //WRITE Hit -> Shared State
        //READ all cpu to make Shared State
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1];})
        
        //WRITE hit cpu0 with the same addr => WRITE Hit Shared State and invalid cpu1 and cpu2 and cpu3
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1]; data == rand_data;})

    //WRITE Hit Modified State
        //READ Miss all cpu to make Shared State
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2];})
        
        //WRITE hit cpu0 with the same addr => invalid cpu1 and cpu2 and cpu3
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2]; data == rand_data;})
        
        #1000;
    endtask

endclass : mesi_write_hit_dcache_seq
