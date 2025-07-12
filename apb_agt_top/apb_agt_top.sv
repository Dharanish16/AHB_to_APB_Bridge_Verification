
class apb_agt_top extends uvm_agent;

    //factory registration
    `uvm_component_utils(apb_agt_top)

    //apb agent top contains apb agents which can be dynamic
    apb_agent apb_agt[];

    //env config contains information about how many agents
    env_cfg cfg;

    //apb agent config handle
    apb_agt_config apb_cfg;

    extern function new(string name="apb_agt_top",uvm_component parent);
    extern function void build_phase(uvm_phase phase);

endclass

//constructor new method for apb agent top
function apb_agt_top::new(string name="apb_agt_top",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of apb agent
function void apb_agt_top::build_phase(uvm_phase phase);
    
    //get the env config 
    if(!uvm_config_db #(env_cfg)::get(this,"","cfg",cfg))
        `uvm_fatal("CONFIG","Cannot get the env config. Have you set it?")
    
    //fixing the no of apb agents
    apb_agt = new[cfg.no_of_apb_agents];

    //creating memory for all the apb agents
    foreach(apb_agt[i])
        begin
            apb_agt[i] = apb_agent::type_id::create($sformatf("apb_agt[%0d]",i),this);
            //connecting the respective apb configs to those respective apb agents
            //for that we need to set the apb agent config using uvm_config_db
            uvm_config_db #(apb_agt_config)::set(this,$sformatf("apb_agt[%0d]*",i),"apb_cfg",cfg.apb_cfg[i]);
        end
    
endfunction