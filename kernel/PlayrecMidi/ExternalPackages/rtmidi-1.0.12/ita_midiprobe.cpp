// midiprobe.cpp
//
// Simple program to check MIDI inputs and outputs.
//
// by Gary Scavone, 2003-2004.

#include <iostream>
#include <cstdlib>
#include "RtMidi.h"

int main()
{
  RtMidiOut *midiout = 0;

  try {

    // Check inputs.
    unsigned int nPorts =0;

    // RtMidiOut constructor ... exception possible
    midiout = new RtMidiOut();

    // Check outputs.
    nPorts = midiout->getPortCount();
    std::cout << "\nThere are " << nPorts << " MIDI output ports available.\n";

    for ( unsigned i=0; i<nPorts; i++ ) {
      std::string portName = midiout->getPortName(i);
      std::cout << "  Output Port #" << i << ": " << portName << std::endl;
    }
    std::cout << std::endl;

  } catch ( RtError &error ) {
    error.printMessage();
  }

	
// message
	
	std::vector<unsigned char> message;
	//message.resize(16,0);
	message.resize(5,0);
	
	message[0]=240;
	message[1]=105;
	message[4]=247;
	
	message[2]=0;
	message[3]=0;
	
	unsigned int InputRange = 2;
	unsigned int Mode = 0;
	unsigned int b0dBOutputRange = true;

	
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
	
	
	if(b0dBOutputRange)
	{
		message[2]+=1;
		message[3]-=1;
	}
	
	std::cout << message[1] << std::endl;

	
	// try robo
	midiout->openPort( 0 );
	midiout->sendMessage( &message );
	midiout->closePort();

	
	
	// clean up
	
  delete midiout;

  return 0;
}
