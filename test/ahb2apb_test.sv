
class ahb2apb_test extends uvm_test;

    //factory registration        
    `uvm_component_utils(ahb2apb_test)

    int no_of_ahb_agents = 1;
    int no_of_apb_agents = 1;
    
    //handles for ahb,apb and env configs
    env_cfg cfg;
    ahb_agt_config ahb_cfg[];
    apb_agt_config apb_cfg[];

    //handle for environment
    bridge_env envh;

    int loop = 1;

    //virtual_sequencer v_seqrh;

    //standard methods
    extern function new(string name="ahb2apb_test",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void start_of_simulation_phase(uvm_phase phase);
endclass

//constructor new method of test
function ahb2apb_test::new(string name="ahb2apb_test",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of test
function void ahb2apb_test::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //create memory for configs
    cfg = env_cfg::type_id::create("cfg");
    // initialize the dynamic array of ahb config equal to no_of_ahb_agents
    ahb_cfg = new[no_of_ahb_agents];
    // for all the configuration objects, set the following parameters 
	// is_active to UVM_ACTIVE
    foreach(ahb_cfg[i])
        begin
            //creating an instance for ahb_agt_config using ahb_cfg
            ahb_cfg[i] = ahb_agt_config::type_id::create($sformatf("ahb_cfg[%0d]",i));
            
		    // Get the virtual interface from the config database
            if(!uvm_config_db #(virtual ahb2apb_if) :: get(this,"","ahb_vif",ahb_cfg[i].vif))
                `uvm_fatal("CONFIG","Unable to get the uvm_config_db. Have you set it?")
            ahb_cfg[i].is_active = UVM_ACTIVE;

        end
    // initialize the dynamic array of apb config equal to no_of_apb_agents
    apb_cfg = new[no_of_apb_agents];
    // for all the configuration objects, set the following parameters
    // is_active to UVM_ACTIVE
    foreach(apb_cfg[i])
        begin
            //creating an instance for apb_agt_config using apb_cfg
            apb_cfg[i] = apb_agt_config::type_id::create($sformatf("apb_cfg[%0d]",i));

            //get the virtual interface from the config database
            if(!uvm_config_db #(virtual ahb2apb_if) :: get(this,"","apb_vif",apb_cfg[i].vif))
                `uvm_fatal("CONFIG","Unable to get the uvm_config_db. Have you set it?")
            apb_cfg[i].is_active = UVM_ACTIVE;
        end

    //connecting the ahb and apb configs to env configs
    cfg.ahb_cfg = ahb_cfg;
    cfg.apb_cfg = apb_cfg;

    //properties connection with the env configs
    cfg.no_of_ahb_agents = no_of_ahb_agents;
    cfg.no_of_apb_agents = no_of_apb_agents;

    // set the env config object into UVM config DB  
	uvm_config_db #(env_cfg)::set(this,"*","cfg",cfg);

    //create a memory for env
    envh = bridge_env::type_id::create("envh",this);

endfunction

//start of simulation phase of test
function void ahb2apb_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_top.print_topology();
endfunction

//--------------------------Single sequence test-----------------------//
class single_seq_test extends ahb2apb_test;

    //factory registration
    `uvm_component_utils(single_seq_test)

    //handle for single sequence
    single_seq single_seqh;

    //standard methods
    extern function new(string name="single_seq_test",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass

//constructor new method for single sequence test
function single_seq_test::new(string name="single_seq_test",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of single sequence test
function void single_seq_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

//task run phase of single sequence test
task single_seq_test::run_phase(uvm_phase phase);
    super.run_phase(phase);
    //creating object for single sequence
    single_seqh = single_seq::type_id::create("single_seqh");
    phase.raise_objection(this);
    repeat(loop)
        begin
            //starting single sequnce on respective ahb agent sequencer
            single_seqh.start(envh.ahb_agt_toph.ahb_agt[0].ahb_seqr);
        end
#30;
    //#80;
    phase.drop_objection(this);
endtask

//--------------------------Increment sequence test-----------------------//
class increment_seq_test extends ahb2apb_test;

    //factory registration
    `uvm_component_utils(increment_seq_test)

    //handle for increment sequence
    increment_seq increment_seqh;

    //standard methods
    extern function new(string name="increment_seq_test",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass

//constructor new method for increment sequence test
function increment_seq_test::new(string name="increment_seq_test",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of increment sequence test
function void increment_seq_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

//task run phase of increment sequence test
task increment_seq_test::run_phase(uvm_phase phase);

    //creating object for increment sequence
    increment_seqh = increment_seq::type_id::create("increment_seqh");
    phase.raise_objection(this);
    repeat(loop)
        begin
            //starting increment sequence on respective ahb agent sequencer
            increment_seqh.start(envh.ahb_agt_toph.ahb_agt[0].ahb_seqr);
        end
    #3000;
    phase.drop_objection(this);
endtask

//--------------------------Wrap sequence test-----------------------//
class wrap_seq_test extends ahb2apb_test;

    //factory registration
    `uvm_component_utils(wrap_seq_test)

    //handle for wrap sequence
    wrap_seq wrap_seqh;

    //standard methods
    extern function new(string name="wrap_seq_test",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass

//constructor new method for wrap sequence test
function wrap_seq_test::new(string name="wrap_seq_test",uvm_component parent);
    super.new(name,parent);
endfunction

//build phase of wrap sequence test
function void wrap_seq_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

//task run phase of wrap sequence test
task wrap_seq_test::run_phase(uvm_phase phase);

    //creating object for wrap sequence
    wrap_seqh = wrap_seq::type_id::create("wrap_seqh");
    phase.raise_objection(this);
    repeat(loop)
        begin
            //starting wrap sequence on respective ahb agent sequencer
            wrap_seqh.start(envh.ahb_agt_toph.ahb_agt[0].ahb_seqr);
        end
    #3000;
    phase.drop_objection(this);
endtask

