
class apb_agt_seqr extends uvm_sequencer #(apb_xtn);

    //factory registration
    `uvm_component_utils(apb_agt_seqr)


    extern function new(string name="apb_agt_seqr",uvm_component parent);

endclass

//constructor new method for apb agent sequencer
function apb_agt_seqr::new(string name="apb_agt_seqr",uvm_component parent);
    super.new(name,parent);
endfunction