module led_ctrl(
    input            clk     ,    //外部50M时钟
    input            rst_n   ,    //外部复位信号，低有效
    
    input            led_en  ,    //led控制使能
    input      [3:0] led_data,    //led控制数据
    
    output reg [3:0] led          //led灯
    );

//*****************************************************
//**                    main code
//*****************************************************

//控制led灯的变化
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) 
        led <= 2'b00;
    else if(led_en)              //在led_en使能时，改变led灯的状态
            led <= ~led_data;    //按键按下时为低电平，而led高电平时点亮
        else
            led <= led;
end
    
endmodule 