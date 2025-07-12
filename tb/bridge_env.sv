
class bridge_env extends uvm_env;

    //factory registration
    `uvm_component_utils(bridge_env)

    //handles for ahb agent top and apb agent top
    ahb_agt_top ahb_agt_toph;
    apb_agt_top apb_agt_toph;

    //handle for scoreboard
    bridge_scoreboard sb;

    //virtual sequencer handle
    //virtual_sequencer v_seqrh;

    //env config handle
    env_cfg cfg;

    //standard methods
    extern function new(string name="bridge_env",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass

//constructor new method of env
function bridge_env::new(string name="bridge_env",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of env
function void bridge_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //get the env config 
    if(!uvm_config_db #(env_cfg)::get(this,"", "cfg", cfg))
        `uvm_fatal("ENV","Unable to get the env_cfg. Have you set it?")
    
    //check with has_ahb_agt_top and create them
    if(cfg.has_ahb_agt_top)
        ahb_agt_toph = ahb_agt_top::type_id::create("ahb_agt_toph",this);

    //check with has_apb_agt_top and create them
    if(cfg.has_apb_agt_top)
        apb_agt_toph = apb_agt_top::type_id::create("apb_agt_toph",this);

    //check with has_scoreboard and create them
    if(cfg.has_scoreboard)
        sb = bridge_scoreboard::type_id::create("sb",this);

    //check with has_virtual_sequencer and create them
    //if(cfg.has_virtual_sequencer)
        //v_seqrh = virtual_sequencer::type_id::create("v_seqrh",this);
    
endfunction

//connect phase of environment
function void bridge_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //connecting the physical sequencer handles to virtual sequencer handles in ahb side
    /*if(cfg.has_ahb_agt_top)
		begin
			for(int i = 0; i < cfg.no_of_ahb_agents; i++)
				v_seqrh.ahb_agt_seqrh[i] = ahb_agt_toph.ahb_agt[i].ahb_seqr;
		end

    //connecting the physical sequencer handles to virtual sequencer handles in apb side		
	if(cfg.has_apb_agt_top)
		begin
			for(int i = 0; i < cfg.no_of_apb_agents; i++)
				v_seqrh.ahb_agt_seqrh[i] = apb_agt_toph.apb_agt[i].apb_seqr; 
		end*/

    //for(int i = 0;i < cfg.no_of_ahb_agents;i++)
    ahb_agt_toph.ahb_agt[0].ahb_mon.monitor_port.connect(sb.ahb_fifo.analysis_export);

    apb_agt_toph.apb_agt[0].apb_mon.apb_monitor_port.connect(sb.apb_fifo.analysis_export);

endfunction