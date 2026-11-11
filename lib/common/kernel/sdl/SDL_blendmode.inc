{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{
* # CategoryBlendmode
*
* Blend modes decide how two colors will mix together. There are both
* standard modes for basic needs and a means to create custom modes,
* dictating what sort of math to do on what color components.
}

{*
 * A set of blend modes used in drawing operations.
 *
 * These predefined blend modes are supported everywhere.
 *
 * Additional values may be obtained from SDL_ComposeCustomBlendMode.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_ComposeCustomBlendMode
  }
type
  PPSDL_BlendMode = ^PSDL_BlendMode;
  PSDL_BlendMode = ^TSDL_BlendMode;
  TSDL_BlendMode = cuint32;

const
  SDL_BLENDMODE_NONE = TSDL_BlendMode($00000000);                    {*< no blending: dstRGBA = srcRGBA  }
  SDL_BLENDMODE_BLEND = TSDL_BlendMode($00000001);                   {*< alpha blending: dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA)), dstA = srcA + (dstA * (1-srcA))  }
  SDL_BLENDMODE_BLEND_PREMULTIPLIED = TSDL_BlendMode($00000010);     {*< pre-multiplied alpha blending: dstRGBA = srcRGBA + (dstRGBA * (1-srcA))  }
  SDL_BLENDMODE_ADD = TSDL_BlendMode($00000002);                     {*< additive blending: dstRGB = (srcRGB * srcA) + dstRGB, dstA = dstA  }
  SDL_BLENDMODE_ADD_PREMULTIPLIED = TSDL_BlendMode($00000020);       {*< pre-multiplied additive blending: dstRGB = srcRGB + dstRGB, dstA = dstA  }
  SDL_BLENDMODE_MOD = TSDL_BlendMode($00000004);                     {*< color modulate: dstRGB = srcRGB * dstRGB, dstA = dstA  }
  SDL_BLENDMODE_MUL = TSDL_BlendMode($00000008);                     {*< color multiply: dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA)), dstA = dstA  }
  SDL_BLENDMODE_INVALID = TSDL_BlendMode($7FFFFFFF);

{*
 * The blend operation used when combining source and destination pixel
 * components.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_BlendOperation = ^PSDL_BlendOperation;
  PSDL_BlendOperation = ^TSDL_BlendOperation;
  TSDL_BlendOperation =  Integer;
const
  SDL_BLENDOPERATION_ADD = TSDL_BlendOperation($1);             {*< dst + src: supported by all renderers  }
  SDL_BLENDOPERATION_SUBTRACT = TSDL_BlendOperation($2);        {*< src - dst: supported by D3D, OpenGL, OpenGLES, and Vulkan  }
  SDL_BLENDOPERATION_REV_SUBTRACT = TSDL_BlendOperation($3);    {*< dst - src: supported by D3D, OpenGL, OpenGLES, and Vulkan  }
  SDL_BLENDOPERATION_MINIMUM = TSDL_BlendOperation($4);         {*< min(dst, src): supported by D3D, OpenGL, OpenGLES, and Vulkan  }
  SDL_BLENDOPERATION_MAXIMUM = TSDL_BlendOperation($5);         {*< max(dst, src): supported by D3D, OpenGL, OpenGLES, and Vulkan  }

{*
 * The normalized factor used to multiply pixel components.
 *
 * The blend factors are multiplied with the pixels from a drawing operation
 * (src) and the pixels from the render target (dst) before the blend
 * operation. The comma-separated factors listed above are always applied in
 * the component order red, green, blue, and alpha.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_BlendFactor = ^PSDL_BlendFactor;
  PSDL_BlendFactor = ^TSDL_BlendFactor;
  TSDL_BlendFactor =  Integer;
const
  SDL_BLENDFACTOR_ZERO = TSDL_BlendFactor($1);                  {*< 0, 0, 0, 0  }
  SDL_BLENDFACTOR_ONE = TSDL_BlendFactor($2);                   {*< 1, 1, 1, 1  }
  SDL_BLENDFACTOR_SRC_COLOR = TSDL_BlendFactor($3);             {*< srcR, srcG, srcB, srcA  }
  SDL_BLENDFACTOR_ONE_MINUS_SRC_COLOR = TSDL_BlendFactor($4);   {*< 1-srcR, 1-srcG, 1-srcB, 1-srcA  }
  SDL_BLENDFACTOR_SRC_ALPHA = TSDL_BlendFactor($5);             {*< srcA, srcA, srcA, srcA  }
  SDL_BLENDFACTOR_ONE_MINUS_SRC_ALPHA = TSDL_BlendFactor($6);   {*< 1-srcA, 1-srcA, 1-srcA, 1-srcA  }
  SDL_BLENDFACTOR_DST_COLOR = TSDL_BlendFactor($7);             {*< dstR, dstG, dstB, dstA  }
  SDL_BLENDFACTOR_ONE_MINUS_DST_COLOR = TSDL_BlendFactor($8);   {*< 1-dstR, 1-dstG, 1-dstB, 1-dstA  }
  SDL_BLENDFACTOR_DST_ALPHA = TSDL_BlendFactor($9);             {*< dstA, dstA, dstA, dstA  }
  SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA = TSDL_BlendFactor($A);   {*< 1-dstA, 1-dstA, 1-dstA, 1-dstA  }

{*
 * Compose a custom blend mode for renderers.
 *
 * The functions SDL_SetRenderDrawBlendMode and SDL_SetTextureBlendMode accept
 * the SDL_BlendMode returned by this function if the renderer supports it.
 *
 * A blend mode controls how the pixels from a drawing operation (source) get
 * combined with the pixels from the render target (destination). First, the
 * components of the source and destination pixels get multiplied with their
 * blend factors. Then, the blend operation takes the two products and
 * calculates the result that will get stored in the render target.
 *
 * Expressed in pseudocode, it would look like this:
 *
 * ```c
 * dstRGB = colorOperation(srcRGB * srcColorFactor, dstRGB * dstColorFactor);
 * dstA = alphaOperation(srcA * srcAlphaFactor, dstA * dstAlphaFactor);
 * ```
 *
 * Where the functions `colorOperation(src, dst)` and `alphaOperation(src,
 * dst)` can return one of the following:
 *
 * - `src + dst`
 * - `src - dst`
 * - `dst - src`
 * - `min(src, dst)`
 * - `max(src, dst)`
 *
 * The red, green, and blue components are always multiplied with the first,
 * second, and third components of the SDL_BlendFactor, respectively. The
 * fourth component is not used.
 *
 * The alpha component is always multiplied with the fourth component of the
 * SDL_BlendFactor. The other components are not used in the alpha
 * calculation.
 *
 * Support for these blend modes varies for each renderer. To check if a
 * specific SDL_BlendMode is supported, create a renderer and pass it to
 * either SDL_SetRenderDrawBlendMode or SDL_SetTextureBlendMode. They will
 * return with an error if the blend mode is not supported.
 *
 * This list describes the support of custom blend modes for each renderer.
 * All renderers support the four blend modes listed in the SDL_BlendMode
 * enumeration.
 *
 * - **direct3d**: Supports all operations with all factors. However, some
 *   factors produce unexpected results with `SDL_BLENDOPERATION_MINIMUM` and
 *   `SDL_BLENDOPERATION_MAXIMUM`.
 * - **direct3d11**: Same as Direct3D 9.
 * - **opengl**: Supports the `SDL_BLENDOPERATION_ADD` operation with all
 *   factors. OpenGL versions 1.1, 1.2, and 1.3 do not work correctly here.
 * - **opengles2**: Supports the `SDL_BLENDOPERATION_ADD`,
 *   `SDL_BLENDOPERATION_SUBTRACT`, `SDL_BLENDOPERATION_REV_SUBTRACT`
 *   operations with all factors.
 * - **psp**: No custom blend mode support.
 * - **software**: No custom blend mode support.
 *
 * Some renderers do not provide an alpha component for the default render
 * target. The `SDL_BLENDFACTOR_DST_ALPHA` and
 * `SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA` factors do not have an effect in this
 * case.
 *
 * \param srcColorFactor the SDL_BlendFactor applied to the red, green, and
 *                       blue components of the source pixels.
 * \param dstColorFactor the SDL_BlendFactor applied to the red, green, and
 *                       blue components of the destination pixels.
 * \param colorOperation the SDL_BlendOperation used to combine the red,
 *                       green, and blue components of the source and
 *                       destination pixels.
 * \param srcAlphaFactor the SDL_BlendFactor applied to the alpha component of
 *                       the source pixels.
 * \param dstAlphaFactor the SDL_BlendFactor applied to the alpha component of
 *                       the destination pixels.
 * \param alphaOperation the SDL_BlendOperation used to combine the alpha
 *                       component of the source and destination pixels.
 * \returns an SDL_BlendMode that represents the chosen factors and
 *          operations.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetRenderDrawBlendMode
 * \sa SDL_GetRenderDrawBlendMode
 * \sa SDL_SetTextureBlendMode
 * \sa SDL_GetTextureBlendMode
  }
function SDL_ComposeCustomBlendMode(
           srcColorFactor: TSDL_BlendFactor;
           dstColorFactor: TSDL_BlendFactor;
           colorOperation: TSDL_BlendOperation;
           srcAlphaFactor: TSDL_BlendFactor;
           dstAlphaFactor: TSDL_BlendFactor;
           alphaOperation: TSDL_BlendOperation): TSDL_BlendMode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ComposeCustomBlendMode' {$ENDIF} {$ENDIF};

