{ MSEgui Copyright (c) 2011-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseglextglob;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msedynload,{msegl,}msesys,{$ifdef FPC}dynlibs,{$else}classes_del,{$endif}
 msegraphics,msetypes;

type
 glextensionty = (
  {$ifdef mswindows}
  {$else}
  gle_glx,
  gle_glx_mesa,
  {$endif}
  gle_GL_version_1_2,
  gle_GL_ARB_imaging,
  gle_GL_version_1_3,
  gle_GL_ARB_multitexture,
  gle_GL_ARB_transpose_matrix,
  gle_GL_ARB_multisample,
  gle_GL_ARB_texture_env_add,
{$IFDEF msWindows}
  gle_WGL_ARB_extensions_string,
  gle_WGL_ARB_buffer_region,
{$ENDIF}
  gle_GL_ARB_texture_cube_map,
  gle_GL_ARB_depth_texture,
  gle_GL_ARB_point_parameters,
  gle_GL_ARB_shadow,
  gle_GL_ARB_shadow_ambient,
  gle_GL_ARB_texture_border_clamp,
  gle_GL_ARB_texture_compression,
  gle_GL_ARB_texture_env_combine,
  gle_GL_ARB_texture_env_crossbar,
  gle_GL_ARB_texture_env_dot3,
  gle_GL_ARB_texture_mirrored_repeat,
  gle_GL_ARB_vertex_blend,
  gle_GL_ARB_vertex_program,
  gle_GL_ARB_window_pos,
  gle_GL_EXT_422_pixels,
  gle_GL_EXT_abgr,
  gle_GL_EXT_bgra,
  gle_GL_EXT_blend_color,
  gle_GL_EXT_blend_func_separate,
  gle_GL_EXT_blend_logic_op,
  gle_GL_EXT_blend_minmax,
  gle_GL_EXT_blend_subtract,
  gle_GL_EXT_clip_volume_hint,
  gle_GL_EXT_color_subtable,
  gle_GL_EXT_compiled_vertex_array,
  gle_GL_EXT_convolution,
  gle_GL_EXT_fog_coord,
  gle_GL_EXT_histogram,
  gle_GL_EXT_multi_draw_arrays,
  gle_GL_EXT_packed_pixels,
  gle_GL_EXT_paletted_texture,
  gle_GL_EXT_point_parameters,
  gle_GL_EXT_polygon_offset,
  gle_GL_EXT_secondary_color,
  gle_GL_EXT_separate_specular_color,
  gle_GL_EXT_shadow_funcs,
  gle_GL_EXT_shared_texture_palette,
  gle_GL_EXT_stencil_two_side,
  gle_GL_EXT_stencil_wrap,
  gle_GL_EXT_subtexture,
  gle_GL_EXT_texture3D,
  gle_GL_EXT_texture_compression_s3tc,
  gle_GL_EXT_texture_env_add,
  gle_GL_EXT_texture_env_combine,
  gle_GL_EXT_texture_env_dot3,
  gle_GL_EXT_texture_filter_anisotropic,
  gle_GL_EXT_texture_lod_bias,
  gle_GL_EXT_texture_object,
  gle_GL_EXT_vertex_array,
  gle_GL_EXT_vertex_shader,
  gle_GL_EXT_vertex_weighting,
  gle_GL_HP_occlusion_test,
  gle_GL_NV_blend_square,
  gle_GL_NV_copy_depth_to_color,
  gle_GL_NV_depth_clamp,
  gle_GL_NV_evaluators,
  gle_GL_NV_fence,
  gle_GL_NV_fog_distance,
  gle_GL_NV_light_max_exponent,
  gle_GL_NV_multisample_filter_hint,
  gle_GL_NV_occlusion_query,
  gle_GL_NV_packed_depth_stencil,
  gle_GL_NV_point_sprite,
  gle_GL_NV_register_combiners,
  gle_GL_NV_register_combiners2,
  gle_GL_NV_texgen_emboss,
  gle_GL_NV_texgen_reflection,
  gle_GL_NV_texture_compression_vtc,
  gle_GL_NV_texture_env_combine4,
  gle_GL_NV_texture_rectangle,
  gle_GL_NV_texture_shader,
  gle_GL_NV_texture_shader2,
  gle_GL_NV_texture_shader3,
  gle_GL_NV_vertex_array_range,
  gle_GL_NV_vertex_array_range2,
  gle_GL_NV_vertex_program,
  gle_GL_NV_vertex_program1_1,
  gle_GL_ATI_element_array,
  gle_GL_ATI_envmap_bumpmap,
  gle_GL_ATI_fragment_shader,
  gle_GL_ATI_pn_triangles,
  gle_GL_ATI_texture_mirror_once,
  gle_GL_ATI_vertex_array_object,
  gle_GL_ATI_vertex_streams,
{$IFDEF msWindows}
  gle_WGL_I3D_image_buffer,
  gle_WGL_I3D_swap_frame_lock,
  gle_WGL_I3D_swap_frame_usage,
{$ENDIF}
  gle_GL_3DFX_texture_compression_FXT1,
  gle_GL_IBM_cull_vertex,
  gle_GL_IBM_multimode_draw_arrays,
  gle_GL_IBM_raster_pos_clip,
  gle_GL_IBM_texture_mirrored_repeat,
  gle_GL_IBM_vertex_array_lists,
  gle_GL_MESA_resize_buffers,
  gle_GL_MESA_window_pos,
  gle_GL_OML_interlace,
  gle_GL_OML_resample,
  gle_GL_OML_subsample,
  gle_GL_SGIS_generate_mipmap,
  gle_GL_SGIS_multisample,
  gle_GL_SGIS_pixel_texture,
  gle_GL_SGIS_texture_border_clamp,
  gle_GL_SGIS_texture_color_mask,
  gle_GL_SGIS_texture_edge_clamp,
  gle_GL_SGIS_texture_lod,
  gle_GL_SGIS_depth_texture,
  gle_GL_SGIX_fog_offset,
  gle_GL_SGIX_interlace,
  gle_GL_SGIX_shadow_ambient,
  gle_GL_SGI_color_matrix,
  gle_GL_SGI_color_table,
  gle_GL_SGI_texture_color_table,
  gle_GL_SUN_vertex,
  gle_GL_ARB_fragment_program,
  gle_GL_ATI_text_fragment_shader,
  gle_GL_APPLE_client_storage,
  gle_GL_APPLE_element_array,
  gle_GL_APPLE_fence,
  gle_GL_APPLE_vertex_array_object,
  gle_GL_APPLE_vertex_array_range,
{$IFDEF msWindows}
  gle_WGL_ARB_pixel_format,
  gle_WGL_ARB_make_current_read,
  gle_WGL_ARB_pbuffer,
  gle_WGL_EXT_swap_control,
  gle_WGL_ARB_render_texture,
  gle_WGL_EXT_extensions_string,
  gle_WGL_EXT_make_current_read,
  gle_WGL_EXT_pbuffer,
  gle_WGL_EXT_pixel_format,
  gle_WGL_I3D_digital_video_control,
  gle_WGL_I3D_gamma,
  gle_WGL_I3D_genlock,
{$ENDIF}
  gle_GL_ARB_matrix_palette,
  gle_GL_NV_element_array,
  gle_GL_NV_float_buffer,
  gle_GL_NV_fragment_program,
  gle_GL_NV_primitive_restart,
  gle_GL_NV_vertex_program2,
  {$IFDEF msWindows}
  gle_WGL_NV_render_texture_rectangle,
  {$ENDIF}
  gle_GL_NV_pixel_data_range,
  gle_GL_EXT_texture_rectangle,
  gle_GL_S3_s3tc,
  gle_GL_ATI_draw_buffers,
  {$IFDEF msWindows}
  gle_WGL_ATI_pixel_format_float,
  {$ENDIF}
  gle_GL_ATI_texture_env_combine3,
  gle_GL_ATI_texture_float,
  gle_GL_NV_texture_expand_normal,
  gle_GL_NV_half_float,
  gle_GL_ATI_map_object_buffer,
  gle_GL_ATI_separate_stencil,
  gle_GL_ATI_vertex_attrib_array_object,
  gle_GL_ARB_vertex_buffer_object,
  gle_GL_ARB_occlusion_query,
  gle_GL_ARB_shader_objects,
  gle_GL_ARB_vertex_shader,
  gle_GL_ARB_fragment_shader,
  gle_GL_ARB_shading_language_100,
  gle_GL_ARB_texture_non_power_of_two,
  gle_GL_ARB_point_sprite,
  gle_GL_EXT_depth_bounds_test,
  gle_GL_EXT_texture_mirror_clamp,
  gle_GL_EXT_blend_equation_separate,
  gle_GL_MESA_pack_invert,
  gle_GL_MESA_ycbcr_texture,
  gle_GL_ARB_fragment_program_shadow,
  gle_GL_NV_fragment_program_option,
  gle_GL_EXT_pixel_buffer_object,
  gle_GL_NV_fragment_program2,
  gle_GL_NV_vertex_program2_option,
  gle_GL_NV_vertex_program3,
  gle_GL_ARB_draw_buffers,
  gle_GL_ARB_texture_rectangle,
  gle_GL_ARB_color_buffer_float,
  gle_GL_ARB_half_float_pixel,
  gle_GL_ARB_texture_float,
  gle_GL_EXT_texture_compression_dxt1,
  gle_GL_ARB_pixel_buffer_object,
  gle_GL_EXT_framebuffer_object,
  gle_GL_ARB_framebuffer_object,
  gle_GL_ARB_map_buffer_range,
  gle_GL_ARB_vertex_array_object,
  gle_GL_ARB_copy_buffer,
  gle_GL_ARB_uniform_buffer_object,
  gle_GL_ARB_draw_elements_base_vertex,
  gle_GL_ARB_provoking_vertex,
  gle_GL_ARB_sync,
  gle_GL_ARB_texture_multisample,
  gle_GL_ARB_blend_func_extended,
  gle_GL_ARB_sampler_objects,
  gle_GL_ARB_timer_query,
  gle_GL_ARB_vertex_type_2_10_10_10_rev,
  gle_GL_ARB_gpu_shader_fp64,
  gle_GL_ARB_shader_subroutine,
  gle_GL_ARB_tessellation_shader,
  gle_GL_ARB_transform_feedback2,
  gle_GL_ARB_transform_feedback3,
  gle_GL_version_1_4,
  gle_GL_version_1_5,
  gle_GL_version_2_0,
  gle_GL_version_2_1,
  gle_GL_version_3_0,
  gle_GL_version_3_1,
  gle_GL_version_3_2,
  gle_GL_version_3_3,
  gle_GL_version_4_0
 );
 glextensionsty = set of glextensionty;

function mseglparseextensions(const astr: pchar): glextensionsty;
function gldeviceextensions(const device: ptruint): glextensionsty;
function mseglloadextensions(const extensions: array of glextensionty): boolean;
                  //true if ok
var
 libgl: tlibhandle;

procedure init(); //do not use, automatically called by msegl

implementation
uses
 msegl,mseglext,msestrings{$ifdef mswindows}{$else},
                                          mseglx,mseguiintf{$endif},
 mseglu;

type
 glextloaderty = function: boolean;

 glextensioninfoty = record
  name: string;
  loader: glextloaderty;
 end;
var
 loadedextensions: glextensionsty;
 badextensions: glextensionsty;

function gldeviceextensions(const device: ptruint): glextensionsty;
begin
 result:= [];
{$ifdef mswindows}
 if mseglloadextensions([gle_WGL_EXT_extensions_string]) then begin
  result:= result + mseglparseextensions(wglGetExtensionsStringEXT());
 end;
 if mseglloadextensions([gle_WGL_ARB_extensions_string]) then begin
  result:= result + mseglparseextensions(wglGetExtensionsStringARB(device));
 end;
{$else}
 if {$ifndef FPC}@{$endif}glxqueryextensionsstring <> nil then begin
  result:= mseglparseextensions(
       glxqueryextensionsstring(msedisplay,msedefaultscreenno));
 end;
{$endif}
end;

procedure initglext(const ainfo: dynlibinfoty);
begin
 libgl:= ainfo.libhandle;
 initializeglu([]);
end;

procedure deinitglext(const ainfo: dynlibinfoty);
begin
 loadedextensions:= [];
 badextensions:= [];
 releaseglu;
end;

function l_GL_version_1_2: boolean;
begin
 result:= load_GL_version_1_2;
end;

function l_GL_version_1_3: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_1_2]) and load_GL_version_1_3;
end;

function l_GL_version_1_4: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_1_3]) and load_GL_version_1_4;
end;

function l_GL_version_1_5: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_1_4]) and load_GL_version_1_5;
end;

function l_GL_version_2_0: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_1_5]) and load_GL_version_2_0;
end;

function l_GL_version_2_1: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_2_0]) and load_GL_version_2_1;
end;

function l_GL_version_3_0: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_2_1]) and load_GL_version_3_0;
end;

function l_GL_version_3_1: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_3_0]) and load_GL_version_3_1;
end;

function l_GL_version_3_2: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_3_1]) and load_GL_version_3_2;
end;

function l_GL_version_3_3: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_3_2]) and load_GL_version_3_3;
end;

function l_GL_version_4_0: boolean;
begin
 result:= mseglloadextensions([gle_GL_version_3_3]) and load_GL_version_4_0;
end;

const
 glextensions: array[glextensionty] of glextensioninfoty =
 (
  {$ifdef mswindows}
  {$else}
   (name: 'glx'; loader: {$ifdef FPC}@{$endif}load_glx),
   (name: 'glx_mesa'; loader: {$ifdef FPC}@{$endif}load_glx_mesa),
  {$endif}
   (name: 'GL_version_1_2'; loader: {$ifdef FPC}@{$endif}l_GL_version_1_2),
   (name: 'GL_ARB_imaging'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_imaging),
   (name: 'GL_version_1_3'; loader: {$ifdef FPC}@{$endif}l_GL_version_1_3),
   (name: 'GL_ARB_multitexture'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_multitexture),
   (name: 'GL_ARB_transpose_matrix'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_transpose_matrix),
   (name: 'GL_ARB_multisample'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_multisample),
   (name: 'GL_ARB_texture_env_add'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_env_add),
{$IFDEF msWindows}
   (name: 'WGL_ARB_extensions_string'; loader: {$ifdef FPC}@{$endif}load_WGL_ARB_extensions_string),
   (name: 'WGL_ARB_buffer_region'; loader: {$ifdef FPC}@{$endif}load_WGL_ARB_buffer_region),
{$ENDIF}
   (name: 'GL_ARB_texture_cube_map'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_cube_map),
   (name: 'GL_ARB_depth_texture'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_depth_texture),
   (name: 'GL_ARB_point_parameters'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_point_parameters),
   (name: 'GL_ARB_shadow'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_shadow),
   (name: 'GL_ARB_shadow_ambient'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_shadow_ambient),
   (name: 'GL_ARB_texture_border_clamp'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_border_clamp),
   (name: 'GL_ARB_texture_compression'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_compression),
   (name: 'GL_ARB_texture_env_combine'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_env_combine),
   (name: 'GL_ARB_texture_env_crossbar'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_env_crossbar),
   (name: 'GL_ARB_texture_env_dot3'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_env_dot3),
   (name: 'GL_ARB_texture_mirrored_repeat'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_mirrored_repeat),
   (name: 'GL_ARB_vertex_blend'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_vertex_blend),
   (name: 'GL_ARB_vertex_program'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_vertex_program),
   (name: 'GL_ARB_window_pos'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_window_pos),
   (name: 'GL_EXT_422_pixels'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_422_pixels),
   (name: 'GL_EXT_abgr'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_abgr),
   (name: 'GL_EXT_bgra'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_bgra),
   (name: 'GL_EXT_blend_color'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_blend_color),
   (name: 'GL_EXT_blend_func_separate'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_blend_func_separate),
   (name: 'GL_EXT_blend_logic_op'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_blend_logic_op),
   (name: 'GL_EXT_blend_minmax'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_blend_minmax),
   (name: 'GL_EXT_blend_subtract'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_blend_subtract),
   (name: 'GL_EXT_clip_volume_hint'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_clip_volume_hint),
   (name: 'GL_EXT_color_subtable'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_color_subtable),
   (name: 'GL_EXT_compiled_vertex_array'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_compiled_vertex_array),
   (name: 'GL_EXT_convolution'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_convolution),
   (name: 'GL_EXT_fog_coord'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_fog_coord),
   (name: 'GL_EXT_histogram'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_histogram),
   (name: 'GL_EXT_multi_draw_arrays'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_multi_draw_arrays),
   (name: 'GL_EXT_packed_pixels'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_packed_pixels),
   (name: 'GL_EXT_paletted_texture'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_paletted_texture),
   (name: 'GL_EXT_point_parameters'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_point_parameters),
   (name: 'GL_EXT_polygon_offset'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_polygon_offset),
   (name: 'GL_EXT_secondary_color'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_secondary_color),
   (name: 'GL_EXT_separate_specular_color'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_separate_specular_color),
   (name: 'GL_EXT_shadow_funcs'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_shadow_funcs),
   (name: 'GL_EXT_shared_texture_palette'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_shared_texture_palette),
   (name: 'GL_EXT_stencil_two_side'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_stencil_two_side),
   (name: 'GL_EXT_stencil_wrap'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_stencil_wrap),
   (name: 'GL_EXT_subtexture'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_subtexture),
   (name: 'GL_EXT_texture3D'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture3D),
   (name: 'GL_EXT_texture_compression_s3tc'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_compression_s3tc),
   (name: 'GL_EXT_texture_env_add'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_env_add),
   (name: 'GL_EXT_texture_env_combine'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_env_combine),
   (name: 'GL_EXT_texture_env_dot3'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_env_dot3),
   (name: 'GL_EXT_texture_filter_anisotropic'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_filter_anisotropic),
   (name: 'GL_EXT_texture_lod_bias'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_lod_bias),
   (name: 'GL_EXT_texture_object'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_object),
   (name: 'GL_EXT_vertex_array'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_vertex_array),
   (name: 'GL_EXT_vertex_shader'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_vertex_shader),
   (name: 'GL_EXT_vertex_weighting'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_vertex_weighting),
   (name: 'GL_HP_occlusion_test'; loader: {$ifdef FPC}@{$endif}load_GL_HP_occlusion_test),
   (name: 'GL_NV_blend_square'; loader: {$ifdef FPC}@{$endif}load_GL_NV_blend_square),
   (name: 'GL_NV_copy_depth_to_color'; loader: {$ifdef FPC}@{$endif}load_GL_NV_copy_depth_to_color),
   (name: 'GL_NV_depth_clamp'; loader: {$ifdef FPC}@{$endif}load_GL_NV_depth_clamp),
   (name: 'GL_NV_evaluators'; loader: {$ifdef FPC}@{$endif}load_GL_NV_evaluators),
   (name: 'GL_NV_fence'; loader: {$ifdef FPC}@{$endif}load_GL_NV_fence),
   (name: 'GL_NV_fog_distance'; loader: {$ifdef FPC}@{$endif}load_GL_NV_fog_distance),
   (name: 'GL_NV_light_max_exponent'; loader: {$ifdef FPC}@{$endif}load_GL_NV_light_max_exponent),
   (name: 'GL_NV_multisample_filter_hint'; loader: {$ifdef FPC}@{$endif}load_GL_NV_multisample_filter_hint),
   (name: 'GL_NV_occlusion_query'; loader: {$ifdef FPC}@{$endif}load_GL_NV_occlusion_query),
   (name: 'GL_NV_packed_depth_stencil'; loader: {$ifdef FPC}@{$endif}load_GL_NV_packed_depth_stencil),
   (name: 'GL_NV_point_sprite'; loader: {$ifdef FPC}@{$endif}load_GL_NV_point_sprite),
   (name: 'GL_NV_register_combiners'; loader: {$ifdef FPC}@{$endif}load_GL_NV_register_combiners),
   (name: 'GL_NV_register_combiners2'; loader: {$ifdef FPC}@{$endif}load_GL_NV_register_combiners2),
   (name: 'GL_NV_texgen_emboss'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texgen_emboss),
   (name: 'GL_NV_texgen_reflection'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texgen_reflection),
   (name: 'GL_NV_texture_compression_vtc'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texture_compression_vtc),
   (name: 'GL_NV_texture_env_combine4'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texture_env_combine4),
   (name: 'GL_NV_texture_rectangle'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texture_rectangle),
   (name: 'GL_NV_texture_shader'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texture_shader),
   (name: 'GL_NV_texture_shader2'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texture_shader2),
   (name: 'GL_NV_texture_shader3'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texture_shader3),
   (name: 'GL_NV_vertex_array_range'; loader: {$ifdef FPC}@{$endif}load_GL_NV_vertex_array_range),
   (name: 'GL_NV_vertex_array_range2'; loader: {$ifdef FPC}@{$endif}load_GL_NV_vertex_array_range2),
   (name: 'GL_NV_vertex_program'; loader: {$ifdef FPC}@{$endif}load_GL_NV_vertex_program),
   (name: 'GL_NV_vertex_program1_1'; loader: {$ifdef FPC}@{$endif}load_GL_NV_vertex_program1_1),
   (name: 'GL_ATI_element_array'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_element_array),
   (name: 'GL_ATI_envmap_bumpmap'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_envmap_bumpmap),
   (name: 'GL_ATI_fragment_shader'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_fragment_shader),
   (name: 'GL_ATI_pn_triangles'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_pn_triangles),
   (name: 'GL_ATI_texture_mirror_once'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_texture_mirror_once),
   (name: 'GL_ATI_vertex_array_object'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_vertex_array_object),
   (name: 'GL_ATI_vertex_streams'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_vertex_streams),
{$IFDEF msWindows}
   (name: 'WGL_I3D_image_buffer'; loader: {$ifdef FPC}@{$endif}load_WGL_I3D_image_buffer),
   (name: 'WGL_I3D_swap_frame_lock'; loader: {$ifdef FPC}@{$endif}load_WGL_I3D_swap_frame_lock),
   (name: 'WGL_I3D_swap_frame_usage'; loader: {$ifdef FPC}@{$endif}load_WGL_I3D_swap_frame_usage),
{$ENDIF}
   (name: 'GL_3DFX_texture_compression_FXT1'; loader: {$ifdef FPC}@{$endif}load_GL_3DFX_texture_compression_FXT1),
   (name: 'GL_IBM_cull_vertex'; loader: {$ifdef FPC}@{$endif}load_GL_IBM_cull_vertex),
   (name: 'GL_IBM_multimode_draw_arrays'; loader: {$ifdef FPC}@{$endif}load_GL_IBM_multimode_draw_arrays),
   (name: 'GL_IBM_raster_pos_clip'; loader: {$ifdef FPC}@{$endif}load_GL_IBM_raster_pos_clip),
   (name: 'GL_IBM_texture_mirrored_repeat'; loader: {$ifdef FPC}@{$endif}load_GL_IBM_texture_mirrored_repeat),
   (name: 'GL_IBM_vertex_array_lists'; loader: {$ifdef FPC}@{$endif}load_GL_IBM_vertex_array_lists),
   (name: 'GL_MESA_resize_buffers'; loader: {$ifdef FPC}@{$endif}load_GL_MESA_resize_buffers),
   (name: 'GL_MESA_window_pos'; loader: {$ifdef FPC}@{$endif}load_GL_MESA_window_pos),
   (name: 'GL_OML_interlace'; loader: {$ifdef FPC}@{$endif}load_GL_OML_interlace),
   (name: 'GL_OML_resample'; loader: {$ifdef FPC}@{$endif}load_GL_OML_resample),
   (name: 'GL_OML_subsample'; loader: {$ifdef FPC}@{$endif}load_GL_OML_subsample),
   (name: 'GL_SGIS_generate_mipmap'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_generate_mipmap),
   (name: 'GL_SGIS_multisample'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_multisample),
   (name: 'GL_SGIS_pixel_texture'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_pixel_texture),
   (name: 'GL_SGIS_texture_border_clamp'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_texture_border_clamp),
   (name: 'GL_SGIS_texture_color_mask'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_texture_color_mask),
   (name: 'GL_SGIS_texture_edge_clamp'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_texture_edge_clamp),
   (name: 'GL_SGIS_texture_lod'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_texture_lod),
   (name: 'GL_SGIS_depth_texture'; loader: {$ifdef FPC}@{$endif}load_GL_SGIS_depth_texture),
   (name: 'GL_SGIX_fog_offset'; loader: {$ifdef FPC}@{$endif}load_GL_SGIX_fog_offset),
   (name: 'GL_SGIX_interlace'; loader: {$ifdef FPC}@{$endif}load_GL_SGIX_interlace),
   (name: 'GL_SGIX_shadow_ambient'; loader: {$ifdef FPC}@{$endif}load_GL_SGIX_shadow_ambient),
   (name: 'GL_SGI_color_matrix'; loader: {$ifdef FPC}@{$endif}load_GL_SGI_color_matrix),
   (name: 'GL_SGI_color_table'; loader: {$ifdef FPC}@{$endif}load_GL_SGI_color_table),
   (name: 'GL_SGI_texture_color_table'; loader: {$ifdef FPC}@{$endif}load_GL_SGI_texture_color_table),
   (name: 'GL_SUN_vertex'; loader: {$ifdef FPC}@{$endif}load_GL_SUN_vertex),
   (name: 'GL_ARB_fragment_program'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_fragment_program),
   (name: 'GL_ATI_text_fragment_shader'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_text_fragment_shader),
   (name: 'GL_APPLE_client_storage'; loader: {$ifdef FPC}@{$endif}load_GL_APPLE_client_storage),
   (name: 'GL_APPLE_element_array'; loader: {$ifdef FPC}@{$endif}load_GL_APPLE_element_array),
   (name: 'GL_APPLE_fence'; loader: {$ifdef FPC}@{$endif}load_GL_APPLE_fence),
   (name: 'GL_APPLE_vertex_array_object'; loader: {$ifdef FPC}@{$endif}load_GL_APPLE_vertex_array_object),
   (name: 'GL_APPLE_vertex_array_range'; loader: {$ifdef FPC}@{$endif}load_GL_APPLE_vertex_array_range),
{$IFDEF msWindows}
   (name: 'WGL_ARB_pixel_format'; loader: {$ifdef FPC}@{$endif}load_WGL_ARB_pixel_format),
   (name: 'WGL_ARB_make_current_read'; loader: {$ifdef FPC}@{$endif}load_WGL_ARB_make_current_read),
   (name: 'WGL_ARB_pbuffer'; loader: {$ifdef FPC}@{$endif}load_WGL_ARB_pbuffer),
   (name: 'WGL_EXT_swap_control'; loader: {$ifdef FPC}@{$endif}load_WGL_EXT_swap_control),
   (name: 'WGL_ARB_render_texture'; loader: {$ifdef FPC}@{$endif}load_WGL_ARB_render_texture),
   (name: 'WGL_EXT_extensions_string'; loader: {$ifdef FPC}@{$endif}load_WGL_EXT_extensions_string),
   (name: 'WGL_EXT_make_current_read'; loader: {$ifdef FPC}@{$endif}load_WGL_EXT_make_current_read),
   (name: 'WGL_EXT_pbuffer'; loader: {$ifdef FPC}@{$endif}load_WGL_EXT_pbuffer),
   (name: 'WGL_EXT_pixel_format'; loader: {$ifdef FPC}@{$endif}load_WGL_EXT_pixel_format),
   (name: 'WGL_I3D_digital_video_control'; loader: {$ifdef FPC}@{$endif}load_WGL_I3D_digital_video_control),
   (name: 'WGL_I3D_gamma'; loader: {$ifdef FPC}@{$endif}load_WGL_I3D_gamma),
   (name: 'WGL_I3D_genlock'; loader: {$ifdef FPC}@{$endif}load_WGL_I3D_genlock),
{$ENDIF}
   (name: 'GL_ARB_matrix_palette'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_matrix_palette),
   (name: 'GL_NV_element_array'; loader: {$ifdef FPC}@{$endif}load_GL_NV_element_array),
   (name: 'GL_NV_float_buffer'; loader: {$ifdef FPC}@{$endif}load_GL_NV_float_buffer),
   (name: 'GL_NV_fragment_program'; loader: {$ifdef FPC}@{$endif}load_GL_NV_fragment_program),
   (name: 'GL_NV_primitive_restart'; loader: {$ifdef FPC}@{$endif}load_GL_NV_primitive_restart),
   (name: 'GL_NV_vertex_program2'; loader: {$ifdef FPC}@{$endif}load_GL_NV_vertex_program2),
  {$IFDEF msWindows}
   (name: 'WGL_NV_render_texture_rectangle'; loader: {$ifdef FPC}@{$endif}load_WGL_NV_render_texture_rectangle),
  {$ENDIF}
   (name: 'GL_NV_pixel_data_range'; loader: {$ifdef FPC}@{$endif}load_GL_NV_pixel_data_range),
   (name: 'GL_EXT_texture_rectangle'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_rectangle),
   (name: 'GL_S3_s3tc'; loader: {$ifdef FPC}@{$endif}load_GL_S3_s3tc),
   (name: 'GL_ATI_draw_buffers'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_draw_buffers),
  {$IFDEF msWindows}
   (name: 'WGL_ATI_pixel_format_float'; loader: {$ifdef FPC}@{$endif}load_WGL_ATI_pixel_format_float),
  {$ENDIF}
   (name: 'GL_ATI_texture_env_combine3'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_texture_env_combine3),
   (name: 'GL_ATI_texture_float'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_texture_float),
   (name: 'GL_NV_texture_expand_normal'; loader: {$ifdef FPC}@{$endif}load_GL_NV_texture_expand_normal),
   (name: 'GL_NV_half_float'; loader: {$ifdef FPC}@{$endif}load_GL_NV_half_float),
   (name: 'GL_ATI_map_object_buffer'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_map_object_buffer),
   (name: 'GL_ATI_separate_stencil'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_separate_stencil),
   (name: 'GL_ATI_vertex_attrib_array_object'; loader: {$ifdef FPC}@{$endif}load_GL_ATI_vertex_attrib_array_object),
   (name: 'GL_ARB_vertex_buffer_object'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_vertex_buffer_object),
   (name: 'GL_ARB_occlusion_query'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_occlusion_query),
   (name: 'GL_ARB_shader_objects'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_shader_objects),
   (name: 'GL_ARB_vertex_shader'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_vertex_shader),
   (name: 'GL_ARB_fragment_shader'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_fragment_shader),
   (name: 'GL_ARB_shading_language_100'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_shading_language_100),
   (name: 'GL_ARB_texture_non_power_of_two'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_non_power_of_two),
   (name: 'GL_ARB_point_sprite'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_point_sprite),
   (name: 'GL_EXT_depth_bounds_test'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_depth_bounds_test),
   (name: 'GL_EXT_texture_mirror_clamp'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_mirror_clamp),
   (name: 'GL_EXT_blend_equation_separate'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_blend_equation_separate),
   (name: 'GL_MESA_pack_invert'; loader: {$ifdef FPC}@{$endif}load_GL_MESA_pack_invert),
   (name: 'GL_MESA_ycbcr_texture'; loader: {$ifdef FPC}@{$endif}load_GL_MESA_ycbcr_texture),
   (name: 'GL_ARB_fragment_program_shadow'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_fragment_program_shadow),
   (name: 'GL_NV_fragment_program_option'; loader: {$ifdef FPC}@{$endif}load_GL_NV_fragment_program_option),
   (name: 'GL_EXT_pixel_buffer_object'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_pixel_buffer_object),
   (name: 'GL_NV_fragment_program2'; loader: {$ifdef FPC}@{$endif}load_GL_NV_fragment_program2),
   (name: 'GL_NV_vertex_program2_option'; loader: {$ifdef FPC}@{$endif}load_GL_NV_vertex_program2_option),
   (name: 'GL_NV_vertex_program3'; loader: {$ifdef FPC}@{$endif}load_GL_NV_vertex_program3),
   (name: 'GL_ARB_draw_buffers'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_draw_buffers),
   (name: 'GL_ARB_texture_rectangle'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_rectangle),
   (name: 'GL_ARB_color_buffer_float'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_color_buffer_float),
   (name: 'GL_ARB_half_float_pixel'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_half_float_pixel),
   (name: 'GL_ARB_texture_float'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_float),
   (name: 'GL_EXT_texture_compression_dxt1'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_texture_compression_dxt1),
   (name: 'GL_ARB_pixel_buffer_object'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_pixel_buffer_object),
   (name: 'GL_EXT_framebuffer_object'; loader: {$ifdef FPC}@{$endif}load_GL_EXT_framebuffer_object),
   (name: 'GL_ARB_framebuffer_object'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_framebuffer_object),
   (name: 'GL_ARB_map_buffer_range'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_map_buffer_range),
   (name: 'GL_ARB_vertex_array_object'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_vertex_array_object),
   (name: 'GL_ARB_copy_buffer'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_copy_buffer),
   (name: 'GL_ARB_uniform_buffer_object'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_uniform_buffer_object),
   (name: 'GL_ARB_draw_elements_base_vertex'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_draw_elements_base_vertex),
   (name: 'GL_ARB_provoking_vertex'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_provoking_vertex),
   (name: 'GL_ARB_sync'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_sync),
   (name: 'GL_ARB_texture_multisample'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_texture_multisample),
   (name: 'GL_ARB_blend_func_extended'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_blend_func_extended),
   (name: 'GL_ARB_sampler_objects'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_sampler_objects),
   (name: 'GL_ARB_timer_query'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_timer_query),
   (name: 'GL_ARB_vertex_type_2_10_10_10_rev'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_vertex_type_2_10_10_10_rev),
   (name: 'GL_ARB_gpu_shader_fp64'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_gpu_shader_fp64),
   (name: 'GL_ARB_shader_subroutine'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_shader_subroutine),
   (name: 'GL_ARB_tessellation_shader'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_tessellation_shader),
   (name: 'GL_ARB_transform_feedback2'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_transform_feedback2),
   (name: 'GL_ARB_transform_feedback3'; loader: {$ifdef FPC}@{$endif}load_GL_ARB_transform_feedback3),
   (name: 'GL_version_1_4'; loader: {$ifdef FPC}@{$endif}l_GL_version_1_4),
   (name: 'GL_version_1_5'; loader: {$ifdef FPC}@{$endif}l_GL_version_1_5),
   (name: 'GL_version_2_0'; loader: {$ifdef FPC}@{$endif}l_GL_version_2_0),
   (name: 'GL_version_2_1'; loader: {$ifdef FPC}@{$endif}l_GL_version_2_1),
   (name: 'GL_version_3_0'; loader: {$ifdef FPC}@{$endif}l_GL_version_3_0),
   (name: 'GL_version_3_1'; loader: {$ifdef FPC}@{$endif}l_GL_version_3_1),
   (name: 'GL_version_3_2'; loader: {$ifdef FPC}@{$endif}l_GL_version_3_2),
   (name: 'GL_version_3_3'; loader: {$ifdef FPC}@{$endif}l_GL_version_3_3),
   (name: 'GL_version_4_0'; loader: {$ifdef FPC}@{$endif}l_GL_version_4_0)
   );

function mseglparseextensions(const astr: pchar): glextensionsty;
var
 ar1: stringarty;
 int1: integer;
 str1: string;
 ext1: glextensionty;
begin
 result:= [];
 ar1:= splitstring(astr,' ');
 for int1:= 0 to high(ar1) do begin
  for ext1:= low(ext1) to high(ext1) do begin
   pointer(str1):= pointer(ar1[int1]); //no refcount
   if glextensions[ext1].name = str1 then begin
    include(result,ext1);
    break;
   end;
  end;
 end;
end;

function mseglloadextensions(const extensions: array of glextensionty): boolean;
var
 int1: integer;
 ext: glextensionty;
begin
 result:= true;
 for int1:= 0 to high(extensions) do begin
  ext:= extensions[int1];
  if ext in badextensions then begin
   result:= false;
  end
  else begin
   if not (ext in loadedextensions) then begin
    if glextensions[ext].loader() then begin
     include(loadedextensions,ext);
    end
    else begin
     include(badextensions,ext);
     result:= false;
    end;
   end;
  end;
 end;
end;

procedure init();
begin
 regglinit(@initglext);
 reggldeinit(@deinitglext);
end;

initialization
// regglinit(@initglext);     //msegl not yet initialized
// reggldeinit(@deinitglext);
end.