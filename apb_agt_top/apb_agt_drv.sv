
class apb_agt_drv extends uvm_driver #(apb_xtn);

    //factory registration
    `uvm_component_utils(apb_agt_drv)
    
    //interface 
    virtual ahb2apb_if.APB_DRV vif;

    //apb configuration handle
    apb_agt_config apb_cfg; 

    //apb_xtn xtn;

    extern function new(string name = "apb_agt_drv", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task send_to_dut(/*apb_xtn xtn*/);

endclass

//constructor new method for apb agent driver
function apb_agt_drv::new(string name = "apb_agt_drv", uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of apb agent driver
function void apb_agt_drv::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //getting the apb_agt_config
    if(!uvm_config_db #(apb_agt_config)::get(this,"","apb_cfg",apb_cfg))
        `uvm_fatal("APB CONFIG","cannot get the apb_agt_config, Have you set it properly")
endfunction

//connect phase of apb agent driver
function void apb_agt_drv::connect_phase(uvm_phase phase);
    vif = apb_cfg.vif;
endfunction

//run phase of apb agent driver
task apb_agt_drv::run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever    
        begin
            send_to_dut();
        end
endtask

//send to dut task
task apb_agt_drv::send_to_dut();

    //waiting for Pselx
    wait(vif.apb_drv_cb.Pselx===(1||2||4||8))

    //checking for the Pwrite signal for read operation
    if(vif.apb_drv_cb.Pwrite == 0)
        vif.apb_drv_cb.Prdata <= $urandom;

    //the next randomization of Prdata happens after 2 clock cycles
    //one clock for configuration address and another for sending the data to bridge
    repeat(2)
        @(vif.apb_drv_cb);

endtask
