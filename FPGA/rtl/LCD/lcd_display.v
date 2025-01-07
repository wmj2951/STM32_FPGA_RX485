module lcd_display(
    input             lcd_pclk,     //时钟
    input             rst_n,        //复位，低电平有效
    input    [3:0]    signal1,        //复位，低电平有效

    input   [7:0]     rx_out_data,         //rs485串口接受数据
                                    
    input      [10:0] pixel_xpos,   //像素点横坐标
    input      [10:0] pixel_ypos,   //像素点纵坐标    
    output reg [15:0] pixel_data    //像素点数据,
);                                   
                                     
//parameter define                   
localparam PIC_X_START = 11'd10;     //图片起始点横坐标
localparam PIC_Y_START = 11'd10;     //图片起始点纵坐标
localparam PIC_WIDTH   = 11'd100;    //图片宽度
localparam PIC_HEIGHT  = 11'd100;    //图片高度
                       
localparam CHAR_X_START= 11'd10;     //字符起始点横坐标
localparam CHAR_Y_START= 11'd120;    //字符起始点纵坐标
localparam CHAR_WIDTH  = 11'd128;    //字符宽度,4个字符:32*4
localparam CHAR_HEIGHT = 11'd32;     //字符高度
                       
localparam BACK_COLOR  = 16'hE7FF; //背景色，浅蓝色
localparam CHAR_COLOR  = 16'hF800; //字符颜色，红色

localparam num_0   =    128'h00001824424242424242422418000000; //字符0
localparam num_1   =    128'h00003E08080808080808083808000000; //字符1
localparam num_2   =    128'h00007E4220100804024242423C000000; //字符2
localparam num_3   =    128'h00003C4242020418040242423C000000; //字符3
localparam num_4   =    128'h00001F04047F442424140C0C04000000; //字符4
localparam num_5   =    128'h0000384442020244784040407E000000; //字符5
localparam num_6   =    128'h00001C22424242625C40402418000000; //字符6
localparam num_7   =    128'h0000101010101008080404427E000000; //字符7
localparam num_8   =    128'h00003C4242422418244242423C000000; //字符8
localparam num_9   =    128'h0000182402023A464242424438000000; //字符9

localparam txzf1   =    128'h00001818000000001818000000000000;                                     //字符:
localparam char_1  =    256'hC28234441828642842102210FE28102888A449442A44FF44083E2A2049200820;    //“数”
localparam char_2  =    256'h4884A4FC24842284228422FCE22032202BFE22202220FBFC2204220423FC2000;    //“据”

//reg define
reg   [127:0] char[31:0];  //字符数组
reg   [127:0] word[31:0];  //字符数组

reg   [13:0]  rom_addr  ;  //ROM地址
//************************************
//瞎编的代码
reg   [1:0]  number1  ;  //计数器,最大计数到3
reg         number_en  ;  //使能

reg   [127:0] dtz_1;  //动态字1
reg   [127:0] dtz_2;  //动态字2
reg   [127:0] dtz_3;  //动态字3
reg   [127:0] dtz_4;  //动态字4

reg   [127:0] dtz_5;  //动态字5
reg   [127:0] dtz_6;  //动态字6
reg   [127:0] dtz_7;  //动态字7

//************************************

//wire define   00000018244242424242424224180000:/*"0",0*/
wire  [10:0]  x_cnt         ;       //横坐标计数器
wire  [10:0]  y_cnt         ;       //纵坐标计数器
wire          rom_rd_en     ;       //ROM读使能信号
wire  [15:0]  rom_rd_data   ;       //ROM数据

wire   [3:0]  data0         ;       // 个位数
wire   [3:0]  data1         ;       // 十位数
wire   [3:0]  data2         ;       // 十位数


//*****************************************************
//**                    main code
//*****************************************************

assign  x_cnt = pixel_xpos + 1'b1  - CHAR_X_START; //像素点相对于字符区域起始点水平坐标
assign  y_cnt = pixel_ypos - CHAR_Y_START; //像素点相对于字符区域起始点垂直坐标
assign  rom_rd_en = 1'b1;                  //读使能拉高，即一直读ROM数据

//提取显示数值所对应的十进制数的各个位
assign  data0 = rx_out_data % 4'd10;               // 个位数
assign  data1 = rx_out_data / 4'd10 % 4'd10   ;    // 十位数
assign  data2 = rx_out_data / 7'd100 % 4'd10  ;    // 百位数




//计数器
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)
        number1 <= 0;
    else 
        number1  <= number1 + 1;        //计数器自加
end


//动态字567显示
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        dtz_5 <= num_0;
        dtz_6 <= num_0;
        dtz_7 <= num_0;
    end
    else begin
        case(data0)
            4'd0:dtz_7 <= num_0;
            4'd1:dtz_7 <= num_1;
            4'd2:dtz_7 <= num_2;
            4'd3:dtz_7 <= num_3;
            4'd4:dtz_7 <= num_4;
            4'd5:dtz_7 <= num_5;
            4'd6:dtz_7 <= num_6;
            4'd7:dtz_7 <= num_7;
            4'd8:dtz_7 <= num_8;
            4'd9:dtz_7 <= num_9;
        endcase
        case(data1)
            4'd0:dtz_6 <= num_0;
            4'd1:dtz_6 <= num_1;
            4'd2:dtz_6 <= num_2;
            4'd3:dtz_6 <= num_3;
            4'd4:dtz_6 <= num_4;
            4'd5:dtz_6 <= num_5;
            4'd6:dtz_6 <= num_6;
            4'd7:dtz_6 <= num_7;
            4'd8:dtz_6 <= num_8;
            4'd9:dtz_6 <= num_9;
        endcase
        case(data2)
            4'd0:dtz_5 <= num_0;
            4'd1:dtz_5 <= num_1;
            4'd2:dtz_5 <= num_2;
            4'd3:dtz_5 <= num_3;
            4'd4:dtz_5 <= num_4;
            4'd5:dtz_5 <= num_5;
            4'd6:dtz_5 <= num_6;
            4'd7:dtz_5 <= num_7;
            4'd8:dtz_5 <= num_8;
            4'd9:dtz_5 <= num_9;
        endcase
    end
end

//动态显示字
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        dtz_1 <= 128'd0;
        dtz_2 <= 128'd0;
        dtz_3 <= 128'd0;
        dtz_4 <= 128'd0;
    end
    else  if (signal1 != 4'b0000)      begin
        case(signal1)

            4'b0001 : begin
                dtz_1 <=  num_1;
                dtz_2 <=  num_0;
                dtz_3 <=  num_0;
                dtz_4 <=  num_0; 
            end
            4'b0010 : begin
                dtz_1 <=  num_0;
                dtz_2 <=  num_1;
                dtz_3 <=  num_0;
                dtz_4 <=  num_0; 
            end
            4'b0100 : begin
                dtz_1 <=  num_0;
                dtz_2 <=  num_0;
                dtz_3 <=  num_1;
                dtz_4 <=  num_0; 
            end
            4'b1000 : begin 
                dtz_1 <=  num_0;
                dtz_2 <=  num_0;
                dtz_3 <=  num_0;
                dtz_4 <=  num_1; 
            end    

        endcase
       
    end 
    else begin
        dtz_1  <= num_0;        //显示
        dtz_2  <= num_0;        //显示
        dtz_3  <= num_0;        //显示
        dtz_4  <= num_0;        //显示

    end
end


//$@@%#%
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)begin
            word[0 ]  <= 128'h00000000000000000000000000000000;
            word[1 ]  <= 128'h00000000000000000000000000000000;
            word[2 ]  <= 128'h00000000000100000000002000000000;
            word[3 ]  <= 128'h000000100001800002000070000000C0;
            word[4 ]  <= 128'h000000380001800003FFFFF803FFFFE0;
            word[5 ]  <= 128'h07FFFFFC0001800003006000000001E0;
            word[6 ]  <= 128'h0000C000000180600300600000000300;
            word[7 ]  <= 128'h0000C0000001FFF00300C00000000600;
            word[8 ]  <= 128'h0000C000000180000310804000001800;
            word[9 ]  <= 128'h0000C00000018000031FFFE000003000;
            word[10]  <= 128'h0000C00000018000031800400001C000;
            word[11]  <= 128'h0000C00000018000031800400001C000;
            word[12]  <= 128'h00C0C000018181800318004000018000;
            word[13]  <= 128'h00C0C00001FFFFC0031FFFC000018010;
            word[14]  <= 128'h00C0C060018001800318004000018038;
            word[15]  <= 128'h00C0FFF001800180031800403FFFFFFC;
            word[16]  <= 128'h00C0C000018001800318004000018000;
            word[17]  <= 128'h00C0C000018001800218004000018000;
            word[18]  <= 128'h00C0C00001800180021FFFC000018000;
            word[19]  <= 128'h00C0C000018001800210304000018000;
            word[20]  <= 128'h00C0C00001FFFF800200300000018000;
            word[21]  <= 128'h00C0C000018001800606300000018000;
            word[22]  <= 128'h00C0C000018001000607370000018000;
            word[23]  <= 128'h00C0C00000000000060E31C000018000;
            word[24]  <= 128'h00C0C000001000400418307000018000;
            word[25]  <= 128'h00C0C000020830600430303800018000;
            word[26]  <= 128'h00C0C010020C18300860301800018000;
            word[27]  <= 128'h00C0C038060E18180883700800018000;
            word[28]  <= 128'h3FFFFFFC0C0618181100F008003F8000;
            word[29]  <= 128'h000000001C0408182000600000070000;
            word[30]  <= 128'h00000000000000000000000000020000;
            word[31]  <= 128'h00000000000000000000000000000000;
            number_en   <= 1'b0;
	end
    else if( number_en )
        word[0 ]  <= 128'h00000000000000000000000000000000;  //
    else begin
      word[0 ]  <=  { char_1[15   :0  ],char_2[15   :0   ], num_1[7    :0   ], txzf1[7    :0  ], dtz_1[7    :0  ], {8{1'b0}}, dtz_2[7  :0  ], {4{8'b0}}, dtz_5[7  :0  ],dtz_6[7  :0  ],dtz_7[7  :0  ] }; 
      word[1 ]  <=  { char_1[31   :16 ],char_2[31   :16  ], num_1[15   :8   ], txzf1[15   :8  ], dtz_1[15   :8  ], {8{1'b0}}, dtz_2[15 :8  ], {4{8'b0}}, dtz_5[15 :8  ],dtz_6[15 :8  ],dtz_7[15 :8  ] }; 
      word[2 ]  <=  { char_1[47   :32 ],char_2[47   :32  ], num_1[23   :16  ], txzf1[23   :16 ], dtz_1[23   :16 ], {8{1'b0}}, dtz_2[23 :16 ], {4{8'b0}}, dtz_5[23 :16 ],dtz_6[23 :16 ],dtz_7[23 :16 ] }; 
      word[3 ]  <=  { char_1[63   :48 ],char_2[63   :48  ], num_1[31   :24  ], txzf1[31   :24 ], dtz_1[31   :24 ], {8{1'b0}}, dtz_2[31 :24 ], {4{8'b0}}, dtz_5[31 :24 ],dtz_6[31 :24 ],dtz_7[31 :24 ] }; 
      word[4 ]  <=  { char_1[79   :64 ],char_2[79   :64  ], num_1[39   :32  ], txzf1[39   :32 ], dtz_1[39   :32 ], {8{1'b0}}, dtz_2[39 :32 ], {4{8'b0}}, dtz_5[39 :32 ],dtz_6[39 :32 ],dtz_7[39 :32 ] }; 
      word[5 ]  <=  { char_1[95   :80 ],char_2[95   :80  ], num_1[47   :40  ], txzf1[47   :40 ], dtz_1[47   :40 ], {8{1'b0}}, dtz_2[47 :40 ], {4{8'b0}}, dtz_5[47 :40 ],dtz_6[47 :40 ],dtz_7[47 :40 ] }; 
      word[6 ]  <=  { char_1[111  :96 ],char_2[111  :96  ], num_1[55   :48  ], txzf1[55   :48 ], dtz_1[55   :48 ], {8{1'b0}}, dtz_2[55 :48 ], {4{8'b0}}, dtz_5[55 :48 ],dtz_6[55 :48 ],dtz_7[55 :48 ] }; 
      word[7 ]  <=  { char_1[127  :112],char_2[127  :112 ], num_1[63   :56  ], txzf1[63   :56 ], dtz_1[63   :56 ], {8{1'b0}}, dtz_2[63 :56 ], {4{8'b0}}, dtz_5[63 :56 ],dtz_6[63 :56 ],dtz_7[63 :56 ] }; 
      word[8 ]  <=  { char_1[143  :128],char_2[143  :128 ], num_1[71   :64  ], txzf1[71   :64 ], dtz_1[71   :64 ], {8{1'b0}}, dtz_2[71 :64 ], {4{8'b0}}, dtz_5[71 :64 ],dtz_6[71 :64 ],dtz_7[71 :64 ] }; 
      word[9 ]  <=  { char_1[159  :144],char_2[159  :144 ], num_1[79   :72  ], txzf1[79   :72 ], dtz_1[79   :72 ], {8{1'b0}}, dtz_2[79 :72 ], {4{8'b0}}, dtz_5[79 :72 ],dtz_6[79 :72 ],dtz_7[79 :72 ] }; 
      word[10]  <=  { char_1[175  :160],char_2[175  :160 ], num_1[87   :80  ], txzf1[87   :80 ], dtz_1[87   :80 ], {8{1'b0}}, dtz_2[87 :80 ], {4{8'b0}}, dtz_5[87 :80 ],dtz_6[87 :80 ],dtz_7[87 :80 ] }; 
      word[11]  <=  { char_1[191  :176],char_2[191  :176 ], num_1[95   :88  ], txzf1[95   :88 ], dtz_1[95   :88 ], {8{1'b0}}, dtz_2[95 :88 ], {4{8'b0}}, dtz_5[95 :88 ],dtz_6[95 :88 ],dtz_7[95 :88 ] }; 
      word[12]  <=  { char_1[207  :192],char_2[207  :192 ], num_1[103  :96  ], txzf1[103  :96 ], dtz_1[103  :96 ], {8{1'b0}}, dtz_2[103:96 ], {4{8'b0}}, dtz_5[103:96 ],dtz_6[103:96 ],dtz_7[103:96 ] }; 
      word[13]  <=  { char_1[223  :208],char_2[223  :208 ], num_1[111  :104 ], txzf1[111  :104], dtz_1[111  :104], {8{1'b0}}, dtz_2[111:104], {4{8'b0}}, dtz_5[111:104],dtz_6[111:104],dtz_7[111:104] }; 
      word[14]  <=  { char_1[239  :224],char_2[239  :224 ], num_1[119  :112 ], txzf1[119  :112], dtz_1[119  :112], {8{1'b0}}, dtz_2[119:112], {4{8'b0}}, dtz_5[119:112],dtz_6[119:112],dtz_7[119:112] }; 
      word[15]  <=  { char_1[255  :240],char_2[255  :240 ], num_1[127  :120 ], txzf1[127  :120], dtz_1[127  :120], {8{1'b0}}, dtz_2[127:120], {4{8'b0}}, dtz_5[127:120],dtz_6[127:120],dtz_7[127:120] }; 
        
      word[16]  <=  { char_1[15   :0  ],char_2[15   :0  ], num_2[7    :0   ], txzf1[7    :0  ], dtz_3[7    :0  ], {8{1'b0}},   dtz_4[7    :0  ], {8{1'b0}}, {6{num_0[7    :0     ]}}     };     //
      word[17]  <=  { char_1[31   :16 ],char_2[31   :16 ], num_2[15   :8   ], txzf1[15   :8  ], dtz_3[15   :8  ], {8{1'b0}},   dtz_4[15   :8  ], {8{1'b0}}, {6{num_0[15   :8     ]}}     };     //
      word[18]  <=  { char_1[47   :32 ],char_2[47   :32 ], num_2[23   :16  ], txzf1[23   :16 ], dtz_3[23   :16 ], {8{1'b0}},   dtz_4[23   :16 ], {8{1'b0}}, {6{num_0[23   :16    ]}}     };     //
      word[19]  <=  { char_1[63   :48 ],char_2[63   :48 ], num_2[31   :24  ], txzf1[31   :24 ], dtz_3[31   :24 ], {8{1'b0}},   dtz_4[31   :24 ], {8{1'b0}}, {6{num_0[31   :24    ]}}     };     //
      word[20]  <=  { char_1[79   :64 ],char_2[79   :64 ], num_2[39   :32  ], txzf1[39   :32 ], dtz_3[39   :32 ], {8{1'b0}},   dtz_4[39   :32 ], {8{1'b0}}, {6{num_0[39   :32    ]}}     };     //
      word[21]  <=  { char_1[95   :80 ],char_2[95   :80 ], num_2[47   :40  ], txzf1[47   :40 ], dtz_3[47   :40 ], {8{1'b0}},   dtz_4[47   :40 ], {8{1'b0}}, {6{num_0[47   :40    ]}}     };     //
      word[22]  <=  { char_1[111  :96 ],char_2[111  :96 ], num_2[55   :48  ], txzf1[55   :48 ], dtz_3[55   :48 ], {8{1'b0}},   dtz_4[55   :48 ], {8{1'b0}}, {6{num_0[55   :48    ]}}     };     //
      word[23]  <=  { char_1[127  :112],char_2[127  :112], num_2[63   :56  ], txzf1[63   :56 ], dtz_3[63   :56 ], {8{1'b0}},   dtz_4[63   :56 ], {8{1'b0}}, {6{num_0[63   :56    ]}}     };     //
      word[24]  <=  { char_1[143  :128],char_2[143  :128], num_2[71   :64  ], txzf1[71   :64 ], dtz_3[71   :64 ], {8{1'b0}},   dtz_4[71   :64 ], {8{1'b0}}, {6{num_0[71   :64    ]}}     };     //
      word[25]  <=  { char_1[159  :144],char_2[159  :144], num_2[79   :72  ], txzf1[79   :72 ], dtz_3[79   :72 ], {8{1'b0}},   dtz_4[79   :72 ], {8{1'b0}}, {6{num_0[79   :72    ]}}     };     //
      word[26]  <=  { char_1[175  :160],char_2[175  :160], num_2[87   :80  ], txzf1[87   :80 ], dtz_3[87   :80 ], {8{1'b0}},   dtz_4[87   :80 ], {8{1'b0}}, {6{num_0[87   :80    ]}}     };     //
      word[27]  <=  { char_1[191  :176],char_2[191  :176], num_2[95   :88  ], txzf1[95   :88 ], dtz_3[95   :88 ], {8{1'b0}},   dtz_4[95   :88 ], {8{1'b0}}, {6{num_0[95   :88    ]}}     };     //
      word[28]  <=  { char_1[207  :192],char_2[207  :192], num_2[103  :96  ], txzf1[103  :96 ], dtz_3[103  :96 ], {8{1'b0}},   dtz_4[103  :96 ], {8{1'b0}}, {6{num_0[103  :96    ]}}     };     //
      word[29]  <=  { char_1[223  :208],char_2[223  :208], num_2[111  :104 ], txzf1[111  :104], dtz_3[111  :104], {8{1'b0}},   dtz_4[111  :104], {8{1'b0}}, {6{num_0[111  :104   ]}}     };     //
      word[30]  <=  { char_1[239  :224],char_2[239  :224], num_2[119  :112 ], txzf1[119  :112], dtz_3[119  :112], {8{1'b0}},   dtz_4[119  :112], {8{1'b0}}, {6{num_0[119  :112   ]}}     };     //
      word[31]  <=  { char_1[255  :240],char_2[255  :240], num_2[127  :120 ], txzf1[127  :120], dtz_3[127  :120], {8{1'b0}},   dtz_4[127  :120], {8{1'b0}}, {6{num_0[127  :120   ]}}     };     //
    end    
end

// //给字符数组赋值，显示汉字“正点原子”，每个汉字大小为32*32
// always @(posedge lcd_pclk) begin
//     char[0 ]  <= word[0 ];
//     char[1 ]  <= word[1 ];
//     char[2 ]  <= word[2 ];
//     char[3 ]  <= word[3 ];
//     char[4 ]  <= word[4 ];
//     char[5 ]  <= word[5 ];
//     char[6 ]  <= word[6 ];
//     char[7 ]  <= word[7 ];
//     char[8 ]  <= word[8 ];
//     char[9 ]  <= word[9 ];
//     char[10]  <= word[10];
//     char[11]  <= word[11];
//     char[12]  <= word[12];
//     char[13]  <= word[13];
//     char[14]  <= word[14];
//     char[15]  <= word[15];
//     char[16]  <= word[16];
//     char[17]  <= word[17];
//     char[18]  <= word[18];
//     char[19]  <= word[19];
//     char[20]  <= word[20];
//     char[21]  <= word[21];
//     char[22]  <= word[22];
//     char[23]  <= word[23];
//     char[24]  <= word[24];
//     char[25]  <= word[25];
//     char[26]  <= word[26];
//     char[27]  <= word[27];
//     char[28]  <= word[28];
//     char[29]  <= word[29];
//     char[30]  <= word[30];
//     char[31]  <= word[31];
// end

//为LCD不同显示区域绘制图片、字符和背景色
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)
        pixel_data <= BACK_COLOR;
    else if( (pixel_xpos >= PIC_X_START - 1'b1) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'b1) 
          && (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) )
        pixel_data <= rom_rd_data ;  //显示图片
    else if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
         && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
        // if(char[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
        if(word[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
            pixel_data <= CHAR_COLOR;    //显示字符
        else
            pixel_data <= BACK_COLOR;    //显示字符区域的背景色
    end
    else
        pixel_data <= BACK_COLOR;        //屏幕背景色
end

//根据当前扫描点的横纵坐标为ROM地址赋值
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)
        rom_addr <= 14'd0;
    //当横纵坐标位于图片显示区域时,累加ROM地址    
    else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
        && (pixel_xpos >= PIC_X_START - 2'd2) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 2'd2)) 
        rom_addr <= rom_addr + 1'b1;
    //当横纵坐标位于图片区域最后一个像素点时,ROM地址清零    
    else if((pixel_ypos >= PIC_Y_START + PIC_HEIGHT))
        rom_addr <= 14'd0;
end

//ROM：存储图片
rom_10000x16b	rom_10000x16b_inst (
	.address ( rom_addr ),// input wire clka
	.clock ( lcd_pclk ),  // input wire ena
	.rden ( rom_rd_en ),  // input wire [13 : 0] addra
	.q ( rom_rd_data )    // output wire [15 : 0] douta
	);


endmodule 