`timescale  1ns/1ns

module  top_functionGenerate
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [1:0]   key         ,   //输入2位按键
	input   wire    rx          ,   //串口接收数据

    output  wire            pulse_out1,     //输出第一路脉冲信号
	output  wire            pulse_out2,     //输出第二路脉冲信号
	output  wire    tx     ,         //串口发送数据
	output  wire    led_out,  //调试灯
	output  wire    relay_out1 , //第一路继电器
	output  wire    relay_out2  //第二路继电器
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ,   //时钟频率
			memsize = 7;
//wire  define

wire    [1:0]   key_select ;   //按键选择
wire     key_en;    //按键触发信号
reg      uart_en;    //串口触发信号
wire    [7:0]   po_data;
reg     [7:0]   rx_data[8:0];  //9个字节的数组
reg     [3:0] rec_byte_cnt;//4位 0-9
reg     [1:0] pulse_en_cnt;
wire            po_flag;//20ns的脉冲宽度
reg        enable_Pulse;
reg        pulse_en_flag;
reg     [1:0]    pulse_select;//两个脉冲通道的使能位
reg     [15:0]   pulse_width[1:0];//两个脉冲的宽度 ，出现三个脉冲可能是宽度太大，占两个字节
reg     [15:0]   pulse_gap;//脉冲之间的间隔宽度，占两个字节
//dac_clka:DAC模块时钟


reg  po_flag2=0;

integer i = 0;
reg   [1:0]led_reg;
reg   relay_reg1;
reg   relay_reg2;
// 接收数据的上升沿判断

reg    [7:0]   uart_test_data;
assign  led_out = led_reg;
assign  relay_out1 = relay_reg1;
assign  relay_out2 = relay_reg2;
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//-------------------------- dds_inst -----------------------------
/* dds     dds_inst
(
    .sys_clk        (sys_clk    ),   //系统时钟,50MHz my_clk倍频的时钟
    .sys_rst_n      (sys_rst_n  ),   //复位信号,低电平有效
    .wave_select    (wave_select),   //输出波形选择

    .data_out       (dac_data   )    //波形输出
);
 */
 //----------------------- key_control_inst ------------------------
key_control key_control_inst
(
    .sys_clk        (sys_clk    ),   //系统时钟,50MHz
    .sys_rst_n      (sys_rst_n  ),   //复位信号,低电平有效
    .key            (key        ),   //输入4位按键

    .key_select    (key_select)   , //输出稳定后4位按键
	.key_en        (key_en) //按键脉冲信号
 );
 //-----------------------脉冲输出
 functionGenerate functionGenerate_inst
 (
    .sys_clk   (sys_clk    ),   //系统时钟50Mhz
	.sys_rst_n (sys_rst_n  ),   //全局复位
	.pulse_select  (pulse_select ), //输入4位按键
	.uart_flag (enable_Pulse),  //uart_en uart_en po_flag2串口确认发脉冲信号
    .pulse_width1(pulse_width[0]),   //第一个脉冲的宽度 10ns一个单位
	.pulse_width2(pulse_width[1]),   //第二个脉冲的宽度 10ns一个单位  
	.pulse_gap(pulse_gap),   //脉冲之间的间隔 10ns一个单位

	.pulse_out1  (pulse_out1 ) , 
	.pulse_out2   (pulse_out2)
	//.led_out      (led_out)
 );

//------------------------ uart_rx_inst ------------------------
uart_rx
#(
    .UART_BPS    (UART_BPS  ),  //串口波特率
    .CLK_FREQ    (CLK_FREQ  )   //时钟频率
)
uart_rx_inst
(
    .sys_clk    (sys_clk    ),  //input             sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input             sys_rst_n
    .rx         (rx         ),  //input             rx
            
    .po_data    (po_data    ),  //output    [7:0]   po_data
    .po_flag    (po_flag    )   //output            po_flag
);
		   
/* always@(posedge sys_clk or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
		 begin
            po_flag2 <= 1'b0;			
		end
        else  if(( po_data==7) )//&& (pulse_en ==1)
		   begin
            po_flag2 <= po_flag;			
            //led_reg = ~led_reg;	
		   end */
		
        
//------------------------ uart_tx_inst ------------------------
uart_tx
#(
    .UART_BPS    (UART_BPS  ),  //串口波特率
    .CLK_FREQ    (CLK_FREQ  )   //时钟频率
)
uart_tx_inst
(
    .sys_clk    (sys_clk    ),  //input             sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input             sys_rst_n
    .pi_data    (uart_test_data    ),  //input     [7:0]   pi_data
    .pi_flag    (po_flag2    ),  //input             pi_flag
                
    .tx         (tx         )   //output            tx
);
   
// 如果长时间没有信号使能脉冲，将接收字节计数器置零,防止数据错位情况，待测试。
// 产生使能信号的脉冲
//按键单独可以，如果和接收信号或了以后就不行了，待研究。
always@(posedge sys_clk or negedge sys_rst_n)
       if(sys_rst_n == 1'b0)
		   enable_Pulse<=0;
       /*  else if((key_en == 1))//(uart_en ==1)||
		   enable_Pulse[0]<=1;
		else if((uart_en ==1))
		   enable_Pulse[0]<=1; */
		/* else if(uart_en == 1)
		   enable_Pulse<=1; */
		else if((key_en == 1)||(uart_en == 1))//
		  begin
		   //led_reg <= ~led_reg;
		   enable_Pulse<=1;
		  end		   
		else
           enable_Pulse<=0;		
//串口检测命令输出使能发送脉冲命令，po_flag2有些问题，设置后存在测试灯不亮的问题
/* always@(posedge sys_clk or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
		   begin
		    //uart_en<=0;po_flag2<=0;
		    //uart_en<=0;po_flag2<=0;
		   end
        else if((rx_data[8] == 'h12)&&(rx_data[0] == 'd7)  && (po_flag == 1))//简单的校验一下 &&(rec_byte_cnt == 'd8)
		   begin
		   //uart_en<=1;
		   //led_reg = ~led_reg;
		   //po_flag2<=1;
		   end
		else
		   begin
		 	 po_flag2<=0;
           uart_en<=0;	    
		   end*/
		   
// 07 01 01 08 05 00  发脉冲命令，第一个字节是标识头
//第二个字节是第一个脉冲使能 ，第三个字节是第一个脉冲使能 ，
//第四、五个字节是第一个脉冲的脉冲宽度 ,第六、七个字节 第二路脉冲的脉冲宽度，第八、九个字节 两个脉冲的间隔	  
always@(posedge po_flag or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
			 begin
				rec_byte_cnt<=1'b0;	
				 rx_data[0]<=1'b0;rx_data[1]<=1'b0;rx_data[2]<=1'b0;rx_data[3]<=1'b0;
				rx_data[4]<=1'b0;rx_data[5]<=1'b0;rx_data[6]<=1'b0;rx_data[7]<=1'b0;
				rx_data[8]<=1'b0;
				/**/pulse_width[0]<=5;pulse_width[1]<=5; 
			    pulse_gap     <=5;pulse_select<=0;
				uart_en<=0;
				//enable_Pulse[0]<=0;	enable_Pulse[1]<=0;	
			end         
		else
		  //if(po_flag == 1)
		   begin		   
		    rx_data[rec_byte_cnt]<=po_data;
			
				if(rec_byte_cnt == 'd8)//9字节数据接收完毕
					begin
						 rec_byte_cnt<=0;
						  case(rx_data[0]) 
							'd7://头字符
								begin
								  //led_reg<=~led_reg; 
								 /* */ 
								 if({rx_data[3],rx_data[4]}<=4)
								   pulse_width[0]<='d4;
								  else
								  pulse_width[0]<={rx_data[3],rx_data[4]};
								   if({rx_data[5],rx_data[6]}<=4)
								     pulse_width[1]<='d4;
								  else
								     pulse_width[1]<={rx_data[5],rx_data[6]};
								  
								  if({rx_data[7],rx_data[8]}<=4)
								     pulse_gap<='d4;
								  else
								     pulse_gap     <={rx_data[7],rx_data[8]}; 
								 /*  if(rx_data[1]==1)pulse_select<=1;
								  else if(rx_data[2]==1)pulse_select<=2;
								  else pulse_select<=0; */
								  pulse_select<={(rx_data[2]==1?1'b1:1'b0),(rx_data[1]==1?1'b1:1'b0)};
								  uart_en<=1;//必须放在脉宽和间隔设置的下面，否则下个po_flag才能生效
								  if(pulse_select ==2)led_reg<=~led_reg;
								  //if((rx_data[8] == 'h12)||(rx_data[8] == 'h5))led_reg<=~led_reg;
								  //enable_Pulse[0]<=rx_data[1];
								  //enable_Pulse[1]<=rx_data[2];
                                  //po_flag2<=1;
								  uart_test_data<=	pulse_select;
                                  //relay_reg2	<=	~relay_reg2;							  
								end							
							default:
								 begin
								  //enable_Pulse[0]<=0;
								  //enable_Pulse[1]<=0;	
								 /* */ pulse_width[0]<=0;
								  pulse_width[1]<=0;
								  pulse_gap     <=0; 
								  pulse_select<=0;
								  uart_en<=0;
								  po_flag2<=0;
								end
						   endcase					
					end
			    else
				    begin
				    uart_en<=0;
					po_flag2<=0;
			        rec_byte_cnt<=	rec_byte_cnt+1;	
                    end					
                    //led_reg = ~led_reg;	
		   end
		 /*  else
		   begin
		   uart_en<=0;
		   //po_flag2<=0;
		  end */
		   
endmodule