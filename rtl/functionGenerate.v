`timescale  1ns/1ns


module  functionGenerate

(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位
	 input   wire    [3:0]   key_select         ,   //输入4位按键
    input   wire  	uart_flag,//一个触发沿
	input 	wire  	[20:0]pulse_width1,   //第一个脉冲的宽度
	input 	wire  	[20:0]pulse_width2,   //第二个脉冲的宽度
	input 	 wire 	[20:0]pulse_gap,   //脉冲之间的间隔
          
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

/* always@(posedge sys_clk or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
		 begin
            pulse_flag <= 1'b0;			
		end
        else  if(pulse_en ==1)
		   begin
            pulse_flag<= 1;	           
		   end
		else
		  begin
		    pulse_flag<= pulse_flag;		    			
		  end */
//********************************************************************//
//***************************** Main Code ****************************//
//3,125 是 大约 60us  521 是 大约 10us    2 是大约 40ns  
//999   是 10us （myClk 100Mhz)  5 是  50ns
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
          pulse_out1 <= 1;//第一个脉冲开始
		  pulse_out2<=1;
         end
    else    if((cnt == pulse_width1-1) && (pulse_flag==1))
	     begin
           pulse_out1 <= 0;//第一个脉冲结束
		   pulse_out2<=0;           		   
         end
    else    if((cnt == pulse_width1+pulse_gap-1) && (pulse_flag==1))
	     begin
           pulse_out1 <= 1;//第二个脉冲开始
		   pulse_out2<=1;           		   
         end
    else    if((cnt == pulse_width1+pulse_width2+pulse_gap-1) && (pulse_flag==1))
	     begin
           pulse_out1 <= 0;//第二个脉冲结束
		   pulse_out2 <= 0; 
           pulse_flag<=0;		   
         end
    else  if(pulse_en ==1)
		   begin
            pulse_flag<= 1;	           
		   end
	 else
		  begin
		    pulse_flag<= pulse_flag;		    			
		  end	  
end	
/* always@(posedge my_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
	   begin
        pulse_out <= 1'b0;
		 pulse_flag <= 1'b0;	
	   end
    else    if((cnt == CNT_MAX-25'd5)&& (pulse_flag==1))
	     begin
          pulse_out2 <= 1;
         end
    else    if((cnt == CNT_MAX-1) && (pulse_flag==1))
	     begin
           pulse_out2 <= 0;//一直输出 看看电流多大
           pulse_flag<=0;		   
         end
    else  if(pulse_en ==1)
		   begin
            pulse_flag<= 1;	           
		   end
	 else
		  begin
		    pulse_flag<= pulse_flag;		    			
		  end	  
end	 */
/* always@(posedge my_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        flag <= 3; 
     else if(pulse_flag == 2)
	    begin
          flag <= 0; //开始脉冲输出
		  
		end
	 else  if((cnt == CNT_MAX-1) && (flag==0))
	     begin
          led_out <= ~led_out;
		  flag <= 2'd1;//脉冲结束
	     end
	else 
	    flag <= flag; */
/* always@(posedge my_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        key0_Pulse_flag <= 2'b0; 
     else if(key0 == 1'b1)
	    begin
          key0_Pulse_flag <= 2'b1;	
		  //led_out <= ~led_out;
		end
	 else if((key0 == 1'b0)&&(key0_Pulse_flag==1))//按键脉冲信号建立	
	    begin
          key0_Pulse_flag <= 2;	
		  //led_out <= ~led_out;
		end
	else if((key0 == 1'b0)&&(key0_Pulse_flag==2))//按键脉冲信号结束
	    begin
          key0_Pulse_flag <= 0;	
		  //flag <= 2'd0;//脉冲开始
		end */
/* always@(posedge sys_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        pulse_flag <= 2'b0; 
     else if(key_select[0] == 4'b0001)
	    begin
          pulse_flag <= 2'b1;	
		  //led_out <= ~led_out;
		end
	 else if((key_select[0] != 4'b0001)&&(pulse_flag==1))//按键脉冲信号建立	
	    begin
          pulse_flag <= 2;	
		  //led_out <= ~led_out;
		end
	else if((key_select[0] != 4'b0001)&&(pulse_flag==2))//按键脉冲信号结束
	    begin
          pulse_flag <= 0;	
		  //flag <= 2'd0;//脉冲开始
		end */
/* always@(posedge sys_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        pulse_flag <= 2'b0; 
     else if(uart_flag == 1)
	    begin
          pulse_flag <= 2;	
		  //led_out <= ~led_out;//关闭灯
		  //uart_flag <= 2'b00;
		end
	else if(flag == 1)
	    begin
          pulse_flag <= 0;	
		  //led_out <= ~led_out;//关闭灯
		  //uart_flag <= 2'b00;
		end
	 else 
	   pulse_flag <= pulse_flag; */
/* always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led_out   <=  4'b0000;
    else    if(key_select == 4'b0001)
        led_out <= ~led_out;   
    else
         led_out <= led_out;   */
//----------------------- key_control_inst ------------------------
/* key_control key_control_inst
(
    .sys_clk        (sys_clk    ),   //系统时钟,50MHz
    .sys_rst_n      (sys_rst_n  ),   //复位信号,低电平有效
    .key            (key        ),   //输入4位按键

    .key_select    (key_select)    //按键选择
 ); */
//------------------------ pll_inst ------------------------
ipcore  pll_ip_inst
(
    .inclk0 (sys_clk        ),  //input     inclk0

    .c0     (my_clk      ),  //output    c0   
    .locked (locked         )   //output    locked
);
//------------- key_fifter_inst3 --------------
/* key_filter 
#(
    .CNT_MAX      (KEY_CNT_MAX  )       //计数器计数最大值
)
key_filter_inst3
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[3]   )   ,   //按键输入信号

    .key_flag     (key3     )       //按键消抖后标志信号
);

//------------- key_fifter_inst2 --------------
key_filter 
#(
    .CNT_MAX      (KEY_CNT_MAX  )       //计数器计数最大值
)
key_filter_inst2
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[2]   )   ,   //按键输入信号

    .key_flag     (key2     )       //按键消抖后标志信号
);

//------------- key_fifter_inst1 --------------
key_filter 
#(
    .CNT_MAX      (KEY_CNT_MAX  )       //计数器计数最大值
)
key_filter_inst1
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[1]   )   ,   //按键输入信号

    .key_flag     (key1     )       //按键消抖后标志信号
);
//------------- key_fifter_inst0 --------------
key_filter 
#(
    .CNT_MAX      (KEY_CNT_MAX  )       //计数器计数最大值
)
key_filter_inst0
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[0]   )   ,   //按键输入信号

    .key_flag     (key0     )       //按键消抖后标志信号
); */
endmodule
