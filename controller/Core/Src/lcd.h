#include "main.h"

#define LCD_P					GPIOB
#define LCD_Delay			3UL
#define LCD_SR				0xC1
#define LCD_Clear			0x01

void __LCD_Data(uint8_t);
void __LCD_RS(uint8_t);
void __LCD_E(uint8_t);
void LCD_SendEnable(void);
void LCD_Command(uint8_t);
void LCD_Char(char);
void LCD_String(char*);
void LCD_ICommand(unsigned char);
void initLCD(void);
void Delay(uint32_t);
