module spi_t #(parameter a_width=16,d_width=8) (clk,rst,start,r_w,w_addr,w_data,r_addr,r_data,sclk_w,cs_w,sdio_w);
    input clk,rst,start;
    input [1:0]r_w;
    input [a_width-1:0]w_addr,r_addr;
    input [d_width-1:0]w_data;
    output sclk_w,cs_w;
    inout sdio_w;
    output [d_width-1:0]r_data;
        
    spi_mt s1(.clk(clk),.rst(rst),.start(start),.r_w(r_w),.w_addr(w_addr),.w_data(w_data),.r_addr(r_addr),.r_data(r_data),.sclk(sclk_w),.cs(cs_w),.sdio(sdio_w));
    spi_s s2(.rst(rst),.sclk(sclk_w),.cs(cs_w),.sdio(sdio_w));
    

endmodule
