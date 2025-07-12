
class ahb_agent extends uvm_agent;

    //Factory registration
    `uvm_component_utils(ahb_agent)

    //ahb driver handle
    ahb_agt_drv ahb_drv;
    //ahb sequencer handle
    ahb_agt_seqr ahb_seqr;
    //ahb monitor Handle
    ahb_agt_mon ahb_mon;

    //ahb agent config handle
    ahb_agt_config ahb_cfg;

    //standard methods
    extern function new(string name="ahb_agent",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass

//constructor new method of ahb agent
function ahb_agent::new(string name="ahb_agent",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of ahb agent
function void ahb_agent::build_phase(uvm_phase phase);

    //get the ahb agent config using uvm_config_db
    if(!uvm_config_db #(ahb_agt_config)::get(this,"","ahb_agt_config",ahb_cfg))
        `uvm_fatal("CONFIG","Cannot ge the ahb agent config. Have you set it?")
    //creating memory for monitor
    ahb_mon = ahb_agt_mon::type_id::create("ahb_mon",this);
    if(ahb_cfg.is_active == UVM_ACTIVE)
        begin
            ahb_drv = ahb_agt_drv::type_id::create("ahb_drv",this);
            ahb_seqr = ahb_agt_seqr::type_id::create("ahb_seqr",this);
        end
    super.build_phase(phase);
endfunction

//connect phase of ahb agent
function void ahb_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(ahb_cfg.is_active==UVM_ACTIVE)
		begin
			ahb_drv.seq_item_port.connect(ahb_seqr.seq_item_export);
  		end
endfunction