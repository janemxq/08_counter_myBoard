`timescale  1ns/1ns

module  top_functionGenerate
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   key         ,   //输入4位按键
	input   wire    rx          ,   //串口接收数据

    output  wire            pulse_out1,     //输出第一路脉冲信号
	output  wire            pulse_out2,     //输出第二路脉冲信号
	output  wire    tx              //串口发送数据
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ,   //时钟频率
			memsize = 7;
//wire  define

wire    [3:0]   key_select ;   //按键选择
wire    [7:0]   po_data;
reg     [7:0]   rx_data[7:0];  //8个字节的数组
reg     [2:0] rec_byte_cnt;//3位 0-7
wire            po_flag;
reg     [1:0]   enable_Pulse;
//dac_clka:DAC模块时钟


reg  po_flag2;

integer i = 0;
reg   led_reg;

// 接收数据的上升沿判断


assign  led_out = led_reg;
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

    .key_select    (key_select)    //输出稳定后4位按键
 );
 //-----------------------脉冲输出
 functionGenerate functionGenerate_inst
 (
    .sys_clk   (sys_clk    ),   //系统时钟50Mhz
	.sys_rst_n (sys_rst_n  ),   //全局复位
	.key_select  (key_select ), //输入4位按键
	.uart_flag (enable_Pulse[0]),  // po_flag2串口确认发脉冲信号
	
	.pulse_out1  (pulse_out1 ) , 
	.pulse_out2   (pulse_out2)
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
    .pi_data    (po_data    ),  //input     [7:0]   pi_data
    .pi_flag    (po_flag2    ),  //input             pi_flag
                
    .tx         (tx         )   //output            tx
);

// 07 01 01 00 00 00  发脉冲命令，
//第二个字节是第一路脉冲使能 ，第三个字节是第二路脉冲使能 ,
// 第四个字节 第一路脉冲的脉冲宽度，第五个字节 第二路脉冲的脉冲宽度
// 第六个字节 两个脉冲的间隔 ns

always@(posedge po_flag or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
			 begin
				rec_byte_cnt<=1'b0;	
				rx_data[0]<=1'b0;rx_data[1]<=1'b0;rx_data[2]<=1'b0;rx_data[3]<=1'b0;
				rx_data[4]<=1'b0;rx_data[5]<=1'b0;rx_data[6]<=1'b0;rx_data[7]<=1'b0;
							
			end         
		else
		   begin
		    rx_data[rec_byte_cnt]<=po_data;
			rec_byte_cnt<=	rec_byte_cnt+1;		
            //led_reg = ~led_reg;	
		   end
always@(posedge po_flag or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
		  begin
		  enable_Pulse[0]<=0; enable_Pulse[1]<=0;
          end		  
		else if(rec_byte_cnt == 'd7)//8字节数据接收完毕
				begin
					  case(rx_data[0]) 
						'd7:
							begin
							  enable_Pulse[0]<=rx_data[1];
							  enable_Pulse[1]<=rx_data[2];					 
							end
						default:
							begin
							  enable_Pulse[0]<=0;
							  enable_Pulse[1]<=0;	
							end
					   endcase					
				end
endmodule
