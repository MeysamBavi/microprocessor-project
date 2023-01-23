#include "lcd.h"

void initLCD()
{

  __LCD_Data(0x00);
  __LCD_RS(0);
  __LCD_E(0);

  __LCD_Data(0x00);
  Delay(30);
  Delay(1);
  LCD_ICommand(0x03);
  Delay(5);
  LCD_ICommand(0x03);
  Delay(1);
  LCD_ICommand(0x03);
  LCD_ICommand(0x02);
  LCD_ICommand(0x02);
  LCD_ICommand(0x08);
  LCD_ICommand(0x00);
  LCD_ICommand(0x0C);
  LCD_ICommand(0x00);
  LCD_ICommand(0x06);
}

void LCD_SendEnable()
{
	__LCD_E(1);
	Delay(LCD_Delay);
	__LCD_E(0);
	Delay(LCD_Delay);
}

void LCD_Command(uint8_t cmd)
{
	uint8_t high = cmd >> 4;
	uint8_t low = cmd;
	
	__LCD_RS(0);
	
	__LCD_Data(high);
	LCD_SendEnable();
	
	__LCD_Data(low);
	LCD_SendEnable();
}

void LCD_Char(char c)
{
	uint8_t high = c >> 4;
	uint8_t low = c;
	
	__LCD_RS(1);
	
	__LCD_Data(high);
	LCD_SendEnable();
	
	__LCD_Data(low);
	LCD_SendEnable();
}

void LCD_String(char* str)
{
	char c;
	while ((c = *(str++)))
	{
		LCD_Char(c);
	}
}


void __LCD_Data(uint8_t data)
{
	const unsigned int pos = 4;
	const unsigned int mask = 0x0FUL;
	
	data &= mask;
	LCD_P->BSRR = ((uint32_t) data) << pos;
	
	data = ~data & mask;
	LCD_P->BSRR = ((uint32_t) data) << (16 + pos);
}

void __LCD_RS(uint8_t data)
{
	const unsigned int pos = 10;
	const unsigned int mask = 0x01UL;
	
	data &= mask;
	LCD_P->BSRR = ((uint32_t) data) << pos;
	
	data = ~data & mask;
	LCD_P->BSRR = ((uint32_t) data) << (16 + pos);
}

void __LCD_E(uint8_t data)
{
	const unsigned int pos = 8;
	const unsigned int mask = 0x01UL;
	
	data &= mask;
	LCD_P->BSRR = ((uint32_t) data) << pos;
	
	data = ~data & mask;
	LCD_P->BSRR = ((uint32_t) data) << (16 + pos);
}

void Delay(uint32_t d)
{
	/*
	unsigned int t;
	while(d--)
	{
		t = Delay_C;
		while(t--);
	}*/
	
	HAL_Delay(d);
		
}

void LCD_ICommand(unsigned char CMD)
{

  __LCD_RS(0);

  __LCD_Data(CMD);

  __LCD_E(1);
  Delay(LCD_Delay);
  __LCD_E(0);
}
