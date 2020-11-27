pro fitstopng,filename

	quicklookpath='/poubelle/romagnan/quicklook/'
	img = READFITS(filename, h)
	outf = FILE_BASENAME(filename, '.fits')
	WRITE_PNG,quicklookpath+'/'+outf + ".png", alogscale(img)

END
