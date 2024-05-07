/*************************************************************
* Program som testar de olika funktionerna i I/O-biblioteket *
*************************************************************/

#include "my_iolib.h"


int main(){
    char headMsg[] = "Start av testprogram. Skriv in 5 tal!";
    char endMsg[] = "Testprogram slut";
    char buf[64];
    long long sum = 0;
    long long temp;
    unsigned int pos, count;

    // Lägger inledande text i utmatningsbuffer, 
    // samt skickar innehåll från utmatningsbuffer till terminal.
    // Hämtar sedan text från terminalinmatning.
    putText(headMsg);   
    outImage();         
    inImage();   

    // Loop som hämtar 5 tal från inmatningsbuffert, 
    // samt placerar uträkning med dessa tal att presentera i utmatningsbufferten.
    // Talen summeras också i variabeln sum.
    for (count=5; count>0; count-- ){
        temp = getInt();
        if (temp < 0){
            pos = getOutPos();
            pos--;
            setOutPos(pos);
        }
        sum += temp;
        putInt(temp);
        putChar('+');
    }
    pos = getOutPos();
    pos--;
    setOutPos(pos);

    // Lägger till summan i uträkningen i utbufferten,
    // och skriver uträkningen till terminalskärmen.
    putChar('=');
    putInt(sum);
    outImage();

    // Försöker läsa ytterligare 12 tecken från inbufferten,
    // och lägger de lästa tecknen i utbufferten.
    // Lägger även till ett nyradstecken och talet 125 i utbufferten,
    // och skriver sedan ut alltihopa i terminalen.
    getText(buf, 12); 
    putText(buf);
//    putChar('\n');
    putInt(125);    
    outImage(); 

    // Lägger till sist avslutningstext i utmatningsbufferten,
    // och visar texten i terminalen.
    putText(endMsg); 
    outImage();  

    return 0;
}

