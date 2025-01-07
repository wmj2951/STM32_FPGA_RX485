module  top_file(
    input               sys_clk         ,
    input               sys_rst_n       ,
    input       [3:0]  	key             ,
	output 		[3:0]   led             ,       //led灯
    //RGB LCD接口 
    output              lcd_hs          ,       //LCD 行同步信号
    output              lcd_vs          ,       //LCD 场同步信号
    output              lcd_de          ,       //LCD 数据输入使能
    inout      [15:0]   lcd_rgb         ,       //LCD RGB565颜色数据
    output              lcd_bl          ,       //LCD 背光控制信号
    output              lcd_rst         ,       //LCD 复位
    output              lcd_clk         ,       //LCD 采样时钟
	
	//uart接口
    input               rs485_uart_rxd  ,       //rs485串口接收端口
    output              rs485_uart_txd  ,       //rs485串口发送端口

    output    [5:0]     seg_sel         ,       //数码管位选信号
    output    [7:0]     seg_led                 //数码管段选信号
);

wire [7:0] rx_out_data  ;    //UART接收数据

lcd_rgb_char u_lcd_rgb_char(
    
    .rx_out_data      (rx_out_data   ),

    .sys_clk          (sys_clk       ),
    .sys_rst_n        (sys_rst_n     ),
    .key              (key           ),
    .lcd_hs           (lcd_hs        ),
    .lcd_vs           (lcd_vs        ),
    .lcd_de           (lcd_de        ),
    .lcd_rgb          (lcd_rgb       ),
    .lcd_bl           (lcd_bl        ),
    .lcd_rst          (lcd_rst       ),
    .lcd_clk          (lcd_clk       )


);

rs485_key_led u_rs485_key_led(
    .sys_clk          (sys_clk       ),
    .sys_rst_n        (sys_rst_n     ),
    .key              (key           ),
    .led              (led           ),

    .rx_out_data      (rx_out_data   ),

    .rs485_uart_rxd   (rs485_uart_rxd),  //rs485串口接收端口
    .rs485_uart_txd   (rs485_uart_txd)  //rs485串口发送端口    

);

seg_led_top u_seg_led_top(
    .sys_clk          (sys_clk       ),
    .sys_rst_n        (sys_rst_n     ),

    .rx_out_data      (rx_out_data   ),

    .seg_sel          (seg_sel       ),
    .seg_led          (seg_led       )

);


endmodule
