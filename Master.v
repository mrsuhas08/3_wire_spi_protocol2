module spi_mt #(parameter a_width=16,d_width=8)(clk,rst,start,r_w,w_addr,w_data,r_addr,r_data,sclk,cs,sdio);
    input clk,rst,start;
    input [1:0]r_w;
    input [a_width-1:0]w_addr,r_addr;
    input [d_width-1:0]w_data;
    output reg [d_width-1:0]r_data;
    output reg sclk,cs;
    inout sdio;
    
    reg [a_width-1:0]a_shift;
    reg [d_width-1:0]d_shift;
    reg [a_width-1:0]count;
    
    reg [2:0]state;
    
    localparam idle=0,
               inst_rw=1,
               wr_addr=2,
               wr_data=3,
               rd_data=4;
               
    reg drive,sdo;
    wire sdi;
    
    assign sdio=drive?sdo:1'bz;
    assign sdi=sdio;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            count<=0;
            a_shift<=0;
            d_shift<=0;
            sclk<=0;
            cs<=1;
            drive<=0;
            sdo<=0;
            r_data<=0;
            state<=idle;                        
        end
        else begin
            case (state)
                idle:begin
                    sclk<=0;
                    cs<=1;
                    drive<=0;
                    count<=0;
                    d_shift<=0;
                    
                    if(start) begin
                        cs<=0;
                        drive<=1;
                        count<=0;
                        a_shift<=r_w?r_addr:w_addr;
                        state<=inst_rw;
                    end
                end
                
                inst_rw:begin
                    sclk<=~sclk;
                    if(sclk==0)begin
                        sdo<=r_w;
                        count<=count+1;
                        if(count==1)begin
                        count<=a_width;
                        state<=wr_addr;
                        end
                    end
                end
                
                wr_addr: begin
                    sclk<=~sclk;
                    if(sclk==0) begin
                        sdo<=a_shift[a_width-1];
                        a_shift<={a_shift[a_width-2:0],1'b0};
                        count<=count-1;
                        if(count==0 && r_w=='b11)begin
                            d_shift<=0;
                            drive<=0;
                            count<=d_width;
                            state<=rd_data;
                        end
                        if(count==1 && r_w=='b00)begin
                            d_shift<=w_data;
                            count<=d_width;
                            state<=wr_data;
                        end
                    end
                end
                
                wr_data: begin
                    sclk<=~sclk;
                    if(sclk==0) begin
                        sdo<=d_shift[d_width-1];
                        d_shift<={d_shift[d_width-2:0],1'b0};
                        count<=count-1;                        
                        if(count==0)begin
                            count<=0;
                            cs<=1;
                            sclk<=0;
                            drive<=0;
                            state<=idle;
                        end
                    end
                end
                
                rd_data:begin
                    sclk<=~sclk;
                    if(sclk==0)begin
                        d_shift<={d_shift[d_width-2:0],sdi};
                        count<=count-1;
                            
                        if(count==0)begin
                            r_data<=d_shift;
                            count<=0;
                            cs<=1;
                            sclk<=0;
                            drive<=0;
                            state<=idle;
                        end
                    end
                end
                default:state<=idle;
            endcase
        end  
    end
endmodule
