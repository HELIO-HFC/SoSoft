;---------------------------------------------------------------------------
; Init method
;---------------------------------------------------------------------------

FUNCTION ConfigFile::Init

print,'inititititi'
  self.fits_filename  = '*.fits'
  self.pp_out_path    = './'
  self.pp_in_path     = './'
  self.quicklook_path = './'
	self.im_size        = 1
  self.csv_path       = './'
  self.display_res    = 0
  self.dialog         = 0
  self.jpeg_output    = 0
  self.ascii          = 1
	RETURN, self->IDLffxmlsax::Init()
END

;---------------------------------------------------------------------------
; Cleanup method
;---------------------------------------------------------------------------

pro ConfigFile::cleanup
	self->IDLffxmlsax::cleanup
end

;---------------------------------------------------------------------------
; EndElement method
; Called when the parser encounters the end of an element.
;---------------------------------------------------------------------------

PRO ConfigFile::EndElement, URI, local, strName
	case strName of
		"fits_filename"  : self.fits_filename  = self.charBuffer
		"pp_out_path"    : self.pp_out_path    = self.charBuffer
		"pp_in_path"     : self.pp_in_path     = self.charBuffer
	  "quicklook_path" : self.quicklook_path = self.charBuffer
		"im_size"        : self.im_size        = self.charBuffer
    "csv_path"       : self.csv_path       = self.charBuffer
    "display_res"    : self.display_res    = self.charBuffer
    "dialog"         : self.dialog         = self.charBuffer
    "jpeg_output"    : self.jpeg_output    = self.charBuffer
    "ascii"          : self.ascii          = self.charBuffer
	  else:
	endcase
END

;---------------------------------------------------------------------------
; Characters method
; Called when parsing character data within an element.
; Adds data to the charBuffer field.
;---------------------------------------------------------------------------

PRO ConfigFile::characters, data
	self.charBuffer = data
END

;---------------------------------------------------------------------------
; Retourne l'objet sous forme d'une structure
;---------------------------------------------------------------------------

FUNCTION ConfigFile::get_struct
print,'rrrr'  
struc_return = {fits_filename:self.fits_filename,$
    pp_out_path:self.pp_out_path,pp_in_path:self.pp_in_path,$
    quicklook_path:self.quicklook_path,im_size:self.im_size,$
    csv_path:self.csv_path,display_res:self.display_res,$
    jpeg_output:self.jpeg_output,dialog:self.dialog,ascii:self.ascii}
	return, struc_return
END

;---------------------------------------------------------------------------
; DEFINITION DE LA CLASSE OBJET : readConfigFile_default
;---------------------------------------------------------------------------

PRO ConfigFile__define
	; Structure principale
	struct = {ConfigFile, $
	  INHERITS IDLffXMLSAX, $
	  fits_filename:'', $
	  pp_out_path:'', $
	  pp_in_path:'' ,$
    quicklook_path:'' ,$
    csv_path:'',$
    display_res:0,$
    jpeg_output:0,$
    dialog:0,$
    ascii:1,$
		im_size : 0 ,$
    charBuffer:'' $
	}
END

