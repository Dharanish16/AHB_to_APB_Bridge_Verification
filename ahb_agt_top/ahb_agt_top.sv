
class ahb_agt_top extends uvm_env;

    //factory registration
    `uvm_component_utils(ahb_agt_top)

    //ahb agent top contains ahb agents which can be dynamic
    ahb_agent ahb_agt[];

    //env config contains information about how many agents
    env_cfg cfg;

    //ahb agent config handle
    ahb_agt_config ahb_cfg;

    //standard methods
    extern function new(string name="ahb_agt_top",uvm_component parent);
    extern function void build_phase(uvm_phase phase);

endclass

//constructor new method for ahb agent top
function ahb_agt_top::new(string name="ahb_agt_top",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of ahb agent top
function void ahb_agt_top::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //get the env config 
    if(!uvm_config_db #(env_cfg)::get(this,"", "cfg", cfg))
        `uvm_fatal("CONFIG","Unable to get the env_cfg. Have you set it?")
    //fixing the ahb agents using no of ahb agents from env config
    ahb_agt = new[cfg.no_of_ahb_agents];
    //creating a memory for all the source agents
    foreach(ahb_agt[i])
        begin
            ahb_agt[i] = ahb_agent::type_id::create($sformatf("ahb_agt[%0d]",i),this);
            //connecting the respective ahb configs to those respective ahb agents
            //for that we need to set the ahb agent config using uvm_condig_db
            uvm_config_db #(ahb_agt_config)::set(this,$sformatf("ahb_agt[%0d]*",i),"ahb_agt_config",cfg.ahb_cfg[i]);
        end
endfunction