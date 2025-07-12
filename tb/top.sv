

module top;

    //import uvm packages
    import uvm_pkg::*;

    //import test packages
    import test_pkg::*;

    // Generate clk signal
	bit clock;  
	always 
		#5 clock=!clock; 

    
    //instantiation of interfaces with clock as input
    ahb2apb_if ahb_vif(clock);
    ahb2apb_if apb_vif(clock);

    //design top module instantiation

    rtl_top DUV (.Hclk(clock),.Hresetn(ahb_vif.Hresetn),.Htrans(ahb_vif.Htrans),.Hsize(ahb_vif.Hsize),.Hreadyin(ahb_vif.Hreadyin),
                    .Hwdata(ahb_vif.Hwdata),.Haddr(ahb_vif.Haddr),.Hwrite(ahb_vif.Hwrite),.Hrdata(ahb_vif.Hrdata),
                    .Hresp(ahb_vif.Hresp),.Prdata(apb_vif.Prdata),.Pselx(apb_vif.Pselx),.Pwrite(apb_vif.Pwrite),
                    .Penable(apb_vif.Penable),.Paddr(apb_vif.Paddr),.Pwdata(apb_vif.Pwdata),.Hreadyout(ahb_vif.Hreadyout));


    initial
        begin

            `ifdef VCS
         		$fsdbDumpvars(0, top);
        		`endif
            
            uvm_config_db #(virtual ahb2apb_if)::set(null,"*","ahb_vif",ahb_vif);
            uvm_config_db #(virtual ahb2apb_if)::set(null,"*","apb_vif",apb_vif);
            
            //call run_test
            run_test();

        end


endmodule
