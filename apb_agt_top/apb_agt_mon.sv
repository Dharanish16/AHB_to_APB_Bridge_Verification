
class apb_agt_mon extends uvm_monitor;

    //factory resgistration
    `uvm_component_utils(apb_agt_mon)

    //interface handle
    virtual ahb2apb_if.APB_MON vif;

    //configuration class
    apb_agt_config apb_cfg;

    //analysis port declaration
    uvm_analysis_port #(apb_xtn) apb_monitor_port;

    apb_xtn xtn;

    extern function new(string name="apb_agt_mon",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task collect_data();

endclass

//constructor new method for apb agent monitor
function apb_agt_mon::new(string name="apb_agt_mon",uvm_component parent);
    super.new(name,parent);
    apb_monitor_port = new("apb_monitor_port",this);
endfunction

//build phase of apb agent monitor
function void apb_agt_mon::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //get the apb agent config using uvm_config_db
    if(!uvm_config_db #(apb_agt_config)::get(this,"","apb_cfg",apb_cfg))
        `uvm_fatal("APB CONFIG","cannot get the uvm_config_db. Have you set it?")
endfunction

//connect phase of apb agent monitor
function void apb_agt_mon::connect_phase(uvm_phase phase);
    vif = apb_cfg.vif;
endfunction

//run phase of apb agent monitor
task apb_agt_mon::run_phase(uvm_phase phase);
    forever 
        begin
            collect_data();
        end
endtask

//collect data task
task apb_agt_mon::collect_data();
    //create memory for apb transaction
    xtn = apb_xtn::type_id::create("xtn");
    
    //wait for Penable to be high
    wait(vif.apb_mon_cb.Penable === 1)

    xtn.Paddr = vif.apb_mon_cb.Paddr;
    xtn.Pwrite = vif.apb_mon_cb.Pwrite;
    xtn.Pselx = vif.apb_mon_cb.Pselx;
    xtn.Penable = vif.apb_mon_cb.Penable;

    //checking the Pwrite and reading the data 
    if(xtn.Pwrite)
        xtn.Pwdata = vif.apb_mon_cb.Pwdata;
    else
        xtn.Prdata = vif.apb_mon_cb.Prdata;

    $display("apb_mon");
    xtn.print();
    $display("apb_mon_ended");

    apb_monitor_port.write(xtn);

    repeat(2)
        @(vif.apb_mon_cb);

endtask