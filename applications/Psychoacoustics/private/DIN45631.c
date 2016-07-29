#include "mex.h"
#include <math.h>

/*
%	Based on BASIC Program Published in J. Acoust. Soc. Jpn (E) 12, 1 (1991)
%	by E. Zwicker, H. Fastl, U. Widmann, K. Kurakata, S. Kuwano, and S. Namba
%
%	"Re-Author":	Aaron Hastings, Herrick Labs, Purdue University
%	Date Started: 29 October 00
%	Last Modified: 31 October 00
%	Status: Program Correctly Calculates Loudness for a 70 dB 1000 Hz sine 
%			  filtered using 1/3 octave band filters
%
%	Syntax:
%	[N, Ns]=DIN45631(LT, MS)
%
%	This is a loudness function which:
%		Calculates loudness based on DIN 45631 / ISO 532 B (Zwicker)
%		Accepts 1/3 octave band levels (SPL Linear Weighting)
%		* This data must be calibrated using a separate calibration function
%
%	Input Variables
%	LT(28)			Field of 28 elements which represent the 1/3 OB levels in dB with 
%						fc = 25 Hz to 12.5 kHz
%	MS				Type of sound field ( free = 0 / diffuse  = 1 )
%	
%	Output Variables
%	N				Loudness in sone G
%	NS				Specific Loudness
%	err				Error Code

%	Working Variables
%	FR(28)			Center frequencies of 1/3 OB
%	RAP(8)			Ranges of 1/3 OB levels for correction at low frequencies according 
%						to equal loudness contours
%	DLL(11,8)		Reduction of 1/3 OB levels at low frequencies according to equal 
%						loudness contours within the 8 ranges defined by RAP
%	LTQ(20)			Critical Band Rate level at absolute threshold without taking into 
%						account the transmission characterisics of the ear
%	AO(20)			Correction of levels according to the transmission characteristics 
%						of the ear
%	DDF(20)			Level difference between free and diffuse sound fields
%	DCB(20)			Adaptation of 1/3 OB levels to the corresponding critical band level
%	ZUP(21)			Upper limits of approximated critical bands in terms of critical 
%						band rate
%	RNS(18)			Range of specific loudness for the determination of the steepness of 
%						the upper slopes in the specific loudness -critical band rate pattern
%	USL(18,8)		Steepness of the upper slopes in the specific loudness - critical 
%						band rate pattern for the ranges RNS as a function of the number of 
%						the critical band
%	
%	Working Variables (Uncertain of Definitions)
%	XP					Equal Loudness Contours
%	TI					Intensity of LT
%	LCB                 Lower Critical Band
%	LE					Level Excitation 
%	NM					Critical Band Level 
%	KORRY				Correction Factor
%	N					Loudness (in sones)
%	DZ					Speparation in CBR 
%	N2					Main Loudness 
%	Z1					Critical Band Rate for Lower Limit 
%	N1					Loudness of previous band 
%	IZ					Center "Frequency" Counter, used with NS
%	Z					Critical band rate 
%	J,IG				Counters used with USL 
 */





void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] ) {
    double *LT, *N, *NS, *MS;
    mwSize mrows, ncols;
    
    double FR[28] = {25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1.0, 1.25, 1.6, 2.0, 2.5, 3.15, 4.0, 5.0, 6.3, 8.0, 10.0, 12.5};
    double RAP[]={45, 55, 65, 71, 80, 90, 100, 120};
    double DLL[8][11] = { { -32, -24, -16, -10, -5, 0, -7, -3, 0, -2, 0 },
    { -29, -22, -15, -10, -4, 0, -7, -2, 0, -2, 0 },
    { -27, -19, -14, -9,  -4, 0, -6, -2, 0, -2, 0 },
    { -25, -17, -12, -9,  -3, 0, -5, -2, 0, -2, 0 },
    { -23, -16, -11, -7,  -3, 0, -4, -1, 0, -1, 0 },
    { -20, -14, -10, -6,  -3, 0, -4, -1, 0, -1, 0 },
    { -18, -12, -9,  -6,  -2, 0, -3, -1, 0, -1, 0 },
    { -15, -10, -8,  -4,  -2, 0, -3, -1, 0, -1, 0 } };
    double LTQ[] = {30, 18, 12, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3};
    double AO[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.5, -1.6, -3.2, -5.4, -5.6, -4.0, -1.5, 2.0, 5.0, 12.0};
    double DDF[] = {0, 0, 0.5, 0.9, 1.2, 1.6, 2.3, 2.8, 3.0, 2.0, 0.0, -1.4, -2.0, -1.9, -1.0, 0.5, 3.0, 4.0, 4.3, 4.0};
    double DCB[] = {-0.25, -0.6, -0.8, -0.8, -0.5, 0.0, 0.5, 1.1, 1.5, 1.7, 1.8, 1.8, 1.7, 1.6, 1.4, 1.2, 0.8, 0.5, 0.0, -0.5};
    double ZUP[] = {0.9, 1.8, 2.8, 3.5, 4.4, 5.4, 6.6, 7.9, 9.2, 10.6, 12.3, 13.8, 15.2, 16.7, 18.1, 19.3, 20.6, 21.8, 22.7, 23.6, 24.0};
    double RNS[] = {21.5, 18.0, 15.1, 11.5, 9.0, 6.1, 4.4, 3.1, 2.13, 1.36, 0.82, 0.42, 0.30, 0.22, 0.15, 0.10, 0.035, 0.0};
    double USL[18][8] = { {13.00, 8.20, 6.30, 5.50, 5.50, 5.50, 5.50, 5.50 },
    { 9.00, 7.50, 6.00, 5.10, 4.50, 4.50, 4.50, 4.50 },
    { 7.80, 6.70, 5.60, 4.90, 4.40, 3.90, 3.90, 3.90 },
    { 6.20, 5.40, 4.60, 4.00, 3.50, 3.20, 3.20, 3.20 },
    { 4.50, 3.80, 3.60, 3.20, 2.90, 2.70, 2.70, 2.70 },
    { 3.70, 3.00, 2.80, 2.35, 2.20, 2.20, 2.20, 2.20 },
    { 2.90, 2.30, 2.10, 1.90, 1.80, 1.70, 1.70, 1.70 },
    { 2.40, 1.70, 1.50, 1.35, 1.30, 1.30, 1.30, 1.30 },
    { 1.95, 1.45, 1.30, 1.15, 1.10, 1.10, 1.10, 1.10 },
    { 1.50, 1.20, 0.94, 0.86, 0.82, 0.82, 0.82, 0.82 },
    { 0.72, 0.67, 0.64, 0.63, 0.62, 0.62, 0.62, 0.62 },
    { 0.59, 0.53, 0.51, 0.50, 0.42, 0.42, 0.42, 0.42 },
    { 0.40, 0.33, 0.26, 0.24, 0.22, 0.22, 0.22, 0.22 },
    { 0.27, 0.21, 0.20, 0.18, 0.17, 0.17, 0.17, 0.17 },
    { 0.16, 0.15, 0.14, 0.12, 0.11, 0.11, 0.11, 0.11 },
    { 0.12, 0.11, 0.10, 0.08, 0.08, 0.08, 0.08, 0.08 },
    { 0.09, 0.08, 0.07, 0.06, 0.06, 0.06, 0.06, 0.05 },
    { 0.06, 0.05, 0.03, 0.02, 0.02, 0.02, 0.02, 0.02}};
    
    double KORRY, XP,  N2, Z1, Z2, N1, Z, DZ, MP1, MP2,S;
    double TI[11], LCB[3], LE[20], NM[21], GI[3];
    int i, J, IG, IZ;
    /* Check for proper number of arguments. */
    if(nrhs!=2) {
        mexErrMsgTxt("Two input arguments required.");
    } else if(nlhs!=2) {
        mexErrMsgTxt("Wrong number of output arguments.");
    }
    

    /* INPUT CHECK */
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])  ) {
        mexErrMsgTxt("Input #1 [LT] must be a noncomplex double.");
    }
    if( !((mrows==28 && ncols==1) || (mrows==1 && ncols==28)) ) {
        mexErrMsgTxt("Input #1 [LT] must be a vector of size [28 x 1] or [1 x 28].");
    }
    mrows = mxGetM(prhs[1]);
    ncols = mxGetN(prhs[1]);
    if( !mxIsDouble(prhs[1]) || !(mrows==1 && ncols==1)  ){
        mexErrMsgTxt("Input #2 [MS] must be scalar double. [ 0=free || 1= diffuse ]");
    }
    
    

    
    
    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1, 240, mxREAL);
    
    /* Assign pointers to each input and output. */
    LT = mxGetPr(prhs[0]);
    MS = mxGetPr(prhs[1]);
    N  = mxGetPr(plhs[0]);
    NS = mxGetPr(plhs[1]);
    

   
    /*	Begin Loudness Calcultation
    
    	Correction of 1/3 OB levels according to equal loudness contours(XP) and
    	calculation of the intensities for 1/3 OB's up to 315 Hz */
    
    for(i=0; i<11; i++){
        J=0;
        while (J<7){
            if ( LT[i] <= (RAP[J] - DLL[J][i]) ){
                XP = LT[i] + DLL[J][i];
                TI[i]=pow(10, (0.1*XP));
                J=8;
            }
            else
                J=J+1;
        }
    }
    
    
/*	Determination of Levels LCB(1), LCB(2), and LCB(3) within the first three critical bands */
    
    GI[0]=TI[1]+TI[2]+TI[3]+TI[4]+TI[5]+TI[0];
    GI[1]=TI[7]+TI[8]+TI[6];
    GI[2]=TI[10]+TI[9];
    
    for (i=0;i<3;i++) {
        if(GI[i]>0)
            LCB[i]=10 * log10(GI[i]);
        
    }
    
    
/*	Calculation of Main Loudness */
    
    for (i=0;i<20;i++){
        LE[i]=LT[i+8];
        if (i<=2)
            LE[i]=LCB[i];
        
        LE[i]=LE[i]-AO[i];
        NM[i]=0; /* DEL? */
        if ( *MS==1 ) /* if diffuse */
            LE[i]=LE[i]+DDF[i];
        
        if (LE[i]>LTQ[i]) {
            LE[i]=LE[i]-DCB[i];
            S=0.25;
            MP1 = 0.0635 * pow(10, (0.025 * LTQ[i]));
            MP2 = pow(1 - S + S * pow( 10, (0.1 * (LE[i]-LTQ[i])) ), 0.25) - 1;
            /* MP2 =   S * pow( 10, (0.1 * (LE[i]-LTQ[i])) ); */
            NM[i]= MP1* MP2;
            if (NM[i]<=0)
                NM[i]=0;
            
        }
    }
    
    NM[20]=0;
    
/*
    for(i=0;i<21;i++) {
        NS[i] = NM[i];
        printf("%f \n", NM[i]);
    }
*/

/*	Correction of specific loudness in the lowest critical band taking
	into account the dependence of absolute threshold within this critical band */

  
    KORRY= 0.4+ 0.32 * pow(NM[0], 0.2);
    if (KORRY>1)
        KORRY=1;
    NM[0]=NM[0]*KORRY;
    
/* Start Values */
    
    *N=0;
    Z1=0;
    N1=0;
    IZ=0;
    Z=0.1;
    
    
    /*	Step to first and subsequent critical bands */
     
    for (i=0;i<21;i++) {
        ZUP[i]=ZUP[i]+0.0001;
        IG=i-1; /* IG = -1 als Index??????????? */
       

/*       if (IG<0){
                IG =0;
                printf("IG ware kleiner 0 \n");
       } */

        if (IG>7)
            IG=7;
       while (Z1<ZUP[i]) {	/*	Note, Z1 will always be < ZUP[i] when line is first reached for each i */
           if (N1>NM[i]){
                /*	Decide whether the critical band in question is completely or
                	partly masked by accessory loudness */
                N2=RNS[J];
                if (N2<NM[i])
                    N2=NM[i];
                DZ = (N1-N2)/ USL[J][IG];
                Z2 = Z1+DZ;
                if (Z2>ZUP[i]){
                    Z2=ZUP[i];
                    DZ=Z2-Z1;
                    N2=N1-DZ * USL[J][IG];
                }
                /*	Contribtion of accessory loudness to total loudness */
                *N=*N+ DZ * (N1+N2)/2;
                while (Z<Z2){
                    NS[IZ]=N1-(Z-Z1)* USL[J][IG];
                    IZ=IZ+1;
                    Z=Z+0.1;
                }
            }

            else if (N1==NM[i]){
                /*	Contribution of umasked main loudness to total loudness and calculation
                	of values NS(IZ) with a spacing of Z=IZ*0.1 Bark */
                Z2=ZUP[i];
                N2=NM[i];
               *N = *N + N2 * (Z2-Z1);
                while (Z<Z2) {
                    NS[IZ] = N2;
                    IZ=IZ+1;
                    Z=Z+0.1;
                }
            }


           else{
                /*	Determination of the number J corresponding to the range of specific
                	loudness */
                for (J=0;J<18;J++){
                    if (RNS[J]<NM[i])
                        break;
                }
                
                
                /*	Contribution of umasked main loudness to total loudness and calculation
                	of values NS(IZ) with a spacing of Z=IZ*0.1 Bark */
                Z2=ZUP[i];
                N2=NM[i];
                *N=*N + N2 * (Z2-Z1);
                while (Z<Z2){
                    NS[IZ]=N2;
                    IZ=IZ+1;
                    Z=Z+0.1;
                }
            }

            /*	Step to next segment */
         while (J<17){
                if (N2<=RNS[J])
                        J=J+1;
                else
                    break;
                        
            }
          
           
            if (N2<=RNS[J] && J>=17)
                J=17;
            
            Z1=Z2;
            N1=N2;
      
        }
      }  
        /*	Now apply some sort of correction */


        if (*N<0)
            *N=0;
        else if (*N<=16)
            *N = floor(*N *1000+0.5)/1000;
        else
            *N = floor(*N * 100+0.5)/100;
         
   
    

 
}

