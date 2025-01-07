module rs485_key_led(
    input           sys_clk       ,    //外部50M时钟
    input           sys_rst_n     ,    //外部复位信号，低有效
    
    input  [3:0]    key           ,    //按键
    output [3:0]    led           ,    //led灯
    
    //uart接口
    input           rs485_uart_rxd,    //rs485串口接收端口
    output          rs485_uart_txd,    //rs485串口发送端口

    output   [7:0]  rx_out_data         //rs485串口接受数据
    );
    
//parameter define
parameter  CLK_FREQ = 50000000;    //定义系统时钟频率
parameter  UART_BPS = 115200  ;    //定义串口波特率
    
//wire define   
wire       uart_tx_en    ;    //UART发送使能
wire       uart_rx_done  ;    //UART接收完毕信号
wire [7:0] uart_tx_data  ;    //UART发送数据
wire [7:0] uart_rx_data  ;    //UART接收数据
wire [3:0] key_data      ;    //按键数据  

assign rx_out_data = uart_rx_data;

//*****************************************************
//**                    main code
//*****************************************************   

//将2位按键数据编码为8位的串口数据
assign   uart_tx_data = {4'b0 , key_data};

//串口接收模块
uart_rx #(
    .CLK_FREQ       (CLK_FREQ),        //设置系统时钟频率
    .UART_BPS       (UART_BPS))        //设置串口接收波特率
u_uart_rx(                 
    .clk            (sys_clk       ), 
    .rst_n          (sys_rst_n     ),
    
    .uart_rxd       (rs485_uart_rxd),
    .uart_rx_done   (uart_rx_done  ),
    .uart_rx_data   (uart_rx_data  )
    );

//led控制模块   
led_ctrl u_led_ctrl(
    .clk            (sys_clk          ),
    .rst_n          (sys_rst_n        ),

    .led_en         (uart_rx_done     ),  //led控制使能
    .led_data       (uart_rx_data[3:0]),  //led控制数据
    .led            (led              )
);

//按键触发模块
key_trig u_key_trig(
    .clk            (sys_clk    ), 
    .rst_n          (sys_rst_n  ),
    
    .key            (key        ),
    .key_data_valid (uart_tx_en ),     //按键有效通知信号
    .key_data       (key_data   )      //按键数据
    );

//串口发送模块   
uart_tx #(
    .CLK_FREQ       (CLK_FREQ),        //设置系统时钟频率
    .UART_BPS       (UART_BPS))        //设置串口发送波特率
u_uart_tx(                 
    .clk            (sys_clk       ),
    .rst_n          (sys_rst_n     ),
     
    .uart_tx_en     (uart_tx_en    ),
    .uart_tx_data   (uart_tx_data  ),
    .uart_txd       (rs485_uart_txd)
    );

endmodule 