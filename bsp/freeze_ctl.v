module freeze_ctl
#( 
  parameter WIDTH=32
)
(
   input clk,
   input resetn,

   // Slave port
   input [1:0] slave_address,  // Word address
   input [WIDTH-1:0] slave_writedata,
   input slave_read,
   input slave_write,
   input [WIDTH/8-1:0] slave_byteenable,
   output [WIDTH-1:0] slave_readdata,
   output reg slave_readdatavalid,
   output slave_waitrequest,

   output reg freeze,
   output reg freeze_1,
   output reg freeze_2,
   output reg freeze_3
);

reg [WIDTH-1:0] reg0;
reg [WIDTH-1:0] reg1;
reg [WIDTH-1:0] reg2;
reg [WIDTH-1:0] reg3;
reg [WIDTH-1:0] read_reg;

// read and write transactions
always@(posedge clk) begin
  if (slave_write) begin
  case (slave_address)
    2'b00:     reg0 <= {slave_byteenable[3] ? slave_writedata[31:24] : reg0[31:24],
			slave_byteenable[2] ? slave_writedata[23:16] : reg0[23:16],
			slave_byteenable[1] ? slave_writedata[15:8] : reg0[15:8],
			slave_byteenable[0] ? slave_writedata[7:0] : reg0[7:0]};
    2'b01:     reg1 <= {slave_byteenable[3] ? slave_writedata[31:24] : reg1[31:24],
			slave_byteenable[2] ? slave_writedata[23:16] : reg1[23:16],
			slave_byteenable[1] ? slave_writedata[15:8] : reg1[15:8],
			slave_byteenable[0] ? slave_writedata[7:0] : reg1[7:0]};
    2'b10:     reg2 <= {slave_byteenable[3] ? slave_writedata[31:24] : reg2[31:24],
			slave_byteenable[2] ? slave_writedata[23:16] : reg2[23:16],
			slave_byteenable[1] ? slave_writedata[15:8] : reg2[15:8],
			slave_byteenable[0] ? slave_writedata[7:0] : reg2[7:0]};
    2'b11:     reg3 <= {slave_byteenable[3] ? slave_writedata[31:24] : reg3[31:24],
			slave_byteenable[2] ? slave_writedata[23:16] : reg3[23:16],
			slave_byteenable[1] ? slave_writedata[15:8] : reg3[15:8],
			slave_byteenable[0] ? slave_writedata[7:0] : reg3[7:0]};
    default:   reg0 <= {slave_byteenable[3] ? slave_writedata[31:24] : reg0[31:24],
			slave_byteenable[2] ? slave_writedata[23:16] : reg0[23:16],
			slave_byteenable[1] ? slave_writedata[15:8] : reg0[15:8],
			slave_byteenable[0] ? slave_writedata[7:0] : reg0[7:0]};
  endcase
  end
  if (slave_read) begin
    case (slave_address)
      2'b00: read_reg <= reg0;
      2'b01: read_reg <= reg1;
      2'b10: read_reg <= reg2;
      2'b11: read_reg <= reg3;
      default: read_reg <= -1;
    endcase
  end
end
assign slave_readdata = read_reg;
//pipeline the register to system probe
always@(posedge clk) begin
  freeze <= reg0[0];
  freeze_1 <= reg1[0];
  freeze_2 <= reg2[0];
  freeze_3 <= reg3[0];
end

// rddata valid
always@(posedge clk) slave_readdatavalid <= slave_read;

assign slave_waitrequest = 1'b0; 
  
endmodule

