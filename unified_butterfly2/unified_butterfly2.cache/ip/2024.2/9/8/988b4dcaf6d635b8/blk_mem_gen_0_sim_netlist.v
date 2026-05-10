// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
// Date        : Fri May  8 14:12:28 2026
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [8:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [8:0]addra;
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
  wire [8:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [8:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "9" *) 
  (* C_ADDRB_WIDTH = "9" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.375199 mW" *) 
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
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "512" *) 
  (* C_READ_DEPTH_B = "512" *) 
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
  (* C_WRITE_DEPTH_A = "512" *) 
  (* C_WRITE_DEPTH_B = "512" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[8:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[8:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 18992)
`pragma protect data_block
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
M7/E5uT2IhMpAvQ=
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
