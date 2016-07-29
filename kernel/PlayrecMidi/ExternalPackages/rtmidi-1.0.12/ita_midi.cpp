/*=================================================================
 * Author: Pascal Dietrich -- pdi@akustik.rwth-aachen.de
 * Date Created: 30-March-2011
 * Uses: RtMidi
 * Compilation Script in MATLAB: compile_ita_midi.m
 *=============================================================*/
#include "mex.h"
#include <iostream>
#include <cstdlib>
#include "RtMidi.h"

// Platform-dependent sleep routines.
#if defined(__WINDOWS_MM__ )
#include <windows.h>
#define SLEEP( milliseconds ) Sleep( (DWORD) milliseconds )
#else // Unix variants
#include <unistd.h>
#define SLEEP( milliseconds ) usleep( (unsigned long) (milliseconds * 1000.0) )
#endif


void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
    
    if(nrhs == 0) { //no input argument, just return string
        
        RtMidiOut *midiout = NULL; // get object
        
        try {
            // Check inputs.
            unsigned int nPorts = 0;
            
            // std::cout << "RTmidiout" <<std::endl;

            
            // RtMidiOut constructor ... exception possible
            midiout = new RtMidiOut();
            
            // std::cout << "test" <<std::endl;
            
            // Get Midi Device String
            nPorts = midiout->getPortCount();
            std::string portName = "";
            for ( unsigned i=0; i<nPorts; i++ ) {
                portName+="|";
                portName+= midiout->getPortName(i);
            }
//             SLEEP( 20 ); // better? no
            
//             midiout->closePort(); // test: is closing better?
//             SLEEP( 20 ); // better? no
            
            
            plhs[0] = mxCreateString(portName.c_str()); // return converted string to matlab

           
            
        } catch ( RtError &error ) {
            error.printMessage();
        }
        delete midiout; // clean up
        midiout = NULL;
        return;
    }
    
    /* check for proper number of arguments */
    if(nrhs!=2)
        mexErrMsgTxt("Two inputs required.");
    else if(nlhs > 1)
        mexErrMsgTxt("Too many output arguments.");
    
    /* input must be a row vector */
    if (mxGetM(prhs[0])!=1)
        mexErrMsgTxt("Input must be a row vector.");
    
    if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[0])) {
        mexErrMsgTxt("Input must be a noncomplex scalar double.");
    }
    
    /* Assign pointers to each input and output. */
    double *portNumberOrig = mxGetPr(prhs[1]);
        
    // get message
    int nArray = mxGetN(prhs[0]);
    double *input_buf = mxGetPr(prhs[0]);
    
    std::vector<unsigned char> message;
    message.resize(nArray, 0);
    
    // covert to char vector :)
    for (int i=0;i<nArray;i++) {
        message[i] = (int)input_buf[i];
    }
    
    // MIDI stuff below
    RtMidiOut *midiout = 0;
    
    midiout = new RtMidiOut();
    
    midiout->openPort((int)portNumberOrig[0]);
    
    midiout->sendMessage( &message );
    SLEEP( 100 ); // works well, was 100 before
    
    
    midiout->closePort();
    
    SLEEP( 50 ); // works well
    
    
//     mxFree(input_buf); %kills matlab
    delete midiout;
    
    return;
}

