
class ahb_agt_seqr extends uvm_sequencer #(ahb_xtn);

    //factory registration
    `uvm_component_utils(ahb_agt_seqr)


    extern function new(string name="ahb_agt_seqr",uvm_component parent);

endclass

//constructor new method for ahb_agt_seqr
function ahb_agt_seqr::new(string name="ahb_agt_seqr",uvm_component parent);
    super.new(name,parent);
endfunction