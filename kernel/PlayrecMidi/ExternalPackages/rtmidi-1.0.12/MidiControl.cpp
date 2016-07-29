// MidiControl.cpp: implementation of the CMidiControl class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RoboControlCenter.h"
#include "MidiControl.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

#define WIDTH 15

CMidiControl::CMidiControl()
{
	midiout = new RtMidiOut();

	//Initialisieren!
	Mode=0;
	InputRange=0;
	this->b0dBOutputRange=false;


	p40dB=CRect(340,45,356,60); //(oben,liks,rechts,unten)
	p20dB=CRect(340,67,341+WIDTH,67+WIDTH); //(oben,liks,rechts,unten)
	p0dB=CRect(340,88,341+WIDTH,88+WIDTH); //(oben,liks,rechts,unten)
	m20dB=CRect(340,110,341+WIDTH,110+WIDTH); //(oben,liks,rechts,unten)
	m40dB=CRect(340,131,341+WIDTH,131+WIDTH); //(oben,liks,rechts,unten)

	
	Norm=CRect(414,46,429,46+WIDTH); //(oben,liks,rechts,unten)
	Imp=CRect(414,67,429,67+WIDTH); //(oben,liks,rechts,unten)
	Ohms=CRect(414,88,429,88+WIDTH); //(oben,liks,rechts,unten)
	Line=CRect(414,110,429,110+WIDTH); //(oben,liks,rechts,unten)
	AmpRef=CRect(414,132,429,132+WIDTH); //(oben,liks,rechts,unten)


	Range20=CRect(488,46,488+WIDTH,46+WIDTH); //(oben,liks,rechts,unten)
	Range0=CRect(489,67,489+WIDTH,67+WIDTH); //(oben,liks,rechts,unten)


}

CMidiControl::~CMidiControl()
{

}


//Diese memberfunktion bearbeitet die Anfrage, ob ein Schalter
//angeklickt wurde. Falls ja, so werden die entsprechenden 
//Statusvariablen gesetzt
//Die Identifier �bernehmen mittlerweile nur noch Debug-Funktionen
char* CMidiControl::m_cGetCickedIdentifier(CPoint point)
{
	


	if(p40dB.PtInRect(point))
	{
		InputRange=0;
		return "p40dB";
	}
	if(p20dB.PtInRect(point))
	{
		InputRange=1;
		return "p20dB";
	}
	if(p0dB.PtInRect(point))
	{
		InputRange=2;
		return "p0dB";
	}
	if(m20dB.PtInRect(point))
	{
		InputRange=3;
		return "m20dB";
	}
	if(m40dB.PtInRect(point))
	{
		InputRange=4;
		return "m40dB";
	}

	//////////////////////////////////////////////////////////////////

	if(AmpRef.PtInRect(point))
	{
		Mode=4;
		return "AmpRef";
	}
	if(Norm.PtInRect(point))
	{
		Mode=0;
		return "Norm";
	}
	if(Imp.PtInRect(point))
	{
		Mode=1;
		return "Imp";
	}
	if(Ohms.PtInRect(point))
	{
		Mode=2;
		return "Ohms";
	}
	if(Line.PtInRect(point))
	{
		Mode=3;
		return "Line";
	}

	/////////////////////////////////////////////////////////////////77
	if(Range20.PtInRect(point))
	{
		this->b0dBOutputRange=false;
		return "Range20";
	}
	
	if(Range0.PtInRect(point))
	{
		this->b0dBOutputRange=true;
		return "Range0";
	}
	


	return "NULL";
}

//schlie�t den MIDI-Port
bool CMidiControl::stop()
{
	
	this->midiout->closePort();
	return true;
}


bool CMidiControl::start(int PortNumber)
{
	this->midiout->openPort( PortNumber );
	iCurrentPortNumber=PortNumber;
	return true;

}

void CMidiControl::send(std::vector<unsigned char> message)
{
	midiout->sendMessage( &message );
	midiout->closePort();
	this->midiout->openPort( iCurrentPortNumber );
	
}


//stellt e nach Statusvariablen die Flags f�r die MIDI-Befehle bereit
//und startet den Aufruf
bool CMidiControl::bUpdateRobo()
{
	std::vector<unsigned char> message;
	//message.resize(16,0);
	message.resize(5,0);
	
	message[0]=240;
	message[1]=105;
	message[4]=247;
	
	message[2]=0;
	message[3]=0;

	switch(InputRange)
	{
	case 0:            //+40dBu
		message[2]+=0;
		message[3]+=15;		
		break;
	case 1:				//+20dBu
		message[2]+=2;
		message[3]+=13;		
		
		break;
	case 2:				//0dBu
		message[2]+=4;
		message[3]+=11;		
		
		break;
	case 3:				//-20dBu
		message[2]+=6;
		message[3]+=9;		
		
		break;
	case 4:				//-40dBu
		message[2]+=8;
		message[3]+=7;		
		
		break;

	
	}
	

	switch(Mode)
	{
	case 0:				//Norm
		message[2]+=0;
		message[3]+=7*16;
		break;
	case 1:				//Imp
		message[2]+=16;
		message[3]+=6*16;
		break;
	case 2:				//10Ohms
		message[2]+=2*16;
		message[3]+=5*16;
		break;
	case 3:				//LineRef
		message[2]+=3*16;
		message[3]+=4*16;
		break;
	case 4:				//AmpRef
		message[2]+=4*16;
		message[3]+=3*16;
		break;

	
	}
	

	if(this->b0dBOutputRange)
	{
		message[2]+=1;
		message[3]-=1;
	}

	send(message); //MIDI-Signal wird gesendet! 

	
	return true;

}
//Zur�cksetzen auf Urspr�nglicheEinstellung: +40dBu, Norm, +20dBu
void CMidiControl::ResetRobo()
{
	Mode=0;
	InputRange=0;
	this->b0dBOutputRange=false;
	this->bUpdateRobo();

}
//Diese Funktion wird ganz zu Anfang aufgerufen und gibt dem Benutzer eine R�ckmeldung,
//ob die Hardware auf die MIDI-Befehle reagiert
void CMidiControl::Fun()
{
/*	int ModeBup=Mode;
	int InputRangeBup=InputRange;
	
	InputRange=4;
	for (int i=0;i<5;i++)
	{
		
		InputRange--;
		bUpdateRobo();
		Sleep(100);

	}
	InputRange=0;
	Mode=4;
	for (int j=0;j<5;j++)
	{
		
		Mode--;
		bUpdateRobo();
		Sleep(100);

	}*/
	InputRange=0;
	Mode=0;
	for (int k=0;k<4;k++)
	{
		
		this->b0dBOutputRange=!this->b0dBOutputRange;
		bUpdateRobo();
		Sleep(200);

	}

	

}

//ben�tigt zum Zeichnen der farbigen Markierungen
CRect CMidiControl::GiveInputRegion()
{
	switch(InputRange)
	{
	case 0:
		return p40dB;
		break;
	case 1:
		return p20dB;
		break;
	case 2:
		return p0dB;
		break;
	case 3:
		return m20dB;
		break;
	case 4:
		return m40dB;
		break;


	}
return 0;
}
//ben�tigt zum Zeichnen der farbigen Markierungen
CRect CMidiControl::GiveOutputRegion()
{

	switch(Mode)
	{
	case 0:
		return Norm;
		break;
	case 1:
		return Imp;
		break;
	case 2:
		return Ohms;
		break;
	case 3:
		return Line;
		break;
	case 4:
		return AmpRef;
		break;


	}
return 0;
}
//ben�tigt zum Zeichnen der farbigen Markierungen
CRect CMidiControl::GiveModusRegion()
{
	if(this->b0dBOutputRange)
		return Range0;
	else
		return	Range20;
}

