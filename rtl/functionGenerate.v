`timescale  1ns/1ns


module  functionGenerate

(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位
	 input   wire    [1:0]   pulse_select         ,   //脉冲通道选择
    input   wire  	uart_flag,//是否发送脉冲标志,脉冲信号
	input 	wire  	[15:0]pulse_width1,   //第一个脉冲的宽度
	input 	wire  	[15:0]pulse_width2,   //第二个脉冲的宽度
	input 	 wire 	[15:0]pulse_gap,   //脉冲之间的间隔
          
	output  reg     pulse_out1  ,       //
	output  reg     pulse_out2
	//output  reg     led_out  
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
parameter   CNT_MAX = 25'd24_999_999 ;
parameter   KEY_CNT_MAX = 25'd999_999 ;
//reg   define
reg     [24:0]  cnt;                //经计算得需要25位宽的寄存器才够500ms
reg      [1:0]  flag; 
reg      [1:0]  pulse_flag;     //脉冲标志 
wire           my_clk;
//wire    [3:0]   key_select ;   //按键选择
//wire  define
/**/ wire            key3    ;   //按键3
wire            key2    ;   //按键2
wire            key1    ;   //按键1
wire            key0    ;   //按键0 


reg  po_flag_dly1; //延迟一个时钟信号
reg  po_flag_dly2; //延迟两个时钟信号
reg   led_reg;

assign pulse_en= po_flag_dly1 &( ~po_flag_dly2);


//  判断是否是产生上升沿
always @(posedge sys_clk or negedge sys_rst_n) begin
   if(sys_rst_n == 1'b0)
     begin 
	    po_flag_dly1 <=1'b0;
		po_flag_dly2 <=1'b0;
	 end
	else
	 begin
	    po_flag_dly1<=uart_flag;
		po_flag_dly2<=po_flag_dly1;
	 end
end

//********************************************************************//
//***************************** Main Code ****************************//
//3,125 是 大约 60us  521 是 大约 10us    2 是大约 40ns  
//999   是 10us （myClk 100Mhz)  5 是  50ns，要求最大脉宽100us 间隔最大10us
//********************************************************************//
//cnt:计数器计数,当计数到CNT_MAX的值时清零
always@(posedge my_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
	 begin
        cnt <= 25'b0;
		  //flag <= 2'b0;
	 end
  else 
  begin
    
    if(pulse_en == 1)//||(pulse_flag == 2)
        cnt <= 25'b0;
    else
        cnt <= cnt + 1'b1;
   end
//pulse_out:
always@(posedge my_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
	   begin
        pulse_out1 <= 1'b0;
		pulse_out2<=1'b0;
		 pulse_flag <= 1'b0;	
	   end
    else    if((cnt == 0) &&(pulse_en == 1))
	     begin
          pulse_out1 <= (pulse_select == 1?1:0);//1;//第一个脉冲开始
		  pulse_out2<=(pulse_select == 2?1:0);
		   pulse_flag<= 1;
         end
    else    if((cnt == pulse_width1-1) && (pulse_flag==1))
	     begin
           pulse_out1 <= 0;//第一个脉冲结束
		   pulse_out2<=0;  
           pulse_flag<=(pulse_width2 >0?1:0) ;  
         end
    else if((pulse_width2 >0)&& (pulse_flag==1))
	  if((cnt == pulse_width1+pulse_gap-1))
	     begin
           pulse_out1 <=(pulse_select == 1?1:0);//1 ;//第二个脉冲开始
		   pulse_out2<=(pulse_select == 2?1:0);           		   
         end
	  else if(cnt == pulse_width1+pulse_width2+pulse_gap-1)
	     begin
           pulse_out1 <= 0;//第二个脉冲结束
		   pulse_out2 <= 0; 
		   //led_out=~led_out;
           pulse_flag<=0;		   
         end
    //看看第二个脉冲宽度是否是零，如果是零，就不进行下面的操作了
	else
		  begin
		    pulse_flag<= pulse_flag;		    			
		  end	  
end	
//------------------------ pll_inst ------------------------
ipcore  pll_ip_inst
(
    .inclk0 (sys_clk        ),  //input     inclk0

    .c0     (my_clk      ),  //output    c0   
    .locked (locked         )   //output    locked
);

endmodule