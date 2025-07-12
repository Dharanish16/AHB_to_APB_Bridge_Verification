
class env_cfg extends uvm_object;

    //factory registration
    `uvm_object_utils(env_cfg)

    //handles for ahb and apb configs
    ahb_agt_config ahb_cfg[];
    apb_agt_config apb_cfg[];

    //declaring no of ahb and apb agents
    int no_of_ahb_agents = 1;
    int no_of_apb_agents = 1;

    bit has_scoreboard = 1;
    bit has_ahb_agt_top = 1;
    bit has_apb_agt_top = 1;
    bit has_virtual_sequencer = 1;

    //standard methods
    extern function new(string name="env_cfg");

endclass

//constructor new method of env config
function env_cfg::new(string name="env_cfg");
    super.new(name);
endfunction