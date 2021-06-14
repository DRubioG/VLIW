module decode(
    f2d_destpipe1, f2d_destpipe2, f2d_destpipe3,
    f2dr_instpipe1, f2dr_instpipe2, f2dr_instpipe3,
    d2e_instpipe1, d2e_instpipe2, d2e_instpipe3,
    d2e_destpipe1, d2e_destpipe2, d2e_destpipe3,
    d2e_datapipe1, d2e_datapipe2, d2e_datapipe3,
    clock, reset, flush, f2d_data
);

input [3:0] f2d_destpipe1, f2d_destpipe2, f2d_destpipe3;
input [3:0] f2dr_instpipe1, f2dr_instpipe2, f2dr_instpipe3;
input [191:0] f2d_data; // 192 bits
input clock, flush, reset;

output [3:0] d2e_destpipe1, d2e_destpipe2, d2e_destpipe3;
output [3:0] d2e_instpipe1, d2e_instpipe2, d2e_instpipe3;
output [63:0] d2e_datapipe1, d2e_datapipe2, d2e_datapipe3;

reg [3:0] d2e_destpipe1, d2e_destpipe2, d2e_destpipe3;
reg [3:0] d2e_instpipe1, d2e_instpipe2, d2e_instpipe3;
reg [63:0] d2e_datapipe1, d2e_datapipe2, d2e_datapipe3;

`include "regname.v"

always @ (posedge clock or posedge reset)
begin
    if(reset)
    begin
        d2e_instpipe1 <= nop;
        d2e_instpipe2 <= nop;
        d2e_instpipe3 <= nop;
        d2e_destpipe1 <= reg0;
        d2e_destpipe2 <= reg0;
        d2e_destpipe3 <= reg0;
        d2e_datapipe1 <= 0;
        d2e_datapipe2 <= 0;
        d2e_datapipe3 <= 0;
    end 
    else
    begin
        if (~flush)
        begin
            
            if (f2dr_instpipe1 == load)
                d2e_datapipe1 <= f2d_data[191:128];
            else
                d2e_datapipe1 <= 0;
           // end

            if (f2dr_instpipe2 == load)
                d2e_datapipe2 <= f2d_data[127:64];
            else
                d2e_datapipe2 <= 0;
            //end

            if (f2dr_instpipe3 == load)
                d2e_datapipe3 <= f2d_data[63:0];
            else
                d2e_datapipe3 <= 0;
           // end

            if (f2dr_instpipe1 == nop)
                d2e_destpipe1 <= reg0;
            else
                d2e_destpipe1 <= f2d_destpipe1;
           // end

            if (f2dr_instpipe2 == nop)
                d2e_destpipe2 <= reg0;
            else
                d2e_destpipe2 <= f2d_destpipe2;
        //    end

            if (f2dr_instpipe3 == nop)
                d2e_destpipe3 <= reg0;
            else
                d2e_destpipe3 <= f2d_destpipe3;
         //   end
            d2e_instpipe1 <= f2dr_instpipe1;
            d2e_instpipe2 <= f2dr_instpipe2;
            d2e_instpipe3 <= f2dr_instpipe3;

       end 
        else
        begin
            d2e_instpipe1 <= nop;
            d2e_instpipe2 <= nop;
            d2e_instpipe3 <= nop;
            d2e_destpipe1 <= reg0;
            d2e_destpipe2 <= reg0;
            d2e_destpipe3 <= reg0;
            d2e_datapipe1 <= 0;
            d2e_datapipe2 <= 0;
            d2e_datapipe3 <= 0;
        end

    end
end
endmodule