
class apb_agent extends uvm_agent;

    //Factory registration
    `uvm_component_utils(apb_agent)

    //apb driver handle
    apb_agt_drv apb_drv;

    //apb seqr handle
    apb_agt_seqr apb_seqr;

    //apb monitor handle
    apb_agt_mon apb_mon;

    //apb agent config
    apb_agt_config apb_cfg;

    extern function new(string name = "apb_agent",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass

//constructor new method for apb agent
function apb_agent::new(string name = "apb_agent",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of apb agent
function void apb_agent::build_phase(uvm_phase phase);

    //get the apb agent config using uvm_config_db
    if(!uvm_config_db #(apb_agt_config)::get(this,"","apb_cfg",apb_cfg))
        `uvm_fatal("CONFIG","Cannot ge the apb agent config. Have you set it?")
    //creating memory for monitor
    apb_mon = apb_agt_mon::type_id::create("apb_mon",this);
    if(apb_cfg.is_active == UVM_ACTIVE)
        begin
            apb_drv = apb_agt_drv::type_id::create("apb_drv",this);
            apb_seqr = apb_agt_seqr::type_id::create("apb_seqr",this);
        end
    super.build_phase(phase);

endfunction

//connect phase of apb agent
function void apb_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(apb_cfg.is_active==UVM_ACTIVE)
		begin
			apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
  		end
endfunction