
class ahb_xtn extends uvm_sequence_item;

    //factory registration
    `uvm_object_utils(ahb_xtn)

    //variables declaration
    rand bit [31:0] Haddr;
    rand bit [31:0] Hwdata;
    //as there are 1024 address locations, to address these we need 10 bits
    rand bit [9:0] Hlength; 
    rand bit Hwrite;
    rand bit [1:0] Htrans;
    rand bit [2:0] Hsize;
    rand bit [2:0] Hburst;


    bit Hreadyin,Hreadyout;
    bit [1:0] Hresp;
    bit [31:0] Hrdata;


    //as apb cannot take more than 4 bytes we need to restrict the Hsize till 2
    constraint valid_Hsize{Hsize inside {[0:2]};}

    //bursts must not cross 1kB address boundary, so each memory location is of 1kB 
    constraint valid_Haddr{Haddr inside {[32'h8000_0000 : 32'h8000_03ff],[32'h8400_0000 : 32'h8400_03ff],
                                    [32'h8800_0000 : 32'h8800_03ff],[32'h8C00_0000 : 32'h8C00_03ff]};}
                                
    //increment in address locations when Hsize is 1 and 2
    constraint valid_incr{Hsize == 1 -> Haddr % 2 == 0;
                            Hsize == 2 -> Haddr % 4 == 0;}
    
    //Based on burst size, the increment in address will happen & this address should not cross the boundary
    //so a variable length is taken and need to restrict this lenght based on Hburst value
    constraint valid_burst{(Hburst == 0) -> Hlength == 1; 
                            (Hburst == 2) -> Hlength == 4; //Hburst == 1 indicates unknown length
                            (Hburst == 3) -> Hlength == 4;
                            (Hburst == 4) -> Hlength == 8;
                            (Hburst == 5) -> Hlength == 8;
                            (Hburst == 6) -> Hlength == 16;
                            (Hburst == 7) -> Hlength == 16;}

    //constraint for boundary calculations
    //Haddr%1024 indirectly gives the last 3 bits of Haddr
    constraint valid_length{(Haddr%1024)+(Hlength*(2^Hsize)) <= 1023;}
    
    //standard methods
    extern function new(string name="ahb_xtn");
    extern function void do_print(uvm_printer printer);
endclass

//constructor new method for ahb transaction
function ahb_xtn::new(string name="ahb_xtn");
    super.new(name);
endfunction

//do_print function
function void ahb_xtn::do_print(uvm_printer printer);
    //super.do_print(printer);
    printer.print_field("Haddr",this.Haddr,32,UVM_DEC);
    printer.print_field("Hwdata",this.Hwdata,32,UVM_DEC);
    printer.print_field("Hwrite",this.Hwrite,1,UVM_BIN);
    printer.print_field("Htrans",this.Htrans,2,UVM_BIN);
    printer.print_field("Hsize",this.Hsize,2,UVM_BIN);
    printer.print_field("Hburst",this.Hburst,3,UVM_BIN);
    printer.print_field("Hrdata",this.Hrdata,32,UVM_HEX);
endfunction