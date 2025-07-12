
class ahb_agt_drv extends uvm_driver #(ahb_xtn);

    //factory registration
    `uvm_component_utils(ahb_agt_drv)

    //declare virtual interface handle with AHB_DRV modport
    virtual ahb2apb_if.AHB_DRV vif;

    //ahb agent config
    ahb_agt_config ahb_cfg;

    ahb_xtn xtn;

    //standard methods
    extern function new(string name="ahb_agt_drv", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task send_to_dut(ahb_xtn xtn);

endclass

//constructor new method for ahb_agt_drv
function ahb_agt_drv::new(string name="ahb_agt_drv", uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of ahb agent driver
function void ahb_agt_drv::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //get the ahb agent config using uvm_config_db
    if(!uvm_config_db #(ahb_agt_config)::get(this,"","ahb_agt_config",ahb_cfg))
        `uvm_fatal("AHB CONFIG","cannot get the uvm_config_db. Have you set it?")
endfunction

//connect phase of ahb agent driver
function void ahb_agt_drv::connect_phase(uvm_phase phase);
    vif = ahb_cfg.vif;
endfunction

//run phase of ahb agent driver
task ahb_agt_drv::run_phase(uvm_phase phase);
    super.run_phase(phase);
    //$display("display from the driver1");
    //for first cycle
    @(vif.ahb_drv_cb);
    vif.ahb_drv_cb.Hresetn <= 1'b0;
    
    //$display("display from the driver2");
    //for second cycle
    @(vif.ahb_drv_cb);
    vif.ahb_drv_cb.Hresetn <= 1'b1;
    //$display("display from the driver3");
    forever
        begin
            seq_item_port.get_next_item(req);
            //$display("display from the driver4");
            send_to_dut(req);
            //req.print();
            seq_item_port.item_done();
        end
endtask

//send to dut task for ahb agent driver
task ahb_agt_drv::send_to_dut(ahb_xtn xtn);
    
    //address phase 
    //waiting for Hready signal indicates that slave is ready 
    //$display("display from the driver5");
    //wait(vif.ahb_drv_cb.Hreadyout === 1'b1)
    //$display("%0d",vif.ahb_drv_cb.Hreadyout);
    while(vif.ahb_drv_cb.Hreadyout !== 1)
        @(vif.ahb_drv_cb);
    //control signals 
    //$display("display from the driver6");
    vif.ahb_drv_cb.Hsize <= xtn.Hsize;
    vif.ahb_drv_cb.Hburst <= xtn.Hburst;
    vif.ahb_drv_cb.Htrans <= xtn.Htrans;
    vif.ahb_drv_cb.Hwrite <= xtn.Hwrite;
    vif.ahb_drv_cb.Hreadyin <= 1'b1;
    //sending the address
    vif.ahb_drv_cb.Haddr <= xtn.Haddr;
    
    //one clocking block for going to the data phase
    @(vif.ahb_drv_cb);

    //data phase 
    wait(vif.ahb_drv_cb.Hreadyout === 1)
    //while(vif.ahb_drv_cb.Hreadyout !== 1)
        //@(vif.ahb_drv_cb);

    //checking for the Hwrite signal so that we can drive the Hwdata 
    if(req.Hwrite === 1)
        vif.ahb_drv_cb.Hwdata <= xtn.Hwdata;
    else
        vif.ahb_drv_cb.Hwdata <= 32'b0;

    $display("driver");
    xtn.print();
    $display("driver ended");
endtask