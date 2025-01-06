#include "./SYSTEM/sys/sys.h"
#include "./SYSTEM/usart/usart.h"
#include "./SYSTEM/delay/delay.h"
#include "./USMART/usmart.h"
#include "./BSP/LED/led.h"
#include "./BSP/LCD/lcd.h"
#include "./BSP/KEY/key.h"
#include "./BSP/RS485/rs485.h"


int main(void)
{
    uint8_t key;
    uint8_t i = 0, t = 0;
    uint8_t cnt = 0;
    uint8_t rs485buf[5];

    HAL_Init();                                 /* 初始化HAL库 */
    sys_stm32_clock_init(RCC_PLL_MUL9);         /* 设置时钟, 72Mhz */
    delay_init(72);                             /* 延时初始化 */
    usart_init(115200);                         /* 串口初始化为115200 */
    usmart_dev.init(72);                        /* 初始化USMART */
    led_init();                                 /* 初始化LED */
    lcd_init();                                 /* 初始化LCD */
    key_init();                                 /* 初始化按键 */
    rs485_init(115200);                           /* 初始化RS485 */

    lcd_show_string(30,  50, 200, 16, 16, "STM32", RED);
    lcd_show_string(30,  70, 200, 16, 16, "RS485 TEST", RED);
    lcd_show_string(30,  90, 200, 16, 16, "ATOM@ALIENTEK", RED);
    lcd_show_string(30, 110, 200, 16, 16, "KEY0:Send", RED);    /* 显示提示信息 */

    lcd_show_string(30, 130, 200, 16, 16, "Count:", RED);       /* 显示当前计数值 */
    lcd_show_string(30, 150, 200, 16, 16, "Send Data:", RED);   /* 提示发送的数据 */
    lcd_show_string(30, 190, 200, 16, 16, "Receive Data:", RED);/* 提示接收到的数据 */

    while (1)
    {
        key = key_scan(0);

        if (key == KEY0_PRES)   /* KEY0按下,发送一次数据 */
        {
            for (i = 0; i < 1; i++)
            {
                rs485buf[i] = cnt + i;      /* 填充发送缓冲区 */
                lcd_show_xnum(30 + i * 32, 170, rs485buf[i], 3, 16, 0X80, BLUE);    /* 显示数据 */
            }

            rs485_send_data(rs485buf, 1);   /* 发送5个字节 */
        }

        rs485_receive_data(rs485buf, &key);

        if (key)    /* 接收到有数据 */
        {
            if (key > 5)key = 5;    /* 最大是5个数据. */

            for (i = 0; i < key; i++)
            {
                lcd_show_xnum(30 + i * 32, 210, rs485buf[i], 3, 16, 0X80, BLUE);    /* 显示数据 */
            }
        }

        t++;
        delay_ms(10);

        if (t == 20)
        {
            LED0_TOGGLE();  /* LED0闪烁, 提示系统正在运行 */
            t = 0;
            cnt++;
            lcd_show_xnum(30 + 48, 130, cnt, 3, 16, 0X80, BLUE);    /* 显示数据 */
        }
    }
}



















