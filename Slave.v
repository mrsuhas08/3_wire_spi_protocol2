module spi_s #(parameter d_width=8, a_width=16)(rst,sclk,cs,sdio);
    input rst,sclk,cs;
    inout sdio;
    
    reg [d_width-1:0]mem[(1<<a_width)-1:0];
    reg [a_width-1:0]reg_addr;
    
    reg [a_width-1:0]count;
    reg [a_width-1:0]a_shift;
    reg [d_width-1:0]d_shift;
    reg [1:0]inst;
    
    reg [2:0] state;
    
    localparam idle=0,
               inst_rw=1,
               wr_addr=2,
               wr_data=3,
               rd_data=4;
                                  
    reg [1:0]r_w;
    reg drive,sdo;
    wire sdi;
    
    assign sdio = drive ?sdo:1'bz;
    assign sdi=sdio;
    
    integer i;
    
    always @(posedge sclk or posedge rst) begin
        if (rst) begin
            for (i=0; i<(1<<a_width); i=i+1)
                mem[i] <= 0;
        end
    end

    always @(posedge sclk or posedge rst or posedge cs)begin
        if(rst | cs)begin
            r_w<=0;
        end
        else if(state<=inst_rw)begin
            inst<={inst[0],sdi};
            count<=count+1;
            if (count==1)begin
            r_w<=inst;
            drive<=0;
            state<=wr_addr;
            end
        end
    end
    
    always @(negedge sclk or posedge rst or posedge cs)begin
        if(rst | cs)begin
            count<=0;
            drive<=0;
            sdo<=0;
            r_w<=0;
            a_shift<=0;
            d_shift<=0;
            reg_addr<=0;
            state<=idle;       
        end
        
            else begin
                case (state)
                    idle: begin
                        count<=0;
                        drive<=0;
                        state<=inst_rw;
                    end
                    
                    wr_addr: begin
                        if(count>=2 && count<=a_width)begin
                            a_shift<={a_shift[a_width-2:0],sdi};
                            count<=count+1;
                        end                      
                        else begin
                        if(count==a_width+1)begin
                            reg_addr<={a_shift[a_width-2:0],sdi};
                            if(r_w=='b11)begin
                                d_shift<=mem[{a_shift[a_width-2:0],sdi}];
                                count<=0;
                                state<=rd_data;
                            end
                            else if(r_w=='b00)begin
                                drive<=0;
                                state<=wr_data;
                            end
                            count<=0;
                        end
                        end
                    end
                    
                    wr_data:begin
                        if(count>=0 && count<d_width)begin
                            d_shift<={d_shift[d_width-2:0],sdi};
                            count<=count+1;
                            if(count==d_width-1)begin
                                mem[reg_addr]<={d_shift[d_width-2:0],sdi};
                                count<=0;
                                state<=idle;
                            end
                        end
                    end
                    
                    rd_data: begin
                        drive<=1;
                        if (count>=0 && count<d_width)begin
                            sdo<=d_shift[d_width-1];
                            d_shift<={d_shift[d_width-2:0],1'b0};
                            count<=count+1;
                        end    
                        if(count==d_width)begin
                            count<=0;
                            drive<=0;
                            state<=idle;
                        end
                    end
                    default:state<=idle;
                endcase
            end
    end
    
endmodule
