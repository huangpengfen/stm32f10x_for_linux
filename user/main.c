#include "stm32f10x.h"
#include "stm32f10x_conf.h"
#include "uart.h"

void Delay(__IO uint32_t nCount)
{
    for(; nCount != 0; nCount--);
}

void RCC_Configuration(void)
{
    ErrorStatus HSEStartUpStatus;

    RCC_DeInit();
    RCC_HSEConfig(RCC_HSE_ON);
    HSEStartUpStatus = RCC_WaitForHSEStartUp();
    if (HSEStartUpStatus == SUCCESS) 
	{
        RCC_HCLKConfig(RCC_SYSCLK_Div1);
        RCC_PCLK2Config(RCC_HCLK_Div1);
        RCC_PCLK1Config(RCC_HCLK_Div2);
        RCC_PLLCmd(ENABLE);
        while (RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET);
        RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);
        while (RCC_GetSYSCLKSource() != 0x08);
    }
}

void GPIO_Configuration(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

    GPIO_InitStructure.GPIO_Pin =  GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOB, &GPIO_InitStructure);
}

int main() {

    RCC_Configuration();
    GPIO_Configuration();

    uart_init();

    debug("start main");

    while(1) {
        GPIO_ResetBits(GPIOB, GPIO_Pin_6);
        debug("ON");
        Delay(10000000);
        GPIO_SetBits(GPIOB, GPIO_Pin_6);
        debug("OFF");
        Delay(10000000);
    }

    return 0;
}
