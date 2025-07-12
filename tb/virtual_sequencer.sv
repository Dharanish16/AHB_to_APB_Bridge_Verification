
class virtual_sequencer extends uvm_sequence #(uvm_sequence_item);

    //factory registration
    `uvm_component_utils(virtual_sequencer)

    //handles for ahb and apb agent sequencers
    ahb_agt_seqr ahb_agt_seqrh[];
    apb_agt_seqr apb_agt_seqrh[];

    //handle for environment config
    env_cfg cfg;

    //standard methods
    extern function new(string name="virtual_sequencer",uvm_component parent);
    extern function void build_phase(uvm_phase phase);

endclass

//constructor new method of virtual_sequencer
function virtual_sequencer::new(string name="virtual_sequencer",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of virtual sequencer
function void virtual_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //get the environment config
    if(!uvm_config_db #(env_cfg)::get(this,"","cfg",cfg))
        `uvm_fatal(get_type_name(),"Cannot get the env_cfg from uvm_config_db. Have you set it properly?")

    ahb_agt_seqrh = new[cfg.no_of_ahb_agents];
    apb_agt_seqrh = new[cfg.no_of_apb_agents];
endfunction