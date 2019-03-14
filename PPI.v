module PPI(portA,portB,portC,data_buffer,cs_low,Reset,A0,A1,RD_low,WR_low);
inout[7:0] portA,portB,portC,data_buffer;
input cs_low,Reset,A0,A1,RD_low,WR_low;
reg[7:0] regA,regB,regC;
reg[7:0]control_reg;
reg[7:0] data;

//input output mode:mode0
assign portA=(cs_low==0&&control_reg[7]==1&&control_reg[6]==0&&control_reg[5]==0&&control_reg[4]==0)?regA:(cs_low==0&&control_reg[7]==1&&control_reg[6]==0&&control_reg[5]==0&&control_reg[4]==1)?8'bzzzz_zzzz:portA;
assign portB=(cs_low==0&&control_reg[7]==1&&control_reg[2]==0&&control_reg[1]==0)?regB:(cs_low==0&&control_reg[7]==1&&control_reg[2]==0&&control_reg[1]==1)?8'bzzzz_zzzz:portB;
assign portC[7:4]=(cs_low==0&&control_reg[7]==1&&control_reg[5]==0&&control_reg[6]==0&&control_reg[3]==0)?regC[7:4]:(cs_low==0&&control_reg[7]==1&&control_reg[5]==0&&control_reg[6]==0&&control_reg[3]==1)?4'bzzzz:portC[7:4];
assign portC[3:0]=(cs_low==0&&control_reg[7]==1&&control_reg[2]==0&&control_reg[0]==0)?regC[3:0]:(cs_low==0&&control_reg[7]==1&&control_reg[2]==0&&control_reg[0]==1)?4'bzzzz:portC[3:0];

//assign data_buffer for read and write
assign data_buffer=(WR_low==1&&RD_low==0&&cs_low==0)?data:(WR_low==0&&RD_low==1&&cs_low==0)?8'bzzzz_zzzz:data_buffer;

  //BSR mode
  always@(control_reg)
  begin//always start
    if(cs_low==0)
    begin//begin of cs_low
    if(control_reg[7]==0)
    begin//begin of BSR mode
    regC[control_reg[3:1]]<=control_reg[0];
     end//end of BSR mode
     end//end of cs_low
  end//end of alwys
//always@(cs_low,Reset,RD_low,WR_low,control_reg)
always@(Reset)
begin//begin of always
if(Reset==1) begin 
control_reg=8'b1001_1011;end

//else //if not reset
/*begin

if(cs_low==0)//if enabled
begin

if(control_reg[7]==0)//BSR mode
begin
//regC[control_reg[3:1]]<=control_reg[0];
case(control_reg[3:0])
 4'b0000:regC[0]<=0;
 4'b0001:regC[0]<=1;

 4'b0010:regC[1]<=0;
 4'b0011:regC[1]<=1;

 4'b0100:regC[2]<=0;
 4'b0101:regC[2]<=1;

 4'b0110:regC[3]<=0;
 4'b0111:regC[3]<=1;

 4'b1000:regC[4]<=0;
 4'b1001:regC[4]<=1;

 4'b1010:regC[5]<=0;
 4'b1011:regC[5]<=1;

 4'b0110:regC[6]<=0;
 4'b0111:regC[6]<=1;

 4'b1110:regC[7]<=0;
 4'b1111:regC[7]<=1;
endcase
end//end of BSR mode

end//end of enabled
end//end of not reset else

 */

end//end of always
//selection
always@(data_buffer,A0,A1)
begin
if(A0==1 && A1==1) begin control_reg<=data_buffer; end
else if(A0==0 &&A1==0) begin if(RD_low==0&&cs_low==0&&WR_low==1) data=regA; else if(RD_low==1&&cs_low==0&&WR_low==0) regA<=data_buffer; end
else if(A0==0&&A1==1) begin if(RD_low==0&&cs_low==0&&WR_low==1) data=regC;else if(RD_low==1&&cs_low==0&&WR_low==0) regC<=data_buffer; end
else if(A0==1&&A1==0) begin if(RD_low==0&&cs_low==0&&WR_low==1) data=regB;else if(RD_low==1&&cs_low==0&&WR_low==0) regB<=data_buffer; end

end

endmodule


module tb();
wire [7:0] portA; //Define PORTA as i/o port 
reg [7:0] a;

wire [7:0]  portC; //Define PORTC as i/o port 
reg [7:0] c;

wire [7:0] portB; //Define PORTB as i/o port 
reg [7:0] b;

wire [7:0] dataBus; //Define Communication Databus buffer between 8255 AND processor as i/o port
reg [7:0] d;

//Define Control Logic
reg RD,WR,CS,reset; 
reg [1:0] SEL;


wire [7:0] CWR;
assign CWR =(SEL==2'b11 && RD == 1 && WR == 0 &&  reset == 0)?dataBus:(reset==1)?0:CWR;
assign dataBus =(RD == 1 && WR == 0)?d:8'bzzzz_zzzz;
assign portA =((CWR[7:5]==3'b100 && CWR[4]==1)||reset)?a:(CWR[7]==0) ? portA : 8'bzzzz_zzzz;
assign portB =((CWR[7]==1 && CWR[2]==0 && CWR[1]==1)||reset)?b:(CWR[7]==0) ? portB :8'bzzzz_zzzz;
assign portC[7:4] =((CWR[7:5]==3'b100 && CWR[3]==1)||reset)?c[7:4]:4'bzzzz;
assign portC[3:0] =((CWR[7]==1 && CWR[2]==0 && CWR[0]==1)||reset)?c[3:0]:4'bzzzz;


initial
begin

$monitor($time ,,, " PORTA: %b .PORTB: %b .PORTC: %b .DATABUS: %b .RD: %b .WR: %b .SEL: %b .RESET: %b .CS: %b .CWR: %b",portA,portB,portC,dataBus,RD,WR,SEL,reset,CS,CWR);


CS=0;
reset=1;
#5
reset=0;//here all ports are input
d=8'b0000_0001;
SEL=2'b00;//here write in portA 1
RD=1;
WR=0;
#5
d=8'b0000_0010;//here we write
SEL=2'b01;//here select portB
#5
d=8'b1000_0000;// here we write 
SEL=2'b11; // here we select the control register 
#5
SEL=2'b00;
RD=0;
WR=1;
end
PPI khaled(portA,portB,portC,dataBus,CS,reset,SEL[0],SEL[1],RD,WR);
endmodule
module tb2_BSR();
wire [7:0] portA; //Define PORTA as i/o port 
reg [7:0] a;

wire [7:0]  portC; //Define PORTC as i/o port 
reg [7:0] c;

wire [7:0] portB; //Define PORTB as i/o port 
reg [7:0] b;

wire [7:0] dataBus; //Define Communication Databus buffer between 8255 AND processor as i/o port
reg [7:0] d;

//Define Control Logic
reg RD,WR,CS,reset; 
reg [1:0] SEL;


wire [7:0] CWR;
assign CWR =(SEL==2'b11 && RD == 1 && WR == 0 &&  reset == 0)?dataBus:(reset==1)?0:CWR;
assign dataBus =(RD == 1 && WR == 0)?d:8'bzzzz_zzzz;
assign portA =((CWR[7:5]==3'b100 && CWR[4]==1)||reset)?a:(CWR[7]==0) ? portA : 8'bzzzz_zzzz;
assign portB =((CWR[7]==1 && CWR[2]==0 && CWR[1]==1)||reset)?b:(CWR[7]==0) ? portB :8'bzzzz_zzzz;
assign portC[7:4] =((CWR[7:5]==3'b100 && CWR[3]==1)||reset)?c[7:4]:4'bzzzz;
assign portC[3:0] =((CWR[7]==1 && CWR[2]==0 && CWR[0]==1)||reset)?c[3:0]:4'bzzzz;


initial
begin

$monitor($time ,,, " PORTA: %b .PORTB: %b .PORTC: %b .DATABUS: %b .RD: %b .WR: %b .SEL: %b .RESET: %b .CS: %b .CWR: %b",portA,portB,portC,dataBus,RD,WR,SEL,reset,CS,CWR);


CS=0;
reset=1;
#5
reset=0;//here all ports are input
d=8'b0000_0001;
SEL=2'b11;//here write in control reg 1
RD=1;
WR=0;
#5
d=8'b0000_0011;//here we write
SEL=2'b11;//here select portB
#5
d=8'b1000_0000;//here we choose PortC to be output through mode 0 
SEL=2'b11; // here we select the control register
RD=1;
WR=0;
#5
SEL=2'b10;
RD=0;
 WR=1;

end
PPI khaled(portA,portB,portC,dataBus,CS,reset,SEL[0],SEL[1],RD,WR);  
endmodule
