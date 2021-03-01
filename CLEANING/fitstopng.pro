pro fitstopng,filename,out_file_path

	img = READFITS(filename, h)
	outf = FILE_BASENAME(filename, '.fits')
	WRITE_PNG,out_file_path+'/'+outf + ".png", alogscale(img)

END
