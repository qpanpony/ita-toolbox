#include "mex.h"
#include <math.h>

#define t_short 0.005
#define t_long 0.015
#define t_var 0.075



void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    int nChannels, iCh, nSamples, iSample;
    double *inData, *outData, *deltaT;
    double B[6] = {0, 0, 0, 0, 0, 0};
    
     double u_o_0, u_2_0;  /* u_o(t-delta_t),   u_2(t-delta_t)*/   
     double lambda_1, lambda_2, p, q, den, e1, e2, delta_t;
     double u_o, u_2, u_i;
/*
        int i;
*/
     
     
    /* Check for proper number of arguments. */
    if(nrhs!=2) {
        mexErrMsgTxt("Two input arguments required. TODO: welche");
    } else if(nlhs!=1) {
        mexErrMsgTxt("Just one output argument.");
    }
    

    /* INPUT CHECK */
    nSamples  = mxGetM(prhs[0]);
    nChannels = mxGetN(prhs[0]);
    
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])  ) {
        mexErrMsgTxt("Input #1 must be a noncomplex double.");
    }
/*   if( !((mrows==28 && ncols==1) || (mrows==1 && ncols==28)) ) {
        mexErrMsgTxt("Input #1 [LT] must be a vector of size [28 x 1] or [1 x 28].");
    }
*/
    if( !(mxGetM(prhs[1]) == 1)  || !(mxGetM(prhs[1])==1 )  ){
        mexErrMsgTxt("Input #2 deltaT must be scalar double.]");
    }


    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix( nSamples,nChannels, mxREAL);
 
    
    /* Assign pointers to each input and output. */
    inData      = mxGetPr(prhs[0]);
    deltaT      = mxGetPr(prhs[1]);
    outData     = mxGetPr(plhs[0]);
    
    
    /* Init */
        delta_t = *deltaT;
        p =(t_var + t_long) / (t_var*t_short);
        q = 1/(t_short*t_var);
        lambda_1 = -p/2+sqrt(p*p/4 - q);
        lambda_2 = -p/2-sqrt(p*p/4 - q);
        den = t_var*(lambda_1 - lambda_2);
        e1 = exp(lambda_1*delta_t);
        e2 = exp(lambda_2*delta_t);
        B[0] = (e1-e2)/den;
        B[1] = ((t_var*lambda_2+1)*e1 - (t_var*lambda_1+1)*e2)/den;
        B[2] = ((t_var*lambda_1+1)*e1 - (t_var*lambda_2+1)*e2)/den;
        B[3] = (t_var*lambda_1+1)* (t_var*lambda_2+1)* (e1-e2)/den;
        B[4] = exp(-delta_t/t_long);
        B[5] = exp(-delta_t/t_var);
        
        


    
    
    
    
        for ( iCh = 0; iCh <nChannels; iCh++){
            
            
            u_o_0 = 0;
            u_2_0 = 0;
            
            for (iSample = 0; iSample<nSamples; iSample++){
                
                    u_i = inData[(iCh*nSamples)+ iSample];
                    if (u_i < u_o_0) /* case 1 */
                        if (u_o_0 > u_2_0){ /* case 1.1 */
                        u_2 = u_o_0*B[0] - u_2_0*B[1];
                        u_o = u_o_0*B[2] - u_2_0*B[3];
                        if (u_i > u_o)
                            u_o = u_i; /* u_o can't become lower than u_i */
                        if (u_2 > u_o) /* case 1.1.1 */
                            u_2 =u_o; /* u_2 can't become  higher than u_o */
                        }
                        else{ /* case 1.2 */
                        u_o = u_o_0*B[4];
                        if (u_i > u_o){
                            u_o = u_i; /* u_o can't become lower than u_i */
                        }
                        u_2 = u_o;
                        }
                    else{
                        if (u_i == u_o_0){ /* case 2 */
                            u_o = u_i;
                            if (u_o > u_2_0) /* case 2.1 */
                                u_2 = (u_2_0 - u_i)*B[5] + u_i;
                            else /* case 2.2 */
                                u_2 = u_i;
                        }
                        else{ /* case 3 */
                            u_o = u_i;
                            u_2 = (u_2_0 - u_i)*B[5] + u_i;
                        }
                    }
                    u_o_0 = u_o; /* preparation for next step */
                    u_2_0 = u_2;
                    
                    
                    outData[(iCh*nSamples)+ iSample] = u_o;
             

                
                
            }
        
        
    }
    
    
}
