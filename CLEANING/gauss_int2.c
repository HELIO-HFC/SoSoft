#include <stdio.h>
#include "/usr/local/rsi/idl_6.3/external/export.h"
#include <math.h>  

/* Gaussian Smoothing, Input - integer (short) array, if input type's different FIX function used
*/
IDL_VPTR GaussSmoothing (int argc, IDL_VPTR argv[]) 
{
	IDL_VPTR hNew, hTemp, hOld, src, np;			
	short *lpOldDibBits;
	short *lpNewDibBits;
	short  * lpTemp ;
	long n;
	long i ,j, k, ijn, ir ;
	long cxDib1, cxDib, cyDib ;
	long value;
	static	long mask[15] ;
	static	long w, sum ;
	double smal ;
	double a ;
	

	src=argv[0];
	np=argv[1];
	
	IDL_ENSURE_SIMPLE(src);
	IDL_ENSURE_ARRAY(src);
	

	if (src->type != IDL_TYP_INT)
		src=IDL_CvtFix(1, argv);

	n= np -> value.i;
	cxDib= src->value.arr->dim[0];
	cyDib= src->value.arr->dim[1];
	cxDib1=cxDib;

	lpOldDibBits=(short *)
			IDL_MakeTempArray(IDL_TYP_INT, src->value.arr->n_dim,
			src->value.arr->dim, IDL_ARR_INI_ZERO, &hOld);

	lpOldDibBits=(short *) src->value.arr->data;

	lpNewDibBits=(short *)
			IDL_MakeTempArray(IDL_TYP_INT, src->value.arr->n_dim,
			src->value.arr->dim, IDL_ARR_INI_ZERO, &hNew);

	lpTemp=(short *)
		IDL_MakeTempArray(IDL_TYP_INT, src->value.arr->n_dim,
			src->value.arr->dim, IDL_ARR_INI_ZERO, &hTemp);
	if (n > 7 ) n = 7 ;
	if (n < 2 ) n = 2 ;
	w = 2*n+1 ;
	a = 5.0/w*n ;
	smal = exp(-a*a/2.0) ;
	mask[0] = 1 ;
	sum = 1 ;
	for (i = 1 ; i < 15 ; i++) mask[i] = 0 ;
/*	sum=15;
*/
	for (i = 1 ; i < w ; i++)
	{
		a = 5.0/w*(n-i) ;
		mask[i] = exp(-a*a/2.0)/smal + 0.5 ;
		sum = sum + mask[i] ;
	}
	
	/* first pass rows */
	for ( i = n ; i <= cyDib-n-1 ; i++)
	{  
		ir = i*cxDib1 ;
		for ( j = n ; j <= cxDib1-n-1 ; j++)
		{  
			value = 0;
			ijn = ir+j-n ;
			for (k = 0 ; k <= w-1 ; k++)  value = value + mask [k]* lpOldDibBits [ijn+k];
			value = value/sum ;
		/*	if (value > 255 ) {value = 255 ; } */
			lpTemp [ir+j] = (short) value  ;
	
		}
	}

	/*	 second pass columns */

	for ( i = n ; i <= cyDib-n-1 ; i++)
	{  
		ir = i*cxDib1 ;
		for ( j = n ; j <= cxDib1-n-1 ; j++)
		{  value = 0 ;
			ijn = (i-n)*cxDib1+j ;
			for (k = 0 ; k <= w-1 ; k++)
/*		value = value + mask [k]*lpOldDibBits [(i+k-n)*cxDib1+j] ; */
			{  
				value = value + mask [k]*lpTemp [ijn] ;
				ijn = ijn + cxDib1 ;
			}
			value = value/sum ;
/*			if (value > 255 ) {value = 255 ; } */
				lpNewDibBits [ir+j] = (short) value  ;
	
		}
	}

/*	IDL_Deltmp(src_int); */
	IDL_Deltmp(hTemp);
	IDL_Deltmp(hOld);
	return(hNew);
}



/* Canny Edge Detection, Input - integer (short) array, if input type's different FIX function used
*/

IDL_VPTR CannyHT (int argc, IDL_VPTR argv[]) 
{ 

	IDL_VPTR inIm, hOld, hNew, hTempd, hTempm, hTempe, hTH, hTL;

	short   *lpTempd,   *lpTempm,   *lpTempe ;
	short	*lpOldDibBits, *lpNewDibBits;
	long  cxDib, cyDib, cxDib1, i ,j;
	long value, pos, n, m, dn, dm ;
	double value1, value2, value3, pass ;
	int TH, TL;


	inIm=argv[0];
	hTH=argv[1];
	hTL=argv[2];

	IDL_ENSURE_SIMPLE(inIm);
	IDL_ENSURE_ARRAY(inIm);


	if (inIm->type != IDL_TYP_INT)
		inIm=IDL_CvtFix(1, argv);

	TH=hTH->value.i;
	TL=hTL->value.i;
	cxDib= inIm->value.arr->dim[0];
	cyDib=inIm->value.arr->dim[1];
	
	lpOldDibBits=(short *)
			IDL_MakeTempArray(IDL_TYP_INT, inIm->value.arr->n_dim,
			inIm->value.arr->dim, IDL_ARR_INI_ZERO, &hOld);

	lpOldDibBits=(short *) inIm->value.arr->data;

		lpNewDibBits=(short *)
			IDL_MakeTempArray(IDL_TYP_INT, inIm->value.arr->n_dim,
			inIm->value.arr->dim, IDL_ARR_INI_ZERO, &hNew);

	lpTempd=(short *)
		IDL_MakeTempArray(IDL_TYP_INT, inIm->value.arr->n_dim,
			inIm->value.arr->dim, IDL_ARR_INI_ZERO, &hTempd);

	lpTempe=(short *)
		IDL_MakeTempArray(IDL_TYP_INT, inIm->value.arr->n_dim,
			inIm->value.arr->dim, IDL_ARR_INI_ZERO, &hTempe);

	lpTempm=(short *)
		IDL_MakeTempArray(IDL_TYP_INT, inIm->value.arr->n_dim,
			inIm->value.arr->dim, IDL_ARR_INI_ZERO, &hTempm);

	cxDib1=cxDib;



/*	 "Calculate direction map" 
*/

/* calculate direction map and magnitude map */
	for (i = 1; i < cxDib1-1; i++)
	for (j = 1; j < cyDib-1; j++)
	{
		value1 = lpOldDibBits[j*cxDib1+i+1] - lpOldDibBits[j*cxDib1+i-1] ; /* horizontal derivative */
		value2 = lpOldDibBits[(j+1)*cxDib1+i] - lpOldDibBits[(j-1)*cxDib1+i] ; /* vertical derivative */
		if( fabs(value1) > 0.0 || fabs(value2) > 0)
        {
           	value3 = atan2 (value2, value1) ;
            if(value3 < 0) value3 = value3 + 3.14159 ;
           	if(value3 < 0.393 ){ value = 63 ; }
				else if(value3 < 1.178 ){ value = 127 ; }
				else if(value3 < 1.96 ) { value = 191 ;}
				else if(value3 < 2.74 ) { value = 255 ;}
				else {value = 63 ;  }
        }
        else value = 0 ;

		lpTempd [j*cxDib1+i] = (short) value  ;      /* direction map */
		lpTempm[j*cxDib1+i] = (short) sqrt(value1*value1+value2*value2) ;  /* edge map */
	}

/* suppress non-maximum points in the edge map */
	for (i = 1; i < cxDib1-1; i++)
	for (j = 1; j < cyDib-1; j++)
	{	
		pos = j*cxDib1+i ;
		if(lpTempd[pos] == 0) lpNewDibBits[pos] = 0 ;
		else if(lpTempd[pos] == 63)
		{
			if(lpTempm[pos] < lpTempm[pos+1] || lpTempm[pos] < lpTempm[pos-1]) lpTempe[pos] = 0;
			else lpTempe[pos] = lpTempm[pos] ;
		}
		else if(lpTempd[pos] == 191)
		{
			if(lpTempm[pos] < lpTempm[pos+cxDib1] || lpTempm[pos] < lpTempm[pos-cxDib1]) lpTempe[pos] = 0;
			else lpTempe[pos] = lpTempm[pos] ;
		}
		else if(lpTempd[pos] == 127)
		{
			if(lpTempm[pos] < lpTempm[pos+cxDib1+1] || lpTempm[pos] < lpTempm[pos-cxDib1-1]) lpTempe[pos] = 0;
			else lpTempe[pos] = lpTempm[pos] ;
		}
		else if(lpTempd[pos] == 255)
		{
			if(lpTempm[pos] < lpTempm[pos+cxDib1-1] || lpTempm[pos] < lpTempm[pos-cxDib1+1]) lpTempe[pos] = 0;
			else lpTempe[pos] = lpTempm[pos] ;
		}
	}

/*	sprintf(gcBuf, "Hysteresis tracking" ) ;
/	SetWindowText (ghStatic3, gcBuf) ;
/	UpdateStatusBar(gcBuf, 0, 0) ;
/
/  track local maximum points in the edge map.  Mark edge points with 255 in NewDibBits
/  go in two directions from each starting point (usually opposite)
*/
	for (j = 1; j < cyDib-1; j++)
	for (i = 1; i < cxDib1-1; i++)
	{  pos = j*cxDib1+i ; value = lpTempe[pos] ;
		if(value >= TH && lpNewDibBits[pos] != 255)  /* track edge */
		{
			for (pass = 1; pass <= 2; pass++)
			{n = i ; m = j ; if(pass == 2) value = TH ;
				while (value > TL)
				{  pos = m*cxDib1+n ; dn = dm = 0 ;
					lpNewDibBits[pos] = 255 ; value = 0 ;
/* find n and m of next largest non visited point */
					if(lpNewDibBits[pos+1] != 255 && lpTempe[pos+1] > value) { value = lpTempe[pos+1] ; dn = 1 ; dm = 0 ;}
					if(lpNewDibBits[pos-1] != 255 && lpTempe[pos-1] > value) {value = lpTempe[pos-1] ;  dn = -1 ; dm = 0 ; }

					if(lpNewDibBits[pos+cxDib1] != 255 && lpTempe[pos+cxDib1] > value) { value = lpTempe[pos+cxDib1] ; dn = 0 ; dm = 1 ; }
					if(lpNewDibBits[pos-cxDib1] != 255 && lpTempe[pos-cxDib1] > value) { value = lpTempe[pos-cxDib1] ; dn = 0 ; dm = -1 ; }

					if(lpNewDibBits[pos+cxDib1+1] != 255 && lpTempe[pos+cxDib1+1] > value) { value = lpTempe[pos+cxDib1+1] ; dn = 1 ; dm = 1 ; }
					if(lpNewDibBits[pos-cxDib1-1] != 255 && lpTempe[pos-cxDib1-1] > value) { value = lpTempe[pos-cxDib1-1] ; dn = -1 ; dm = -1 ; }

					if(lpNewDibBits[pos+cxDib1-1] != 255 && lpTempe[pos+cxDib1-1] > value) { value = lpTempe[pos+cxDib1-1] ; dn = -1 ; dm = 1 ; }
					if(lpNewDibBits[pos-cxDib1+1] != 255 && lpTempe[pos-cxDib1+1] > value) { value = lpTempe[pos-cxDib1+1] ; dn = 1 ; dm = -1 ; }
					n = n + dn ; m = m + dm ;
				}
			}
		}
	}




	IDL_Deltmp(hTempm);
	IDL_Deltmp(hTempe);
	IDL_Deltmp(hTempd);
	IDL_Deltmp(hOld);

	 
	return(hNew);

}
