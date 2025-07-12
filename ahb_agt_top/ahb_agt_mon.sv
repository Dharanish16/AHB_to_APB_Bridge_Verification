
class ahb_agt_mon extends uvm_monitor;

    //factory registration
    `uvm_component_utils(ahb_agt_mon)

    //declare virtual interface handle with AHB_MON modport
    virtual ahb2apb_if.AHB_MON vif;

    //ahb agent config
    ahb_agt_config ahb_cfg;

    // Analysis TLM port to connect the monitor to the scoreboard
  	uvm_analysis_port #(ahb_xtn) monitor_port;

    //handle for ahb_xtn
    ahb_xtn mon_xtn;

    extern function new(string name = "ahb_agt_mon",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task collect_data();
endclass

//constructor new method for ahb_agt_mon
function ahb_agt_mon::new(string name = "ahb_agt_mon",uvm_component parent);
    super.new(name,parent);
    monitor_port = new("monitor_port",this);
endfunction

//build phase of ahb agent monitor
function void ahb_agt_mon::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //get the ahb agent config using uvm_config_db
    if(!uvm_config_db #(ahb_agt_config)::get(this,"","ahb_agt_config",ahb_cfg))
        `uvm_fatal("AHB CONFIG","cannot get the uvm_config_db. Have you set it?")
endfunction

//connect phase of ahb agent monitor
function void ahb_agt_mon::connect_phase(uvm_phase phase);
    vif = ahb_cfg.vif;
endfunction

//run phase of ahb agent monitor
task ahb_agt_mon::run_phase(uvm_phase phase);
    forever
        begin
            collect_data();
        end
endtask

//collect data task of ahb agent monitor
task ahb_agt_mon::collect_data();

    //$display("monitor");
    //$display("%0d",vif.ahb_mon_cb.Haddr);
    
    //memory for ahb_xtn
    mon_xtn = ahb_xtn::type_id::create("mon_xtn");

    //$display($time," 4");
    wait(vif.ahb_mon_cb.Hreadyout === 1'b1);
    wait(vif.ahb_mon_cb.Htrans === 2'b10 | vif.ahb_mon_cb.Htrans === 2'b11)
       // begin   
    //while(vif.ahb_mon_cb.Hreadyout !== 1)
	  //  @(vif.ahb_mon_cb);

    //$display($time," 3");
    mon_xtn.Haddr = vif.ahb_mon_cb.Haddr;
    mon_xtn.Hsize = vif.ahb_mon_cb.Hsize;
    mon_xtn.Hburst = vif.ahb_mon_cb.Hburst;
    mon_xtn.Hwrite = vif.ahb_mon_cb.Hwrite;
    mon_xtn.Htrans = vif.ahb_mon_cb.Htrans;

    @(vif.ahb_mon_cb);
    //$display("1");
    //while(vif.ahb_mon_cb.Hreadyout !== 1)
	    //@(vif.ahb_mon_cb);
    wait(vif.ahb_mon_cb.Hreadyout === 1'b1)
        //$display("2");
    
    if(mon_xtn.Hwrite)
	    mon_xtn.Hwdata = vif.ahb_mon_cb.Hwdata;
    else
	    mon_xtn.Hrdata = vif.ahb_mon_cb.Hrdata;

    $display("AHB_MON");
    mon_xtn.print();
    $display("ahb_mon_ended");
    //$finish;
       // end
    monitor_port.write(mon_xtn);

endtask