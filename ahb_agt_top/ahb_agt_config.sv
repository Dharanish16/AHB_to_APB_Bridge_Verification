
class ahb_agt_config extends uvm_object;

    //factory registration
    `uvm_object_utils(ahb_agt_config)
    
    //handle for virtual interface
    virtual ahb2apb_if vif;

    // Declare parameter is_active of type uvm_active_passive_enum and assign it to UVM_ACTIVE
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    extern function new(string name="ahb_agt_config");

endclass

//constructor new method for ahb_agt_config
function ahb_agt_config::new(string name="ahb_agt_config");
    super.new(name);
endfunction