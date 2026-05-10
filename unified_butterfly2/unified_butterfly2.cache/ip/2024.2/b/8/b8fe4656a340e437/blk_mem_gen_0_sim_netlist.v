// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
// Date        : Fri May  8 16:34:02 2026
// Host        : pacl-System-Product-Name running 64-bit Ubuntu 24.04.4 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tftg256-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [9:0]addra;
  wire clka;
  wire [31:0]douta;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_doutb_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.622 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "blk_mem_gen_0.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[31:0]),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
FPXllyX2NFs/RMngGqZy2bLYbZr92CdofeZrJOHklWXExpaPgHNYp2Lzm4MnflbnrfSkCmLwwKT5
zfRgEip7FKQ5Zhb73p0MAIADixBZ/ZRt4hQkJL0T9brm0waLHfanjnov2aCX6jN3LbQc3ujmDga6
Dd73k78u4xjRTDv1/P4=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kr7VKKvChFoiyRCReag+OvU3jnmG9pN0cv+BxhNmMKLthg/ksgNZyU3L+fQ7cmIQELtlUjwjkBAP
Jjq5RsCnHbJxj+Ys1GNhriiBsxLqxWCP8onhAVvgZN2xZFOih0UWpqlU8NVP8Eww1ohvkDgxTstC
3kDmYehxIUJjqCC/mgRZmuezqugrFdubYmBoz16tUvD17iA5qqCIMS9xSIXYp2LBNekmWEwrVqzu
R4koEo4UlXl/CEw0XY3QvMoHnlXgu6N/6sc+nxZtKSwjiMVvGnZE9UVvJPAC3Hn3zKFGlK53mmGO
Tj0dWzhwX0ahSYzkyJC/HLdbGZmriL2UNvDyFw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
CaLc9FGt3AdRHfNtGAsGFY/QEvHY1Vv4TvvgCDsdDMqiuDeLizFJDJeskBWjeKDoE2cufK8TxiBq
mySRQNJoeOKnxTiDdf+Rx6m0iR6h/YeswegYwgghpM5KVrl6mSwF3+4yEovPM7a+9ArDQ5vl+WT8
SilNGzyW0KnTwe7+szs=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cEnudSW1X71p0Xuq6jrXOxHnBku87IA0RA3zKqmeZHZM0r+9rEm5MSzX8RecnQ994yiqeyxbIH2l
fGEzUzr0ZzryS3fkf2LnJuB39f2YARW9eVCSiaeWaraZuY1l89T+h3vgdlurS/1LIraYLS1MyOXa
6F1LAcQp3W4OO4ctc3q1FRMZGldRS1biMsKwJ8Lxj8NEOm67UfgFrJNQAxbVXEfbWRWhKtwNxcTB
JbgC8j4EHkIA46mzoHloeBAL6KieplQUBjKXSSTb66rxglbFhWLy+mirROHcocu9J4ZbvTRYZEww
4lso1lqAllVLAoKYqa3WImZuSRoTbGDngBt9Lg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rOyI+x4PlmKcVSFoN3oKgSYpVlmYxc194Ej04il/YmBg10xopy4zmtu5sdCP/uGSNYcNGWeAiw01
mNf98KyNgTUFXruHCA38qjhhEIvl4vfWWn3W3mFRxrIuwmnreT6qTvgMaxIkCdVBDP7Iy7O6WmCf
3Va5X5hnCHhtXgX5UYniBHiLjmupv63B8XMAYDH2n6mQ3H0DF7mtb7psBafd0Z6+IWUbmzwMtKrf
ZrRJBGAhNT0i1KrEjEh/rWjN7Z7N32zQ+Pl1kc5gYCQIX5McfdTdqSaRVXZ/HF90ymS7/8d5LDyj
Er+ORdcjnOn6oAyY4PuUUl4OYUHv5k+RglTe5Q==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bJa7kPSpDipzoJoQu1APEjc8vFLqBfQZK/grZvWijD7/FgMTerFCWLUY6n8DWeGdvjXvTeyrqCHE
2rP/H57wUqPC8tIJlGm6ZYQGjZ3TgYqLrJshDE5zYMTO//q0vuSraWvZP7A7SLuW6y7tFE/nplpx
L8gbYORx6j70okGUwnamCMS9yhFr7Z2QTJne1k4GNFGvy66URk3k5cBPl5j4/1yc4xGV+aWYl6L8
q8RorRU/CltObHKrji/jdiY1WtdGrkpRyCEFc+XNPazL9xSLLu5bz6XlvKwoks+8a5KYT/VFUovM
JbM0bpAXM8Z7rGaPuXjqXtZBg5praTZLu/WNcA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PYKBDinOGc/kIVdFzXrz2wA4/QNFxLDrQfTWfR5TjYE6bm49vrZi0bawcr9HXp4OP1+XxPLB3oCP
oV5e/rYeDln531ebt8yEg27XCoSHEX4FU8oG8aBJ8fqgWayOnAMJt025WodOxuZXbhT1zPo7J3uh
6iO9Mv7RtYE2fZ1W+G8oN//FTOEJYPWlKYnt0cDeZrN3I4rHHptZHuu7l8T+df0PYea3x6U3Mvkl
ojZ+TwQtdu0NuYY5j3QNgx3+W2XYq1M773FAnEz/deW54EjE+jf1jjrBk2pl8SYxeKuutS15oPVF
eHdqXYVcJxoUY5JH8z04lITKEnZ4oq6sYS6dog==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
tl+2vFCWZ583gQGsVC7oopz2NCKBiJ9uOHYBGzJZheOHJMqI/ehNvo25l710eBx00tztXzM30AH6
ZhAJg+kJwE2jO0MV5fmG5dnwXmLqoGEJMBs7xwWxvYK7w/0z9M0AJKD7HnuC+IiLhNU/fIxyuE+I
+vWqp//RcfY0tMMp2I2J1yEW6GUahS1ve/4JchssZ7Xu7VthoSDWXMQWATbvsUsDzeSo2+Ruz8Kq
Dc05HqEU8NgBxDPPEKLCcdKLp4byglwj7iCAtCjsPy8P18qjgb2sycFjNgmaiNMMB51WqeD+hneG
hLOue9bqVdEojkrb3q4WbsGZKz0bAGsryxslOlYHP1b8vey3yI2ixA80wyERe8d3GRIeZiSxGykH
qWxsE6x/iyi8QRb5mXZPMApA+Fln8tYmn7+1rFCm8gF4gJWhr1PsSJqTi658symGrzT0Ghjvf2QL
SvvoaeNdy0pOsWs7jLBFndd4GiFA+9K6Y33sziLToU9EvvFokENIslod

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oYiCujFRj1F3wKsGZlHR9niEtR9MLXEVAVfy+f/3xrmpW6Ye5a+fBCvm4TH+iRQefGHNdMPnzTNW
K/pEPAS9uMJjOdFiu+APT+LYrSRnEg4W0dX5buSDGM6LBWAuMseoTMjbJJoYDGLRckJgW43E30mX
ej4823nkbfwc+Ecbrup825qLyv8RTQLNHafvJA5lSapdqXwnlOIYRmcHn+sfAh5pGv9kW9aokcdh
ObR2XYxX99rYloyvz3x0pmjxD5ILW4SQMB1IUEuuyqX6eb5IQ+kZ41hjvsHIuQH29vzpCfV9Jqha
WC5yxxK1R+cleZSKD1H1gVzbTei8uFs/91Bgeg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
urNc+S8AFPj+GVFdqJE5V7P8O6QI6MA3nkwYb8NKbYbVufnXKg6voJIRYYeYr7EOa8mrqirozWbY
Lln9SLWnkaAy2LvL/N6WahoQdCt++4RH+xe768XvSrVUFPrIwZRixqMLurc/tPov4i5P/ukZKl18
ZPZvXRzUNlvCZnMPcF+5QCQihqPbjcZ0YyGgWgX/ipTGG3sNqmylGN7qLa4Rgqu/mB5a2xVyu5Wc
911+/X3VVFx697WVaP5V0SbOzYN8R8+8B8kdznwixMA+f4lSbBXyRysVOSzYjo8bKEMqyKMVBQn9
xDmEuV0DvVWXdO7VPvWA1LuJFwS07OxeI2GCcQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QcP7fsLZxaDrG29e9HQeXfu2TsKsdyW7Yc1vWct6lbmDEfXkWMU1fFWSPIjPzRc9UOnfEu0bRn+B
D+8MWokqes3WF7txljBmgUPiNGZ8arUU6ENa/IY/Wv7iaB/ZKM5PtdnFAkjDIrYyKFCTz/U6Yzwi
hBGGarK/wYQOLzeeKRewiPTiNUL7tztWuMZ1t1msxD951EeKrwjrjcXIIuf/TzrOGUOlWgjHlnrl
4Q/lfMAnRLBNTSWG+5wWewCE8jK2X/gJ5AV4p3x1WP3+JglbxpP39l3pzedXqciZPbuz2XlFnRPV
KByaUaAShzJ56p8+0HjWebibqQdieGNPiPWW0Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 27152)
`pragma protect data_block
1bFwGUfsXzn+J6NteFrOiOEiZExmTvObQBWuhc5ppTp3kPbUg4ARYBs0s1kk29yyZg9h3p66GJYb
+ezw8/w6HQ4Iat6U+kcbFjN3RZgq7HQZ2q8Mjg+9OliJ3CwNu5zgvIHUm130gYDKo937UXBFkETx
cjRWaeKv4t6T/Ka1YJFdY+GemUNSwL96gYA+gRuJFE1XDnu1X567eoRd6Df8y6nbyGBDyOA982xG
qy1+LErY46PEkuy+b7QpKmYCcsv9B6yqSaFIMhPsI/xWRYKhs7x4fvdB460JRWPO3LWneUnn1GDj
u4GLlLNIPDa0UzgGOHKkKA4Pnpm7nqnN4X/Bx2MY2qRYxlrEZf5XMsaBoOzAZWZk+hHME2ObQbtm
Q2Lu8MZxs2LyEioRnFiqLczSmc8Viby/NEC5ujxe6QPUgqxXA2xbPRTndD9ljIk4usBgSVrbv/ld
y00OY/Y2xD2x08rT15yCMZwL+g+wL6gPvcA7e084HdzhIReGqB7g0lFJGIXyPj9Rmz67CTnehex6
YWk0Mclme6YMXkJ8PtyUienOBHttvyGhElP78Yux77v1ZVzloUPVavcD9Ppu6Xy3XpZFmO0SdhKU
qKt6dhgpkRUW0AhGl3CjFZHwcghMdrRjYhGhRFz28B8Hm4syBXKuN+C3964oCuSDJwN89u8loIE9
zTuIhRtEOkujQcopkv0/ai0sjoMVLh/6cwD2aUmXRdWOXFu6OeLWh/laB1bVFTbnfGfpX3lumrZa
CcAv8x3w36eo7erG4ZnIDj2ChNy8Nzz+R0ETnAPU7aR7Dlu16vdbkIlzvWFxCAF/ccQzTfzcmNI7
yWHdI3pnSpZEXOyyv2DcDw3SSwfBQjebJhJ+SKLrPBDIdBMq942FHoUME7gG6dOxg0hfTxNX6zf4
B7fYQ3sTTwp90wN7hvyLj4Azn8sShTLt9qItq83vpH+L9nWCX4DIQ+U5OiRC828H3r3VFA+ohvqG
rn8OXeMtxXcpWBlx8+2Ovgrtu54av4ByYlZzodJzhj6xXdiEkvLoEm7eDHtH4pn4nmOz8XTp0aLr
olADR+50aPkUL8En6v0Eu6h3SY1WTntsTtGb3hXYLfCnNeCjTYosHwfduGa+Xudp7kquhCy0XBlR
KS3HwAxVP+B1ZEbqPyGwL9sACXmIMeRBD5M+c53PdDL4+FsM3FFnHZUdbuXIN9ux1A3eX1UxIwmS
sU+Xzer78n8ByStXIVO5EGffd6iFZZdri+2aEH9yUgRbrk4S33nBE1HljQcUN0SOcMi26phU27ex
JDI4s/JKu49RujJIdp0ttOEdIeUeuNyKoHeGxZIEeUublpikROQxmuFbq8+tREab/dcMT6IFbsjD
56aoEkaNfibqPiZxd6udcfQR9/uzYn1xRNYHH3m+QD+iFpOQWQtCKTQru9M5zyGdZWzgxL15vE0s
ZQlIo75yhhCz4jgT1XKm4Vkq6Aii/PbiFxo+pv6Yg6qXWQQNlhRoGf74e9DB60IslBKWXMYWdr1i
slEUuPQ0dvi/LnaEW9mdusZN5ssBoypsISSXbQhA35tEtVo7F8g6wvVEgRylblRS/HSZVQGzDbW0
0Apyu3Jp3PVsEHqnNIYHgXrrVGrRZr/6e/b1NbZIWrYS140INXOXgKWJ0gLjWr3DSVbgZ/h+OSQL
bJSP0n/at0spN0T+/6SgTD8MFH9sQ19E7PM9s+c7Ua/FtbvOiBhy4NQ8fTcbGkk3bu+RI5BpqXk+
DLCh8cxR3Gl+1rhfMPCHFTsdFqIVtwOPWlGpfnHWzVGhaZVbXUCOi/fM949nrPizP74KV3+WIXjn
f/4FYMTaz2kXO1ZNtFezqUkAjK6DQzeTcWaSl92jV13GfOodoX4Pp/h1Ip1sVWW2hJcijSlNDR5G
2KTJnh02iIM2wqEdepiueh5ifkrTCFUotYrLKrRsh3+btcDl9+mvJJRsXj0TjnlavTpJc6cYVY+G
phsDY4r/PiNPvQdY0sNoc/bTXXh7JZ4NDKut7T8yDHiB/rbQ7mMe0djdUsN8S1+mwtxQAbaHVSJv
IJXkO54pS2mtu8qK2mQ6YqOtmJw2AvuP1ahTA0ndC+hGJV2VCn4Kusy46bkMndfzZHf5bZ5wNgOF
ahSbzaDfZZ2uHpXX7k3JBFfjLfmM74KJfv/dQ9hoHl1BwAt0w8bvEEnNRCcp+aPSTvasHw7JR/nH
E0kqfBoPrzKKIntETikXw/896qUUFnRx4XzbAXA469ilTsDsEAcv8KkFLf+pwh9prxmHNDsbi39N
INF7W9K4xbN0cR381f0Kx9ya9PdI9/6rMaZ8yaVjO1kfEWW0y38SyekwljYX7NFJFafjMYUzd7oe
KqCFIzGXKDgEaP/xgciKWNCCGQOuxcjaDUgnsocRwtYWpn71Oe0R+kCHhnepyYrd/JL7FfOi4OW+
DS68zrXgrPr+u8Sd2KG9+zz9nEttFDj9RyVzV64qLVCBwvN1uVd5gO8BV2gZNt0bMbE2Bswto+oB
sfse7gjaU9DaAJ27P+h2kThcT46m6MFSAs0jekS158IGZahG31z5zQrQQ+hDkINVkRwomprtQesi
zqt9vz0QaBC79uSCScfvgvwjJJKrUqTz2rSMzss1oitqQGj8T9gVcx4zQ2vFVc0RsVC8oGOoCOPT
EeG+XhvlqnsTo8tuX7YkBvEOCZvLG8VLZell4Ra+XeV6N6ss/abELtgdBjGV5jJ2RHfiBJHwBS3x
7M1E5AwXEHltUid7Vmm36nzzKM6+AsWqouvMon53BHe34ezDte8unslDDNIFZvZzDDBwbN+aa9su
iQc0RVILVABCabUXfptpv8SCSA9mqw1SRlFtcOTFHxSxPz7QPuwFekKG6Djyx8y0LADdgeTU92CI
I2pFIwFgN1XIk99RR8rR4ib98uapI1dSR7QghNEE97mLYKNnOz6y+cOSNJ41b7ErNnxd7fjuz9yK
IOj+Wcmjqg5+tMna+7+M6ozUg0R+uqdnbt/B6RWcQywuB7//GWWHvA4Bw+6lo+CMjbyKr/7qeVPj
VBUKW/eIIMzO7sVqvvz5KmtT7dlenyjaMXAoFG/ncOKN9yJb6jQEfojKmeJDlTs5VgZMgOFaai4C
FpHGlaV927N5BSh0oS4ekXncUpCsF2EPclCPIE3HyycwMRCugZiwQJ/6UQTWFue/qBe+KLBmRJm+
o68otvMaFl6Yef0nXa2gkpzhC9WP1WjDKpkahPfGXBVTY12OI40fnutmigSKRBP6pWrlCB6TQjJ4
t1mwLDNhGG3NYUQdp2P4DXIMRFxH3sxBManWZSh/M43MYcX/LUDXX8j9OdJDW8+BKajXdfiKvBFx
P3dq2226TqoXVb81iaz5P5E5MhVslGWI3eWd+KWTRstLTc4YmPjIT2lf+2UUQvzhE5yIiZMVz9u8
bwp5MjtOS/4ih3L303XlAkXk7nu9yQp/Wz4N4A6ybumXXW5ZNK1L65pYiF1Mxa18HCTy6yjjJUQl
ZIFF/l8hvV2CgIXw5rfpML3F4ZsT4E4U3BcsVonHNU/hZ7uxqV4S0oB7v6gBROtpAoCuvBB7bdrm
+gBDhIMWQ8J0ef3gX5n4/ZQ/fiC1JIIkOBekooK7Jh9tOdZXgjQ2do47ieEHGV1rxEjATS8yz1G8
WearFG4JVke4viYjuhRc7QJ4VVFyObjZo2RkVeW+CwDh5Ge6FrXU48aOsWSBjPUWSbrjt8FYq1kU
qbktXOZ1o0tEwiafB2wTNtypMpLWjDEQs8ekinPFHPcH+UqiVV1x3+LEyzsanjzpKpyw5QMDIQqf
N8PBOrcZUo/ob+EoEy19JSu3m/GTmh/70ACPrnwqKAf8iw43UcLTvPZabFt+3sW8kn2/POtDPSW0
KobkdJgve0VUhoTVQYLxDro/4ENLhWydGFaVv3GjQ8nuM1TvpK4M9hA5i6ZzT0memAHTGjzqi+rx
jrIH98aVG5n4n0HAVQ2VpqKr/aZAF4TMinqCgFPSqhZUarppSuYY5l0LDOSYC/EJrgQydVWsHHKz
0AcbFWJ/XvR9GuWweXyvwCExg11ITTCiJGmdVYjjff52iIURLOrjauYRIA/hhIzQY5+dNMCWE32M
XAwyKM0c7hJksd/YgMcd3c3/2Mm710DjG0Qg7QTRUujXDujF6LywjYzyqSJvA+AVZGBkZid3COyH
CIj/A2MQlKAXDHCa+ktaJEiUksD38CtRWkOVY6usUooBBhb0+OnebWZLRirfEluOROIJ6hWcQ2Bo
fWjmCTySWnbnI77UuKOdi5qmhdt9YVEJJE/N2zBcpMv/VBU6OyxPUXTyHrN9i7KeR7pnPQ+jAhca
JR65WDBF9JN4HDlZxdBT7CzWPGCz820+DXoDE6FHpy/P42owEvDzYees+4gLUIBN3vBK0A/wHhqg
urvLBwCTNQSc8i/DujtcYaap0zipeFhrXd7i69XLh5YZMrmW2NU3JWQRPbCg7vHZctqb/VHaJ71W
zfwthxNAEaHtOwU2nj2ycOu7RbtTaeXp2RjFfORf0sJLTq+3xK7NGCKU0qOGgZsUTu1+lok0vaqN
TMgjwkqzpg21YlooGbSdChKmF8mv82+K6zRBqgY7FZbIXUn3b4a2shyQ/M0bW5cPQX0aWyt7kZ60
2kxaXszRpDednwF7FEYb1VrWbsz2Ryph2+k4Hh1enm/9NYriDV5YMRyFgVq85XPQMYIqNJo0wjYc
KMAYSdpYoWjSjOD1uLqnoFhpPvwM0Evm4OZI4mzfnq3UxqWMNdqCCDtWIekn9Qr5LGO2wADptlhf
OFZfZtMNFQhii0RqaiVFre5cbC4zXHUaAJZ1iPcsFY+4rz4tYs0r0aFyhKS47FWpDCOUmIohIG4L
oMTu8ZPRkbea5k1nPfSw/va+dz5f9RPLa9IcnOeW0fm7lhBTYlfhrc3Wcw44LIkaFVsZcagelST1
X0p0mY4ekUtxuECeVkC4S43HHYDn8zKOoJoRn+9vItKK2/oBSWG84hb2PwyzowBWT+l4VoH03meY
epAhAunfkOVbY5GseGf/+hYqyAKYVnWsEXhn6KZbuYS+5z8RsXStdOgToAfZieB8Qkji/LmnCTaU
8NPuJGon8JWzlr3aLs4IjJxy/af8BDXJSuy0smkr6QkPG8KdxeBfawVPEG0c6zPn1pJMbKcEgLhK
mKOkj9Fw82jRy9ES5CndTpQJUce2sH+sS1mrGVU4rlvwT9kfTWa8ugyWM9wIrRdg+bPUTNB0ZXsz
EH+5q1DCk5kDMSBd/SN4Ff14RnEssD6cnsGrzyaMmQcRTr3ygE95BbPDDl1kbZLvrrrN+lNoUegr
6r94WtM2bb3eUDeji1acTCQykY3+exuUZYKjNDwE8QRuPIe03wlHF5Z6BjbIT1NjqATaEVwGe33g
fm4e0kfXddYINrMbAVvRGqARAboDZaZdM5PKjirUo6K/H/SgyfAzK3gfxXzMSZ6Fgu+soMiA1q8l
v60Ye4whDMjEjsVwJSYYreoQvg52N8zRFfAgXNgJvKZY0sZpZlxj6hkbL3XbHf/kmCo15eJNHK0s
uRFjRiqzSzUopYndXvKwXn11jGoaG9MlNU58+bSfGeS2dXM6FkCQSurWSRMudABloQPRvWx4icq8
+Wyc5ZYmzDnup1qhQ0yKdp8d3yld8JJXwVDf3uOo9kvL4JDVVrPjUsmu3mkyPQnm8TPV9bVXcNuF
WyUUhiVzAVGnV5icLsCSn0jJfKakcS//KgHs774hVW+jc2YxqAPt51/B+qqfqQLJjxy7UruWq0BP
8zb8R4lq4pAPlrH/uzwjzXPK5FRyLccUGhxAu0DAF5029cSo9JV6dH+qkr+dj0D/JdSpy8L0OV6a
hJLD86d5Q900iCFhwcGGD5Sl5va58d/kQwZsRii8ciPg/yZBIAYMlLKQit756OOJnCaylSALVHJx
40YM3HxqkT9E//MVBcqiF1iatLnsnoSByY9CAIrdpnGScf7tJRXDK3jhOyg8rpBsXbale+uChm3x
a1G37BLORWRRwQGvR/VrqRZP566OMRvg4ljen8I2+PnMAZ6iDazbeyIfNcwOK2uIv6cYaky0I5zw
8p2/Ktt45yXHFuod21HCQZPIh1P6M1RL9htxDcSinHjBLYPlF1uqH7pVWWmUfN2rmXgF5fswKadO
pzsZRqxNuS1Nrp7r7Bib0qKdPyZCmGAP+aP23m841Ce2CdMzJ5FHmWfTJmQEYMnk0Y2ReEQ0XUBy
QYQthe5DQAQDtrm9yfIf7B15zGyRGvWOan8HN06X6zeiAElVeYW+O+Cto2kGUPGZWFbV4buCv+Yn
QJx1lFzgmgA2fsDxSBY2spEA+Zyu3BOGSeLF/kTwm0i8x8onnKu8iq+i6SF1bn9EQ2zFvEMj8/NN
kI6EOOMlaiw+IGdI+OFWBzNTvgfXWIC18UP0rCEBOO32ASWjvdz9UpFdSeHYs4mifXyXimvLpZWo
JCIRck+EqEh7f+JjU/CuAT4me6JcdPFn/kGehXvGFQ9sqHNBWIPjePwu/jVSeC1MgdTISHzbgxXI
o2B86ShJ5CPh305T+TGcc8MnJaGg7LocTpbaFAISPoqoa2eJxdoblZtHWo3S7ZYleK5nwlM3mGZb
4yiLWND1XkhTaztvig8cKo6IXoBtA68JG1jQYjw51QJSnWevDnSllutchy8TbVkBYJIHHOB8UxbZ
ccZFRLCYm2w1SdYv9+Uo8tny48RdKJO/Stu9I8wd3Rk4HmKtI5zE/zD29ooP7RrvuQeFlvQ7SjlX
MWbNUjtaftka+HiddtNCOyTJuv5qpO4UG7dRHjCUFwm/He98iq3HE1JEndWh3ukAqSEsKK/3SyDL
sf9lFS61q410ZfvnseoTiGvKJ6WS6clYOrZgF6LpkNQX655aQnOmz2zDCy1aWSu3+yKmY+hGLqFD
qZ/6RqgEek8P/zyA1RTRPTqChVN0lhUxIhp5MNC/iOd0EZFvV3SsKiqB5avRW/p5B4o+rXrhiHkQ
0QfvI31BT3mFgpbQM0Y7yrJYbGA2cR+sZetLq81R3UBeH1ptq4zTf7w4Dm05SnsiGzQzx4YR+8/D
3+Sfm+hBjx/6lu9VOz/oaO7BiaeSKYFq5F+ciQDzLxouMNHhVAZ6p5rYGF8bHMnhQnd++hs7omIV
Pox8AnyKkQzdiX/3waVxI3WSA185D/3RtEHeo5ycUz8CRflgDcQjjgSZzdC+r9vm7bVZoyWtE7YK
kXBILVIALkWrn34Bg780js/Gs0ln7H4QrVUNYNYpcQJ5nglLMc8tyDftvlnXy/iZP0mb46S66TeP
FTQrhV6zNoECT5lSyGcJ8CrLTH/SAK46wM3WXqXUn1f/MpfHs2fCS22YyJSyjJWvBibp1DhIk5c2
WDqKxmOR7mUN0KJeK4oUfpoLORIGiOsJA1IBOZnvfEGCgIbBAP3oD6pmxsVYfUn6EkQgJ9cqRyj/
Q1YqRt4KcJWrNr5FDIv4kKQnQIXfnIZTtbq1IH1D7E8bqeN76cMB5baaDj/OxhRa3us2AO/uzsjv
lmYrI5b+y6bnQJTfQC1SEkEdzOZ4c5jMdWww3QGKbwsJnWqc2yszLShaxekq2rjiXw4qWrdKKlUC
ljTr79kRcH3fQRfuK0QdGqTK7W1eHIvoZ8uZvvHiReoc1dQRrvSmEvitmH0fgjsmabdoa+s6EsZW
7pk8MFjLfVhTBGEBu1S4lIJTn3tj7fWkH7s7I61k7VFkmahjjZJ7BCh59wsFPZvioFek9heVY7rU
hcMmh6IpTZ///Tiv/QN5IpQhngZrPx/pz7uODLsWmopPyxkHyeHPm+cOh1GxKkycq9DPA2NOe78E
SEIFLQRnn5htpNhtBpI5JuKWxIfVmovH1x+T4mMtRJu3T5Elkv6QYjLhdi3FZdkUBCb87LwZSavx
FRYhBgLPHGvyeSFvIEnGK8nDtIKYQf9Hx1uL9KqJ0MzTWnEX6N7mRfsm6Tkc4vcGcM70MQ8kDGGD
S4jOsLC6pRAQeDYa6OE2YfmcrHqn6X3XOwqW7WhMVmgE0gvrLEg0G6Z7mSNRr2jjUkMTTkDnqUoQ
Yc1RLeu3xUSFs/mBZrrYcTYhrButABDqOASIIXGLz1oxKi6QmH3eBYMZ9851ViUy0Qkw4AV6sqrm
H7FhQ/yt+84J5IUX1u4V0G2KcikadAM0c9/ze0iSzzXShjfqjLZR3NGnb7WKreycQ6PkTneFtCA5
4IueiHnVwDP9AeNg38Gk56zU0NwS/FYm0lDz4UUJGqYFoAqxikv4/Yr4wDL3cXBODYrX+eB6crxl
ZsklRk5aOIEd+pAm6LVSQp1k0xlcKJh/BDN2frMWnx12qAuPzCNpUqyENqZX9tmNrCP0DpaImQkr
8y7tdMy3VPVLMRss6Co65KKBEQnf9S7APzVGsPCEUVNeGq7sTgH+XNMLLPkRDXwiFg1sZn2eeP+D
I2N4CcHH7+jffHpKoBpgyeRwH0aC+bXqHLFmzMBTs4G6RPM6ShQdEVXysLQBWrOEALr0ODIktJ0L
laQKSghPj4WBE7mObL0w1wzYhJGi4gYgQk73hIwj+lsfEQHVuRZYPqFozcvTMg68yAbDkcY9scMr
+XV108V4P45W5MZJR1wcwSHejvMrCYY6if+cUYz0abFt2EtcaHmp8uD/c9GJ7IRAihSg5McGVE/p
lAvSpSDBfPk0pNeWbG4PsfGkk0TeUV1HDCq0bAtqsYYQtLFukjyATjC/mu9xcSNaYqhYtvSLMO5C
NPXmfvJQMcQVPwq28Mri7zHbynlTu89bhJ1o3uhWIt4CMcM0UAN0D4ZayBqYQOXuXXuWVgFaVPHk
9SfTy9HiSWJFrXZJxdtYre6KkHu0ddauPXglzlx7kSsRFg9a2faH9+hxAAXaGeUCGnQZOIML7oN7
x3sO1RVbPvDtqDt8629WZMBE4wE0Eh9wF55MAHfRGegDU5J1V0U4Y58xQfE3ecCcgghfq097WG4X
jLocgCGI2oRFhRqtVirnjQ+ULxey2rxRXXTZfer10UGnRyMwstMaW62lhz3vKngXuThTyGVeNf8j
ZlrFHkWVxzf/DwnZGONKM0zBnIU3JDHRBlETp/Xs8u1C5YTAy4OSWBuFCNtAfd/7OI1HoRvFwZHD
bhSurFsy4aXpEWysKMHgAGM+/yhH36WOgHx4v/M/epMDay+e1dSIpYN53VeY8n5Wk1Nkq+60BPav
yv/eHugWmYsaJQYepF9CGHVwuPtnjqQmJy6F5m+6lX8tFO0sIOuYizskwSi7m9mEJi3x10zzebae
kcKoroYyhAewbKd8lWGqgRkoI2tCVvZ4q+EklQicVmAB8MzCURRfZ7GqSFRI8DL5rz7rfy6oHbK4
6a228Ry3k0nk64SPc7zdnccLCj76WLfA0MJIscuzSzUq/VhE40Y14ez4nkMjn8ME3BlEomr40fPh
Vk+gScVbuDxyetDjnmziJnZPHAfL/MNTSUtJgyjk4MxlTegQLdumYUkRH6AElnUkcHEuFApK0Wgp
5vH7Eg30abgSgWAIeaNRwImAoQEx3fFD2nYFuXwzgfBK5uCSKvKGzXv6988R91a7D/hrRboFZMEc
phsiqqeW76zK4GpR7o9tT6gnA77M7RPUH3LuT+8rYi7E9BEHZuYccQsbGnnhdvdODWhSamxE8Z5k
VQa+4LrywgrMjEqUoY2pdwlsHcnRCPPpW4xtyPBBZIu1a7pMSwI0mbOQRbVOCQJ2fWzZXNXzt9qs
JUc/KPQEVQwhQ8zYNwwf+6Smj70Uym13WDGVB9bp4dD/UwIvo+Z0d2Gg6qnQUWgcUJKeBUNw3Yks
x1GWvF7gl+yOlv8SKHE0rw5jVNFPP50yQJIaOGjWBn5+7J8SRng80a8vVyEu8NzgruMMGjBjoGOw
LmYkiLAjKZB14/LqKVBVvFmirJOvwDa5gpTCiFFIfpJ9Xiv+IHz/ZJoFOdWwW/EDvNrKuQujAd8k
pyVogXw7cAp+j+eV7JZGVGuktf4sYUtdNUm2yBTc7YMXyfrWXF9wi32iMAvmnOvxD7rMQ+l47bzF
wZVija7jiNbcPNWKv9E6q0fucyQ4N5CBTelbUqLYznFcY4n6bmjyRZYUj7zHQQEz+Ltje66oINuk
OS6HlIvuWvZkp9gHvPPEhrmdzK95pU2cazTya2Ta2lVNGO/640lcPbvRAYsjpwSd4mzv0CCMrCdf
dkn52jv0K4UJQAAFwrLvNMNi1qySEISJfqviHar4kr2swfM86g8TsRRD4AqVzrIZhx4ao3oKOlOs
YAbeECqBuJawgDx3kDxyTBXt4O23aHWr27KX8nzLloF+fpRndI2Xt0sI8lA1JvxT7N05fepXDa8O
9yTp0AsHzq2VEOWkne9nl93cHSDRSRjRxlQkNMUY9n+tL5V6CIyn71GsrhfPkcBx5qn+mSt+zW2y
pmJMooDi+JKWVM+PmyIVpoR80UlOs77+YMMt2/Tezq8M7sigpfyvobdjahz/FGYqgDOWxCBnB1gd
uq0eRvaHyxj3hyyA52WYEOPJcU73/Dfa2RVS+uacMcKQxlwZpVpeSY5l5ptnJxELDOqZtQR4FKqm
a1zpqiIuqu32YPwnK/TDGthuWEBjE3HPLYXJAoNE25V1mpnp7A76BwIcO38QJw3ZkbAnxK+Q7XBr
j41DWZW18EO72GR4fzWGFXqS+BOXkzg461E/qy8LOHaBRRfjCULJCntOeU1eC4duz6ggWAhM2cuT
JvIQWxFWBgeNwhFlNVrqlO6OUaImbzu4ovlERJNxb14WsOMQ4c0NC5UgdDwm2EEMK9Y9tsPhoR1p
oh82IxaF2LN9uPqvpYDUpZ0sB7NVBs7r8Ec6cGKy/8wA+u+K0cjAocy6skl5wLBrc2wci4BWg6Z2
d4HJcABtO1xvgDoF966B19SatXPQbU5GpWF7PKFExAbKTLKOVyzQhDuqXYqsjaJjM9vvfm7D0F3c
pE6iK5ABJ76fmhRpm5VDp/JRp4lfsrieTO45mU4uNiticgPeYuJRbyXwapcD3XiF1rr6Vc20C9p3
x3oZkKCPoFk9mau7ZTaNLhMZVXgUoGIy7F2tCtwLGF1Vd+TzaOYvjdY19Gd720vnRGJyTxJQ+Laa
JvSomcHqR5PzSaLBFVLZbdZaySH79lGQvia/u+5WY8Ptzmqmq+hQycggpGnZ5HxHfsrgfFutcnaH
GVXQ6T0j2MoX+Kntur/TfFboPUV47rvGEVa/BIXSOugrAm1fO5m9Ya0sfsPwUx2/1a4/0drSPZJt
tmhccpS09idPVCBT6yU+gxZMzh1vuTL2l2aeyk/TI4peaHUETObWWsPeg5uKjHYx4lVOMS57XHi6
LCfY4T7orQ12IfMJnW4egHu3xCxKmCl3gwuA9ZbQrJ9bZwk7z138GlMCYPRQjks8cmN0SGHpjeJH
SUrHH5y0M+yByMzVUDv1nEF0425XyvEaGs5MvRt9HfEqZu3V0G7EHnyoNrljwdHRWYpHQYk7Cwaq
E0XYuj9AFfQJNWKAK2XXsh2gGQeZLLt8lV4BAZcqqby5b6j/7QzCLu3i4eNSKlRDb1Gtvu2RFx2j
+gle6csK1ZP6/HYnN/7hEnl8/FbNtrGcXOMQ6UWQDUomdCU/wEyXClNcCN9Sve7NfXFZ05P2aq2+
BTMt0KZc3m//VRemUZaaaiYJ+Aqd3JO3D2FjrGu+o8aYN3yV6vhECYTedddrGjvS9V8dpoT5ruoN
6sMW4e/E1q2ZBdqgknLdjVXM1wIUy/EeBKn2bw9pi22fcPNZvGzbM2ortd4aBY1Eo7fX5BPwPczo
M77e8cSRSMB9hmwZ6huJR1F3q3xNOTT3YXPAQLzneJkpGEYxuBYbfZJ03zs5BRgOm7lijTN+OC1d
XdAHOL1ERmMIywVTPff3+j6/Q3CwrbmtRDqAaLM28P3cZGc8Bk+4SGwFK75CsN/s/cjh5+RWFniy
u5RjP62cFoiYjyg5/MBQtHX/MCm4AmJxRbq6z6WjAgxIxvEUYJgcRGA9d5j33u0ug+sMAfT4gRXx
XVEJgRKzSdjSEmwE3K17K+vkw1u1fwASCR11/RIrTNYaay0xwKzq40iaS9QcD88b0gucKQQWUenA
45JYVLqygc3ji/ItxCQo+0om3EzhXAv77PatIQ9LoLaFjnsG5tPw7b6VB4rdYAGWr78B0pXFcEKD
j2p1kNUCvDpBFCAJXXmjxdS+Tl2ZhYciOAGeAWRT1FZt6vmcXZ0g4uu16Z5wVQu3XRjej8004nA0
5oSJylRLi9yQ3zQyEXtxfEYOCO7i9vA7hA8XE8lvc8ZqM6zwzUK4SZszWr1wOh/gco1Q2P7jnE9U
20TFxFex2fZTYZa9cc0ekeF3/LO6ZrQiY3rQiFWSZhahWINJWex0em9QDJTrcTwgL1iGO8C1AmZ/
kpDsuBRM/74KbPCDDQRceCP+O8iFYAZk5pYKbi8eu4b7FWGwlGQ/zCeQIF7hcdxgd+DgLi7BGpr6
73iYAUI2CPekfrgkFt7Zx3lm2+lpCCUFdiB6/h4pDvfx+yJNNSLUw3H051r+Hzu5lP5dBWf8b5mH
Ui6C6xaoxX2ojAI68nzIugq7WbzgQSV6PtQ9h1pE7yX6FOD1XmEZU+xbnbbJsIl6Q56eskPVgKmH
921Ei18X12LUEPRtVZWsG25FWl6Ezyl/h8W5FslUpivPJM13ltBND9DpB3dAMpLvKF+1WwleSd7J
nA+kaTVdiQQ8jvQ80utnMllhAls/9iqX3W9xCliw2PGJ2/GaUHu+MdbFzQofcuvnbbgpGfyl/GTS
6QLXkiNJeaxO8le+wQXJhbu7h1k2AHkckMxw+M6VoJpmY/OEZeVz7fL9PpJSV1WpUHvzk/J6XghN
Lh1reDyyYzwYBiYOmNalW/ylYdxYkqhieF8SyooEjlzecMYAR9S3JOI03F29Kv8csIaT0TBlyNFu
0oBPkVtUDtj+dvepzdkx527REh3SgGcKsl89imn+HUhAYG/Yfo16NlV1rL/KyrSram5mLhFUBu+z
ARXTScapmiPdMjOzs/AeHkjS1v6PtHyS7cj/PPsV8Bo+MhrKI/Dqoq5mO+1yqcJirOn5WAIsga4m
2D0UvvQFLK67ORa4QTUymXMBt5f8BmDUSyHCNzx1C3x4Kg0gp8hM2tLzpD0Mfav01Ssp4CRmplfN
PeQea/RF15dLS47wqvYGz5QZr2NEFPSnO56LvhA7VWDXA9P6qS84wL9J1+dk+tsgyzsYtKhifa2a
xw4paRN47Hfb+6V2Z6i4g0GRuLJo0F68RZ+c2pLCoAiJ9UIiQXlEc+5AhqIukNuMOOZArDjsbVf/
3EwjvvttrDQqdvP2LfsdFwN/30t7rGgUPUErQwTkURi0MgYg3toiuTaMpWj857yBwKCAJcsfg5UT
cbxUkkVAzT85prAo9W1JXx0kXwc4Yl9O1waAh7RY9mh5MJdb0X2UwRx1ze23JqDMCynctNCm4VsK
erWuY3wwOrPExyctIT3QvFOGQvyz1gHdJA8aifmMbGa6fpYHzNYRaFl00PGgRUgodPSkyU2vsh5d
oMPZrJW9V4OAMv9Mwb/c/CwUXSw93wvFBnJp04w6nt7dzyoE0TwNRieMM5yl25RR7hSDG/UH47EZ
vgObuhgDx+1ddZ+HqLdc8LTdx8j1l8ftJoVcSwfBoN53KIqHqNrZeouXE81BqTV0TZS0uLHIAg8w
f6j9WH3SnpM1A0rn2E/tQRPvhE1yU+IOp/6I+dnjW/y/auwgqsiIg596cnSJaaovTT8nugitsV7I
homPBXjOt3JgvDukw/9i4weorAGbRjbKv6TUrsZ0CwpH+ICz1l0GpYLeL4E+mRMu2OGPAFSOWY8y
S1C6YKMpsMjTh5fwqoBAZbma2V5upm0CIpGO3zrwOq/cKAu3gKY/uqeiLv+vBO7fmFUu+POxPsyL
KoWyPrCFzQGjSV5FXzdYdHAgsx68Og7/gwl4iNOvq27w3+V8IKNEFsGegLdRQkWDXjGfIPfXxvMF
i2f5RHGEbJE0y68VpoPh2XRvT2qgQKFmfS8a+svrSwTFhLnwuxYns5henMt3nzmu1inu5DYhHxDm
yf/0Hoe67LPi6gPbLcw2+uPM7aVUW5CTI9wktWxaJJhDJgu2tsGktDkuC1DLXvmfQihD2OH5Y3mL
RsnFVC1sxM9vk76oZKDLaR873RKcV5cVaFgPKE3x3NK4JpohgZHq/rN5IbdoI0xSAXWHiprFRGCE
dej9jNACvfg/oqGdkxNVnL47JJIvvbDLbfM8A5R8XpHKtbLQi6N8vju0AwAAKmDqTprAgghSMwbm
JflXk5mp4OidsWK/fh+xyeAzk75hzve6gOGdLKJd2YMlb5QMnqpexz09sPHPMpUrdZJ7lJLeW5xD
BK4NajZSbgHCA+FcoPWvo4op9Q4+65VRnYt89o+5PMYoAnhxiVDSCkQu/IwKQIwArOcTth6/7Hsu
OZLoDhMACzCTRAnT1vPvb7K72cVYwH0yNmPi1omiU+1pksLMET/JAZdVwbadte8JjD3x2LPLdWWL
CKWJgq+RVJnhbD6R+YXYk1OzZznRVQfjbCzhG7kXx7wn8ujqxm4YBlG8JHCcu8Un6lFdfqkLy8Mm
AImVwOS5LPFkgcUHvBfeBu4E+P6zibMGq1aUBUvRtOtL1AL3cDAISSZxCwveZtE3JA9wCOyULV4i
SixhpHB0iTE5AEJWSm06tnU+nvC0FLNgV1uPYyobwsOglhye/U+jBwGtxMlCCy+YlYqmZywLY7RK
sy6R2x2+uAoasquIk8dWmbSKYvpTR9i/KRg3jcm98JlLpsw0h+GN+woiWlI8BqkH1w0B6bx2X46G
NPlqUFXAjXMXM61RVbVb7ylzHqdEwbTyTbVsCJLoeoT2exYwv+rFw0vnrIQVkFMAKF9YFIftdFIE
hDrkszHMcfAeTRbeE4lsA1j+e6tCOAbVeGiohrPHV55jK893ES9OszLqrNyrWNEtW07AtIPuv0Z4
Ya6zye0nA82RkxRbubsW54S4053NxD9REB6XXdTItxW0BJ9E2PWlqia28t7wqOqmBCRk89HRydLq
ska6k5w7dbiYXWaLEDsRKUdzt2y0t4XfvoWSAfJxC0/XCVRhEz5UHyTiLZ+3Iyf3BmWCJ+kj/Nhe
tfhsAOasPW4XKKWkQoC67WLADTm8U1LfBcCTahO+YZkfhe/PfdMRJeDJyHKAc/vFEO9WAzx1oT80
jA8lNtjdHnAlud+tNjM6d8VRGi69DTzg87smIw/luPNn8b7D8wgvAf807imbpiHEResNckl2Ept1
Ie9Ieb3lF1T5ExGs8Wz+TQ20Ofe0u+l9mwTGjMv5aXahzJdNjSmtRKAEYykHQCNSr9hQsYoQs3YB
i+CuuDgWATn/A6BWLL2R7+S2y88qeLt0ORsx3GwHsBZcX5gaxrzF/dSnFzarK6vljAPHlDD0vOW0
j1iORoJF7RTYMXWqKqz+SVHNc/VOyKtA5k4gCcjwq5QyZvN3N6RG+WECqhOsVDjiAYpMe3Yaz7Si
8sNXbkh7D7wxBF1POP7WApzVJtxedH1+DpDdKrMq6gpWQHdjcxTux5N9l4Mj5r7GLdSlY9EEo2U1
aGjA1AzCI1S1SkO7F+2MVBNuoWq6O3kUnpouz0ccq/er7X1swSLuuXYbyOkuj5IJNO/NSEqQ5DiF
/kePjqs3dbP2/J1JeVQLy62J6XLn+AZQx3xMgJleuxQZb/Q9MninpxzZpeaEoK6Jve3nW7Qx7DNp
Syr+zhCaOOHKwN298eaC02aahVE2kFxhdzLPaRIsmwiNYVUhw8cO5boPRh00rZFm4BwmWujlALem
YQj68ABnElESvN463H1uHMMdJZDmE8D6FeRSBzMUKs2vZimwCJcILz/YTBt7L3z7e1LRdA7unkiD
la7fKnkibGnb+6G0Plx3vLXPZkEn74eM4AwoLjDl6UwJKUYrLCMRhlL4FOByawxUOvQJVl7xV5xE
SurJzTWor2D+dIzcB5/N4sTi0IqWV5eC25DHDK/c8GsmT4Az+vrFox6IgzP7bS5REIKrg4EGbqNH
5nNTHQxxh32xLHL3tDA16BjyYysi9LzZRKsbuCjn0fY50dr/ihtyihe/M4WT/50ZwrI1sIvGgJtc
SVbcYGuLuUgVSwaoXFvxd5REVYjK5LFry9zbCF8zQFCfzSQnVIlNjcNFOHD9rnDxQ+EwD3zrZC+x
U8DvQ4CxEq+5V6fEEqbpgAHABHKkHPo+KDkYP88vJyT+TszgLY0JaGTsQdRnY0EyolMRlBDUiLSK
ACLpSFbdcRk9ynVLqSu7sRu5n/Oyn118CirBvy6C4NxHZvEec8Jan946XuyyxB6KephyqsiKLW3B
zmnKqqavfZms2KZ8T/fy2Ye3nQJp7gvIJmRxHCXs6SJ3/f3/bTuClRIMkQPv5Oj/dMYqZ2hEZWZQ
3clxBYr6GW0gTy2+rA/JWSsWonRb2zg/EE/iGasDVlwa0NM7OBQIRIvJW0q3u3zC0b9lheFg/7kx
yI/X2pCEJILaNwXru3RdwaNIN7h0+aoANUB0LfuF4J8W+wQpxqK2cAcg9i6zR5fV4G9j3XIsKm+K
Hd34rvm3DIyH+w3O6Csp0WIlNwWS/Cu+iiTDM+WoChxxedJdQfMZThN+gKajY48s4NKVwHw9Tjzj
KJPxOMtjs51IvfG6oPlnLSIsCJ6/PSU3kPFFiQ3jhKadBge8UohkmAtMeRcmOIvkg4ikPKOjq3p8
o3G8KwWR41FWlR32I1nHIbo1OqIz6LdWhJwHZQxahBauF2pjKlCtI9tFcmDNlbPp0nRj5wQbeU7/
kp4qsKSdbqeZkW1BJbPoENngKoJ+IrhdczptKM6zXNrxR7pFLxpD8mlvoM/ohErYnHCg4x0jc+hC
B5bNdokxBscJJw/HZiwaTGZNNg/oXVhZ5VRvddh+UkLOFqSzq6EDJiAMDFZ26IXYenbWkRXgezaY
wlWUMi0244DUmUXPahhL59NZP9GEu2i1LGs/WNW+djZlZQxnA+78OOouqDz9qSVshx0R/ZD4aWXQ
6REEsWYBxTRvByJYvcP9oxOAfh+3ItsDgA6PGFq6e/q+RmgI7nLJ6+P5VnEp8wjp/FW9RLiHrl2Y
7Fwt7jxcY0vaSSjsA/FiFUulKktfZAnBSTLhuN00QI05KpNnCwNLqA3+HVajRkh/Fnvkqpuf8Y/1
ihtIUEvB27faPwyWodCn/IAyBNKbwT4hmI72bTNDsfXwVAbw98NIncJByuXcA21iy5lECYf1Zxqo
B0zEzWAfF+CK0rJYjL/7DzEJuP5HuPQHet9xhSkOBYflBx00w5xpAQD2a6XI27gYXH7J7K3PWsZf
ACz5uJLkqJvYRSxXDdL4xNWRDcHKDwoYvRt430XXcobhhxaDEUxDGDq0Zx79l/t85O+aJEqBiw32
dUlmRBmtYnFGvGt4iFoz718datCHUkiSxvLlffHV+qKoaQ/DHyrDiTYc0Zt1v8O7cO7WbjmmBwuk
3m5g0DFZw7vGDCPp0mdsjBHqo9iv1X4IFpCEzY00bzhCljrXp4V2v6WFqKCPqTSuf37gb6pzsqRM
RI74u7ulqamzCkbRspp3E8HGUTyurdxb6IPmTfr9pATmvRYMZz4l5pqi/1KoxMVq+csFSd+CLXIc
hCpwztc6Gz7dIVDvRlTabSAiqGqrudK+TZfaBFU7qoRhUbgvZECY0EoFmH6O6HuJIgtDA7lFlWBp
1aqUyduW9DiqvMrwSeGKIbdD8LSif69Cb8Le3RkYC8fIGmsUNApJmvRsVWtKxOMAz0qk13gSS6ov
doADDvRKOf63UCNhBXQc1ZxDramit66i+BPUKZv4/sqBVYTHtjEQEdcJdw6+p2mlAAWNmiwq6Lij
2+jXeijnde8L/bh95ngL+BrlSA977IX+26ClKT3rwKMjwxv5BS0vnI+lGUPLI2kkd7SqIWmnE2im
CrGOHpXtck9lc1ax1HMW0quhxE/PmyfDxoc5ytJm8UjwRyPrRf9XXqlSOiaAbYYy4KMp2NPrrZ8G
G25zyEmcAXPSXVHP/NgAAv7aBbht+OIEoifOUT9MyZioDpFTMvnJ2FBzOmyPSqiz5GGKo30Fov16
ohHCQ1vYRM6MknSkcy6EbEZ74nVVM32Q6kgvUIR7V6oy4BWHB8J4fcMGnebnLfWAsk94XltBCvOH
d1T7Hs2L08H5+YzfzrZ7Mlc0ItW+JUcyu6NwTRFH1GO1t4tU1SoLeQxp9T5njhI10umGW9ec4V0/
3aXDk0t1Sib4NP1eA/jUZOkjAhnAncL/tS/D3JZ/adOtkroKUC1Zmx5gLDRK6K6jBGvtutGnE2AZ
Yya6lXpSWDNgQu8MUYUmmReTFF6VdrzN7ISBz3M8lCDgVMsinOHXjVMacUDaJh4gXp7KrrJ0FWom
aFOp7ZrUsQoLphVWuP6AIZq/twk8/dPldS1jCeS6ec/Cx8b6TKm6HE7XCywGfW4srocRI1K4xbic
23eqQmHAL7y6pyfg9meBx41+QOS9RfdlyEPY3fxE77SfKyf28HeJEBzuX/yKEbXF7z5aAbmOZ6Is
QGCQ/ziCX00YHfg/5hWiC2VXCNlepK32JheEEy7nPvfWmCeiG3WVW454Nq4aKwtjrjuqaqAAQoZT
CE7OvmPcjKYBBEkNIrCn2xdillbEfLE+z6xxcv8/4Qz5jjSGQMlpfBZQB+gSw/sdJbt2dnz4nM3J
n5ghfyGj7HWJNSDdw2zaTWTFqKyDXr5KxD8znc570+pdPIiMLmUxGJ5DokteLa0T9PVwkKxTE/Ea
qFhAsT9oBAjJ6BwdH3tMNQNWxI2E9uAnMDYm7Db0czBObXB9V6bpNjBjbsM5oaEfoNVSUbJLPnOr
rkdc0ylZMlVlbsQUShnKaeiNwfZuyzIA1ZMC/hEB0RC80L7xjNnMlIuj647o8+GFZfYnUCVYcs+B
DGTIgY26wvqUaUkczoYBbLXkfLX/gKfwzZBpsGFo6sL5OxREkodNmY7K3Wi37MRb5TDY7ITEcpd+
uBRVYPWdeeFiIzbU4F8jjSI2uTLot4q6o/jIjHX1aCfQl8kUHQtWgdRSNl3YkZHPRP8wHqQwZwV4
9OVkp9/n5DKotBxJJTMr6A4GIOwjySo4re3MziRcmLqvIq7WD1FmQGLe8Eg3vVys3w+nhkYBI/KG
f6XPEmEy6YZcuorixET+NCi62WCNB643+MflB/oOBZvHqjWK8lVRRgz3aH0Za2VBABaoVpkhA0dO
0VIFPEIdJg6JeoqNR5XPMux7MQRaZR9Ewe8k9L6sFXvcomGqjNk0Z/38uUNoXJTbv6fF6kFd4MCr
HaP5kVLyo3W8sr1uXnAFOTeep9DcQgdmQvw2X5NeFz9vM05yqqs+u92Cowljkqnu3XljRKETdD5R
f7Fx5gM0kcgyelJvy50joTDFdI4cUyaL7iHA4NbetBuinLIBiTwx+WXyMnbeAKsoNKkg+Kj94FMr
qqQH+gP2Ijb/z9ber0G64LpJ+Zl0l18rmdS+nWZdfcC3uIWfgBVuuAN5SnLRi9jd+Xzhu0DUMMWG
BPncseUe0b4pmV4W/hWa78Gj5QcfvVu8hnNrNO9NZBGsjGFYyDh4yrsFl4LRd6UN9YtOh6cezvUU
J41CIRH6F5R208v8a5Y7SeD9VZU56BtPksDJvtPCnfTNJcryPwmIBKwtnajnljw/M6LkowY8wAjz
SZQshpEP1giQGExkiaRPNTU812s2NYT7AL6LpQ+6QMqMgdJDoXV6bN82Ygvqif85X0yM5GU+ASYf
+cPu2mYxj1l+bIVoa/cNoSNaMo0BzO8PPa25CkrC+39Yy7mV9DX5UGnEJS3JF0DXhOyJ16CuFRX0
SQRZFKQSNtTtkBQEiRJkaxOIkExYiG1Kj5AU+VkCuJCfPbpGw3NmUDToDcxHnallJbbYK/QoAoKA
qpiLL5aDU0hw81EpEOuf20n+MAK+R3+/fsS4x64p1UauyU20eM88zjJ5ubPuQtnSol0t5Qvmdcd3
jHVdAAjxYgNTzY+u6aiNMD7sLp5/aU9FgtzY0agNcjnc4AdgufCRde8w3YhIcD2QCy4ezw4zEa57
OcOJQ9MyZygoytYQAAG+X0f9h+NI6BXudRSu3THoo7iPWoItW9qhzbMyMuuMlBe5Keurq+Ff1gtq
fezDLVpcqvPGbNJH9NvaZsxzuNPLYDHZRBeV/Wttr05KxCGhK4XIyfmPls0+8h9LVaCqkln2ckwc
Aw3XSnKMh8fIVReTIQnRqJ7y1x1brQ9OLUkwVJTYDHKpvFEokL/4Jrr5ynWjutlFksI9UlytBW1f
LfYsCzPHEDlQ/kFX434vOB6Yc+dYBNyCJJXun6H6sxedXTuwPNAQO0MdX+Na1DXAnuQIgu2Wq0NE
bHuj5zgMH3ZUSFAeSZQY6dgpEaLylPxDFgmPNd8EPnm8vEMIUWA3IzedNyGIVn+NJ0dXnOaPzRJ0
lVWeB9W3AzM3nJVCNRJoOE2CTafVvkARTohdDEwY57ldOw1PazWvC93bRwV7jwPWVmNM72+KsqXk
14oQ3+tbwjCjFV7GthW+Ts+oEImqWSCENFj2oEgsZEnGWeMLR//XtvKqHY8A9Q+KkMquRQq3WD36
d4L5TB8aLJicKasUaNl0EnGbA83gBTMx+qbIKSlu1mI8VpQ1Qet52o61GQaoGRklNIHLrGNEhbEP
mubtY7a0dzQsgZylLBWmcjAaOlLDUZYPzd7aXmyzUKMcLAoq3VhNSpOF2mCSXbFPUKWzQ4biKRAP
AI3O04evpCSlOsXxV/LP2EoatwbCdRDLFkCCLYR3vZOQ29OlbSesu9mTf5h74Xk8DVDyxKx1ka/s
m1ww/Q45OH4BjIijwbjLpooWm2kSsmdFFoj4NY1Qo7D9vkDT7UXyNvA1COKiIzNTRaGfzKl8Zhwe
vwKRbMJQlQC0Gn938UjEezcovWW3EcarG8ouNoEMiwXzFt9ImnmlvxOgW8Jb58ip2uqHM5+kA+mk
L3PABti7Gx2LgC5ubTUP7cxZYtJratBmhUoxlsVpztq0O6EMvrwn8wy2HcEnaWHnAsa1Sz/JHDDL
A89HXZfUHh6O2a8xkzt3PH4sGN+NXAbNqodYAXF8HRm2r8o96B7CkFeGcNq3kUyXRJrFMeCxTBjR
eOmYITgsR7gAzzZ8nAXLe2CceKb70R1oQ+Dyr2Io+XQ/4oQm8y2eH++z6qNE4wvhKjQT7qenlTPm
VpkNuLaZTip9p1HXHvGKnIEmzyvR3iqL4ZQsSktRyV3IbBW/1FRfN5yJSy5vCxPoNyCpt+9QbhnE
gt2Be4ukJ4qRD6ctTDLpJyynhfpXhJu50IB1rCkj7EWH5RN2Vs8nas1T40EJNcRH83LmgxtingA4
qYy/Ol8yES2t6tmqtajusLLVfQJsE9XKZ42zWsd15cvsfWr4d88t2qDH9l3pSoyHE7ZDYjiyJ/De
EKoXJlWJQvFrjRpyGYIA350zdTArErgPMpF2RahKefyPCjVvwePhBJt50EXDTWb+HBPMupVEhosU
LmfP+StKPuzFysYam9Ok8Cph8RKpBfAaSe+4LFiu56g/XDnjH3tQ94uDyR7iOH0sk73+oqF/DrOo
uAuH7VNnp4VjxzkLbafY/oqTfl7FWsn659onDjQYnHg27+JiA28H0WD4qT7F2wERv6SbfL4om0+l
mA1Z2Hj/U/ui35MyECPOMdTxljSu7cXpgmnWLdBPdTO1YEuCGIj2Mc54VcTECWPceW1KGi/Ht0u8
zu5Yh0pe+HiI4ThFbAbT2yES8UEytqS/5Be02JsPcPb21ofSpuFbMBiJi4XtW++l330iRQqm70bj
+/Y7+i1AJrSCQhQs/uYp+VAN9p34fQk4Vd6rnMXGEPvXxUhC825UsZUQyRKjvczvCBduFfJeEdrC
wMshQOPbgnPQEaP3vKXw7xSOjtWHhXUxZZwkUjhtp00dNqT/E33HMqQkF6VRcOSPfPf9yEmTZ2sn
P98SRHnwZm1ZhOBs1484k+IQr/nS7CTOLpNGiv/0PjMZI7DEpt5G8wRd2Quz9c2869NnknvPqxxj
zHeDK00CP0ByR84rZJcifk2e+EXv3F3twqvhkiOz1YI0FHBsl/IKvNn3mZp1wtvz7/qLNA4v/iWO
D93grDIjOz7l/SB7EFcB+9KSezlCIk3ajIxXS4tBA9IMFQJA1e5JEaG82i1h0p31WhpfXG+1IYOk
JeeBaPT13e0C6FOTQeRviS4p2UtTdX/nO8fmRooeu2D9WERILRNPsbI+ZuGo9J5uC2yPOPoh4q/+
cUat7wuIU//Dc1uStoBoZqlF1Hg/Aeugcj3EIicnZYAb72ti3SQ2wxKoprf5HIy31kQmnM9e+YQm
LuzbRZ6uqO9Gwg70/Igra1QZXj16+CFqJDCcrMtWTIUx5Fb5ziRy3UuPpyT/hX+AepFaxn/k6gfG
ugN0lZ8TRQ78F8XnZQi+E3HGb57RBfx7zVwa5tRVUWpjC57Lz1bGUeRgI+cHKxW58rj8S6n+Y8mO
CrOFEoiqxX9mSNeN+rN2mMAqckqqexsc9D2O6P0GZ22+LdbjUv+mnukUAHsZ8s4uddt8AjCvLqug
Qu9LouVP7rBQpwuBEdKm6vz6OA6l3lyVubTE09R52LQsELxYu4p2Dg5M01oy8wv5m/vPWn/8MMvi
OmQo1vA8aoFwdN7HrRo8+hXgkTj413TGmH66j/pVZ1zDAYdlQspPSRk0swtF7j/X3X7zA7SeyvaX
4lHqSLDW5npX9FppSq2f3S+EaCL8+TEWD0GSPYcxU1zEcRwgInKM9iXvelSQSXN/9JWVJunXmEPD
2z1z9QXZErbwq+Mn6HLQgbS/emp9vn8clpdJlX7j3zLi2RMzcIscr3IuM1uESk24leW6tfRYc3bZ
Om5aFgIVoVajSOARFnpGdlJjhadfpRt+NjynRjyzNCeHA3JMfVReJF+NRYCBOB+wWrwv+sa8iKrK
kqokYPRSZtY1QwRLckOvDQ4Lmp5uUPQBl1ObS31WixHxQT9Bfz20mpphn4qv9MIlFWV2Sv6heWpS
xorO1cyoro8FMHSagq0TjwQv9I64/S6zbLa/oCu1cSE7iygu2zUlUp9YZluG4rUXjBQNcEVeau2c
NZKuoMiwutDGE9t9GyWEs8jf4GEcfYzqOn8kRUDfE1Wd0YxcB0RCLUwqGQrZpEbzjOv/P+qRt45t
GNiEpi1wsWad8SgtCwWRp43vNe8kvw5aO7uEln1vs2bSlv81+0HOuZCv6rAG3E54MeYSIOMDM4I9
MOhGn4nGGg4MpiP7jRHE7L3muvGQ2GIUMbF9ump1IADeyw66xERdlpPng++EpCLXuRu47fXN3Gus
Zqs460nX5ixqyeyMS3AX0XP4SH7O6rVSVoK+Yj9a40gq2+XuCvhJ9S7OVT42qvOhB9y1miGplSH2
kg1fmDhWgZJj/GrRNqJ052wiMhcH7nG9dIq9Kwpy9GrWoq2aR8y059vwieB5EhgA9Pq/atCLeg+/
hPhPrlt5gLuAYMIMotlGgBvFaiHCfgz2YxeuTHiEtZM+zyBTdmetV1SpyeX2t7dh9RMH+kxQAWch
fBgB7WwvE6WzCNk0X648nOgRXoCEm++ZAT+Imnn8H8qgUyM80XP+45h59gpAR6VG9h0uyl8RPR+9
S1b4WZpDbV4bZR3K+bKKUl659RNlXJBn9QJ+76U6lhubTFcoh6pXAmYGVpJJCE9VN8WQWVHydomv
SWuowCObp161WGFtkswQWU7HOOLMpMeSr9SSvVUq0csSBKYT7hWuX4pDLBNb7creO5sSlx3M04gU
fvj9nzIm+Dqze9tC2url+70LSGKOQs++TRdY9QgMy8I8b6py1qavsHt22OMjQE0YHSqZMJ3B9Al8
LB2lkByPuiZfL+/k3VjrtUtSJOa+PEy3ciJp9OWAr9fkVHYb8fZsGpz5tSvu4KnuxQFyj/56c8rQ
xazqBBFF2g2C5nZSHqmv400b7aa5SoW62Puz8ZlRy+v/psve0jQ/rgHUeYQzyn8yGAdFz8yz70do
KIO44sqMWm23c3OfyIjCboW5SZAQExfo33JdCtkv6f56LxymyZc99DI8SDCj168/m0Pw7SegR8Ta
Q1WNRQSp7ZVNPVT8EKWNW178t09wNXas8LPdQNdkssbiRfq02Mu5rIVyLBzn1IYgMR7uR59Fp5My
ZFnSlH8VJlBo3KsSD09f50xIj5d/DdU8/KKIfwwFkkW40S+L2YAoSZ2e51dyafg+izk9TiZR1eQz
GDIf+cimYu1aqi//J6gvC/SmK/cwapBqYjoC7VhEgHvDFHWV/W69xRx+7XInyEmRXnHCe0Uuio4C
ZnELXVr1CAdz1LQ/A65tkT22SmaAfgzPVZcPTljoFPC5b066fsQ47w8dyhVUUgxmp7utSeRAF0jA
r43+omGkdx2i0hjMh1dDAmMHwI5CjXrmataEOCfVhQWCBAYGssOOJ5cDhcjOqeWWR47ITpz0QBz5
PeOCVOiL/nug/FpYeQANkoxQPhAxjAhZDKn9nDbp1OM9f0KyfysF2LHGRVS6Fs1h8cfMTMugl/ta
tQ37qJE2AJRJLUdfcZBmPkoxCxPOULZaW2W2guG2sZ/jfE4jX2Wu+5ckxDg4k7sLIcH7MSqU0pvJ
8dhUOXa4bBE4ZGPjN6dnxyhfBivZg1NdCBwXtU+WXBqEi4F/CjdxIh+nbe9n1aW4JHWlpwpGoZHV
WbAHsrIYGbhNCWIeTbO59CWjdwsLwGCeZIx5sCBHCbDhN6tsSK3Z7b6MsqfDBUfms/M1UogHMZOe
4M+2Q84XeAHTnucoLnLiNGJG9POPsjH1g/vwTRJ+Yn/5SThHKUh6KzsNiUyySbAv+rkFL3OzrYDG
69zS6VR+JoB3vlew2ZkEsJChe4PPRnZClhiiiBssJHBU98GoKEY3E3D77X2kbIFIpxIov7jQtCa3
zCulRpalf1FeHpaD6G2LmmFh6izGZt1O3rZvjyiEG48964f2jFpuWruJCB9YICUVR8ZppybEqeED
27QbijMbhGUu7vCLTU7ZGxPtgGHuw4ena825BV8kf6AtiLHAxROnAHSVSUfEGHsobUZU5VOacely
83gJsaXJDYaXkdXJmpgfrby1qpY49ARuGYHq1ckqXr8H63cJXGt42YRZ8GMy7PTBMzcyClV/FhDt
GKL934bJElxFFhUpYfMwvYHfGvWGEKtHIvj8Xx5L7Pahts+B1R3s5IBoBhQfv9Y1lqXVykNezphQ
QTPynmEdj2nCNXdwzIgGYfWyJZBUBJMA/wuqanvPnwRKVCkCb4toA54gkoHPZauAN9TKkM+BA8WH
MrkqH4NGvsaFt9NONsNXblyIlzOYG6IKkkaVrL3y7fwKUxetZFbTDDX8Yx5gQhH4ftjNbNAMRNQT
/VHBQYtwtBAxAtNIHsW/OeA4uDO9ONa+eHnyveFKAdC101c8929N10ycsPDlPzfj/jLmJ9e0hd2V
JBbBD7/dSOp6u7JkLmMU2204WZ3wr5JhMJurPzTzvYBrnUjclg+8ewxeptz7i4gxUEl1PDTbT1SG
6xaLf32wJWNzrvLN8Zt5/Z/BXfmUWU7BbtZYqKTiWaDlfgZwhTvJCF1pwhEOLTlkfWgurzqJlrRJ
kYySCH2jiIUCeEF3b+MRu5TP+CHb/HbgmuDFqVd5n4vmr3IvgGT9f2EPqxFRoBBoAgpd5PJmPwsg
huRzbyPlSavNnB5tFYs6W3wAMUA2Wecwf/xHgpeQxl3UEao8UcZykh1R5H/26N7o/gUatXkqtzyz
bxpCmqjo7juJ+t8tNOenvCbNtdI0o9czhFglueqXEpyTkw1Ko1AR5OaEEqDOGpo6qu7dMvGzRyno
0eTdCpvII9DsN3DNh5VyNO7V/I6KZHN7bweQDfrq5L8exB1o0wLAbsDc8aSjRbFU0OxXN4oKwiYH
90FqiNuLcBNCxn3uSWibiyw+Mm08h30nQEwGumIQP12iyHjR0DGvyc706ytCS23/jY5qdeulzxFU
9JA34e2Pnp+cNF06y9Al5BJhRCA9o7H6m0nj35oA4hIAoFwFnUGlnGUjxlx4O3BtCvZaiaI4XpmW
7FCcdl2QWs9jCqo7lVcL1Uip3F32HDSXkLkYO8naOi7QY98yAY7ZXqjN07joq1IrND5B/wgLIHMp
od5KaL+b+0Fjd7L874KUiLOvP0CjDa8DpAeLB2qYPtN2vidIF6VoKztCZ88mFZJbI7f2CrwirzYL
/bCBqmPLIISbDmbya/ZaF2rzc1wRNPvml2ha2mxD81xJlM4b62TKS7/3qYxCeVKTzMsn6I9ulyv4
0Mk1pFpw1OuqBpyzbqm5NzJWo/I30iNYbrwfTQ6agkqGEwoanPVhyb9HICKp1vDUTyT/HCByGxuV
XHaWQIftau89GXnuJVk6zjj3il7mE8GA8shoyAXda/jOu1Xtitb0jdIoiHWVo3QmD+H5khhjxMNw
edySAMukOIl9Yd7xJK45LCNGVR8saryL1OElAGUZj6t96pxsVoAUbvWn1ouLLcLJ2tLxnBRopkai
wWm7HrFAQtT1Iy61Yn56TzZrmvoPLc6yoJRjEaNcIeWnkbihZFMliMn7iJPGm3l8i0EYdAA5G/TQ
CVf6jZHynNyrlopYZ9RhgnM+PZrFfZLZuZq3YL/1b51n+QIW8FCs4OhkrZgOrucAKDzoonkmIt2S
6h9h6BXLPFT1DBLgF5QBwF4Z6EeiuECZPtgwMlE6iPVXFDWXEhU+n43Df9aIyt/r17fs9jaT4lxJ
VYDN8wwpbCvyacYKGfSdRrl9DF//tx3yQdSwNdpKNuvmUeXPGkZ3o3aWM8nQomNuZ/i3+1McimtA
yoglQXgblkXoB+1gu1/dYywuY+FZig0ZACyfBjnZaTWXYFD1HXRji0gCdgTTv+l06pmPz2ctPOf/
2MOecZ7Y8lqZC1WO7xwFdW/HcIDjNNxkLJ5Xkpk3QmdL39PjfFOXZtM0kZhZqBraQunxxLk1HoWK
SfaY0heEpyc66SoQMwXIHGsJ6dR+36l1+I7BY/BzORDh1tZcbdttX8+iinAOkHw06eCt+QxmItwx
c8TivJYeGZE8EM193HXHI3II4uG11Xa5iCgFRpUXIykLFCY9z74kJ3T86nCaRwBSlUOChPwMVByk
RY3mxJ857EDX6JJC0asmXAUZEOG8y8CsqsQl4t4tEdRKdJVktD6w4KOAqG1TF/G9CS3/iHReb+3Z
W3lufhqpuh+M9Hc4YWCyt43qHC0Oq2nZexKUv4SDPZrmdqBUFg+J62aeGL7X3CfUuGj17AKLkBBR
AMXj3+BHVVytow/ZIlH0DqcU9HW1oCtMR+jJEnc3Xi/eqXsoeWShbEPTeQA1d27s2p3rZQOBZptC
Gi7rjN3n43fTlY8RdQba9d2qHJNeYDtAjssydKk2yZx6u2Kj0Hp5b8q2QgWbq6lxHIKzSN+4aTS2
q1Z82IVEsEDOJOoPAcRjankVmbhheUNP9WBTP89s0UvNz6b0J4mjL6PsCbQLabGBa8o8wuSFhud/
qUG6dMkg7lDH+/JHHNhVuvZ6hKxL0uvxcXa7hDX9aMjOoTNNAprAwdYh+ZNbMoQFmpZwo11kAQV0
33CX8daXnGSaWPe7Zw2fhBQ8IMnP0wLiQ7xt3lLytB9GTtvNntltH1qG/+AwbEGLNkTiv/J5Yro+
hCwIo/IMU5nKie9P61u2aUMZLG8+zYsgrfS0ICUGygspvu37GyuwEqVAhA+YqpxPqtY15X6ZskrT
JiJu66O8XYDBH6cynLwRa/x9mdnRxmUSlUBI9JUj4iaufi5/S/Dg26xZ5zm62odVFo6xjtHzYPMa
q7fMewCEOjVxJ1MRJyNgY2QddVK/g4QhPlCKkfeXkxc1DalcHAh1AAcFmu179JNWCNBadzlyaBdJ
JR+dxgXWDpeO+jwp9m/Fa1mksbnMulEC4XR5NPcjMeonFLRARR/cSXq/Nz9iFc56LULES4lCnELv
VVThyLaikTj9GUon14XwKP8GTLH2QwSJs1hwgcFmDomDZR2wbbq1hpTqRC0RkSyP85fvjiFyF+vz
i3LXpi8FW8FtwVA5iYnZDeezS4YCpu/O0SC2Homm2a30gzbtDntpkQANKlKhRzVWCovQ7vlvwTsf
AVFi+WrltCqtDpV6uuHJL+HpsnClxGpIc8efPwBpNDotiEGgYlGpH7v2XJ1rsDT8mJffZR/cWrLA
50o8nHIpStl9XNZ82QgnpfPq1BIP7CslWUe0X9cd8jIQHbyBszvZ1WgfoyAT91SR75ZBw2zPT3vW
UAYGGBwPFKw+9gL8csZPTQbDPqYrVeYOtSKbRqWCENneXYfXKAU4f5hLxFWcwtL7+iNc79I1ot0A
GWUxqanuWYYA1f3f3dOS8+Uqb8oNWf8WoedGk7OVaN1/8B7LGM0FZ/4SGXxnxxLXE9dhqZdKc87K
8awKO0/T1Bn3mha9RO4RUfhwmkvSGumkhsMPg5WkHRF0Cxao3x8+KOh6KkmfaFvvEIXtkeEhbSSD
+APwDAkhDTiP/U+IRkf5ZxYeP+w0oBVb6piLo6DmXwwwSrslyE1rHqO8YoT58mO3oMiZgL6kh12j
enTvDRk0YK55XMp6Vr8KouFGj1AuuHc5SrRo/Jzf+TGsCD32XOhljCe7k+pwDKpErJ7NLQEzdGRp
eaq6TbfFOOtBxLEA+kKOGs0O+RmBdqmQovi0mH57aEXf7aFw1aBiQ6BMXOKILZNXqNB6L+VrkWB7
8haUfCjMVPnAbdADvlGDv0J+oNI0JskjCusGNZbSVCQtqEwLkywcFv990hnbLMtbkGbGLoqlKF4s
hx2fRcajMcEosht+JoJKlOg4T1nKuwuKVbIBqysf3wD6MUqgZxgA0AX7h2XUcJ0PtkMXCMMexfIq
g0+qV7Iy2SqKOKrLJ+++gSEYWbHFrVSbECzIzwwiyZihnjvSeBAYhPGz4xlgrVolzmUEHwsacz8c
2tjwUQI+MQH0MRnKp6qKA8uAmsjBjomR+FDNmgasTFKMY1VeyEQ5XeL+HmOA0QHJ5J9YPd4MzUto
77wGkHm1PGyzirHTO4j3jRIwwAP0lW/wm/b04jol8UaXjedqYPC+pZUr4FOSWtMKVU5oLdJMTjMB
mY9luo46+ruBvZgYhVLGvTYqMb9DsEdBR50qDUa+7Z9w39pti9ccmJg6EWs3N0IUbbA7xkS2HOvx
CBdkWG4uEKPtM0b+UQCHA/LIblL90obGJKKGnPdFpQ1SGQNEwTnCsTuTxF52UJ5ZHE1RPGzJTY7E
JeQz5pwujcnMe+K452ox9AbpWF9ez5bbsdo7uY8WxaBO6JBpc6JRZudJcolbKyltBU6a9QoXX2Wd
eAaPaT62OXYMzoltuTMBJAXQ+8dya7RKWwQ5b54p/xj0ncSnlB22OQwxKk2j7LYfkRqv6h2XZKrh
KpcKo6cfVaUbIf9jqElumOy8kGoxK5KMFi+FSD0fhW6ileAZpuF5++IjOKFIm6mpzcUv1GXzH1u0
RHC3oSa2L7/6hlXZWugxoqItoW+M58W+iE7LMGTGbuk46yOsiS23b49DrQlZ5vsTEq3rgvIys/Tl
X9ExBhxgWAB/Ak96RTVjB36xXi5iIb9WkRvR4X82oIbpTJonAKVQtb9C0x1iMIgH3p/HHjf7pAZG
pxp9n/C2HZNW+WATDQbL4NwqF06zK0yIL19NnoFYzj3GbYD8rCr/dqWuIqf/b80e0DdWhUROTqei
WIJirJJjC/vzMJUXGA9Sxkbx6Lwuw/NrllvIFQiTf2QF6xYShXNzjMOGZqPmhE/K0tTlIGWrk7xf
L4NfJYUPoLTC6socGcuiI30hJi/JrVqVRbGTx4z3mTQi/pEWu63HymvvGyzIAse1GzvEzcrkuiU0
RUZGWeLedlATOgtVjUBp7tZjjFvhZb9xbWpGD27Xg5tXQLgXgwEmcZmYFjwGcxrEuzJD4IArhHJd
JmoSNcdF0bv5SY/pxyGxdKwrCxqWBRDPZ4dHTH3ZDEZlHy/1p1LhweyW3sqCqXy85XU5KYOyDYW6
WHIRBqPh+Vzb0WkVlDU0b/myY3CtjtSEnXFatgIcz4SSoBj7LU5oJiIZXedLkHLCwIQ9Fk6xmLJE
r43YQiOw+he6E3oPiKxgIYy5ihwRyKBpPOkVn6THaxDmv80a/BEYh62WT2NvomIGWI1b7U4FZkNq
/69p2kfode2I312dy85l1+QS4VVcoVUFBPHwY4xI/rCZtGgNs+aHNifP3pU6EmSLKLEIeK8zs902
wgdq3vyZCms2Ddj9By74OmW5a85M3inE7qWmSUZZVpqX6MeFTVWnmmyfOX3zX/h4XxoiQco7jPo1
+pqcNTofYwK+po2Mz6H72dx8ZewoGYYjqBCUjovFj1bhHkf9yKMWSK2cfI20d7+8fU4bzPzF06Ih
ALwY5xeap/VIvwLncopsmDNFMqjHI4hQsksEPW8dy12y5uw0jRJ4AArEWDJH7/EyTCSIQ/oWItGg
XTCNL4atCQPZ3Cs9w2Qrb/kbFhk5xC974k+RxoGGgrTHJ0N0/8MQ9A8qd/fm33saFulYrx7/Hm88
V5HziyMlH1sfw/rNf4jXuRj42sSqTchsf0CgTvoaMg1W5OMu4JOhWveAo8HbMTxcPvcMNjGV4ZRx
eMgy0IhDrI+KafsElATkIamN4vSa4vHDd1sLi8WM5YdbAZpKx/c1RmsFNBJ04QhaMEIrw/bqe9p+
cmj59ZgpeERu1bGSriNxpY0Np6ld8GAdlIsQHd2yKUU0wf/4SdyRuryDdPOlIYBaxr57YYs8j8I3
nr6E1DVF9SSLcPQCZ6xq14m0pCIIE6xLw0lyzb3uLd7b1OPcmKGT8qU+zVsb/RwXkowIoXNTv+i7
PFfEektd6OMIXQT3zKFRcCxchXWgiv3+/6apelJfkaB2gLHuzDXH6qdNEnZ9LDxk6BfeJ1FZHRKu
UL4ZR25IVETAyFWnBu/Ez0UHdRbMwADFh47C2MkYB/Fh6I5x+0V5V3GSBY1+Ztf5QxbeIAPWDxby
9he889xTstDLU3Zpt6NpTJctEaDBSTYxJVMFVG1UAQV72fBM4BNenTgHjY6c/F2wA14qMURTJMxr
KvLd2A6sY2UiJqxiT0TLHPkEiNfQt1mYKM10bD9nmbIZIqrMFn5OXewUsFQ0pP53mCAdofM78hQ/
KyGJSK5IS6sG0IY/+t3xgCvJXMiGQzUUS0AvdbWv+UNkdCn3d5wYlMhSYo3seoxAVqEgRy1DKB1k
zhUhD8UqMoyCU+JgaFogoiNDEKRS49OHtLlJqShCo9KPqCiH8sDjfOQUizpVSrZn1ylEzZ8RQhXu
qQbtFIZwwtXt1nw5KzX8NQ7pUsCgVXsrdvHQeYxPsRL+PBUoYPNWfU0UH8CvUn0SbOriiXSrRcF4
0VfUXMwMKUh2OkFwQOBNN9XAW8nrh6jtLFUFOBOfrqHCl8TGGqkE4XfZvQgy/4Mn67SDI5wuQUAl
VL1Q/LMC1mr6gr7sZjjv2tRyJXCS7dfa/TS19x+cXQIwI7x/mR8S25LsMvodo1tuG2a6Uzr8A9SW
H/B3JqDO6GKUHK2tRExmpald06V8PPl/R8kh3vFchfaSJQB1tDLFo23EubJtnFSv8rA0ZiLPIb2A
SskttubP2es2sCTctwp54CEvphPt++faG3W/2ieqNdSq3txVdQZQooJeMD1zMhr4NtBQ/BaSXArh
bQD+6GqrrkNpXiSQhtc7k+McEc1GMR8VHNYHuyD/j5RBeNcVMXfaRvHkdCtMLzHXEYKManQm7Kz1
ttuDI3I6OKFwLwSRARi8b6iq6PzOOkNp84TptCYA38NfvTLDJZIZdnLUdPD7sfFZLG89W4hG213Z
hUZcCOQNvhhhQwG3zjMjMuy3MdcYHq48KailKpdhNXeYqPhe/tXXYJbPCIhcltbpRyzwklBs5e0V
0CUxIJ9jpOw03M5Y2QrY/OBB6wykuluSl85z0ioQVC93FvEaENztJqwAH2Di8jAWFfMZnL3CfK+X
7kKGqlp40LbNaIShs/YNFgeF9iarohJhvzs6CDykJuh0flqkAYVFsCIP8RPqhI0EgXWPIEQVOD+P
Rv0dCvOP2HqgjQC+jrxUAIRzIyjuMcm8NdPt/l6FpSo1Xx4agicktuVTB4u9AwAVc8+qphfh0IYQ
dDTcCVXX5+Q0amvi7DDcr5X1XmR+qrfQDsp/ZjUOWMwGIIatnqXdiPMKL3CJmOICkcugjz11kSWv
wdx1zwVmETmh4oQElJmeAb0SDI7JzqlBz6FiEVeUbr7mUTmMxZqVhlpv53OtF4A9x1BsauUQArC0
1sCh7ibnTCcEDZRrWAvCYz+DL4dTYQASzFHdqt4ShOa4TrKjK/oSAKx7iyvv3JIe1S/luYUpdBVF
73S1+V9MJpsd2VpO2KAHybJtTgAWu1LpqzWEjtYc544wXvEm/Qsxnwpbq7W9jwED8Rws0h4Fx/YA
2qll2OA6oOtRDzAYA0zhkHqcBLqwLC2TOmMEpALO5cV/DMLYajhfLPnMkSKwqqwEwbBh/XEfLHNk
Eq3V8OtkRyO1fZdVOf2QZkdh2t/tgZ22cxzOnyW3ZkMU3CA4hD1dLaDQnDHfn5fveGZpZ737cIbn
Xn8fUNDk/2Xb6BWCDeM65PdMH3eyWSSxWLAlRWXwcUEPPXMPVbYoZ5uZXLIQTarEjYBiR9fjjSdy
Q0FqhefGc0SfEMqUvHDK/2xavDl33moYhgEfIGS+5vRQBAu7M+rI4b9W8B2pB9iuwZBXa+az4/dz
dvGPMtDwiBHJJ8SYpPLkX1fcjIztjUO6jPar+eSVkZXlLboHt6/uNndTrcybRO8isJ67z8TWVJdT
s/dSrOcX5OvdKFe5VtfIxP/s020+qgrTKQaUF4rG/5yk6rFvU8TvLJloWKRFOk6LFZ2QGHQRuwNd
UqdvsL1TJWHOE3G7NXugWEz8jdQspEvecgAmG86rpcN8ARKjPe83xBvauyUzcGX4mg8A4f66rxH1
NnRsV/BDj8FLk8a7PaWn+mvpt96n2i7SnMsVGgonG57RAWEQIxOtcjIJX9LaF3ADjC7l15k9anOa
HRUEhWPXHy5kgyQKmls+euEcvAG1MstZ1exz8/RCTQt5xuO+Qm24yj0BFdJAc3t0nxXGvujISHYZ
mhqe2F1hQDJ7zfSCQ17rOQzHkC+FKSIICo9JtD6GaL/PhSEz6jMiJkqpSWqaELBmykNcS7dKfX+E
VxPt/2QnlTIR0rmreqhxHEPTTccL5sTRAMJd/0qh8yjW/DwUTX6Ix6poQbTdIXLwQVb5RNEP/oao
nopVFYwZVVUtXL3CC9vG6a9r41sKLk+dQSlcaoGLUrkozE83A7v9zNjfvLv8gkLNgPzgYv6Fip5F
rKNIRKe2ls2gyFf3jme26miJZqgv2m6JXKxpaxkFQpoR3Qd3yltEslldWS1iIn7iFQGqI1toJily
OIrpzqknzNVDs9mi1553RTz4hylmIkkNnMHIwj8JwJUqRPfqG3hO0hTtbW5JmdO/IFiHhXqmkSlf
YOsRN4PaMd4eXQ7fcITkFqm1RVJTKtfveJl/owda8zN3/VHfPJfjgYGeAPvcvbnGnJXmsLi2XJ4H
AaOMOYUo3dLFTQcQPlkt2EXU6ug9KHHtIownp+vgzpdBUuJdqM3qKEc3adXwhtNHz2sXO7FEB172
JCkNbRsoeEF03yIoiF2Pni+wpk40bmF52oQ2jbIiMlEHQb45pQCiNraaestDAnDECz4d26TbzH8K
mREPDkHZvPVSy/FsZgGP8N8Mqi1PDAJQ0OJlNwrrn0Ec2+YyUHqFB9Uxqy/6+X6BH5NIoIzd8eU0
3LiE1aWLE4QSkmAwlyF5827MSbI1YdGoF0Ytirk3eLedHDW+WWPQdBtCnuWeoRnNkxsmyLzGUvPL
1BlhZKoinE49wY+U8Mw8w7BoZfJsSgNcDuJ6VUPMwzp53gTLvzU/HtHOp2SX8XRsMPhkj3cRCkc2
Wj/gI7zVEmU6ZuI86VrPFBd0DoRyj3Se/1/PYuf1oQJ0euIY3oYvkgn7nzgR+7iDSVA5Tksmctzr
CyWb6kvwsGBNq2v20uk/Jj4zda1LbVbewtWrvjmtI6PKLC9oPtjV5li0mmRypVDogn1X+Z1r/OEH
oudPFGtj+gVNNZjteqt1jISBa4vAvi8JwyMZ7JtsDQeorURDD99w+4q42upC0Pul+vjmG6stJYRl
aUxETetE+LpdpfKCtl/9GHkAVWznrGc3h0sazsQeTxJHhTdzeZp9aJEaV9tPgEpFnFnbiZiEwa+z
56QUGSB5Dm1dQhexsvNm0jc6WDDRdQHChPSt49dELT7qOUzAlDXDaxjX9UPgDVnlYRTJnYi4pZTa
27rvRZgZJKFBETx8450EJ8iFraAb+wV9r9jqDjxRGCa07g+dq0lj4SxoKxonB35z8xT8CmsIfp/H
Fhei2BPhUasC9qLJ19tvuJbBdb9y9fP2z9SAH62hRATMmjlUXn8xlyLjJ4d1R9qYD8M/iuckYLcE
B94lhzp9MU0m3GyKgiYkHddX0Gvrc1qwYFP+zbyBmTeZjZaF1qJTNiYTqGvpwDK2ys+l4j+pMYDt
gmZ6nwhqMSDJfSvX9Tsud7BTJzYEEcrqf93YxwyjAzAGS8zuRFiFgttZ6BgUn/i21qJpBmIq/7XY
nDt7r9HVeAEDUaK06AztldN8ERdN3hrcPQti/GVZU13MgshxXl911GqpXxn7HpHjjaOqI8CJZVV1
bn4P/BbLHYAacy/8S6ZGBPfCEHy0U+XJ94p1bUPaLpj3irmMzQCFrIzgDKK3FH7OAqOjWlYB5Go4
4vzE21Jj1EIvrX+zpZf0chyBtC9HL2fY5zuQ1L9YCZEss50EmK7p9qSHsj3qB0dqu7GhYSVLr1j+
kd8LcFXqvVwWmV/cpDJXkgXroFvNfkLaON0nw1Dip33A0wXzsKOyoMZAgx3m4gk5BF/DuJUIp3+k
qHIOHoMKzYIzshmlnLxytykn0+n1T58VlTaCK3jWFjgqyEsI4QC+yOby6a2eGO/mjyrk2ObC2Ba1
RF3mQ/sFXVthOwGm9EugSfE71PMiYi+FOUGp3cHxT9rsitIxY9arK6Gqm/UikG+VlXbPlu/vgWXh
C6Z0DNcxg5JotGJNRL9Kf1mMpbyt30dPzB5MgHl59yStmg2i/Q2IaaLnNDCC3AF+xXDBLzoJf8Oj
RKTcfeFImcJP/r3/pNmUwa9F+8IFI7/rJswa8j7jR0WT85p+6HNtFX+TPtpBbLRXyxU3JuOGRwLc
7JQqMo21H67JWjscyXlk8oj26FiLtru9SsAQVlTMO+ODemkTYvF4ENLF4pXKHfIoaXGczMIkFcXP
TGryDX6OcpQ1Vq2ADtIlAR1+ksOTLGa9mc3lSt7Ek86hWVjc+F+fSCu2svuW4IMHgLr2kybFEi41
trCgMYTPHtt1ypl6S5cBijMfu9w8hSEjPOBw27SADbqq0O10qo32WzlTEbfFNkgfTNyzAYoY+2F3
+P/t4O3sW6edpIMxoEMYO4txanAXBe/Vr0txmWc+FNmdj736XCP7lNbwZWY1eOYhi2LNOhcSxSVd
Q2xc3W/acC3PqX1YC23XIgHsH4yqyJgbCwbIaAb1NfFkla0jBTv24Avqz1Iewc4g4xpYl1wervu0
DcMeMm0nOFlSejJKMhyjcuce2D3uKvR0qbiAmkuw926Aq5ou6ngkiFQUw3M2fK4yEWMV9qFL4tOQ
8l5R9Nsx+ioMX05HNc9v3m+adlj5o10LWgIIUeR3HqydX/bcyIXjVH+7lU86YuiB5c6f3dYneXVF
iZvotR01qQjv32taMmkF+fUrlgbkVlABepA99Ue+hdhwMf4F7WLTpnsc5IO/fOE3YBb+kIwIAwj+
bIN2XVrbURfCw58IDzzDyS3bp0y78dlMg1pqaopHkf8e+LasD90Ir/Fd6d6ftUpaisrDEqOH2rqS
VWVZS5Jm9wecBHwWzFZJHtwsbBPrcBaARiJKbHKqIAzGKQY5TpnJWCn+gi8VTax1RgCrhqtfvLNV
xDmBriQOpLecYrzjCePXJl2BY5TSM9Kt83eVz1fJa6TCpVc6frQaN0N9om4YtFEHPNiSm7R4d4/Q
VTbI7ShbTf+w0aUWZFQfmxjgCowghj6zueyae4aJTV1KuPwWCss9pYkdc4K4wKuL/jjfXNmPu8R8
0a9iahZjgSQAeCPZKVkW0dzy554=
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
