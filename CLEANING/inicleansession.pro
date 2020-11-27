
;=============================================================
; UNIX

; set the explicit path to the gauss/canny library

	dll='/obs/romagnan/C_LIB/gauss.so'
	dll2='/obs/romagnan/C_LIB/canny.so'
	linkimage, 'gauss_smoothing', dll, 1, 'GaussSmoothing'
	linkimage, 'canny', dll2, 1, 'CannyHT'

;=========================================================


end
