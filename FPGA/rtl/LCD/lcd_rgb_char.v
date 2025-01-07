module  lcd_rgb_char(
    input               sys_clk ,
    input               sys_rst_n ,
    input        [3:0]  key,

    input   [7:0]       rx_out_data,         //rs485串口接受数据

    //RGB LCD接口 
    output              lcd_hs  ,       //LCD 行同步信号
    output              lcd_vs  ,       //LCD 场同步信号
    output              lcd_de  ,       //LCD 数据输入使能
    inout      [15:0]   lcd_rgb ,       //LCD RGB565颜色数据
    output              lcd_bl  ,       //LCD 背光控制信号
    output              lcd_rst,        //LCD 复位
    output              lcd_clk         //LCD 采样时钟
);
//参数
parameter CNT_MAX = 25'd25000000;    
//reg define
reg  [24:0]  cnt;
reg  [3:0]   led;

wire [3:0]  signal1;





//wire define    
wire  [15:0]  lcd_id    ;    //LCD屏ID
wire          lcd_pclk  ;    //LCD像素时钟
              
wire  [10:0]  pixel_xpos;    //当前像素点横坐标
wire  [10:0]  pixel_ypos;    //当前像素点纵坐标
wire  [10:0]  h_disp    ;    //LCD屏水平分辨率
wire  [10:0]  v_disp    ;    //LCD屏垂直分辨率
wire  [15:0]  pixel_data;    //像素数据
wire  [15:0]  lcd_rgb_o ;    //输出的像素数据
wire  [15:0]  lcd_rgb_i ;    //输入的像素数据

//*****************************************************
//**                    main code
//*****************************************************

//像素数据方向切换
assign lcd_rgb = lcd_de ?  lcd_rgb_o :  {16{1'bz}};
assign lcd_rgb_i = lcd_rgb;
assign signal1 = led;
//读LCD ID模块
rd_id u_rd_id(
    .clk          (sys_clk  ),
    .rst_n        (sys_rst_n),
    .lcd_rgb      (lcd_rgb_i),
    .lcd_id       (lcd_id   )
    );    

//时钟分频模块    
clk_div u_clk_div(
    .clk           (sys_clk  ),
    .rst_n         (sys_rst_n),
    .lcd_id        (lcd_id   ),
    .lcd_pclk      (lcd_pclk )
    );    

//LCD显示模块    
lcd_display u_lcd_display(
    .lcd_pclk       (lcd_pclk  ),
    .rst_n          (sys_rst_n ),

    .rx_out_data    (rx_out_data   ),

    .signal1        (signal1),
    .pixel_xpos     (pixel_xpos),
    .pixel_ypos     (pixel_ypos),
    .pixel_data     (pixel_data)
    );    

//LCD驱动模块
lcd_driver u_lcd_driver(
    .lcd_pclk      (lcd_pclk  ),
    .rst_n         (sys_rst_n ),
    .lcd_id        (lcd_id    ),
    .pixel_data    (pixel_data),
    .pixel_xpos    (pixel_xpos),
    .pixel_ypos    (pixel_ypos),
    .h_disp        (h_disp    ),
    .v_disp        (v_disp    ),

    .lcd_de        (lcd_de    ),
    .lcd_hs        (lcd_hs    ),
    .lcd_vs        (lcd_vs    ),
    .lcd_bl        (lcd_bl    ),
    .lcd_clk       (lcd_clk   ),
    .lcd_rst       (lcd_rst   ),
    .lcd_rgb       (lcd_rgb_o )
    );


//计数器计时0.5s
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(cnt < (CNT_MAX - 25'd1))
        cnt <= cnt + 25'd1;
    else
        cnt <= 25'd0;
end


    
//LED控制(根据哪个KEY被按下，和led_flag，对LED进行赋值)
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 4'b0000;
    else begin
        case(key)
            4'b1111 : led <= 4'b0000;
            4'b1110 : begin 
                led <= 4'b0001;  
            end
            4'b1101 : begin   
                led <= 4'b0010;  
            end  
            4'b1011 : begin 
                led <= 4'b0100;
            end        
            4'b0111 : begin 
                led <= 4'b1000;
            end    
            default : ;
        endcase    
    end
end      
    


endmodule
