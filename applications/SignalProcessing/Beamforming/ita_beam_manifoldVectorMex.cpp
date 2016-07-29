#include "mex.h"
#include "math.h"
#include "stdlib.h"
#include "vector"
using namespace std;

#define NDIMS 2

/*
 * ita_beam_manifoldVectorMex
 * (mex version of the manifold vector function)
 *
 * call: v = ita_beam_manifoldVectorMex(k,arrayPos,scanPos,d_scan,type);
 *
 * 
 */

/* create the complex vector */
// v = exp(1i*k.*d) split into real and imag
// vr = cos(k.*d), vi = sin(k.*d);
void manifold_vector(double *vr, double *vi, double k, double *array,
                       double *scan, double *d_scan, int type,
                       mwSize *dims) {
    
  mwSize i,j,count=0;
  double d_tmp=0,d=0;
  
      // distance between scan point and microphone
      for (i=0; i<*(dims+1); i++) {
          for (j=0; j<*(dims); j++) {
              // convert to linear index
              count = j+i* *(dims);
              switch (type) {
                  case 1:
                      d_tmp = (*(array+3*j)* *(scan+3*i))+
                              (*(array+3*j+1)* *(scan+3*i+1))+
                              (*(array+3*j+2)* *(scan+3*i+2));
                      d = d_tmp/ *(d_scan+i);
                      *(vr+count) = cos(k*d);
                      *(vi+count) = sin(k*d);
                      break;
                  case 2:
                      d_tmp = pow(pow(*(array+3*j)-*(scan+3*i), 2)+
                              pow(*(array+3*j+1)-*(scan+3*i+1), 2)+
                              pow(*(array+3*j+2)-*(scan+3*i+2), 2), 0.5);
                      d = *(d_scan+i) - d_tmp;
                      *(vr+count) = cos(k*d)* *(d_scan+i)/d_tmp;
                      *(vi+count) = sin(k*d)* *(d_scan+i)/d_tmp;
                      break;
                  case 3:
                      d_tmp = pow(pow(*(array+3*j)-*(scan+3*i), 2)+
                              pow(*(array+3*j+1)-*(scan+3*i+1), 2)+
                              pow(*(array+3*j+2)-*(scan+3*i+2), 2), 0.5);
                      d = *(d_scan+i) - d_tmp;
                      *(vr+count) = cos(k*d);
                      *(vi+count) = sin(k*d);
                      break;
                  default:
                      d_tmp = pow(pow(*(array+3*j)-*(scan+3*i), 2)+
                              pow(*(array+3*j+1)-*(scan+3*i+1), 2)+
                              pow(*(array+3*j+2)-*(scan+3*i+2), 2), 0.5);
                      d = *(d_scan+i) - d_tmp;
                      *(vr+count) = cos(k*d);
                      *(vi+count) = sin(k*d);
              }
          }
      }
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]) {
  double *arrayPos,*scanPos,*vr, *vi,*d_scan;
  double k;
  int type;
  mwSize nFreq,nArray,nScan;
  mwSize dims[NDIMS] = {0,0};
  
  /*  check for proper number of arguments */
  if(nrhs!=5) {
      mexErrMsgTxt("Four inputs required.");
  }
  if(nlhs!=1) {
      mexErrMsgTxt("One output required.");
  }
  
  /* check to make sure the first input argument is a scalar */
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      mxGetN(prhs[0])*mxGetM(prhs[0])!=1 ) {
    mexErrMsgTxt("Input 'k' must be a scalar.");
  }
  
  /* check to make sure the last input argument is a scalar */
  if( !mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) ||
      mxGetN(prhs[4])*mxGetM(prhs[4])!=1 ) {
    mexErrMsgTxt("Input 'type' must be a scalar.");
  }
  
  if ((mxGetM(prhs[1])!=3) || ((mxGetM(prhs[2])!=3))) {
      mexErrMsgTxt("Only three-dimensional data.");
  }
  
   /* get the dimensions of the input matrices */
  nArray = mxGetN(prhs[1]);
  nScan  = mxGetN(prhs[2]);
  
  dims[0] = nArray;
  dims[1] = nScan;
  
  if (nScan != mxGetN(prhs[3])) {
      mexErrMsgTxt("Length of the scan mesh and the scan distance vector must match.");
  }
  
  /* create a pointer to the inputs */
  k        = mxGetScalar(prhs[0]);
  arrayPos = mxGetPr(prhs[1]);
  scanPos  = mxGetPr(prhs[2]);
  d_scan   = mxGetPr(prhs[3]);
  type     = mxGetScalar(prhs[4]);
  
  /* set the output pointer to the output matrix */
  plhs[0] = mxCreateNumericArray(NDIMS,dims,mxDOUBLE_CLASS,mxCOMPLEX);
  
  /* create a C pointer to a copy of the output matrix */
  vr = mxGetPr(plhs[0]);
  vi = mxGetPi(plhs[0]);
  
  /* call the C subroutine */
  manifold_vector(vr,vi,k,arrayPos,scanPos,d_scan,type,dims);
}
