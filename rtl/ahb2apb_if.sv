
interface ahb2apb_if(input bit clock);

    logic Hresetn;
    logic Hwrite;
    logic [2:0] Hsize;
    logic [1:0] Htrans;
    logic [31:0] Hwdata;
    logic [31:0] Haddr;
    logic [2:0] Hburst;
    logic Hreadyin;
    
    logic Penable;
    logic Pwrite;
    logic [31:0] Prdata;
    logic [31:0] Pwdata;
    logic [31:0] Paddr;
    logic Hreadyout;
    logic [1:0] Hresp;
    logic [31:0] Hrdata;
    logic [3:0] Pselx;

    //clocking block for ahb driver
    clocking ahb_drv_cb @(posedge clock);

        default input #1;
        output Haddr,Hwdata,Hwrite,Hresetn,Hreadyin,Hsize,Htrans,Hburst;
        input Hreadyout,Hrdata,Hresp;

    endclocking

    //clocking block for ahb monitor
    clocking ahb_mon_cb @(posedge clock);

        default input #1;
        input Hwdata,Haddr,Hwrite,Hresetn,Hreadyin,Hsize,Htrans,Hburst; 
        input Hreadyout,Hrdata,Hresp;

    endclocking

    //clocking block for apb driver
    clocking apb_drv_cb @(posedge clock);
        
        default input #1;
        output Prdata;
        input Penable,Pwrite,Pselx;
    
    endclocking

    //clocking block for apb monitor
    clocking apb_mon_cb @(posedge clock);

        default input #1;
        input Prdata,Pwrite,Penable,Pselx,Paddr,Pwdata;

    endclocking
    
    //AHB driver modport
    modport AHB_DRV(clocking ahb_drv_cb);

    //AHB monitor modport
    modport AHB_MON(clocking ahb_mon_cb);

    //APB driver modport
    modport APB_DRV(clocking apb_drv_cb);

    //APB monitor modport
    modport APB_MON(clocking apb_mon_cb);

endinterface