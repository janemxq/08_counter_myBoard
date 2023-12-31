`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/06/12
// Module Name   : tb_uart_rx
// Project Name  : rs232
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_uart_rx();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg             sys_clk;
reg             sys_rst_n;
reg             rx;
reg     [7:0]   rx_data[7:0];  //8个字节的数组
reg     [2:0]   rec_byte_cnt;//3位 0-7
//wire  define
wire    [7:0]   po_data;
wire            po_flag;
reg     [1:0]   enable_Pulse;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化系统时钟、全局复位和输入信号
initial begin
        sys_clk    = 1'b1;
        sys_rst_n <= 1'b0;
        rx        <= 1'b1;
        #20;
        sys_rst_n <= 1'b1;
end

//模拟发送8次数据，分别为0~7
initial begin
        #200
        rx_bit(8'd7);  //任务的调用，任务名+括号中要传递进任务的参数
        rx_bit(8'd1);
        rx_bit(8'd1);
        rx_bit(8'd3);
        rx_bit(8'd4);
        rx_bit(8'd5);
        rx_bit(8'd6);
        rx_bit(8'd7);
end

//sys_clk:每10ns电平翻转一次，产生一个50MHz的时钟信号
always #10 sys_clk = ~sys_clk;

//定义一个名为rx_bit的任务，每次发送的数据有10位
//data的值分别为0~7由j的值传递进来
//任务以task开头，后面紧跟着的是任务名，调用时使用
task rx_bit(
    //传递到任务中的参数，调用任务的时候从外部传进来一个8位的值
        input   [7:0]   data
);
        integer i;      //定义一个常量
//用for循环产生一帧数据，for括号中最后执行的内容只能写i=i+1
//不可以写成C语言i=i++的形式
        for(i=0; i<10; i=i+1) begin
            case(i)
                0: rx <= 1'b0;
                1: rx <= data[0];
                2: rx <= data[1];
                3: rx <= data[2];
                4: rx <= data[3];
                5: rx <= data[4];
                6: rx <= data[5];
                7: rx <= data[6];
                8: rx <= data[7];
                9: rx <= 1'b1;
            endcase
            #(5208*20); //每发送1位数据延时5208个时钟周期
        end
endtask         //任务以endtask结束
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
					/* rx_data[0]=1'b0;
					rx_data[1]=1'b0;
					rx_data[2]=1'b0;
					rx_data[3]=1'b0;
					rx_data[4]=1'b0;
					rx_data[5]=1'b0;
					rx_data[6]=1'b0;
					rx_data[7]=1'b0; */
				end
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------uart_rx_inst------------------------
uart_rx uart_rx_inst(
        .sys_clk    (sys_clk    ),  //input           sys_clk
        .sys_rst_n  (sys_rst_n  ),  //input           sys_rst_n
        .rx         (rx         ),  //input           rx
                
        .po_data    (po_data    ),  //output  [7:0]   po_data
        .po_flag    (po_flag    )   //output          po_flag
);

endmodule

