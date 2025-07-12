
//---------------------Base sequence---------------------//
class ahb_sequence extends uvm_sequence #(ahb_xtn);

    //factory registration
    `uvm_object_utils(ahb_sequence)

    //properties to store the randomized data
    bit [31:0] haddr;
    bit [31:0] start_addr, boundary_addr;
    bit [2:0] hburst,hsize;
    bit hwrite;
    bit [9:0] hlength;

    //standard methods
    extern function new(string name="ahb_sequence");

endclass

// constructor new method for ahb_sequence
function ahb_sequence::new(string name="ahb_sequence");
    super.new(name);
endfunction 

//----------------------single sequence-----------------//
class single_seq extends ahb_sequence;

    //factory registration
    `uvm_object_utils(single_seq)

    extern function new(string name="single_seq");
    extern task body();

endclass

//constructor new method for single sequence
function single_seq::new(string name="single_seq");
    super.new(name);
endfunction

//task body for single sequence
task single_seq::body();
    //req is an inbuilt handle for uvm_sequence_base so no need to declare it
    req = ahb_xtn::type_id::create("req");
    start_item(req);
	//$display("SEQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");

    //Hburst is 0 for single transfer and Htrans is 2'b10 for Non-seq
    assert(req.randomize() with {Htrans == 2'b10; Hburst == 3'b000;});
    finish_item(req);

endtask

//-------------------------Increment sequence------------------//
class increment_seq extends ahb_sequence;

    //factory registration
    `uvm_object_utils(increment_seq)

    //standard methods
    extern function new(string name="increment_seq");
    extern task body();
endclass

//constructor new for increment sequence
function increment_seq::new(string name="increment_seq");
    super.new(name);
endfunction

//task body for increment sequence
task increment_seq::body();

    req = ahb_xtn::type_id::create("req");
    start_item(req);
    //Hburst 1,3,5,7 indicates INCR,INCR4,INCR8,INCR16 respectively
    //Htrans 2'b10 indicates Non-sequential type
    assert(req.randomize() with {Hburst inside {3,5,7}; Htrans == 2'b10;})
    finish_item(req);

    //assigning the randomized data to their respective local properties
    haddr = req.Haddr;
    hburst = req.Hburst;
    hsize = req.Hsize;
    hlength = req.Hlength;
    hwrite = req.Hwrite;

    //generating the remaining transfers which is of sequential type
    for(int i = 1; i < hlength; i++)
        begin
            start_item(req);
            assert(req.randomize() with {Htrans == 2'b11; Hburst == hburst; 
                                            Hsize == hsize; Hwrite == hwrite; 
                                            Haddr == (haddr + (2**hsize));})
            finish_item(req);
            
            //haddr value need to be updated for the next iteration
            haddr = req.Haddr;
        end    
endtask

//----------------------------Wrap Sequence------------------------//
class wrap_seq extends ahb_sequence;

    //factory registration
    `uvm_object_utils(wrap_seq)

    //standard methods
    extern function new(string name="wrap_seq");
    extern task body();

endclass

//constructor new method for wrap sequence
function wrap_seq::new(string name="wrap_seq");
    super.new(name);
endfunction

//task body for wrap sequence
task wrap_seq::body();

    req = ahb_xtn::type_id::create("req");
    start_item(req);
    //Hburst 2,4,6 indicates WRAP4,WRAP8,WRAP16 respectively
    //Htrans 2'b10 indicates Non-sequential type
    assert(req.randomize() with {Hburst inside {2,4,6}; Htrans == 2'b10;})
    finish_item(req);
    
    //assigning the randomized data to their respective local properties
    haddr = req.Haddr;
    hburst = req.Hburst;
    hsize = req.Hsize;
    hlength = req.Hlength;
    hwrite = req.Hwrite;


    //calculation of start address using the stored parameters
    start_addr = int'(((haddr)/((2**hsize)*hlength))*((2**hsize)*hlength));

    //calculation of boundary address using the stored parameters
    boundary_addr = start_addr + ((2**hsize)*hlength);

    //increment the haddr for the next transaction
    haddr = req.Haddr + (2**hsize);

    //generating the remaining transfers which is of sequential type
    for(int i = 1; i < hlength; i++)
        begin
            if(boundary_addr == haddr)
                //once it reaches the boundary address it has to start from start address
                haddr = start_addr;
            start_item(req);
            assert(req.randomize() with {Htrans == 2'b11; Hburst == hburst; 
                                            Hsize == hsize; Hwrite == hwrite;
                                            Haddr == haddr;})
            finish_item(req);

            //haddr value need to be updated for the next iteration
            haddr=req.Haddr + (2**hsize);
        end
endtask
