module writeback (clock, reset, flush,
e2w_destpipe1, e2w_destpipe2, e2w_destpipe3,
e2w_datapipe1, e2w_datapipe2, e2w_datapipe3,
e2w_wrpipe1, e2w_wrpipe2, e2w_wrpipe3,
e2w_readpipe1, e2w_readpipe2, e2w_readpipe3,
w2r_wrpipe1, w2r_wrpipe2, w2r_wrpipe3,
w2re_destpipe1, w2re_destpipe2, w2re_destpipe3,
w2re_datapipe1, w2re_datapipe2, w2re_datapipe3,
readdatapipe1, readdatapipe2, readdatapipe3,
readdatavalid);

input clock, reset, flush;
input [3:0]e2w_destpipe1, e2w_destpipe2, e2w_destpipe3;
input [63:0] e2w_datapipe1, e2w_datapipe2, e2w_datapipe3;
input e2w_wrpipe1, e2w_wrpipe2, e2w_wrpipe3;
input e2w_readpipe1, e2w_readpipe2, e2w_readpipe3;

output w2r_wrpipe1, w2r_wrpipe2, w2r_wrpipe3;
output [3:0] w2re_destpipe1, w2re_destpipe2, w2re_destpipe3;
output [63:0] w2re_datapipe1, w2re_datapipe2, w2re_datapipe3;
output [63:0] readdatapipe1, readdatapipe2, readdatapipe3;
output readdatavalid;

reg w2r_wrpipe1, w2r_wrpipe2, w2r_wrpipe3;
reg [3:0] w2re_destpipe1, w2re_destpipe2, w2re_destpipe3;
reg [63:0] w2re_datapipe1, w2re_datapipe2, w2re_datapipe3;
reg [63:0] readdatapipe1, readdatapipe2, readdatapipe3;
reg readdatavalid;

// include the file that declares the parameter declaration for
// register names and also instruction operations
`include "regname.v"

always @ (posedge clock or posedge reset)
begin
    if (reset)
    begin
        w2r_wrpipe1 <= 0;
        w2r_wrpipe2 <= 0;
        w2r_wrpipe3 <= 0;
        w2re_destpipe1 <= reg0;
        w2re_destpipe2 <= reg0;
        w2re_destpipe3 <= reg0;
        w2re_datapipe1 <= 0;
        w2re_datapipe2 <= 0;
        w2re_datapipe3 <= 0;
        readdatapipe1 <= 0;
        readdatapipe2 <= 0;
        readdatapipe3 <= 0;
        readdatavalid <= 0;
    end
    else // positive edge of clock detected
    begin
        if (~flush)
        begin
            if (e2w_readpipe1)
            begin
                readdatapipe1 <= e2w_datapipe1;
            end
            else
            begin
                readdatapipe1 <= 0;
            end

            if (e2w_readpipe2)
            begin
                readdatapipe2 <= e2w_datapipe2;
            end
            else
            begin
                readdatapipe2 <= 0;
            end

            if (e2w_readpipe3)
            begin
                readdatapipe3 <= e2w_datapipe3;
            end
            else
            begin
                readdatapipe3 <= 0;
            end
            
            readdatavalid <= e2w_readpipe1 | e2w_readpipe2 |
            e2w_readpipe3;
            w2r_wrpipe1 <= e2w_wrpipe1;
            w2r_wrpipe2 <= e2w_wrpipe2;
            w2r_wrpipe3 <= e2w_wrpipe3;
            w2re_destpipe1 <= e2w_destpipe1;
            w2re_destpipe2 <= e2w_destpipe2;
            w2re_destpipe3 <= e2w_destpipe3;
            w2re_datapipe1 <= e2w_datapipe1;
            w2re_datapipe2 <= e2w_datapipe2;
            w2re_datapipe3 <= e2w_datapipe3;
        end
        else // flush
        begin
            w2r_wrpipe1 <= 0;
            w2r_wrpipe2 <= 0;
            w2r_wrpipe3 <= 0;
            w2re_destpipe1 <= reg0;
            w2re_destpipe2 <= reg0;
            w2re_destpipe3 <= reg0;
            w2re_datapipe1 <= 0;
            w2re_datapipe2 <= 0;
            w2re_datapipe3 <= 0;
            readdatapipe1 <= 0;
            readdatapipe2 <= 0;
            readdatapipe3 <= 0;
            readdatavalid <= 0;
        end
    end
end
endmodule