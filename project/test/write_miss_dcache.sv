//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_miss_dcache.sv
// Description: Test for simple (write miss + free block) and (write + no free block) to D-cache
// Modifiers: Quy Van
//=====================================================================

class write_miss_dcache extends base_test;

    //component macro
    `uvm_component_utils(write_miss_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_miss_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_miss_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : write_miss_dcache


// Sequence for a read-miss on I-cache
class write_miss_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_miss_dcache_seq)

    cpu_transaction_c trans;
    bit [`ADDR_WID_LV1-1:0] set_addr[5];
    bit [`DATA_WID_LV1-1:0] rand_data;

    //constructor
    function new (string name="write_miss_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //Write miss + free block in the same address
        set_addr = '{32'h4000_0000, 32'h4001_0000, 32'h4002_0000, 32'h4003_0000, 32'h4004_0000};
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0]; data == rand_data;})
        
        //Write miss + free block to fill up cache cpu 0
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[3]; data == rand_data;})
        
        // Write miss + no free block
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[4]; data == rand_data;})

        #1000;

    endtask

endclass : write_miss_dcache_seq
