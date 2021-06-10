module vliw_top (
clock, reset, word, data, readdatapipe1, readdatapipe2, readdatapipe3,
readdatavalid, jump);

input clock, reset;
input [63:0] word;
input [191:0] data;

output [63:0] readdatapipe1, readdatapipe2, readdatapipe3;
output readdatavalid;
output jump;

wire [63:0] readdatapipe1, readdatapipe2, readdatapipe3;
wire readdatavalid;
wire jump;
wire [3:0] f2dr_instpipe1, f2dr_instpipe2, f2dr_instpipe3;
wire [3:0] f2d_destpipe1, f2d_destpipe2, f2d_destpipe3;
wire [3:0] f2r_src1pipe1, f2r_src1pipe2, f2r_src1pipe3;
wire [3:0] f2r_src2pipe1, f2r_src2pipe2, f2r_src2pipe3;
wire [191:0] f2d_data;
wire [3:0] d2e_instpipe1, d2e_instpipe2, d2e_instpipe3;
wire [3:0] d2e_destpipe1, d2e_destpipe2, d2e_destpipe3;
wire [63:0] d2e_datapipe1, d2e_datapipe2, d2e_datapipe3;
wire [63:0] r2e_src1datapipe1, r2e_src1datapipe2, r2e_src1datapipe3;
wire [63:0] r2e_src2datapipe1, r2e_src2datapipe2, r2e_src2datapipe3;
wire [3:0] e2w_destpipe1, e2w_destpipe2, e2w_destpipe3;
wire [63:0] e2w_datapipe1, e2w_datapipe2, e2w_datapipe3;
wire e2w_wrpipe1, e2w_wrpipe2, e2w_wrpipe3;
wire e2w_readpipe1, e2w_readpipe2, e2w_readpipe3;
wire w2r_wrpipe1, w2r_wrpipe2, w2r_wrpipe3;
wire [3:0] w2re_destpipe1, w2re_destpipe2, w2re_destpipe3;
wire [63:0] w2re_datapipe1, w2re_datapipe2, w2re_datapipe3;
wire [3:0] r2e_src1pipe1, r2e_src1pipe2, r2e_src1pipe3;
wire [3:0] r2e_src2pipe1, r2e_src2pipe2, r2e_src2pipe3;

fetch fetchinst (
    .word(word), .data(data),
    .f2d_destpipe1(f2d_destpipe1),
    .f2d_destpipe2(f2d_destpipe2),
    .f2d_destpipe3(f2d_destpipe3),
    .f2d_data(f2d_data),
    .f2dr_instpipe1(f2dr_instpipe1),
    .f2dr_instpipe2(f2dr_instpipe2),
    .f2dr_instpipe3(f2dr_instpipe3),
    .f2r_src1pipe1(f2r_src1pipe1),
    .f2r_src1pipe2(f2r_src1pipe2),
    .f2r_src1pipe3(f2r_src1pipe3),
    .f2r_src2pipe1(f2r_src2pipe1),
    .f2r_src2pipe2(f2r_src2pipe2),
    .f2r_src2pipe3(f2r_src2pipe3),
    .clock(clock), .reset(reset),
    .flush(flush));

decode decodeinst (
    .f2d_destpipe1(f2d_destpipe1),
    .f2d_destpipe2(f2d_destpipe2),
    .f2d_destpipe3(f2d_destpipe3),
    .f2d_data(f2d_data),
    .f2dr_instpipe1(f2dr_instpipe1),
    .f2dr_instpipe2(f2dr_instpipe2),
    .f2dr_instpipe3(f2dr_instpipe3),
    .clock(clock),
    .reset(reset),
    .flush(flush),
    .d2e_instpipe1(d2e_instpipe1),
    .d2e_instpipe2(d2e_instpipe2),
    .d2e_instpipe3(d2e_instpipe3),
    .d2e_destpipe1(d2e_destpipe1),
    .d2e_destpipe2(d2e_destpipe2),
    .d2e_destpipe3(d2e_destpipe3),
    .d2e_datapipe1(d2e_datapipe1),
    .d2e_datapipe2(d2e_datapipe2),
    .d2e_datapipe3(d2e_datapipe3));
execute executeinst (
    .clock(clock),
    .reset(reset),
    .d2e_instpipe1(d2e_instpipe1),
    .d2e_instpipe2(d2e_instpipe2),
    .d2e_instpipe3(d2e_instpipe3),
    .d2e_destpipe1(d2e_destpipe1),
    .d2e_destpipe2(d2e_destpipe2),
    .d2e_destpipe3(d2e_destpipe3),
    .d2e_datapipe1(d2e_datapipe1),
    .d2e_datapipe2(d2e_datapipe2),
    .d2e_datapipe3(d2e_datapipe3),
    .r2e_src1datapipe1(r2e_src1datapipe1),
    .r2e_src1datapipe2(r2e_src1datapipe2),
    .r2e_src1datapipe3(r2e_src1datapipe3),
    .r2e_src2datapipe1(r2e_src2datapipe1),
    .r2e_src2datapipe2(r2e_src2datapipe2),
    .r2e_src2datapipe3(r2e_src2datapipe3),
    .r2e_src1pipe1 (r2e_src1pipe1),
    .r2e_src1pipe2 (r2e_src1pipe2),
    .r2e_src1pipe3 (r2e_src1pipe3),
    .r2e_src2pipe1 (r2e_src2pipe1),
    .r2e_src2pipe2 (r2e_src2pipe2),
    .r2e_src2pipe3 (r2e_src2pipe3),
    .w2re_destpipe1 (w2re_destpipe1),
    .w2re_destpipe2 (w2re_destpipe2),
    .w2re_destpipe3 (w2re_destpipe3),
    .w2re_datapipe1 (w2re_datapipe1),
    .w2re_datapipe2 (w2re_datapipe2),
    .w2re_datapipe3 (w2re_datapipe3),
    .e2w_destpipe1(e2w_destpipe1),
    .e2w_destpipe2(e2w_destpipe2),
    .e2w_destpipe3(e2w_destpipe3),
    .e2w_datapipe1(e2w_datapipe1),
    .e2w_datapipe2(e2w_datapipe2),
    .e2w_datapipe3(e2w_datapipe3),
    .e2w_wrpipe1(e2w_wrpipe1),
    .e2w_wrpipe2(e2w_wrpipe2),
    .e2w_wrpipe3(e2w_wrpipe3),
    .e2w_readpipe1(e2w_readpipe1),
    .e2w_readpipe2(e2w_readpipe2),
    .e2w_readpipe3(e2w_readpipe3),
    .flush(flush),
    .jump(jump)
);

writeback writebackinst (
    .clock(clock),
    .reset(reset),
    .flush(flush),
    .e2w_destpipe1(e2w_destpipe1),
    .e2w_destpipe2(e2w_destpipe2),
    .e2w_destpipe3(e2w_destpipe3),
    .e2w_datapipe1(e2w_datapipe1),
    .e2w_datapipe2(e2w_datapipe2),
    .e2w_datapipe3(e2w_datapipe3),
    .e2w_wrpipe1(e2w_wrpipe1),
    .e2w_wrpipe2(e2w_wrpipe2),
    .e2w_wrpipe3(e2w_wrpipe3),
    .e2w_readpipe1(e2w_readpipe1),
    .e2w_readpipe2(e2w_readpipe2),
    .e2w_readpipe3(e2w_readpipe3),
    .w2r_wrpipe1(w2r_wrpipe1),
    .w2r_wrpipe2(w2r_wrpipe2),
    .w2r_wrpipe3(w2r_wrpipe3),
    .w2re_destpipe1(w2re_destpipe1),
    .w2re_destpipe2(w2re_destpipe2),
    .w2re_destpipe3(w2re_destpipe3),
    .w2re_datapipe1(w2re_datapipe1),
    .w2re_datapipe2(w2re_datapipe2),
    .w2re_datapipe3(w2re_datapipe3),
    .readdatapipe1(readdatapipe1),
    .readdatapipe2(readdatapipe2),
    .readdatapipe3(readdatapipe3),
    .readdatavalid(readdatavalid));

registerfile registerfileinst (
    .f2r_src1pipe1(f2r_src1pipe1),
    .f2r_src1pipe2(f2r_src1pipe2),
    .f2r_src1pipe3(f2r_src1pipe3),
    .f2r_src2pipe1(f2r_src2pipe1),
    .f2r_src2pipe2(f2r_src2pipe2),
    .f2r_src2pipe3(f2r_src2pipe3),
    .f2dr_instpipe1(f2dr_instpipe1),
    .f2dr_instpipe2(f2dr_instpipe2),
    .f2dr_instpipe3(f2dr_instpipe3),
    .clock(clock),
    .flush(flush),
    .reset(reset),
    .w2re_datapipe1(w2re_datapipe1),
    .w2re_datapipe2(w2re_datapipe2),
    .w2re_datapipe3(w2re_datapipe3),
    .w2r_wrpipe1(w2r_wrpipe1),
    .w2r_wrpipe2(w2r_wrpipe2),
    .w2r_wrpipe3(w2r_wrpipe3),
    .w2re_destpipe1(w2re_destpipe1),
    .w2re_destpipe2(w2re_destpipe2),
    .w2re_destpipe3(w2re_destpipe3),
    .r2e_src1datapipe1(r2e_src1datapipe1),
    .r2e_src1datapipe2(r2e_src1datapipe2),
    .r2e_src1datapipe3(r2e_src1datapipe3),
    .r2e_src2datapipe1(r2e_src2datapipe1),
    .r2e_src2datapipe2(r2e_src2datapipe2),
    .r2e_src2datapipe3(r2e_src2datapipe3),
    .r2e_src1pipe1 (r2e_src1pipe1),
    .r2e_src1pipe2 (r2e_src1pipe2),
    .r2e_src1pipe3 (r2e_src1pipe3),
    .r2e_src2pipe1 (r2e_src2pipe1),
    .r2e_src2pipe2 (r2e_src2pipe2),
    .r2e_src2pipe3 (r2e_src2pipe3)
);
endmodule