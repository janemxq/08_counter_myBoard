`timescale  1ns/1ns


module  tb_functionGenerate();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
reg            pulse_out1     ;
reg            pulse_out2     ;
//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;
reg             uart_flag;

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
parameter   CNT_MAX = 25'd24 ;
parameter   KEY_CNT_MAX = 25'd999_999 ;
//reg   define
reg     [24:0]  cnt;                //经计算得需要25位宽的寄存器才够500ms
reg      [1:0]  pulse_flag;     //脉冲标志 
wire           my_clk;

reg  po_flag_dly1; //延迟一个时钟信号
reg  po_flag_dly2; //延迟两个时钟信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//初始化系统时钟、全局复位
initial begin
    sys_clk    = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n <= 1'b1;
	#10
	uart_flag<=1'b0;
	#10
	uart_flag<=1'b1;
	#10
	uart_flag<=1'b0;
end

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk;

initial begin
    $timeformat(-9, 0, "ns", 6);
    //$monitor("@time %t: led_out=%b", $time, led_out);
end


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
    
    if((cnt == CNT_MAX))//||(pulse_flag == 2)
        cnt <= 25'b0;
    else
        cnt <= cnt + 1'b1;
   end
//pulse_out:
always@(posedge my_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
	   begin
        pulse_out1 <= 1'b0;
		 pulse_flag <= 1'b0;	
	   end
    else    if((cnt == CNT_MAX-25'd5)&& (pulse_flag==1))
	     begin
          pulse_out1 <= 1;
         end
    else    if((cnt == CNT_MAX-1) && (pulse_flag==1))
	     begin
           pulse_out1 <= 0;//一直输出 看看电流多大
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
//------------------------ pll_inst ------------------------
ipcore  pll_ip_inst
(
    .inclk0 (sys_clk        ),  //input     inclk0

    .c0     (my_clk      ),  //output    c0   
    .locked (locked         )   //output    locked
);

endmodule
