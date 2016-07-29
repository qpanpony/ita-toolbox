/*=================================================================
 * mls4tap.c
 *
 * Calculates the n order Maximum Length Sequence.
 * Correct taps must be used, and only four taps may be used here.
 *
 * This is a MEX-file for MATLAB.  
 * Bruno Masiero, Feb 2004
 *=================================================================*/
#include <math.h>
#include "mex.h"
#include "matrix.h"

#define	NDIM	2

/* Input Arguments */

#define	N	    prhs[0]
#define	TAP1	prhs[1]
#define	TAP2	prhs[2]
#define	TAP3	prhs[3]
#define	TAP4	prhs[4]

/* Output Arguments */

#define	Y	    plhs[0]
#define	ROW	    plhs[1]
#define	COL	    plhs[2]

void mls(unsigned long int n, unsigned long int tap1, unsigned long int tap2, unsigned long int tap3,
                         unsigned long int tap4, double *y, double *row, double *col)
{
	unsigned int i, j, p, t, L, *temp;
	double *aux;
	L=pow(2,n)-1;
	
	temp = mxCalloc(L, sizeof(unsigned long int));
	aux = mxCalloc(L, sizeof(double));
	
	for (i=0;i<L;i++) *(temp+i) = (unsigned long int)*(y+i);

	for (i=0;i<n;i++) *(temp+i) = 1;                               /*Calcula a sequencia de maximo*/
	for (i=0;i<L-n;i++){
	    *(temp+i+n) = (*(temp+n+i-tap1)^*(temp+n+i-tap2))^(*(temp+n+i-tap3)^*(temp+n+i-tap4));   
	}                                                                /*comprimento de ordem n.*/

	for (i=0;i<L;i++){
		row[i]=0;                                           /*Calcula o vetor de permutacao de linhas.*/
		for (j=0;j<n;j++){                                  
			*(row+i) += *(temp+((i+L-j)%L)) * pow(2,j);
		}
	}

	for (i=0;i<L;i++){
	    t=(unsigned long int)*(row+i);
	    *(aux+t-1)=i+1;
    }
    for (i=0;i<L;i++) *(row+i) = *(aux+i);

	for (i=0;i<L;i++){                                      /*Calcula o vetor de permutacao de colunas.*/
		col[i]=0;                                           
		for (j=0;j<n;j++){
		    p = (unsigned long int)pow(2,j);
			t = (unsigned long int)*(aux+p-1);
			*(col+i) += *(temp+((t-1-i+L)%L)) * pow(2,j);
		}
	}
	
	for (i=0;i<L;i++) *(y+i) = pow(-1,*(temp+i));            /*Mapeia 1 -> -1 e 0 -> 1. */
	
	mxFree(temp);
	mxFree(aux);
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    unsigned long int n, tap1, tap2, tap3, tap4, L;
    double *y, *row, *col;
    
    /* Check for proper number of arguments */
    if (nrhs != 5) {
	mexErrMsgTxt("Three input arguments required.");
    } else if (nlhs > 3) {
	mexErrMsgTxt("Too many output arguments.");
    }

    /* Assign pointers to the input parameters */
    n = (unsigned long int)mxGetScalar(N);
    tap1 = (unsigned long int)mxGetScalar(TAP1);
    tap2 = (unsigned long int)mxGetScalar(TAP2);
    tap3 = (unsigned long int)mxGetScalar(TAP3);
    tap4 = (unsigned long int)mxGetScalar(TAP4);
    L = pow(2,n)-1;
    
    /* Create matrix for the return arguments */
   
    Y = mxCreateDoubleMatrix(L, 1, mxREAL);
    ROW = mxCreateDoubleMatrix(L, 1, mxREAL);
    COL = mxCreateDoubleMatrix(L, 1, mxREAL);
    
    /* Assign pointers to the various parameters */
    y = mxGetPr(Y);
    row = mxGetPr(ROW);
    col = mxGetPr(COL);    

   /* Do the actual computations in a subroutine */
    mls(n,tap1,tap2,tap3,tap4,y,row,col);
    
    return;
}