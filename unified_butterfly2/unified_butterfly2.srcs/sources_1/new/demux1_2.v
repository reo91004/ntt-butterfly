`timescale 1ns / 1ps


module demux1_2(

    input   [31:0] in,
    input          sel,
    output  [31:0] out0,
    output  [31:0] out1
);

    assign out0 = (sel == 1'b0) ? in : 32'b0;
    assign out1 = (sel == 1'b1) ? in : 32'b0;
endmodule
