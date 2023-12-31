`timescale  1ns/1ns

module  key_control
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   key         ,   //输入4位按键

    output  reg     [3:0]   key_select ,     //输出波形选择
	output  reg          key_en      //按键脉冲信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   key0_select    =   4'b0001,    //第一个按键
            key1_select    =   4'b0010,    //第二个按键
            key2_select    =   4'b0100,    //第三个按键
            key3_select    =   4'b1000;    //第四个按键
			
parameter   CNT_MAX =   20'd999_999;    //计数器计数最大值

//wire  define
wire            key3    ;   //按键3
wire            key2    ;   //按键2
wire            key1    ;   //按键1
wire            key0    ;   //按键0


reg  key_flag_dly1; //延迟一个时钟信号
reg  key_flag_dly2; //延迟两个时钟信号
reg   led_reg;

assign key_trigger_en= key_flag_dly1 &( ~key_flag_dly2);


//  判断是否是产生下降沿
always @(posedge sys_clk or negedge sys_rst_n) begin
   if(sys_rst_n == 1'b0)
     begin 
	    key_flag_dly1 <=1'b0;
		key_flag_dly2 <=1'b0;
	 end
	else
	 begin
	    key_flag_dly1<=key0;
		key_flag_dly2<=key_flag_dly1;
	 end
end
//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//wave:按键状态对应波形
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key_select    <=  4'b0000;
    /**/else     if(key_trigger_en == 1'b1)
        key_select    <=  key_select+1; 
	 /* else    if(key0 == 1'b0)
        key_select    <=  4'b0000;
    else    if(key2 == 1'b1)
        key_select    <=  key2_select;
    else    if(key3 == 1'b1)
        key_select    <=  key3_select; */
    else
        key_select    <=  key_select ;
//wave:把脉冲波形传递出来
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key_en    <=  'd0;
    /**/else   
        key_en    <=  key_trigger_en; 	 
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- key_fifter_inst3 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
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
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
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
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
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
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst0
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[0]   )   ,   //按键输入信号

    .key_flag     (key0     )       //按键消抖后标志信号
);

endmodule
