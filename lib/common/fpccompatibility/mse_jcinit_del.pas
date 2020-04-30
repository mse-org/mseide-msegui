Unit mse_jcinit_del;

{ Original: jcinit.c ;  Copyright (C) 1991-1997, Thomas G. Lane. }

{ This file contains initialization logic for the JPEG compressor.
  This routine is in charge of selecting the modules to be executed and
  making an initialization call to each one.

  Logically, this code belongs in jcmaster.c.  It's split out because
  linking this routine implies linking the entire compression library.
  For a transcoding-only application, we want to be able to use jcmaster.c
  without linking in the whole library. }

//modified 2013 by Martin Schreiber

interface

{$I mse_jconfig_del.inc}

uses
  mse_jinclude_del,
  mse_jdeferr_del,
  mse_jerror_del,
  mse_jpeglib_del,
{$ifdef C_PROGRESSIVE_SUPPORTED}
  mse_jcphuff_del,
{$endif}
  mse_JcHuff_del, mse_JcMaster_del, mse_JcColor_del, mse_JcSample_del, mse_JcPrepCt_del,
  mse_JcDCTMgr_del, mse_JcCoefCT_del, mse_JcMainCT_del, mse_JcMarker_del;

{ Master selection of compression modules.
  This is done once at the start of processing an image.  We determine
  which modules will be used and give them appropriate initialization calls. }

{GLOBAL}
procedure jinit_compress_master (cinfo : j_compress_ptr);

implementation



{ Master selection of compression modules.
  This is done once at the start of processing an image.  We determine
  which modules will be used and give them appropriate initialization calls. }

{GLOBAL}
procedure jinit_compress_master (cinfo : j_compress_ptr);
begin
  { Initialize master control (includes parameter checking/processing) }
  jinit_c_master_control(cinfo, FALSE { full compression });

  { Preprocessing }
  if (not cinfo^.raw_data_in) then
  begin
    jinit_color_converter(cinfo);
    jinit_downsampler(cinfo);
    jinit_c_prep_controller(cinfo, FALSE { never need full buffer here });
  end;
  { Forward DCT }
  jinit_forward_dct(cinfo);
  { Entropy encoding: either Huffman or arithmetic coding. }
  if (cinfo^.arith_code) then
  begin
    ERREXIT(j_common_ptr(cinfo), JERR_ARITH_NOTIMPL);
  end
  else
  begin
    if (cinfo^.progressive_mode) then
    begin
{$ifdef C_PROGRESSIVE_SUPPORTED}
      jinit_phuff_encoder(cinfo);
{$else}
      ERREXIT(j_common_ptr(cinfo), JERR_NOT_COMPILED);
{$endif}
    end
    else
      jinit_huff_encoder(cinfo);
  end;

  { Need a full-image coefficient buffer in any multi-pass mode. }
  jinit_c_coef_controller(cinfo,
                          (cinfo^.num_scans > 1) or (cinfo^.optimize_coding));
  jinit_c_main_controller(cinfo, FALSE { never need full buffer here });

  jinit_marker_writer(cinfo);

  { We can now tell the memory manager to allocate virtual arrays. }
  cinfo^.mem^.realize_virt_arrays (j_common_ptr(cinfo));

  { Write the datastream header (SOI) immediately.
    Frame and scan headers are postponed till later.
    This lets application insert special markers after the SOI. }

  cinfo^.marker^.write_file_header (cinfo);
end;

end.
