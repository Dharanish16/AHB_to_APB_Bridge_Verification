
class bridge_scoreboard extends uvm_scoreboard;

    //factory registration
    `uvm_component_utils(bridge_scoreboard)

    //declaration for tlm analysis fifo
    uvm_tlm_analysis_fifo #(ahb_xtn) ahb_fifo;
    uvm_tlm_analysis_fifo #(apb_xtn) apb_fifo;

    //handles for transactions
    ahb_xtn ahb_xtnh;
    apb_xtn apb_xtnh;

    int addr,wr_data,rd_data,trans;

    //standard methods
    extern function new(string name = "bridge_scoreboard", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task check1(ahb_xtn ahb_xtnh, apb_xtn apb_xtnh);
    extern task compare(int Haddr,Paddr,Hdata,Pdata);
    extern function void report_phase(uvm_phase phase);

    //coverage for ahb 
    covergroup ahb_coverage;

        HSIZE : coverpoint ahb_xtnh.Hsize{
                                bins zero = {2'b00};
                                bins one = {2'b01};
                                bins two = {2'b10};}
                                    
        HADDR : coverpoint ahb_xtnh.Haddr{
                                bins c1={[32'h 8000_0000:32'h 8000_03ff]};
                                bins c2={[32'h 8400_0000:32'h 8400_03ff]};
                                bins c3={[32'h 8800_0000:32'h 8800_03ff]};
                                bins c4={[32'h 8C00_0000:32'h 8C00_03ff]};}
        
        HTRANS : coverpoint ahb_xtnh.Htrans{
                                bins NS = {2'b10};
                                bins S = {2'b11};}
        
        HWRITE : coverpoint ahb_xtnh.Hwrite{
                                bins read = {0};
                                bins write = {1};}
        
        //AHB : cross HADDR,HSIZE,HWRITE,HTRANS;

    endgroup
    

    //apb side coverage
    covergroup apb_coverage;

        PADDR : coverpoint apb_xtnh.Paddr{
                                bins b1={[32'h 8000_0000:32'h 8000_03ff]};
                                bins b2={[32'h 8400_0000:32'h 8400_03ff]};
                                bins b3={[32'h 8800_0000:32'h 8800_03ff]};
                                bins b4={[32'h 8C00_0000:32'h 8C00_03ff]};}

        PWRITE : coverpoint apb_xtnh.Pwrite{
                                bins read = {0};
                                bins write = {1};}
                            
        PSELX : coverpoint apb_xtnh.Pselx{
                                bins sel1 = {1};
                                bins sel2 = {2};
                                bins sel3 = {4};
                                bins sel4 = {8};}
        
        //APB : cross PWRITE, PSELX;
    endgroup

endclass

//constructor new method of scoreboard
function bridge_scoreboard::new(string name = "bridge_scoreboard", uvm_component parent);
    super.new(name,parent);

    //memory creation for coverage
    ahb_coverage = new();
    apb_coverage = new();

    //memory creation for tlm fifos
    ahb_fifo = new("ahb_fifo",this);
    apb_fifo = new("apb_fifo",this);
endfunction

//build phase of scoreboard
function void bridge_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //creating memory for transactions
    ahb_xtnh = ahb_xtn::type_id::create("ahb_xtnh");
    apb_xtnh = apb_xtn::type_id::create("apb_xtnh");

endfunction

//run phase of scoreboard
task bridge_scoreboard::run_phase(uvm_phase phase);
    forever
        begin
            fork
                begin
                    //$display("ahb_sb");
                    ahb_fifo.get(ahb_xtnh);
                    //$display("ahb_sb1");
                    //ahb_xtnh.print();
                    //$display("ahb_sb1 ended");
                    ahb_coverage.sample();
                end
                begin
                    //$display("apb_sb");
                    apb_fifo.get(apb_xtnh);
                    //$display("apb_sb1");
                    //apb_xtnh.print();
                    //$display("apb_sb1 ended");
                    trans++;
                    $display($time," trans increment %0d ",trans);
                    check1(ahb_xtnh,apb_xtnh);
                    apb_coverage.sample();
                end
            join
            //trans++;
           // check1(ahb_xtnh,apb_xtnh);
        end

endtask

//compare function
task bridge_scoreboard::compare(int Haddr,Paddr,Hdata,Pdata);
    
    //address comparision
    if(Haddr == Paddr)
        begin
            $display($time," Address compared successfull");
            addr++;
        end
    else
        `uvm_error("SB","Address comparison failed");

    if(ahb_xtnh.Hwrite == 1)
        begin
            if(Hdata == Pdata)
                begin
                    $display($time," Write data matched successfully");
                    wr_data++;
                end
            else
                `uvm_error("SB","Write data mismatched");
        end
    else
        begin
            if(Hdata == Pdata)
                begin
                    $display($time ," Read data matched successfully");
                    rd_data++;
                end
            else
                `uvm_error("SB","Read data mismatched");
        end
endtask

//check1 task

task bridge_scoreboard::check1(ahb_xtn ahb_xtnh,apb_xtn apb_xtnh);
    //$display("in check1");
    if(ahb_xtnh.Hwrite == 1)
        begin
            if(ahb_xtnh.Hsize == 2'b00)
                begin
              $display("hsize hwata 2'b00");
                    if(ahb_xtnh.Haddr[1:0] == 2'b00)
                        compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata[7:0],apb_xtnh.Pwdata);
                    if(ahb_xtnh.Haddr[1:0] == 2'b01)
                        compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata[15:8],apb_xtnh.Pwdata);
                    if(ahb_xtnh.Haddr[1:0] == 2'b10)
                        compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata[23:16],apb_xtnh.Pwdata);
                    if(ahb_xtnh.Haddr[1:0] == 2'b11)
                        compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata[31:24],apb_xtnh.Pwdata);


              $display("hsize prdata 2'b00");
   		            if(ahb_xtnh.Haddr[1:0] == 2'b00)
		                compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hrdata,apb_xtnh.Prdata[7:0]);
                    if(ahb_xtnh.Haddr[1:0] == 2'b01)
		                compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hrdata,apb_xtnh.Prdata[15:8]);
                    if(ahb_xtnh.Haddr[1:0] == 2'b10)
		                compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hrdata,apb_xtnh.Prdata[23:16]);
                    if(ahb_xtnh.Haddr[1:0] == 2'b11)
		                compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hrdata,apb_xtnh.Prdata[31:24]);
                end
            else if (ahb_xtnh.Hsize == 2'b01) 
                begin
                  $display("hsize hwata 2b01");
                    if(ahb_xtnh.Haddr[1:0] == 2'b00)
                        compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata[15:0],apb_xtnh.Pwdata);
                    if(ahb_xtnh.Haddr[1:0] == 2'b10)
                        compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata[31:16],apb_xtnh.Pwdata);

                 $display("hsize prdata 2'b01");
     		        if(ahb_xtnh.Haddr[1:0] == 2'b00)
		                compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hrdata,apb_xtnh.Prdata[15:0]);
                    if(ahb_xtnh.Haddr[1:0] == 2'b10)
		                compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hrdata,apb_xtnh.Prdata[31:16]);
                end
            else if (ahb_xtnh.Hsize == 2'b10) 
                begin
                    $display("hsize hwata 2'b10");
                    compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata,apb_xtnh.Pwdata);

                     $display("hsize prdata 2'b10");

  		            compare(ahb_xtnh.Haddr,apb_xtnh.Paddr,ahb_xtnh.Hwdata,apb_xtnh.Pwdata);
                end
            
        end     
endtask

function void bridge_scoreboard::report_phase(uvm_phase phase);

    `uvm_info("SB",$sformatf("Total number of transactions are %0d",trans),UVM_LOW)
    `uvm_info("SB",$sformatf("Number of sucessful address matched are %0d",addr),UVM_LOW)
    `uvm_info("SB",$sformatf("Number of sucessful write_data matched are %0d",wr_data),UVM_LOW)
    `uvm_info("SB",$sformatf("Number of sucessful read_data matched are %0d",rd_data),UVM_LOW)

endfunction
