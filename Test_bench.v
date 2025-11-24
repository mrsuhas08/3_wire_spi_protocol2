module spi_ttb();
    parameter a_width=16,d_width=8;
    reg clk,rst,start;
    reg [1:0]r_w;
    reg [d_width-1:0]w_data;
    reg [a_width-1:0]w_addr,r_addr;
    wire [d_width-1:0]r_data;
    wire sclk_w,cs_w,sdio_w;
    
    spi_t dut(clk,rst,start,r_w,w_addr,w_data,r_addr,r_data,sclk_w,cs_w,sdio_w);
    
    always #5 clk=~clk;
    
    initial begin
        {clk,start,w_data,w_addr,r_addr}=0;
        {rst}=1;
        #10 rst=0;
        start=1;
             r_w='b00;
                w_addr='hfffe;
                w_data='hfe;
        #540 r_w='b11;
                r_addr='hfffe;
        #540 r_w='b00;        
                w_addr='hfffd;
                w_data='hfd;
        #540 r_w='b11;
                r_addr='hfffd;
        #540 r_w='b00;
                w_addr='hfffc;
                w_data='hfc;
        #540 r_w='b11;
                r_addr='hfffc;
                        
        #1000 $finish;
    
    end
    
    initial $monitor("time= %0d,clk= %0xb,rst= %0xb,start= %0xb,r_w= %0xb,w_addr= %0xh,w_data= %0xh,r_addr= %0xh,r_data= %0xh,sclk_w= %0xb,cs_w= %0xb,sdio_w= %0xb"
                     ,$time,clk,rst,start,r_w,w_addr,w_data,r_addr,r_data,sclk_w,cs_w,sdio_w);

endmodule
