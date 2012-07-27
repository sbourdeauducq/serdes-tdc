#include <stdio.h>
#include <uart.h>
#include <hw/stdc.h>

#include "stdc.h"

void tdc(void)
{
	while(1) {
		while(!CSR_TDC0_EVENT && !CSR_TDC1_EVENT) {
			if(readchar_nonblock()) return;
		}
		if(CSR_TDC0_EVENT) {
			printf("0,%u,%u\n", CSR_TDC0_POLARITY, CSR_TDC0_TIMESTAMP);
			CSR_TDC0_EVENT = 1;
		}
		if(CSR_TDC1_EVENT) {
			printf("1,%u,%u\n", CSR_TDC1_POLARITY, CSR_TDC1_TIMESTAMP);
			CSR_TDC1_EVENT = 1;
		}
	}
}

void diff(void)
{
	CSR_TDC0_EVENT = 1;
	CSR_TDC1_EVENT = 1;
	CSR_TDC0_EVENT = 1;
	
	while(1) {
		while(!(CSR_TDC0_EVENT && CSR_TDC1_EVENT)) {
			if(readchar_nonblock()) return;
		}
		if(CSR_TDC0_POLARITY != CSR_TDC1_POLARITY)
			printf("Inconsistent polarities!\n");
		printf("%u,%d\n", CSR_TDC0_POLARITY, (int)(CSR_TDC1_TIMESTAMP - CSR_TDC0_TIMESTAMP));
		CSR_TDC0_EVENT = 1;
		CSR_TDC1_EVENT = 1;
	}
}
