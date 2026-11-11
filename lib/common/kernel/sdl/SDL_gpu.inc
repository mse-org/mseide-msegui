{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryGPU
 *
 * The GPU API offers a cross-platform way for apps to talk to modern graphics
 * hardware. It offers both 3D graphics and compute support, in the style of
 * Metal, Vulkan, and Direct3D 12.
 *
 * A basic workflow might be something like this:
 *
 * The app creates a GPU device with SDL_CreateGPUDevice(), and assigns it to
 * a window with SDL_ClaimWindowForGPUDevice()--although strictly speaking you
 * can render offscreen entirely, perhaps for image processing, and not use a
 * window at all.
 *
 * Next, the app prepares static data (things that are created once and used
 * over and over). For example:
 *
 * - Shaders (programs that run on the GPU): use SDL_CreateGPUShader().
 * - Vertex buffers (arrays of geometry data) and other rendering data: use
 *   SDL_CreateGPUBuffer() and SDL_UploadToGPUBuffer().
 * - Textures (images): use SDL_CreateGPUTexture() and
 *   SDL_UploadToGPUTexture().
 * - Samplers (how textures should be read from): use SDL_CreateGPUSampler().
 * - Render pipelines (precalculated rendering state): use
 *   SDL_CreateGPUGraphicsPipeline()
 *
 * To render, the app creates one or more command buffers, with
 * SDL_AcquireGPUCommandBuffer(). Command buffers collect rendering
 * instructions that will be submitted to the GPU in batch. Complex scenes can
 * use multiple command buffers, maybe configured across multiple threads in
 * parallel, as long as they are submitted in the correct order, but many apps
 * will just need one command buffer per frame.
 *
 * Rendering can happen to a texture (what other APIs call a "render target")
 * or it can happen to the swapchain texture (which is just a special texture
 * that represents a window's contents). The app can use
 * SDL_WaitAndAcquireGPUSwapchainTexture() to render to the window.
 *
 * Rendering actually happens in a Render Pass, which is encoded into a
 * command buffer. One can encode multiple render passes (or alternate between
 * render and compute passes) in a single command buffer, but many apps might
 * simply need a single render pass in a single command buffer. Render Passes
 * can render to up to four color textures and one depth texture
 * simultaneously. If the set of textures being rendered to needs to change,
 * the Render Pass must be ended and a new one must be begun.
 *
 * The app calls SDL_BeginGPURenderPass(). Then it sets states it needs for
 * each draw:
 *
 * - SDL_BindGPUGraphicsPipeline()
 * - SDL_SetGPUViewport()
 * - SDL_BindGPUVertexBuffers()
 * - SDL_BindGPUVertexSamplers()
 * - etc
 *
 * Then, make the actual draw commands with these states:
 *
 * - SDL_DrawGPUPrimitives()
 * - SDL_DrawGPUPrimitivesIndirect()
 * - SDL_DrawGPUIndexedPrimitivesIndirect()
 * - etc
 *
 * After all the drawing commands for a pass are complete, the app should call
 * SDL_EndGPURenderPass(). Once a render pass ends all render-related state is
 * reset.
 *
 * The app can begin new Render Passes and make new draws in the same command
 * buffer until the entire scene is rendered.
 *
 * Once all of the render commands for the scene are complete, the app calls
 * SDL_SubmitGPUCommandBuffer() to send it to the GPU for processing.
 *
 * If the app needs to read back data from texture or buffers, the API has an
 * efficient way of doing this, provided that the app is willing to tolerate
 * some latency. When the app uses SDL_DownloadFromGPUTexture() or
 * SDL_DownloadFromGPUBuffer(), submitting the command buffer with
 * SDL_SubmitGPUCommandBufferAndAcquireFence() will return a fence handle that
 * the app can poll or wait on in a thread. Once the fence indicates that the
 * command buffer is done processing, it is safe to read the downloaded data.
 * Make sure to call SDL_ReleaseGPUFence() when done with the fence.
 *
 * The API also has "compute" support. The app calls SDL_BeginGPUComputePass()
 * with compute-writeable textures and/or buffers, which can be written to in
 * a compute shader. Then it sets states it needs for the compute dispatches:
 *
 * - SDL_BindGPUComputePipeline()
 * - SDL_BindGPUComputeStorageBuffers()
 * - SDL_BindGPUComputeStorageTextures()
 *
 * Then, dispatch compute work:
 *
 * - SDL_DispatchGPUCompute()
 *
 * For advanced users, this opens up powerful GPU-driven workflows.
 *
 * Graphics and compute pipelines require the use of shaders, which as
 * mentioned above are small programs executed on the GPU. Each backend
 * (Vulkan, Metal, D3D12) requires a different shader format. When the app
 * creates the GPU device, the app lets the device know which shader formats
 * the app can provide. It will then select the appropriate backend depending
 * on the available shader formats and the backends available on the platform.
 * When creating shaders, the app must provide the correct shader format for
 * the selected backend. If you would like to learn more about why the API
 * works this way, there is a detailed
 * [blog post](https://moonside.games/posts/layers-all-the-way-down/)
 * explaining this situation.
 *
 * It is optimal for apps to pre-compile the shader formats they might use,
 * but for ease of use SDL provides a separate project,
 * [SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross)
 * , for performing runtime shader cross-compilation. It also has a CLI
 * interface for offline precompilation as well.
 *
 * This is an extremely quick overview that leaves out several important
 * details. Already, though, one can see that GPU programming can be quite
 * complex! If you just need simple 2D graphics, the
 * [Render API](https://wiki.libsdl.org/SDL3/CategoryRender)
 * is much easier to use but still hardware-accelerated. That said, even for
 * 2D applications the performance benefits and expressiveness of the GPU API
 * are significant.
 *
 * The GPU API targets a feature set with a wide range of hardware support and
 * ease of portability. It is designed so that the app won't have to branch
 * itself by querying feature support. If you need cutting-edge features with
 * limited hardware support, this API is probably not for you.
 *
 * Examples demonstrating proper usage of this API can be found
 * [here](https://github.com/TheSpydog/SDL_gpu_examples)
 * .
 *
 * ## Performance considerations
 *
 * Here are some basic tips for maximizing your rendering performance.
 *
 * - Beginning a new render pass is relatively expensive. Use as few render
 *   passes as you can.
 * - Minimize the amount of state changes. For example, binding a pipeline is
 *   relatively cheap, but doing it hundreds of times when you don't need to
 *   will slow the performance significantly.
 * - Perform your data uploads as early as possible in the frame.
 * - Don't churn resources. Creating and releasing resources is expensive.
 *   It's better to create what you need up front and cache it.
 * - Don't use uniform buffers for large amounts of data (more than a matrix
 *   or so). Use a storage buffer instead.
 * - Use cycling correctly. There is a detailed explanation of cycling further
 *   below.
 * - Use culling techniques to minimize pixel writes. The less writing the GPU
 *   has to do the better. Culling can be a very advanced topic but even
 *   simple culling techniques can boost performance significantly.
 *
 * In general try to remember the golden rule of performance: doing things is
 * more expensive than not doing things. Don't Touch The Driver!
 *
 * ## FAQ
 *
 * **Question: When are you adding more advanced features, like ray tracing or
 * mesh shaders?**
 *
 * Answer: We don't have immediate plans to add more bleeding-edge features,
 * but we certainly might in the future, when these features prove worthwhile,
 * and reasonable to implement across several platforms and underlying APIs.
 * So while these things are not in the "never" category, they are definitely
 * not "near future" items either.
 *
 * **Question: Why is my shader not working?**
 *
 * Answer: A common oversight when using shaders is not properly laying out
 * the shader resources/registers correctly. The GPU API is very strict with
 * how it wants resources to be laid out and it's difficult for the API to
 * automatically validate shaders to see if they have a compatible layout. See
 * the documentation for SDL_CreateGPUShader() and
 * SDL_CreateGPUComputePipeline() for information on the expected layout.
 *
 * Another common issue is not setting the correct number of samplers,
 * textures, and buffers in SDL_GPUShaderCreateInfo. If possible use shader
 * reflection to extract the required information from the shader
 * automatically instead of manually filling in the struct's values.
 *
 * **Question: My application isn't performing very well. Is this the GPU
 * API's fault?**
 *
 * Answer: No. Long answer: The GPU API is a relatively thin layer over the
 * underlying graphics API. While it's possible that we have done something
 * inefficiently, it's very unlikely especially if you are relatively
 * inexperienced with GPU rendering. Please see the performance tips above and
 * make sure you are following them. Additionally, tools like
 * [RenderDoc](https://renderdoc.org/)
 * can be very helpful for diagnosing incorrect behavior and performance
 * issues.
 *
 * ## System Requirements
 *
 * ### Vulkan
 *
 * SDL driver name: "vulkan" (for use in SDL_CreateGPUDevice() and
 * SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING)
 *
 * Supported on Windows, Linux, Nintendo Switch, and certain Android devices.
 * Requires Vulkan 1.0 with the following extensions and device features:
 *
 * - `VK_KHR_swapchain`
 * - `VK_KHR_maintenance1`
 * - `independentBlend`
 * - `imageCubeArray`
 * - `depthClamp`
 * - `shaderClipDistance`
 * - `drawIndirectFirstInstance`
 * - `sampleRateShading`
 *
 * You can remove some of these requirements to increase compatibility with
 * Android devices by using these properties when creating the GPU device with
 * SDL_CreateGPUDeviceWithProperties():
 *
 * - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_CLIP_DISTANCE_BOOLEAN
 * - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_DEPTH_CLAMPING_BOOLEAN
 * - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_INDIRECT_DRAW_FIRST_INSTANCE_BOOLEAN
 * - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_ANISOTROPY_BOOLEAN
 *
 * ### D3D12
 *
 * SDL driver name: "direct3d12"
 *
 * Supported on Windows 10 or newer, Xbox One (GDK), and Xbox Series X|S
 * (GDK). Requires a GPU that supports DirectX 12 Feature Level 11_0 and
 * Resource Binding Tier 2 or above.
 *
 * You can remove the Tier 2 resource binding requirement to support Intel
 * Haswell and Broadwell GPUs by using this property when creating the GPU
 * device with SDL_CreateGPUDeviceWithProperties():
 *
 * - SDL_PROP_GPU_DEVICE_CREATE_D3D12_ALLOW_FEWER_RESOURCE_SLOTS_BOOLEAN
 *
 * ### Metal
 *
 * SDL driver name: "metal"
 *
 * Supported on macOS 10.14+ and iOS/tvOS 13.0+. Hardware requirements vary by
 * operating system:
 *
 * - macOS requires an Apple Silicon or
 *   [Intel Mac2 family](https://developer.apple.com/documentation/metal/mtlfeatureset/mtlfeatureset_macos_gpufamily2_v1?language=objc)
 *   GPU
 * - iOS/tvOS requires an A9 GPU or newer
 * - iOS Simulator and tvOS Simulator are unsupported
 *
 * ## Coordinate System
 *
 * The GPU API uses a left-handed coordinate system, following the convention
 * of D3D12 and Metal. Specifically:
 *
 * - **Normalized Device Coordinates:** The lower-left corner has an x,y
 *   coordinate of `(-1.0, -1.0)`. The upper-right corner is `(1.0, 1.0)`. Z
 *   values range from `[0.0, 1.0]` where 0 is the near plane.
 * - **Viewport Coordinates:** The top-left corner has an x,y coordinate of
 *   `(0, 0)` and extends to the bottom-right corner at `(viewportWidth,
 *   viewportHeight)`. +Y is down.
 * - **Texture Coordinates:** The top-left corner has an x,y coordinate of
 *   `(0, 0)` and extends to the bottom-right corner at `(1.0, 1.0)`. +Y is
 *   down.
 *
 * If the backend driver differs from this convention (e.g. Vulkan, which has
 * an NDC that assumes +Y is down), SDL will automatically convert the
 * coordinate system behind the scenes, so you don't need to perform any
 * coordinate flipping logic in your shaders.
 *
 * ## Uniform Data
 *
 * Uniforms are for passing data to shaders. The uniform data will be constant
 * across all executions of the shader.
 *
 * There are 4 available uniform slots per shader stage (where the stages are
 * vertex, fragment, and compute). Uniform data pushed to a slot on a stage
 * keeps its value throughout the command buffer until you call the relevant
 * Push function on that slot again.
 *
 * For example, you could write your vertex shaders to read a camera matrix
 * from uniform binding slot 0, push the camera matrix at the start of the
 * command buffer, and that data will be used for every subsequent draw call.
 *
 * It is valid to push uniform data during a render or compute pass.
 *
 * Uniforms are best for pushing small amounts of data. If you are pushing
 * more than a matrix or two per call you should consider using a storage
 * buffer instead.
 *
 * ## A Note On Cycling
 *
 * When using a command buffer, operations do not occur immediately - they
 * occur some time after the command buffer is submitted.
 *
 * When a resource is used in a pending or active command buffer, it is
 * considered to be "bound". When a resource is no longer used in any pending
 * or active command buffers, it is considered to be "unbound".
 *
 * If data resources are bound, it is unspecified when that data will be
 * unbound unless you acquire a fence when submitting the command buffer and
 * wait on it. However, this doesn't mean you need to track resource usage
 * manually.
 *
 * All of the functions and structs that involve writing to a resource have a
 * "cycle" bool. SDL_GPUTransferBuffer, SDL_GPUBuffer, and SDL_GPUTexture all
 * effectively function as ring buffers on internal resources. When cycle is
 * true, if the resource is bound, the cycle rotates to the next unbound
 * internal resource, or if none are available, a new one is created. This
 * means you don't have to worry about complex state tracking and
 * synchronization as long as cycling is correctly employed.
 *
 * For example: you can call SDL_MapGPUTransferBuffer(), write texture data,
 * SDL_UnmapGPUTransferBuffer(), and then SDL_UploadToGPUTexture(). The next
 * time you write texture data to the transfer buffer, if you set the cycle
 * param to true, you don't have to worry about overwriting any data that is
 * not yet uploaded.
 *
 * Another example: If you are using a texture in a render pass every frame,
 * this can cause a data dependency between frames. If you set cycle to true
 * in the SDL_GPUColorTargetInfo struct, you can prevent this data dependency.
 *
 * Cycling will never undefine already bound data. When cycling, all data in
 * the resource is considered to be undefined for subsequent commands until
 * that data is written again. You must take care not to read undefined data.
 *
 * Note that when cycling a texture, the entire texture will be cycled, even
 * if only part of the texture is used in the call, so you must consider the
 * entire texture to contain undefined data after cycling.
 *
 * You must also take care not to overwrite a section of data that has been
 * referenced in a command without cycling first. It is OK to overwrite
 * unreferenced data in a bound resource without cycling, but overwriting a
 * section of data that has already been referenced will produce unexpected
 * results.
 *
 * ## Debugging
 *
 * At some point of your GPU journey, you will probably encounter issues that
 * are not traceable with regular debugger - for example, your code compiles
 * but you get an empty screen, or your shader fails in runtime.
 *
 * For debugging such cases, there are tools that allow visually inspecting
 * the whole GPU frame, every drawcall, every bound resource, memory buffers,
 * etc. They are the following, per platform:
 *
 * * For Windows/Linux, use
 *   [RenderDoc](https://renderdoc.org/)
 * * For MacOS (Metal), use Xcode built-in debugger (Open XCode, go to Debug >
 *   Debug Executable..., select your application, set "GPU Frame Capture" to
 *   "Metal" in scheme "Options" window, run your app, and click the small
 *   Metal icon on the bottom to capture a frame)
 *
 * Aside from that, you may want to enable additional debug layers to receive
 * more detailed error messages, based on your GPU backend:
 *
 * * For D3D12, the debug layer is an optional feature that can be installed
 *   via "Windows Settings -> System -> Optional features" and adding the
 *   "Graphics Tools" optional feature.
 * * For Vulkan, you will need to install Vulkan SDK on Windows, and on Linux,
 *   you usually have some sort of `vulkan-validation-layers` system package
 *   that should be installed.
 * * For Metal, it should be enough just to run the application from XCode to
 *   receive detailed errors or warnings in the output.
 *
 * Don't hesitate to use tools as RenderDoc when encountering runtime issues
 * or unexpected output on screen, quick GPU frame inspection can usually help
 * you fix the majority of such problems.
  }

{ Type Declarations  }

{*
 * An opaque handle representing the SDL_GPU context.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_GPUDevice = ^PSDL_GPUDevice;
  PSDL_GPUDevice = type Pointer;

{*
 * An opaque handle representing a buffer.
 *
 * Used for vertices, indices, indirect draw commands, and general compute
 * data.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUBuffer
 * \sa SDL_UploadToGPUBuffer
 * \sa SDL_DownloadFromGPUBuffer
 * \sa SDL_CopyGPUBufferToBuffer
 * \sa SDL_BindGPUVertexBuffers
 * \sa SDL_BindGPUIndexBuffer
 * \sa SDL_BindGPUVertexStorageBuffers
 * \sa SDL_BindGPUFragmentStorageBuffers
 * \sa SDL_DrawGPUPrimitivesIndirect
 * \sa SDL_DrawGPUIndexedPrimitivesIndirect
 * \sa SDL_BindGPUComputeStorageBuffers
 * \sa SDL_DispatchGPUComputeIndirect
 * \sa SDL_ReleaseGPUBuffer
  }
type
  PPSDL_GPUBuffer = ^PSDL_GPUBuffer;
  PSDL_GPUBuffer = type Pointer;

{*
 * An opaque handle representing a transfer buffer.
 *
 * Used for transferring data to and from the device.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTransferBuffer
 * \sa SDL_MapGPUTransferBuffer
 * \sa SDL_UnmapGPUTransferBuffer
 * \sa SDL_UploadToGPUBuffer
 * \sa SDL_UploadToGPUTexture
 * \sa SDL_DownloadFromGPUBuffer
 * \sa SDL_DownloadFromGPUTexture
 * \sa SDL_ReleaseGPUTransferBuffer
  }
type
  PPSDL_GPUTransferBuffer = ^PSDL_GPUTransferBuffer;
  PSDL_GPUTransferBuffer = type Pointer;

{*
 * An opaque handle representing a texture.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTexture
 * \sa SDL_UploadToGPUTexture
 * \sa SDL_DownloadFromGPUTexture
 * \sa SDL_CopyGPUTextureToTexture
 * \sa SDL_BindGPUVertexSamplers
 * \sa SDL_BindGPUVertexStorageTextures
 * \sa SDL_BindGPUFragmentSamplers
 * \sa SDL_BindGPUFragmentStorageTextures
 * \sa SDL_BindGPUComputeStorageTextures
 * \sa SDL_GenerateMipmapsForGPUTexture
 * \sa SDL_BlitGPUTexture
 * \sa SDL_ReleaseGPUTexture
  }
type
  PPSDL_GPUTexture = ^PSDL_GPUTexture;
  PSDL_GPUTexture = type Pointer;

{*
 * An opaque handle representing a sampler.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUSampler
 * \sa SDL_BindGPUVertexSamplers
 * \sa SDL_BindGPUFragmentSamplers
 * \sa SDL_ReleaseGPUSampler
  }
type
  PPSDL_GPUSampler = ^PSDL_GPUSampler;
  PSDL_GPUSampler = type Pointer;

{*
 * An opaque handle representing a compiled shader object.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
 * \sa SDL_CreateGPUGraphicsPipeline
 * \sa SDL_ReleaseGPUShader
  }
type
  PPSDL_GPUShader = ^PSDL_GPUShader;
  PSDL_GPUShader = type Pointer;

{*
 * An opaque handle representing a compute pipeline.
 *
 * Used during compute passes.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUComputePipeline
 * \sa SDL_BindGPUComputePipeline
 * \sa SDL_ReleaseGPUComputePipeline
  }
type
  PPSDL_GPUComputePipeline = ^PSDL_GPUComputePipeline;
  PSDL_GPUComputePipeline = type Pointer;

{*
 * An opaque handle representing a graphics pipeline.
 *
 * Used during render passes.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
 * \sa SDL_BindGPUGraphicsPipeline
 * \sa SDL_ReleaseGPUGraphicsPipeline
  }
type
  PPSDL_GPUGraphicsPipeline = ^PSDL_GPUGraphicsPipeline;
  PSDL_GPUGraphicsPipeline = type Pointer;

{*
 * An opaque handle representing a command buffer.
 *
 * Most state is managed via command buffers. When setting state using a
 * command buffer, that state is local to the command buffer.
 *
 * Commands only begin execution on the GPU once SDL_SubmitGPUCommandBuffer is
 * called. Once the command buffer is submitted, it is no longer valid to use
 * it.
 *
 * Command buffers are executed in submission order. If you submit command
 * buffer A and then command buffer B all commands in A will begin executing
 * before any command in B begins executing.
 *
 * In multi-threading scenarios, you should only access a command buffer on
 * the thread you acquired it from.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_AcquireGPUCommandBuffer
 * \sa SDL_SubmitGPUCommandBuffer
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
  }
type
  PPSDL_GPUCommandBuffer = ^PSDL_GPUCommandBuffer;
  PSDL_GPUCommandBuffer = type Pointer;

{*
 * An opaque handle representing a render pass.
 *
 * This handle is transient and should not be held or referenced after
 * SDL_EndGPURenderPass is called.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPURenderPass
 * \sa SDL_EndGPURenderPass
  }
type
  PPSDL_GPURenderPass = ^PSDL_GPURenderPass;
  PSDL_GPURenderPass = type Pointer;

{*
 * An opaque handle representing a compute pass.
 *
 * This handle is transient and should not be held or referenced after
 * SDL_EndGPUComputePass is called.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPUComputePass
 * \sa SDL_EndGPUComputePass
  }
type
  PPSDL_GPUComputePass = ^PSDL_GPUComputePass;
  PSDL_GPUComputePass = type Pointer;

{*
 * An opaque handle representing a copy pass.
 *
 * This handle is transient and should not be held or referenced after
 * SDL_EndGPUCopyPass is called.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPUCopyPass
 * \sa SDL_EndGPUCopyPass
  }
type
  PPSDL_GPUCopyPass = ^PSDL_GPUCopyPass;
  PSDL_GPUCopyPass = type Pointer;

{*
 * An opaque handle representing a fence.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
 * \sa SDL_QueryGPUFence
 * \sa SDL_WaitForGPUFences
 * \sa SDL_ReleaseGPUFence
  }
type
  PPSDL_GPUFence = ^PSDL_GPUFence;
  PSDL_GPUFence = type Pointer;

{*
 * Specifies the primitive topology of a graphics pipeline.
 *
 * If you are using POINTLIST you must include a point size output in the
 * vertex shader.
 *
 * - For HLSL compiling to SPIRV you must decorate a float output with
 *   [[vk:: builtin("PointSize")]].
 * - For GLSL you must set the gl_PointSize builtin.
 * - For MSL you must include a float output with the [[point_size]]
 *   decorator.
 *
 * Note that sized point topology is totally unsupported on D3D12. Any size
 * other than 1 will be ignored. In general, you should avoid using point
 * topology for both compatibility and performance reasons. You WILL regret
 * using it.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUPrimitiveType = ^PSDL_GPUPrimitiveType;
  PSDL_GPUPrimitiveType = ^TSDL_GPUPrimitiveType;
  TSDL_GPUPrimitiveType = type Integer;
const
  SDL_GPU_PRIMITIVETYPE_TRIANGLELIST  = TSDL_GPUPrimitiveType(0);   {*< A series of separate triangles.  }
  SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP  = TSDL_GPUPrimitiveType(1);  {*< A series of connected triangles.  }
  SDL_GPU_PRIMITIVETYPE_LINELIST  = TSDL_GPUPrimitiveType(2);       {*< A series of separate lines.  }
  SDL_GPU_PRIMITIVETYPE_LINESTRIP  = TSDL_GPUPrimitiveType(3);      {*< A series of connected lines.  }
  SDL_GPU_PRIMITIVETYPE_POINTLIST  = TSDL_GPUPrimitiveType(4);      {*< A series of separate points.  }

{*
 * Specifies how the contents of a texture attached to a render pass are
 * treated at the beginning of the render pass.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPURenderPass
  }
type
  PPSDL_GPULoadOp = ^PSDL_GPULoadOp;
  PSDL_GPULoadOp = ^TSDL_GPULoadOp;
  TSDL_GPULoadOp = type Integer;
const
  SDL_GPU_LOADOP_LOAD  = TSDL_GPULoadOp(0);      {*< The previous contents of the texture will be preserved.  }
  SDL_GPU_LOADOP_CLEAR  = TSDL_GPULoadOp(1);     {*< The contents of the texture will be cleared to a color.  }
  SDL_GPU_LOADOP_DONT_CARE  = TSDL_GPULoadOp(2); {*< The previous contents of the texture need not be preserved. The contents will be undefined.  }

{*
 * Specifies how the contents of a texture attached to a render pass are
 * treated at the end of the render pass.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPURenderPass
  }
type
  PPSDL_GPUStoreOp = ^PSDL_GPUStoreOp;
  PSDL_GPUStoreOp = ^TSDL_GPUStoreOp;
  TSDL_GPUStoreOp = type Integer;
const
  SDL_GPU_STOREOP_STORE  = TSDL_GPUStoreOp(0);             {*< The contents generated during the render pass will be written to memory.  }
  SDL_GPU_STOREOP_DONT_CARE  = TSDL_GPUStoreOp(1);         {*< The contents generated during the render pass are not needed and may be discarded. The contents will be undefined.  }
  SDL_GPU_STOREOP_RESOLVE  = TSDL_GPUStoreOp(2);           {*< The multisample contents generated during the render pass will be resolved to a non-multisample texture. The contents in the multisample texture may then be discarded and will be undefined.  }
  SDL_GPU_STOREOP_RESOLVE_AND_STORE  = TSDL_GPUStoreOp(3); {*< The multisample contents generated during the render pass will be resolved to a non-multisample texture. The contents in the multisample texture will be written to memory.  }

{*
 * Specifies the size of elements in an index buffer.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUIndexElementSize = ^PSDL_GPUIndexElementSize;
  PSDL_GPUIndexElementSize = ^TSDL_GPUIndexElementSize;
  TSDL_GPUIndexElementSize = type Integer;
const
  SDL_GPU_INDEXELEMENTSIZE_16BIT  = TSDL_GPUIndexElementSize(0); {*< The index elements are 16-bit.  }
  SDL_GPU_INDEXELEMENTSIZE_32BIT  = TSDL_GPUIndexElementSize(1); {*< The index elements are 32-bit.  }

{*
 * Specifies the pixel format of a texture.
 *
 * Texture format support varies depending on driver, hardware, and usage
 * flags. In general, you should use SDL_GPUTextureSupportsFormat to query if
 * a format is supported before using it. However, there are a few guaranteed
 * formats.
 *
 * FIXME: Check universal support for 32-bit component formats FIXME: Check
 * universal support for SIMULTANEOUS_READ_WRITE
 *
 * For SAMPLER usage, the following formats are universally supported:
 *
 * - R8G8B8A8_UNORM
 * - B8G8R8A8_UNORM
 * - R8_UNORM
 * - R8_SNORM
 * - R8G8_UNORM
 * - R8G8_SNORM
 * - R8G8B8A8_SNORM
 * - R16_FLOAT
 * - R16G16_FLOAT
 * - R16G16B16A16_FLOAT
 * - R32_FLOAT
 * - R32G32_FLOAT
 * - R32G32B32A32_FLOAT
 * - R11G11B10_UFLOAT
 * - R8G8B8A8_UNORM_SRGB
 * - B8G8R8A8_UNORM_SRGB
 * - D16_UNORM
 *
 * For COLOR_TARGET usage, the following formats are universally supported:
 *
 * - R8G8B8A8_UNORM
 * - B8G8R8A8_UNORM
 * - R8_UNORM
 * - R16_FLOAT
 * - R16G16_FLOAT
 * - R16G16B16A16_FLOAT
 * - R32_FLOAT
 * - R32G32_FLOAT
 * - R32G32B32A32_FLOAT
 * - R8_UINT
 * - R8G8_UINT
 * - R8G8B8A8_UINT
 * - R16_UINT
 * - R16G16_UINT
 * - R16G16B16A16_UINT
 * - R8_INT
 * - R8G8_INT
 * - R8G8B8A8_INT
 * - R16_INT
 * - R16G16_INT
 * - R16G16B16A16_INT
 * - R8G8B8A8_UNORM_SRGB
 * - B8G8R8A8_UNORM_SRGB
 *
 * For STORAGE usages, the following formats are universally supported:
 *
 * - R8G8B8A8_UNORM
 * - R8G8B8A8_SNORM
 * - R16G16B16A16_FLOAT
 * - R32_FLOAT
 * - R32G32_FLOAT
 * - R32G32B32A32_FLOAT
 * - R8G8B8A8_UINT
 * - R16G16B16A16_UINT
 * - R8G8B8A8_INT
 * - R16G16B16A16_INT
 *
 * For DEPTH_STENCIL_TARGET usage, the following formats are universally
 * supported:
 *
 * - D16_UNORM
 * - Either (but not necessarily both!) D24_UNORM or D32_FLOAT
 * - Either (but not necessarily both!) D24_UNORM_S8_UINT or D32_FLOAT_S8_UINT
 *
 * Unless D16_UNORM is sufficient for your purposes, always check which of
 * D24/D32 is supported before creating a depth-stencil texture!
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTexture
 * \sa SDL_GPUTextureSupportsFormat
  }
type
  PPSDL_GPUTextureFormat = ^PSDL_GPUTextureFormat;
  PSDL_GPUTextureFormat = ^TSDL_GPUTextureFormat;
  TSDL_GPUTextureFormat = type Integer;
const
  SDL_GPU_TEXTUREFORMAT_INVALID  = TSDL_GPUTextureFormat(0);

  { Unsigned Normalized Float Color Formats  }
  SDL_GPU_TEXTUREFORMAT_A8_UNORM  = TSDL_GPUTextureFormat(1);
  SDL_GPU_TEXTUREFORMAT_R8_UNORM  = TSDL_GPUTextureFormat(2);
  SDL_GPU_TEXTUREFORMAT_R8G8_UNORM  = TSDL_GPUTextureFormat(3);
  SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM  = TSDL_GPUTextureFormat(4);
  SDL_GPU_TEXTUREFORMAT_R16_UNORM  = TSDL_GPUTextureFormat(5);
  SDL_GPU_TEXTUREFORMAT_R16G16_UNORM  = TSDL_GPUTextureFormat(6);
  SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UNORM  = TSDL_GPUTextureFormat(7);
  SDL_GPU_TEXTUREFORMAT_R10G10B10A2_UNORM  = TSDL_GPUTextureFormat(8);
  SDL_GPU_TEXTUREFORMAT_B5G6R5_UNORM  = TSDL_GPUTextureFormat(9);
  SDL_GPU_TEXTUREFORMAT_B5G5R5A1_UNORM  = TSDL_GPUTextureFormat(10);
  SDL_GPU_TEXTUREFORMAT_B4G4R4A4_UNORM  = TSDL_GPUTextureFormat(11);
  SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM  = TSDL_GPUTextureFormat(12);
  { Compressed Unsigned Normalized Float Color Formats  }
  SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM  = TSDL_GPUTextureFormat(13);
  SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM  = TSDL_GPUTextureFormat(14);
  SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM  = TSDL_GPUTextureFormat(15);
  SDL_GPU_TEXTUREFORMAT_BC4_R_UNORM  = TSDL_GPUTextureFormat(16);
  SDL_GPU_TEXTUREFORMAT_BC5_RG_UNORM  = TSDL_GPUTextureFormat(17);
  SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM  = TSDL_GPUTextureFormat(18);
  { Compressed Signed Float Color Formats  }
  SDL_GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT  = TSDL_GPUTextureFormat(19);
  { Compressed Unsigned Float Color Formats  }
  SDL_GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT  = TSDL_GPUTextureFormat(20);
  { Signed Normalized Float Color Formats   }
  SDL_GPU_TEXTUREFORMAT_R8_SNORM  = TSDL_GPUTextureFormat(21);
  SDL_GPU_TEXTUREFORMAT_R8G8_SNORM  = TSDL_GPUTextureFormat(22);
  SDL_GPU_TEXTUREFORMAT_R8G8B8A8_SNORM  = TSDL_GPUTextureFormat(23);
  SDL_GPU_TEXTUREFORMAT_R16_SNORM  = TSDL_GPUTextureFormat(24);
  SDL_GPU_TEXTUREFORMAT_R16G16_SNORM  = TSDL_GPUTextureFormat(25);
  SDL_GPU_TEXTUREFORMAT_R16G16B16A16_SNORM  = TSDL_GPUTextureFormat(26);
  { Signed Float Color Formats  }
  SDL_GPU_TEXTUREFORMAT_R16_FLOAT  = TSDL_GPUTextureFormat(27);
  SDL_GPU_TEXTUREFORMAT_R16G16_FLOAT  = TSDL_GPUTextureFormat(28);
  SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT  = TSDL_GPUTextureFormat(29);
  SDL_GPU_TEXTUREFORMAT_R32_FLOAT  = TSDL_GPUTextureFormat(30);
  SDL_GPU_TEXTUREFORMAT_R32G32_FLOAT  = TSDL_GPUTextureFormat(31);
  SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT  = TSDL_GPUTextureFormat(32);
  { Unsigned Float Color Formats  }
  SDL_GPU_TEXTUREFORMAT_R11G11B10_UFLOAT  = TSDL_GPUTextureFormat(33);
  { Unsigned Integer Color Formats  }
  SDL_GPU_TEXTUREFORMAT_R8_UINT  = TSDL_GPUTextureFormat(34);
  SDL_GPU_TEXTUREFORMAT_R8G8_UINT  = TSDL_GPUTextureFormat(35);
  SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UINT  = TSDL_GPUTextureFormat(36);
  SDL_GPU_TEXTUREFORMAT_R16_UINT  = TSDL_GPUTextureFormat(37);
  SDL_GPU_TEXTUREFORMAT_R16G16_UINT  = TSDL_GPUTextureFormat(38);
  SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UINT  = TSDL_GPUTextureFormat(39);
  SDL_GPU_TEXTUREFORMAT_R32_UINT  = TSDL_GPUTextureFormat(40);
  SDL_GPU_TEXTUREFORMAT_R32G32_UINT  = TSDL_GPUTextureFormat(41);
  SDL_GPU_TEXTUREFORMAT_R32G32B32A32_UINT  = TSDL_GPUTextureFormat(42);
  { Signed Integer Color Formats  }
  SDL_GPU_TEXTUREFORMAT_R8_INT  = TSDL_GPUTextureFormat(43);
  SDL_GPU_TEXTUREFORMAT_R8G8_INT  = TSDL_GPUTextureFormat(44);
  SDL_GPU_TEXTUREFORMAT_R8G8B8A8_INT  = TSDL_GPUTextureFormat(45);
  SDL_GPU_TEXTUREFORMAT_R16_INT  = TSDL_GPUTextureFormat(46);
  SDL_GPU_TEXTUREFORMAT_R16G16_INT  = TSDL_GPUTextureFormat(47);
  SDL_GPU_TEXTUREFORMAT_R16G16B16A16_INT  = TSDL_GPUTextureFormat(48);
  SDL_GPU_TEXTUREFORMAT_R32_INT  = TSDL_GPUTextureFormat(49);
  SDL_GPU_TEXTUREFORMAT_R32G32_INT  = TSDL_GPUTextureFormat(50);
  SDL_GPU_TEXTUREFORMAT_R32G32B32A32_INT  = TSDL_GPUTextureFormat(51);
  { SRGB Unsigned Normalized Color Formats  }
  SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB  = TSDL_GPUTextureFormat(52);
  SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB  = TSDL_GPUTextureFormat(53);
  { Compressed SRGB Unsigned Normalized Color Formats  }
  SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB  = TSDL_GPUTextureFormat(54);
  SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB  = TSDL_GPUTextureFormat(55);
  SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB  = TSDL_GPUTextureFormat(56);
  SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB  = TSDL_GPUTextureFormat(57);
  { Depth Formats  }
  SDL_GPU_TEXTUREFORMAT_D16_UNORM  = TSDL_GPUTextureFormat(58);
  SDL_GPU_TEXTUREFORMAT_D24_UNORM  = TSDL_GPUTextureFormat(59);
  SDL_GPU_TEXTUREFORMAT_D32_FLOAT  = TSDL_GPUTextureFormat(60);
  SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT  = TSDL_GPUTextureFormat(61);
  SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT  = TSDL_GPUTextureFormat(62);
  { Compressed ASTC Normalized Float Color Formats }
  SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM  = TSDL_GPUTextureFormat(63);
  SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM  = TSDL_GPUTextureFormat(64);
  SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM  = TSDL_GPUTextureFormat(65);
  SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM  = TSDL_GPUTextureFormat(66);
  SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM  = TSDL_GPUTextureFormat(67);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM  = TSDL_GPUTextureFormat(68);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM  = TSDL_GPUTextureFormat(69);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM  = TSDL_GPUTextureFormat(70);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM  = TSDL_GPUTextureFormat(71);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM  = TSDL_GPUTextureFormat(72);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM  = TSDL_GPUTextureFormat(73);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM  = TSDL_GPUTextureFormat(74);
  SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM  = TSDL_GPUTextureFormat(75);
  SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM  = TSDL_GPUTextureFormat(76);
  { Compressed SRGB ASTC Normalized Float Color Formats }
  SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM_SRGB  = TSDL_GPUTextureFormat(77);
  SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM_SRGB  = TSDL_GPUTextureFormat(78);
  SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM_SRGB  = TSDL_GPUTextureFormat(79);
  SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM_SRGB  = TSDL_GPUTextureFormat(80);
  SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM_SRGB  = TSDL_GPUTextureFormat(81);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM_SRGB  = TSDL_GPUTextureFormat(82);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM_SRGB  = TSDL_GPUTextureFormat(83);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM_SRGB  = TSDL_GPUTextureFormat(84);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM_SRGB  = TSDL_GPUTextureFormat(85);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM_SRGB  = TSDL_GPUTextureFormat(86);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM_SRGB  = TSDL_GPUTextureFormat(87);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM_SRGB  = TSDL_GPUTextureFormat(88);
  SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM_SRGB  = TSDL_GPUTextureFormat(89);
  SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM_SRGB  = TSDL_GPUTextureFormat(90);
  { Compressed ASTC Signed Float Color Formats }
  SDL_GPU_TEXTUREFORMAT_ASTC_4x4_FLOAT  = TSDL_GPUTextureFormat(91);
  SDL_GPU_TEXTUREFORMAT_ASTC_5x4_FLOAT  = TSDL_GPUTextureFormat(92);
  SDL_GPU_TEXTUREFORMAT_ASTC_5x5_FLOAT  = TSDL_GPUTextureFormat(93);
  SDL_GPU_TEXTUREFORMAT_ASTC_6x5_FLOAT  = TSDL_GPUTextureFormat(94);
  SDL_GPU_TEXTUREFORMAT_ASTC_6x6_FLOAT  = TSDL_GPUTextureFormat(95);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x5_FLOAT  = TSDL_GPUTextureFormat(96);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x6_FLOAT  = TSDL_GPUTextureFormat(97);
  SDL_GPU_TEXTUREFORMAT_ASTC_8x8_FLOAT  = TSDL_GPUTextureFormat(98);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x5_FLOAT  = TSDL_GPUTextureFormat(99);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x6_FLOAT  = TSDL_GPUTextureFormat(100);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x8_FLOAT  = TSDL_GPUTextureFormat(101);
  SDL_GPU_TEXTUREFORMAT_ASTC_10x10_FLOAT  = TSDL_GPUTextureFormat(102);
  SDL_GPU_TEXTUREFORMAT_ASTC_12x10_FLOAT  = TSDL_GPUTextureFormat(103);
  SDL_GPU_TEXTUREFORMAT_ASTC_12x12_FLOAT  = TSDL_GPUTextureFormat(104);

{*
 * Specifies how a texture is intended to be used by the client.
 *
 * A texture must have at least one usage flag. Note that some usage flag
 * combinations are invalid.
 *
 * With regards to compute storage usage, READ | WRITE means that you can have
 * shader A that only writes into the texture and shader B that only reads
 * from the texture and bind the same texture to either shader respectively.
 * SIMULTANEOUS means that you can do reads and writes within the same shader
 * or compute pass. It also implies that atomic ops can be used, since those
 * are read-modify-write operations. If you use SIMULTANEOUS, you are
 * responsible for avoiding data races, as there is no data synchronization
 * within a compute pass. Note that SIMULTANEOUS usage is only supported by a
 * limited number of texture formats.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTexture
  }
type
  PPSDL_GPUTextureUsageFlags = ^PSDL_GPUTextureUsageFlags;
  PSDL_GPUTextureUsageFlags = ^TSDL_GPUTextureUsageFlags;
  TSDL_GPUTextureUsageFlags = cuint32;
const
  SDL_GPU_TEXTUREUSAGE_SAMPLER = 1 shl 0;                                 {*< Texture supports sampling.  }
  SDL_GPU_TEXTUREUSAGE_COLOR_TARGET = 1 shl 1;                            {*< Texture is a color render target.  }
  SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET = 1 shl 2;                    {*< Texture is a depth stencil target.  }
  SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ = 1 shl 3;                   {*< Texture supports storage reads in graphics stages.  }
  SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ = 1 shl 4;                    {*< Texture supports storage reads in the compute stage.  }
  SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE = 1 shl 5;                   {*< Texture supports storage writes in the compute stage.  }
  SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE = 1 shl 6; {*< Texture supports reads and writes in the same compute shader. This is NOT equivalent to READ | WRITE.  }

{*
 * Specifies the type of a texture.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTexture
  }
type
  PPSDL_GPUTextureType = ^PSDL_GPUTextureType;
  PSDL_GPUTextureType = ^TSDL_GPUTextureType;
  TSDL_GPUTextureType = type Integer;
const
  SDL_GPU_TEXTURETYPE_2D  = TSDL_GPUTextureType(0);           {*< The texture is a 2-dimensional image.  }
  SDL_GPU_TEXTURETYPE_2D_ARRAY  = TSDL_GPUTextureType(1);     {*< The texture is a 2-dimensional array image.  }
  SDL_GPU_TEXTURETYPE_3D  = TSDL_GPUTextureType(2);           {*< The texture is a 3-dimensional image.  }
  SDL_GPU_TEXTURETYPE_CUBE  = TSDL_GPUTextureType(3);         {*< The texture is a cube image.  }
  SDL_GPU_TEXTURETYPE_CUBE_ARRAY  = TSDL_GPUTextureType(4);   {*< The texture is a cube array image.  }

{*
 * Specifies the sample count of a texture.
 *
 * Used in multisampling. Note that this value only applies when the texture
 * is used as a render target.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTexture
 * \sa SDL_GPUTextureSupportsSampleCount
  }
type
  PPSDL_GPUSampleCount = ^PSDL_GPUSampleCount;
  PSDL_GPUSampleCount = ^TSDL_GPUSampleCount;
  TSDL_GPUSampleCount = type Integer;
const
  SDL_GPU_SAMPLECOUNT_1  = TSDL_GPUSampleCount(0);  {*< No multisampling.  }
  SDL_GPU_SAMPLECOUNT_2  = TSDL_GPUSampleCount(1);  {*< MSAA 2x  }
  SDL_GPU_SAMPLECOUNT_4  = TSDL_GPUSampleCount(2);  {*< MSAA 4x  }
  SDL_GPU_SAMPLECOUNT_8  = TSDL_GPUSampleCount(3);  {*< MSAA 8x  }

{*
 * Specifies the face of a cube map.
 *
 * Can be passed in as the layer field in texture-related structs.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_GPUCubeMapFace = ^PSDL_GPUCubeMapFace;
  PSDL_GPUCubeMapFace = ^TSDL_GPUCubeMapFace;
  TSDL_GPUCubeMapFace = type Integer;
const
  SDL_GPU_CUBEMAPFACE_POSITIVEX  = TSDL_GPUCubeMapFace(0);
  SDL_GPU_CUBEMAPFACE_NEGATIVEX  = TSDL_GPUCubeMapFace(1);
  SDL_GPU_CUBEMAPFACE_POSITIVEY  = TSDL_GPUCubeMapFace(2);
  SDL_GPU_CUBEMAPFACE_NEGATIVEY  = TSDL_GPUCubeMapFace(3);
  SDL_GPU_CUBEMAPFACE_POSITIVEZ  = TSDL_GPUCubeMapFace(4);
  SDL_GPU_CUBEMAPFACE_NEGATIVEZ  = TSDL_GPUCubeMapFace(5);

{*
 * Specifies how a buffer is intended to be used by the client.
 *
 * A buffer must have at least one usage flag. Note that some usage flag
 * combinations are invalid.
 *
 * Unlike textures, READ | WRITE can be used for simultaneous read-write
 * usage. The same data synchronization concerns as textures apply.
 *
 * If you use a STORAGE flag, the data in the buffer must respect std140
 * layout conventions. In practical terms this means you must ensure that vec3
 * and vec4 fields are 16-byte aligned.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUBuffer
  }
type
  PPSDL_GPUBufferUsageFlags = ^PSDL_GPUBufferUsageFlags;
  PSDL_GPUBufferUsageFlags = ^TSDL_GPUBufferUsageFlags;
  TSDL_GPUBufferUsageFlags = type cuint32;
const
  SDL_GPU_BUFFERUSAGE_VERTEX = 1 shl 0;                  {*< Buffer is a vertex buffer.  }
  SDL_GPU_BUFFERUSAGE_INDEX = 1 shl 1;                   {*< Buffer is an index buffer.  }
  SDL_GPU_BUFFERUSAGE_INDIRECT = 1 shl 2;                {*< Buffer is an indirect buffer.  }
  SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ = 1 shl 3;   {*< Buffer supports storage reads in graphics stages.  }
  SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ = 1 shl 4;    {*< Buffer supports storage reads in the compute stage.  }
  SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE = 1 shl 5;   {*< Buffer supports storage writes in the compute stage.  }

{*
 * Specifies how a transfer buffer is intended to be used by the client.
 *
 * Note that mapping and copying FROM an upload transfer buffer or TO a
 * download transfer buffer is undefined behavior.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTransferBuffer
  }
type
  PPSDL_GPUTransferBufferUsage = ^PSDL_GPUTransferBufferUsage;
  PSDL_GPUTransferBufferUsage = ^TSDL_GPUTransferBufferUsage;
  TSDL_GPUTransferBufferUsage = type Integer;
const
  SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD  = TSDL_GPUTransferBufferUsage(0);
  SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD  = TSDL_GPUTransferBufferUsage(1);

{*
 * Specifies which stage a shader program corresponds to.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
type
  PPSDL_GPUShaderStage = ^PSDL_GPUShaderStage;
  PSDL_GPUShaderStage = ^TSDL_GPUShaderStage;
  TSDL_GPUShaderStage = type Integer;
const
  SDL_GPU_SHADERSTAGE_VERTEX  = TSDL_GPUShaderStage(0);
  SDL_GPU_SHADERSTAGE_FRAGMENT  = TSDL_GPUShaderStage(1);

{*
 * Specifies the format of shader code.
 *
 * Each format corresponds to a specific backend that accepts it.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
type
  PPSDL_GPUShaderFormat = ^PSDL_GPUShaderFormat;
  PSDL_GPUShaderFormat = ^TSDL_GPUShaderFormat;
  TSDL_GPUShaderFormat = type cuint32;
const
  SDL_GPU_SHADERFORMAT_INVALID = 0;
  SDL_GPU_SHADERFORMAT_PRIVATE = 1 shl 0;  {*< Shaders for NDA'd platforms.  }
  SDL_GPU_SHADERFORMAT_SPIRV = 1 shl 1;    {*< SPIR-V shaders for Vulkan.  }
  SDL_GPU_SHADERFORMAT_DXBC = 1 shl 2;     {*< DXBC SM5_1 shaders for D3D12.  }
  SDL_GPU_SHADERFORMAT_DXIL = 1 shl 3;     {*< DXIL SM6_0 shaders for D3D12.  }
  SDL_GPU_SHADERFORMAT_MSL = 1 shl 4;      {*< MSL shaders for Metal.  }
  SDL_GPU_SHADERFORMAT_METALLIB = 1 shl 5; {*< Precompiled metallib shaders for Metal.  }

{*
 * Specifies the format of a vertex attribute.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUVertexElementFormat = ^PSDL_GPUVertexElementFormat;
  PSDL_GPUVertexElementFormat = ^TSDL_GPUVertexElementFormat;
  TSDL_GPUVertexElementFormat = type Integer;
const
  SDL_GPU_VERTEXELEMENTFORMAT_INVALID  = TSDL_GPUVertexElementFormat(0);

  { 32-bit Signed Integers  }
  SDL_GPU_VERTEXELEMENTFORMAT_INT  = TSDL_GPUVertexElementFormat(1);
  SDL_GPU_VERTEXELEMENTFORMAT_INT2  = TSDL_GPUVertexElementFormat(2);
  SDL_GPU_VERTEXELEMENTFORMAT_INT3  = TSDL_GPUVertexElementFormat(3);
  SDL_GPU_VERTEXELEMENTFORMAT_INT4  = TSDL_GPUVertexElementFormat(4);

  { 32-bit Unsigned Integers  }
  SDL_GPU_VERTEXELEMENTFORMAT_UINT  = TSDL_GPUVertexElementFormat(5);
  SDL_GPU_VERTEXELEMENTFORMAT_UINT2  = TSDL_GPUVertexElementFormat(6);
  SDL_GPU_VERTEXELEMENTFORMAT_UINT3  = TSDL_GPUVertexElementFormat(7);
  SDL_GPU_VERTEXELEMENTFORMAT_UINT4  = TSDL_GPUVertexElementFormat(8);

  { 32-bit Floats  }
  SDL_GPU_VERTEXELEMENTFORMAT_FLOAT  = TSDL_GPUVertexElementFormat(9);
  SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2  = TSDL_GPUVertexElementFormat(10);
  SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3  = TSDL_GPUVertexElementFormat(11);
  SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4  = TSDL_GPUVertexElementFormat(12);

  { 8-bit Signed Integers  }
  SDL_GPU_VERTEXELEMENTFORMAT_BYTE2  = TSDL_GPUVertexElementFormat(13);
  SDL_GPU_VERTEXELEMENTFORMAT_BYTE4  = TSDL_GPUVertexElementFormat(14);

  { 8-bit Unsigned Integers  }
  SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2  = TSDL_GPUVertexElementFormat(15);
  SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4  = TSDL_GPUVertexElementFormat(16);

  { 8-bit Signed Normalized  }
  SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM  = TSDL_GPUVertexElementFormat(17);
  SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM  = TSDL_GPUVertexElementFormat(18);

  { 8-bit Unsigned Normalized  }
  SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM  = TSDL_GPUVertexElementFormat(19);
  SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM  = TSDL_GPUVertexElementFormat(20);

  { 16-bit Signed Integers  }
  SDL_GPU_VERTEXELEMENTFORMAT_SHORT2  = TSDL_GPUVertexElementFormat(21);
  SDL_GPU_VERTEXELEMENTFORMAT_SHORT4  = TSDL_GPUVertexElementFormat(22);

  { 16-bit Unsigned Integers  }
  SDL_GPU_VERTEXELEMENTFORMAT_USHORT2  = TSDL_GPUVertexElementFormat(23);
  SDL_GPU_VERTEXELEMENTFORMAT_USHORT4  = TSDL_GPUVertexElementFormat(24);

  { 16-bit Signed Normalized  }
  SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM  = TSDL_GPUVertexElementFormat(25);
  SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM  = TSDL_GPUVertexElementFormat(26);

  { 16-bit Unsigned Normalized  }
  SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM  = TSDL_GPUVertexElementFormat(27);
  SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM  = TSDL_GPUVertexElementFormat(28);

  { 16-bit Floats  }
  SDL_GPU_VERTEXELEMENTFORMAT_HALF2  = TSDL_GPUVertexElementFormat(29);
  SDL_GPU_VERTEXELEMENTFORMAT_HALF4  = TSDL_GPUVertexElementFormat(30);

{*
 * Specifies the rate at which vertex attributes are pulled from buffers.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUVertexInputRate = ^PSDL_GPUVertexInputRate;
  PSDL_GPUVertexInputRate = ^TSDL_GPUVertexInputRate;
  TSDL_GPUVertexInputRate = type Integer;
const
  SDL_GPU_VERTEXINPUTRATE_VERTEX  = TSDL_GPUVertexInputRate(0);   {*< Attribute addressing is a function of the vertex index.  }
  SDL_GPU_VERTEXINPUTRATE_INSTANCE  = TSDL_GPUVertexInputRate(1); {*< Attribute addressing is a function of the instance index.  }

{*
 * Specifies the fill mode of the graphics pipeline.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUFillMode = ^PSDL_GPUFillMode;
  PSDL_GPUFillMode = ^TSDL_GPUFillMode;
  TSDL_GPUFillMode = type Integer;
const
  SDL_GPU_FILLMODE_FILL  = TSDL_GPUFillMode(0); {*< Polygons will be rendered via rasterization.  }
  SDL_GPU_FILLMODE_LINE  = TSDL_GPUFillMode(1); {*< Polygon edges will be drawn as line segments.  }

{*
 * Specifies the facing direction in which triangle faces will be culled.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUCullMode = ^PSDL_GPUCullMode;
  PSDL_GPUCullMode = ^TSDL_GPUCullMode;
  TSDL_GPUCullMode = type Integer;
const
  SDL_GPU_CULLMODE_NONE  = TSDL_GPUCullMode(0);   {*< No triangles are culled.  }
  SDL_GPU_CULLMODE_FRONT  = TSDL_GPUCullMode(1);  {*< Front-facing triangles are culled.  }
  SDL_GPU_CULLMODE_BACK  = TSDL_GPUCullMode(2);   {*< Back-facing triangles are culled.  }

{*
 * Specifies the vertex winding that will cause a triangle to be determined to
 * be front-facing.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUFrontFace = ^PSDL_GPUFrontFace;
  PSDL_GPUFrontFace = ^TSDL_GPUFrontFace;
  TSDL_GPUFrontFace = type Integer;
const
  SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE  = TSDL_GPUFrontFace(0); {*< A triangle with counter-clockwise vertex winding will be considered front-facing.  }
  SDL_GPU_FRONTFACE_CLOCKWISE  = TSDL_GPUFrontFace(1);         {*< A triangle with clockwise vertex winding will be considered front-facing.  }

{*
 * Specifies a comparison operator for depth, stencil and sampler operations.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUCompareOp = ^PSDL_GPUCompareOp;
  PSDL_GPUCompareOp = ^TSDL_GPUCompareOp;
  TSDL_GPUCompareOp = type Integer;
const
  SDL_GPU_COMPAREOP_INVALID  = TSDL_GPUCompareOp(0);
  SDL_GPU_COMPAREOP_NEVER  = TSDL_GPUCompareOp(1);             {*< The comparison always evaluates false.  }
  SDL_GPU_COMPAREOP_LESS  = TSDL_GPUCompareOp(2);              {*< The comparison evaluates reference < test.  }
  SDL_GPU_COMPAREOP_EQUAL  = TSDL_GPUCompareOp(3);             {*< The comparison evaluates reference == test.  }
  SDL_GPU_COMPAREOP_LESS_OR_EQUAL  = TSDL_GPUCompareOp(4);     {*< The comparison evaluates reference <= test.  }
  SDL_GPU_COMPAREOP_GREATER  = TSDL_GPUCompareOp(5);           {*< The comparison evaluates reference > test.  }
  SDL_GPU_COMPAREOP_NOT_EQUAL  = TSDL_GPUCompareOp(6);         {*< The comparison evaluates reference != test.  }
  SDL_GPU_COMPAREOP_GREATER_OR_EQUAL  = TSDL_GPUCompareOp(7);  {*< The comparison evalutes reference >= test.  }
  SDL_GPU_COMPAREOP_ALWAYS  = TSDL_GPUCompareOp(8);            {*< The comparison always evaluates true.  }

{*
 * Specifies what happens to a stored stencil value if stencil tests fail or
 * pass.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUStencilOp = ^PSDL_GPUStencilOp;
  PSDL_GPUStencilOp = ^TSDL_GPUStencilOp;
  TSDL_GPUStencilOp = type Integer;
const
  SDL_GPU_STENCILOP_INVALID  = TSDL_GPUStencilOp(0);
  SDL_GPU_STENCILOP_KEEP  = TSDL_GPUStencilOp(1);                {*< Keeps the current value.  }
  SDL_GPU_STENCILOP_ZERO  = TSDL_GPUStencilOp(2);                {*< Sets the value to 0.  }
  SDL_GPU_STENCILOP_REPLACE  = TSDL_GPUStencilOp(3);             {*< Sets the value to reference.  }
  SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP  = TSDL_GPUStencilOp(4); {*< Increments the current value and clamps to the maximum value.  }
  SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP  = TSDL_GPUStencilOp(5); {*< Decrements the current value and clamps to 0.  }
  SDL_GPU_STENCILOP_INVERT  = TSDL_GPUStencilOp(6);              {*< Bitwise-inverts the current value.  }
  SDL_GPU_STENCILOP_INCREMENT_AND_WRAP  = TSDL_GPUStencilOp(7);  {*< Increments the current value and wraps back to 0.  }
  SDL_GPU_STENCILOP_DECREMENT_AND_WRAP  = TSDL_GPUStencilOp(8);  {*< Decrements the current value and wraps to the maximum value.  }

{*
 * Specifies the operator to be used when pixels in a render target are
 * blended with existing pixels in the texture.
 *
 * The source color is the value written by the fragment shader. The
 * destination color is the value currently existing in the texture.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUBlendOp = ^PSDL_GPUBlendOp;
  PSDL_GPUBlendOp = ^TSDL_GPUBlendOp;
  TSDL_GPUBlendOp = type Integer;
const
  SDL_GPU_BLENDOP_INVALID  = TSDL_GPUBlendOp(0);
  SDL_GPU_BLENDOP_ADD  = TSDL_GPUBlendOp(1);               {*< (source * source_factor) + (destination * destination_factor)  }
  SDL_GPU_BLENDOP_SUBTRACT  = TSDL_GPUBlendOp(2);          {*< (source * source_factor) - (destination * destination_factor)  }
  SDL_GPU_BLENDOP_REVERSE_SUBTRACT  = TSDL_GPUBlendOp(3);  {*< (destination * destination_factor) - (source * source_factor)  }
  SDL_GPU_BLENDOP_MIN  = TSDL_GPUBlendOp(4);               {*< min(source, destination)  }
  SDL_GPU_BLENDOP_MAX  = TSDL_GPUBlendOp(5);               {*< max(source, destination)  }

{*
 * Specifies a blending factor to be used when pixels in a render target are
 * blended with existing pixels in the texture.
 *
 * The source color is the value written by the fragment shader. The
 * destination color is the value currently existing in the texture.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUBlendFactor = ^PSDL_GPUBlendFactor;
  PSDL_GPUBlendFactor = ^TSDL_GPUBlendFactor;
  TSDL_GPUBlendFactor = type Integer;
const
  SDL_GPU_BLENDFACTOR_INVALID  = TSDL_GPUBlendFactor(0);
  SDL_GPU_BLENDFACTOR_ZERO  = TSDL_GPUBlendFactor(1);                      {*< 0  }
  SDL_GPU_BLENDFACTOR_ONE  = TSDL_GPUBlendFactor(2);                       {*< 1  }
  SDL_GPU_BLENDFACTOR_SRC_COLOR  = TSDL_GPUBlendFactor(3);                 {*< source color  }
  SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR  = TSDL_GPUBlendFactor(4);       {*< 1 - source color  }
  SDL_GPU_BLENDFACTOR_DST_COLOR  = TSDL_GPUBlendFactor(5);                 {*< destination color  }
  SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR  = TSDL_GPUBlendFactor(6);       {*< 1 - destination color  }
  SDL_GPU_BLENDFACTOR_SRC_ALPHA  = TSDL_GPUBlendFactor(7);                 {*< source alpha  }
  SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA  = TSDL_GPUBlendFactor(8);       {*< 1 - source alpha  }
  SDL_GPU_BLENDFACTOR_DST_ALPHA  = TSDL_GPUBlendFactor(9);                 {*< destination alpha  }
  SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA  = TSDL_GPUBlendFactor(10);      {*< 1 - destination alpha  }
  SDL_GPU_BLENDFACTOR_CONSTANT_COLOR  = TSDL_GPUBlendFactor(11);           {*< blend constant  }
  SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR  = TSDL_GPUBlendFactor(12); {*< 1 - blend constant  }
  SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE  = TSDL_GPUBlendFactor(13);       {*< min(source alpha, 1 - destination alpha)  }

{*
 * Specifies which color components are written in a graphics pipeline.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
  }
type
  PPSDL_GPUColorComponentFlags = ^PSDL_GPUColorComponentFlags;
  PSDL_GPUColorComponentFlags = ^TSDL_GPUColorComponentFlags;
  TSDL_GPUColorComponentFlags = type cuint8;
const
  SDL_GPU_COLORCOMPONENT_R = 1 shl 0;  {*< the red component  }
  SDL_GPU_COLORCOMPONENT_G = 1 shl 1;  {*< the green component  }
  SDL_GPU_COLORCOMPONENT_B = 1 shl 2;  {*< the blue component  }
  SDL_GPU_COLORCOMPONENT_A = 1 shl 3;  {*< the alpha component  }

{*
 * Specifies a filter operation used by a sampler.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUSampler
  }
type
  PPSDL_GPUFilter = ^PSDL_GPUFilter;
  PSDL_GPUFilter = ^TSDL_GPUFilter;
  TSDL_GPUFilter = type Integer;
const
  SDL_GPU_FILTER_NEAREST  = TSDL_GPUFilter(0); {*< Point filtering.  }
  SDL_GPU_FILTER_LINEAR  = TSDL_GPUFilter(1);  {*< Linear filtering.  }

{*
 * Specifies a mipmap mode used by a sampler.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUSampler
  }
type
  PPSDL_GPUSamplerMipmapMode = ^PSDL_GPUSamplerMipmapMode;
  PSDL_GPUSamplerMipmapMode = ^TSDL_GPUSamplerMipmapMode;
  TSDL_GPUSamplerMipmapMode = type Integer;
const
  SDL_GPU_SAMPLERMIPMAPMODE_NEAREST  = TSDL_GPUSamplerMipmapMode(0);  {*< Point filtering.  }
  SDL_GPU_SAMPLERMIPMAPMODE_LINEAR  = TSDL_GPUSamplerMipmapMode(1);   {*< Linear filtering.  }

{*
 * Specifies behavior of texture sampling when the coordinates exceed the 0-1
 * range.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUSampler
  }
type
  PPSDL_GPUSamplerAddressMode = ^PSDL_GPUSamplerAddressMode;
  PSDL_GPUSamplerAddressMode = ^TSDL_GPUSamplerAddressMode;
  TSDL_GPUSamplerAddressMode = type Integer;
const
  SDL_GPU_SAMPLERADDRESSMODE_REPEAT  = TSDL_GPUSamplerAddressMode(0);          {*< Specifies that the coordinates will wrap around.  }
  SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT  = TSDL_GPUSamplerAddressMode(1); {*< Specifies that the coordinates will wrap around mirrored.  }
  SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE  = TSDL_GPUSamplerAddressMode(2);   {*< Specifies that the coordinates will clamp to the 0-1 range.  }

{*
 * Specifies the timing that will be used to present swapchain textures to the
 * OS.
 *
 * VSYNC mode will always be supported. IMMEDIATE and MAILBOX modes may not be
 * supported on certain systems.
 *
 * It is recommended to query SDL_WindowSupportsGPUPresentMode after claiming
 * the window if you wish to change the present mode to IMMEDIATE or MAILBOX.
 *
 * - VSYNC: Waits for vblank before presenting. No tearing is possible. If
 *   there is a pending image to present, the new image is enqueued for
 *   presentation. Disallows tearing at the cost of visual latency.
 * - IMMEDIATE: Immediately presents. Lowest latency option, but tearing may
 *   occur.
 * - MAILBOX: Waits for vblank before presenting. No tearing is possible. If
 *   there is a pending image to present, the pending image is replaced by the
 *   new image. Similar to VSYNC, but with reduced visual latency.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_SetGPUSwapchainParameters
 * \sa SDL_WindowSupportsGPUPresentMode
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
  }
type
  PPSDL_GPUPresentMode = ^PSDL_GPUPresentMode;
  PSDL_GPUPresentMode = ^TSDL_GPUPresentMode;
  TSDL_GPUPresentMode = type Integer;
const
  SDL_GPU_PRESENTMODE_VSYNC  = TSDL_GPUPresentMode(0);
  SDL_GPU_PRESENTMODE_IMMEDIATE  = TSDL_GPUPresentMode(1);
  SDL_GPU_PRESENTMODE_MAILBOX  = TSDL_GPUPresentMode(2);

{*
 * Specifies the texture format and colorspace of the swapchain textures.
 *
 * SDR will always be supported. Other compositions may not be supported on
 * certain systems.
 *
 * It is recommended to query SDL_WindowSupportsGPUSwapchainComposition after
 * claiming the window if you wish to change the swapchain composition from
 * SDR.
 *
 * - SDR: B8G8R8A8 or R8G8B8A8 swapchain. Pixel values are in sRGB encoding.
 * - SDR_LINEAR: B8G8R8A8_SRGB or R8G8B8A8_SRGB swapchain. Pixel values are
 *   stored in memory in sRGB encoding but accessed in shaders in "linear
 *   sRGB" encoding which is sRGB but with a linear transfer function.
 * - HDR_EXTENDED_LINEAR: R16G16B16A16_FLOAT swapchain. Pixel values are in
 *   extended linear sRGB encoding and permits values outside of the [0, 1]
 *   range.
 * - HDR10_ST2084: A2R10G10B10 or A2B10G10R10 swapchain. Pixel values are in
 *   BT.2020 ST2084 (PQ) encoding.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_SetGPUSwapchainParameters
 * \sa SDL_WindowSupportsGPUSwapchainComposition
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
  }
type
  PPSDL_GPUSwapchainComposition = ^PSDL_GPUSwapchainComposition;
  PSDL_GPUSwapchainComposition = ^TSDL_GPUSwapchainComposition;
  TSDL_GPUSwapchainComposition = type Integer;
const
  SDL_GPU_SWAPCHAINCOMPOSITION_SDR  = TSDL_GPUSwapchainComposition(0);
  SDL_GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR  = TSDL_GPUSwapchainComposition(1);
  SDL_GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR  = TSDL_GPUSwapchainComposition(2);
  SDL_GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084  = TSDL_GPUSwapchainComposition(3);

{ Structures  }

{*
 * A structure specifying a viewport.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_SetGPUViewport
  }
type
  PPSDL_GPUViewport = ^PSDL_GPUViewport;
  PSDL_GPUViewport = ^TSDL_GPUViewport;
  TSDL_GPUViewport = record
      x: cfloat;          {*< The left offset of the viewport.  }
      y: cfloat;          {*< The top offset of the viewport.  }
      w: cfloat;          {*< The width of the viewport.  }
      h: cfloat;          {*< The height of the viewport.  }
      min_depth: cfloat;  {*< The minimum depth of the viewport.  }
      max_depth: cfloat;  {*< The maximum depth of the viewport.  }
    end;

{*
 * A structure specifying parameters related to transferring data to or from a
 * texture.
 *
 * If either of `pixels_per_row` or `rows_per_layer` is zero, then width and
 * height of passed SDL_GPUTextureRegion to SDL_UploadToGPUTexture or
 * SDL_DownloadFromGPUTexture are used as default values respectively and data
 * is considered to be tightly packed.
 *
 * **WARNING**: On some older/integrated hardware, Direct3D 12 requires
 * texture data row pitch to be 256 byte aligned, and offsets to be aligned to
 * 512 bytes. If they are not, SDL will make a temporary copy of the data that
 * is properly aligned, but this adds overhead to the transfer process. Apps
 * can avoid this by aligning their data appropriately, or using a different
 * GPU backend than Direct3D 12.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUTexture
 * \sa SDL_DownloadFromGPUTexture
  }
type
  PPSDL_GPUTextureTransferInfo = ^PSDL_GPUTextureTransferInfo;
  PSDL_GPUTextureTransferInfo = ^TSDL_GPUTextureTransferInfo;
  TSDL_GPUTextureTransferInfo = record
      transfer_buffer: PSDL_GPUTransferBuffer; {*< The transfer buffer used in the transfer operation.  }
      offset: cuint32;                         {*< The starting byte of the image data in the transfer buffer.  }
      pixels_per_row: cuint32;                 {*< The number of pixels from one row to the next.  }
      rows_per_layer: cuint32;                 {*< The number of rows from one layer/depth-slice to the next.  }
    end;

{*
 * A structure specifying a location in a transfer buffer.
 *
 * Used when transferring buffer data to or from a transfer buffer.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUBuffer
 * \sa SDL_DownloadFromGPUBuffer
  }
type
  PPSDL_GPUTransferBufferLocation = ^PSDL_GPUTransferBufferLocation;
  PSDL_GPUTransferBufferLocation = ^TSDL_GPUTransferBufferLocation;
  TSDL_GPUTransferBufferLocation = record
      transfer_buffer: PSDL_GPUTransferBuffer;  {*< The transfer buffer used in the transfer operation.  }
      offset: cuint32;                          {*< The starting byte of the buffer data in the transfer buffer.  }
    end;

{*
 * A structure specifying a location in a texture.
 *
 * Used when copying data from one texture to another.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CopyGPUTextureToTexture
  }
type
  PPSDL_GPUTextureLocation = ^PSDL_GPUTextureLocation;
  PSDL_GPUTextureLocation = ^TSDL_GPUTextureLocation;
  TSDL_GPUTextureLocation = record
      texture: PSDL_GPUTexture;  {*< The texture used in the copy operation.  }
      mip_level: cuint32;        {*< The mip level index of the location.  }
      layer: cuint32;            {*< The layer index of the location.  }
      x: cuint32;                {*< The left offset of the location.  }
      y: cuint32;                {*< The top offset of the location.  }
      z: cuint32;                {*< The front offset of the location.  }
    end;

{*
 * A structure specifying a region of a texture.
 *
 * Used when transferring data to or from a texture.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUTexture
 * \sa SDL_DownloadFromGPUTexture
 * \sa SDL_CreateGPUTexture
  }
type
  PPSDL_GPUTextureRegion = ^PSDL_GPUTextureRegion;
  PSDL_GPUTextureRegion = ^TSDL_GPUTextureRegion;
  TSDL_GPUTextureRegion = record
      texture: PSDL_GPUTexture;  {*< The texture used in the copy operation.  }
      mip_level: cuint32;        {*< The mip level index to transfer.  }
      layer: cuint32;            {*< The layer index to transfer.  }
      x: cuint32;                {*< The left offset of the region.  }
      y: cuint32;                {*< The top offset of the region.  }
      z: cuint32;                {*< The front offset of the region.  }
      w: cuint32;                {*< The width of the region.  }
      h: cuint32;                {*< The height of the region.  }
      d: cuint32;                {*< The depth of the region.  }
    end;

{*
 * A structure specifying a region of a texture used in the blit operation.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BlitGPUTexture
  }
type
  PPSDL_GPUBlitRegion = ^PSDL_GPUBlitRegion;
  PSDL_GPUBlitRegion = ^TSDL_GPUBlitRegion;
  TSDL_GPUBlitRegion = record
      texture: PSDL_GPUTexture;       {*< The texture.  }
      mip_level: cuint32;             {*< The mip level index of the region.  }
      layer_or_depth_plane: cuint32;  {*< The layer index or depth plane of the region. This value is treated as a layer index on 2D array and cube textures, and as a depth plane on 3D textures.  }
      x: cuint32;                     {*< The left offset of the region.  }
      y: cuint32;                     {*< The top offset of the region.   }
      w: cuint32;                     {*< The width of the region.  }
      h: cuint32;                     {*< The height of the region.  }
    end;

{*
 * A structure specifying a location in a buffer.
 *
 * Used when copying data between buffers.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CopyGPUBufferToBuffer
  }
type
  PPSDL_GPUBufferLocation = ^PSDL_GPUBufferLocation;
  PSDL_GPUBufferLocation = ^TSDL_GPUBufferLocation;
  TSDL_GPUBufferLocation = record
      buffer: PSDL_GPUBuffer; {*< The buffer.  }
      offset: cuint32;        {*< The starting byte within the buffer.  }
    end;

{*
 * A structure specifying a region of a buffer.
 *
 * Used when transferring data to or from buffers.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUBuffer
 * \sa SDL_DownloadFromGPUBuffer
  }
type
  PPSDL_GPUBufferRegion = ^PSDL_GPUBufferRegion;
  PSDL_GPUBufferRegion = ^TSDL_GPUBufferRegion;
  TSDL_GPUBufferRegion = record
      buffer: PSDL_GPUBuffer;  {*< The buffer.  }
      offset: cuint32;         {*< The starting byte within the buffer.  }
      size: cuint32;           {*< The size in bytes of the region.  }
    end;

{*
 * A structure specifying the parameters of an indirect draw command.
 *
 * Note that the `first_vertex` and `first_instance` parameters are NOT
 * compatible with built-in vertex/instance ID variables in shaders (for
 * example, SV_VertexID); GPU APIs and shader languages do not define these
 * built-in variables consistently, so if your shader depends on them, the
 * only way to keep behavior consistent and portable is to always pass 0 for
 * the correlating parameter in the draw calls.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_DrawGPUPrimitivesIndirect
  }
type
  PPSDL_GPUIndirectDrawCommand = ^PSDL_GPUIndirectDrawCommand;
  PSDL_GPUIndirectDrawCommand = ^TSDL_GPUIndirectDrawCommand;
  TSDL_GPUIndirectDrawCommand = record
      num_vertices: cuint32;    {*< The number of vertices to draw.  }
      num_instances: cuint32;   {*< The number of instances to draw.  }
      first_vertex: cuint32;    {*< The index of the first vertex to draw.  }
      first_instance: cuint32;  {*< The ID of the first instance to draw.  }
    end;

{*
 * A structure specifying the parameters of an indexed indirect draw command.
 *
 * Note that the `first_vertex` and `first_instance` parameters are NOT
 * compatible with built-in vertex/instance ID variables in shaders (for
 * example, SV_VertexID); GPU APIs and shader languages do not define these
 * built-in variables consistently, so if your shader depends on them, the
 * only way to keep behavior consistent and portable is to always pass 0 for
 * the correlating parameter in the draw calls.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_DrawGPUIndexedPrimitivesIndirect
  }
type
  PPSDL_GPUIndexedIndirectDrawCommand = ^PSDL_GPUIndexedIndirectDrawCommand;
  PSDL_GPUIndexedIndirectDrawCommand = ^TSDL_GPUIndexedIndirectDrawCommand;
  TSDL_GPUIndexedIndirectDrawCommand = record
      num_indices: cuint32;     {*< The number of indices to draw per instance.  }
      num_instances: cuint32;   {*< The number of instances to draw.  }
      first_index: cuint32;     {*< The base index within the index buffer.  }
      vertex_offset: cint32;    {*< The value added to the vertex index before indexing into the vertex buffer.  }
      first_instance: cuint32;  {*< The ID of the first instance to draw.  }
    end;

{*
 * A structure specifying the parameters of an indexed dispatch command.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_DispatchGPUComputeIndirect
  }
type
  PPSDL_GPUIndirectDispatchCommand = ^PSDL_GPUIndirectDispatchCommand;
  PSDL_GPUIndirectDispatchCommand = ^TSDL_GPUIndirectDispatchCommand;
  TSDL_GPUIndirectDispatchCommand = record
      groupcount_x: cuint32; {*< The number of local workgroups to dispatch in the X dimension.  }
      groupcount_y: cuint32; {*< The number of local workgroups to dispatch in the Y dimension.  }
      groupcount_z: cuint32; {*< The number of local workgroups to dispatch in the Z dimension.  }
    end;

{ State structures  }

{*
 * A structure specifying the parameters of a sampler.
 *
 * Note that mip_lod_bias is a no-op for the Metal driver. For Metal, LOD bias
 * must be applied via shader instead.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUSampler
 * \sa SDL_GPUFilter
 * \sa SDL_GPUSamplerMipmapMode
 * \sa SDL_GPUSamplerAddressMode
 * \sa SDL_GPUCompareOp
  }
type
  PPSDL_GPUSamplerCreateInfo = ^PSDL_GPUSamplerCreateInfo;
  PSDL_GPUSamplerCreateInfo = ^TSDL_GPUSamplerCreateInfo;
  TSDL_GPUSamplerCreateInfo = record
      min_filter: TSDL_GPUFilter;                  {*< The minification filter to apply to lookups.  }
      mag_filter: TSDL_GPUFilter;                  {*< The magnification filter to apply to lookups.  }
      mipmap_mode: TSDL_GPUSamplerMipmapMode;      {*< The mipmap filter to apply to lookups.  }
      address_mode_u: TSDL_GPUSamplerAddressMode;  {*< The addressing mode for U coordinates outside [0, 1).  }
      address_mode_v: TSDL_GPUSamplerAddressMode;  {*< The addressing mode for V coordinates outside [0, 1).  }
      address_mode_w: TSDL_GPUSamplerAddressMode;  {*< The addressing mode for W coordinates outside [0, 1).  }
      mip_lod_bias: cfloat;                        {*< The bias to be added to mipmap LOD calculation.  }
      max_anisotropy: cfloat;                      {*< The anisotropy value clamp used by the sampler. If enable_anisotropy is false, this is ignored.  }
      compare_op: TSDL_GPUCompareOp;               {*< The comparison operator to apply to fetched data before filtering.  }
      min_lod: cfloat;                             {*< Clamps the minimum of the computed LOD value.  }
      max_lod: cfloat;                             {*< Clamps the maximum of the computed LOD value.  }
      enable_anisotropy: Boolean;                  {*< true to enable anisotropic filtering.  }
      enable_compare: Boolean;                     {*< true to enable comparison against a reference value during lookups.  }
      padding1: cuint8;
      padding2: cuint8;

      props: TSDL_PropertiesID;                    {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{*
 * A structure specifying the parameters of vertex buffers used in a graphics
 * pipeline.
 *
 * When you call SDL_BindGPUVertexBuffers, you specify the binding slots of
 * the vertex buffers. For example if you called SDL_BindGPUVertexBuffers with
 * a first_slot of 2 and num_bindings of 3, the binding slots 2, 3, 4 would be
 * used by the vertex buffers you pass in.
 *
 * Vertex attributes are linked to buffers via the buffer_slot field of
 * SDL_GPUVertexAttribute. For example, if an attribute has a buffer_slot of
 * 0, then that attribute belongs to the vertex buffer bound at slot 0.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUVertexAttribute
 * \sa SDL_GPUVertexInputRate
  }
type
  PPSDL_GPUVertexBufferDescription = ^PSDL_GPUVertexBufferDescription;
  PSDL_GPUVertexBufferDescription = ^TSDL_GPUVertexBufferDescription;
  TSDL_GPUVertexBufferDescription = record
      slot: cuint32;                       {*< The binding slot of the vertex buffer.  }
      pitch: cuint32;                      {*< The size of a single element + the offset between elements.  }
      input_rate: TSDL_GPUVertexInputRate; {*< Whether attribute addressing is a function of the vertex index or instance index.  }
      instance_step_rate: cuint32;         {*< Reserved for future use. Must be set to 0.  }
    end;

{*
 * A structure specifying a vertex attribute.
 *
 * All vertex attribute locations provided to an SDL_GPUVertexInputState must
 * be unique.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUVertexBufferDescription
 * \sa SDL_GPUVertexInputState
 * \sa SDL_GPUVertexElementFormat
  }
type
  PPSDL_GPUVertexAttribute = ^PSDL_GPUVertexAttribute;
  PSDL_GPUVertexAttribute = ^TSDL_GPUVertexAttribute;
  TSDL_GPUVertexAttribute = record
      location: cuint32;                   {*< The shader input location index.  }
      buffer_slot: cuint32;                {*< The binding slot of the associated vertex buffer.  }
      format: TSDL_GPUVertexElementFormat; {*< The size and type of the attribute data.  }
      offset: cuint32;                     {*< The byte offset of this attribute relative to the start of the vertex element.  }
    end;

{*
 * A structure specifying the parameters of a graphics pipeline vertex input
 * state.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUGraphicsPipelineCreateInfo
 * \sa SDL_GPUVertexBufferDescription
 * \sa SDL_GPUVertexAttribute
  }
type
  PPSDL_GPUVertexInputState = ^PSDL_GPUVertexInputState;
  PSDL_GPUVertexInputState = ^TSDL_GPUVertexInputState;
  TSDL_GPUVertexInputState = record
      vertex_buffer_descriptions: PSDL_GPUVertexBufferDescription; {*< A Pointer to an array of vertex buffer descriptions.  }
      num_vertex_buffers: cuint32;                                 {*< The number of vertex buffer descriptions in the above array.  }
      vertex_attributes: PSDL_GPUVertexAttribute;                  {*< A Pointer to an array of vertex attribute descriptions.  }
      num_vertex_attributes: cuint32;                              {*< The number of vertex attribute descriptions in the above array.  }
    end;

{*
 * A structure specifying the stencil operation state of a graphics pipeline.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUDepthStencilState
  }
type
  PPSDL_GPUStencilOpState = ^PSDL_GPUStencilOpState;
  PSDL_GPUStencilOpState = ^TSDL_GPUStencilOpState;
  TSDL_GPUStencilOpState = record
      fail_op: TSDL_GPUStencilOp;       {*< The action performed on samples that fail the stencil test.  }
      pass_op: TSDL_GPUStencilOp;       {*< The action performed on samples that pass the depth and stencil tests.  }
      depth_fail_op: TSDL_GPUStencilOp; {*< The action performed on samples that pass the stencil test and fail the depth test.  }
      compare_op: TSDL_GPUCompareOp;    {*< The comparison operator used in the stencil test.  }
    end;

{*
 * A structure specifying the blend state of a color target.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUColorTargetDescription
 * \sa SDL_GPUBlendFactor
 * \sa SDL_GPUBlendOp
 * \sa SDL_GPUColorComponentFlags
  }
type
  PPSDL_GPUColorTargetBlendState = ^PSDL_GPUColorTargetBlendState;
  PSDL_GPUColorTargetBlendState = ^TSDL_GPUColorTargetBlendState;
  TSDL_GPUColorTargetBlendState = record
      src_color_blendfactor: TSDL_GPUBlendFactor;    {*< The value to be multiplied by the source RGB value.  }
      dst_color_blendfactor: TSDL_GPUBlendFactor;    {*< The value to be multiplied by the destination RGB value.  }
      color_blend_op: TSDL_GPUBlendOp;               {*< The blend operation for the RGB components.  }
      src_alpha_blendfactor: TSDL_GPUBlendFactor;    {*< The value to be multiplied by the source alpha.  }
      dst_alpha_blendfactor: TSDL_GPUBlendFactor;    {*< The value to be multiplied by the destination alpha.  }
      alpha_blend_op: TSDL_GPUBlendOp;               {*< The blend operation for the alpha component.  }
      color_write_mask: TSDL_GPUColorComponentFlags; {*< A bitmask specifying which of the RGBA components are enabled for writing. Writes to all channels if enable_color_write_mask is false.  }
      enable_blend: Boolean;                         {*< Whether blending is enabled for the color target.  }
      enable_color_write_mask: Boolean;              {*< Whether the color write mask is enabled.  }
      padding1: cuint8;
      padding2: cuint8;
    end;

{*
 * A structure specifying code and metadata for creating a shader object.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
 * \sa SDL_GPUShaderFormat
 * \sa SDL_GPUShaderStage
  }
type
  PPSDL_GPUShaderCreateInfo = ^PSDL_GPUShaderCreateInfo;
  PSDL_GPUShaderCreateInfo = ^TSDL_GPUShaderCreateInfo;
  TSDL_GPUShaderCreateInfo = record
      code_size: csize_t;            {*< The size in bytes of the code pointed to.  }
      code: pcuint8;                 {*< A Pointer to shader code.  }
      entrypoint: PAnsiChar;         {*< A Pointer to a null-terminated UTF-8 string specifying the entry point function name for the shader.  }
      format: TSDL_GPUShaderFormat;  {*< The format of the shader code.  }
      stage: TSDL_GPUShaderStage;    {*< The stage the shader program corresponds to.  }
      num_samplers: cuint32;         {*< The number of samplers defined in the shader.  }
      num_storage_textures: cuint32; {*< The number of storage textures defined in the shader.  }
      num_storage_buffers: cuint32;  {*< The number of storage buffers defined in the shader.  }
      num_uniform_buffers: cuint32;  {*< The number of uniform buffers defined in the shader.  }

      props: TSDL_PropertiesID;      {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{*
 * A structure specifying the parameters of a texture.
 *
 * Usage flags can be bitwise OR'd together for combinations of usages. Note
 * that certain usage combinations are invalid, for example SAMPLER and
 * GRAPHICS_STORAGE.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTexture
 * \sa SDL_GPUTextureType
 * \sa SDL_GPUTextureFormat
 * \sa SDL_GPUTextureUsageFlags
 * \sa SDL_GPUSampleCount
  }
type
  PPSDL_GPUTextureCreateInfo = ^PSDL_GPUTextureCreateInfo;
  PSDL_GPUTextureCreateInfo = ^TSDL_GPUTextureCreateInfo;
  TSDL_GPUTextureCreateInfo = record
      type_: TSDL_GPUTextureType;        {*< The base dimensionality of the texture.  }
      format: TSDL_GPUTextureFormat;     {*< The pixel format of the texture.  }
      usage: TSDL_GPUTextureUsageFlags;  {*< How the texture is intended to be used by the client.  }
      width: cuint32;                    {*< The width of the texture.  }
      height: cuint32;                   {*< The height of the texture.  }
      layer_count_or_depth: cuint32;     {*< The layer count or depth of the texture. This value is treated as a layer count on 2D array textures, and as a depth value on 3D textures.  }
      num_levels: cuint32;               {*< The number of mip levels in the texture.  }
      sample_count: TSDL_GPUSampleCount; {*< The number of samples per texel. Only applies if the texture is used as a render target.  }

      props: TSDL_PropertiesID;          {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{*
 * A structure specifying the parameters of a buffer.
 *
 * Usage flags can be bitwise OR'd together for combinations of usages. Note
 * that certain combinations are invalid, for example VERTEX and INDEX.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUBuffer
 * \sa SDL_GPUBufferUsageFlags
  }
type
  PPSDL_GPUBufferCreateInfo = ^PSDL_GPUBufferCreateInfo;
  PSDL_GPUBufferCreateInfo = ^TSDL_GPUBufferCreateInfo;
  TSDL_GPUBufferCreateInfo = record
      usage: TSDL_GPUBufferUsageFlags; {*< How the buffer is intended to be used by the client.  }
      size: cuint32;                   {*< The size in bytes of the buffer.  }

      props: TSDL_PropertiesID;        {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{*
 * A structure specifying the parameters of a transfer buffer.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTransferBuffer
  }
type
  PPSDL_GPUTransferBufferCreateInfo = ^PSDL_GPUTransferBufferCreateInfo;
  PSDL_GPUTransferBufferCreateInfo = ^TSDL_GPUTransferBufferCreateInfo;
  TSDL_GPUTransferBufferCreateInfo = record
      usage: TSDL_GPUTransferBufferUsage; {*< How the transfer buffer is intended to be used by the client.  }
      size: cuint32;                      {*< The size in bytes of the transfer buffer.  }

      props: TSDL_PropertiesID;           {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{ Pipeline state structures  }

{*
 * A structure specifying the parameters of the graphics pipeline rasterizer
 * state.
 *
 * Note that SDL_GPU_FILLMODE_LINE is not supported on many Android devices.
 * For those devices, the fill mode will automatically fall back to FILL.
 *
 * Also note that the D3D12 driver will enable depth clamping even if
 * enable_depth_clip is true. If you need this clamp+clip behavior, consider
 * enabling depth clip and then manually clamping depth in your fragment
 * shaders on Metal and Vulkan.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUGraphicsPipelineCreateInfo
  }
type
  PPSDL_GPURasterizerState = ^PSDL_GPURasterizerState;
  PSDL_GPURasterizerState = ^TSDL_GPURasterizerState;
  TSDL_GPURasterizerState = record
      fill_mode: TSDL_GPUFillMode;         {*< Whether polygons will be filled in or drawn as lines.  }
      cull_mode: TSDL_GPUCullMode;         {*< The facing direction in which triangles will be culled.  }
      front_face: TSDL_GPUFrontFace;       {*< The vertex winding that will cause a triangle to be determined as front-facing.  }
      depth_bias_constant_factor: cfloat;  {*< A scalar factor controlling the depth value added to each fragment.  }
      depth_bias_clamp: cfloat;            {*< The maximum depth bias of a fragment.  }
      depth_bias_slope_factor: cfloat;     {*< A scalar factor applied to a fragment's slope in depth calculations.  }
      enable_depth_bias: Boolean;          {*< true to bias fragment depth values.  }
      enable_depth_clip: Boolean;          {*< true to enable depth clip, false to enable depth clamp.  }
      padding1: cuint8;
      padding2: cuint8;
    end;

{*
 * A structure specifying the parameters of the graphics pipeline multisample
 * state.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUGraphicsPipelineCreateInfo
  }
type
  PPSDL_GPUMultisampleState = ^PSDL_GPUMultisampleState;
  PSDL_GPUMultisampleState = ^TSDL_GPUMultisampleState;
  TSDL_GPUMultisampleState = record
      sample_count: TSDL_GPUSampleCount; {*< The number of samples to be used in rasterization.  }
      sample_mask: cuint32;              {*< Reserved for future use. Must be set to 0.  }
      enable_mask: Boolean;              {*< Reserved for future use. Must be set to false.  }
      enable_alpha_to_coverage: Boolean; {   true enables the alpha-to-coverage feature. }
      padding2: cuint8;
      padding3: cuint8;
    end;

{*
 * A structure specifying the parameters of the graphics pipeline depth
 * stencil state.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUGraphicsPipelineCreateInfo
  }
type
  PPSDL_GPUDepthStencilState = ^PSDL_GPUDepthStencilState;
  PSDL_GPUDepthStencilState = ^TSDL_GPUDepthStencilState;
  TSDL_GPUDepthStencilState = record
      compare_op: TSDL_GPUCompareOp;                {*< The comparison operator used for depth testing.  }
      back_stencil_state: TSDL_GPUStencilOpState;   {*< The stencil op state for back-facing triangles.  }
      front_stencil_state: TSDL_GPUStencilOpState;  {*< The stencil op state for front-facing triangles.  }
      compare_mask: cuint8;                         {*< Selects the bits of the stencil values participating in the stencil test.  }
      write_mask: cuint8;                           {*< Selects the bits of the stencil values updated by the stencil test.  }
      enable_depth_test: Boolean;                   {*< true enables the depth test.  }
      enable_depth_write: Boolean;                  {*< true enables depth writes. Depth writes are always disabled when enable_depth_test is false.  }
      enable_stencil_test: Boolean;                 {*< true enables the stencil test.  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
    end;

{*
 * A structure specifying the parameters of color targets used in a graphics
 * pipeline.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUGraphicsPipelineTargetInfo
  }
type
  PPSDL_GPUColorTargetDescription = ^PSDL_GPUColorTargetDescription;
  PSDL_GPUColorTargetDescription = ^TSDL_GPUColorTargetDescription;
  TSDL_GPUColorTargetDescription = record
      format: TSDL_GPUTextureFormat;               {*< The pixel format of the texture to be used as a color target.  }
      blend_state: TSDL_GPUColorTargetBlendState;  {*< The blend state to be used for the color target.  }
    end;

{*
 * A structure specifying the descriptions of render targets used in a
 * graphics pipeline.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GPUGraphicsPipelineCreateInfo
 * \sa SDL_GPUColorTargetDescription
 * \sa SDL_GPUTextureFormat
  }
type
  PPSDL_GPUGraphicsPipelineTargetInfo = ^PSDL_GPUGraphicsPipelineTargetInfo;
  PSDL_GPUGraphicsPipelineTargetInfo = ^TSDL_GPUGraphicsPipelineTargetInfo;
  TSDL_GPUGraphicsPipelineTargetInfo = record
      color_target_descriptions: PSDL_GPUColorTargetDescription; {*< A Pointer to an array of color target descriptions.  }
      num_color_targets: cuint32;                                {*< The number of color target descriptions in the above array.  }
      depth_stencil_format: TSDL_GPUTextureFormat;               {*< The pixel format of the depth-stencil target. Ignored if has_depth_stencil_target is false.  }
      has_depth_stencil_target: Boolean;                         {*< true specifies that the pipeline uses a depth-stencil target.  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
    end;

{*
 * A structure specifying the parameters of a graphics pipeline state.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
 * \sa SDL_GPUShader
 * \sa SDL_GPUVertexInputState
 * \sa SDL_GPUPrimitiveType
 * \sa SDL_GPURasterizerState
 * \sa SDL_GPUMultisampleState
 * \sa SDL_GPUDepthStencilState
 * \sa SDL_GPUGraphicsPipelineTargetInfo
  }
type
  PPSDL_GPUGraphicsPipelineCreateInfo = ^PSDL_GPUGraphicsPipelineCreateInfo;
  PSDL_GPUGraphicsPipelineCreateInfo = ^TSDL_GPUGraphicsPipelineCreateInfo;
  TSDL_GPUGraphicsPipelineCreateInfo = record
      vertex_shader: PSDL_GPUShader;                   {*< The vertex shader used by the graphics pipeline.  }
      fragment_shader: PSDL_GPUShader;                 {*< The fragment shader used by the graphics pipeline.  }
      vertex_input_state: TSDL_GPUVertexInputState;    {*< The vertex layout of the graphics pipeline.  }
      primitive_type: TSDL_GPUPrimitiveType;           {*< The primitive topology of the graphics pipeline.  }
      rasterizer_state: TSDL_GPURasterizerState;       {*< The rasterizer state of the graphics pipeline.  }
      multisample_state: TSDL_GPUMultisampleState;     {*< The multisample state of the graphics pipeline.  }
      depth_stencil_state: TSDL_GPUDepthStencilState;  {*< The depth-stencil state of the graphics pipeline.  }
      target_info: TSDL_GPUGraphicsPipelineTargetInfo; {*< Formats and blend modes for the render targets of the graphics pipeline.  }

      props: TSDL_PropertiesID;                        {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{*
 * A structure specifying the parameters of a compute pipeline state.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUComputePipeline
 * \sa SDL_GPUShaderFormat
  }
type
  PPSDL_GPUComputePipelineCreateInfo = ^PSDL_GPUComputePipelineCreateInfo;
  PSDL_GPUComputePipelineCreateInfo = ^TSDL_GPUComputePipelineCreateInfo;
  TSDL_GPUComputePipelineCreateInfo = record
      code_size: csize_t;                       {*< The size in bytes of the compute shader code pointed to.  }
      code: pcuint8;                            {*< A Pointer to compute shader code.  }
      entrypoint: PAnsiChar;                    {*< A Pointer to a null-terminated UTF-8 string specifying the entry point function name for the shader.  }
      format: TSDL_GPUShaderFormat;             {*< The format of the compute shader code.  }
      num_samplers: cuint32;                    {*< The number of samplers defined in the shader.  }
      num_readonly_storage_textures: cuint32;   {*< The number of readonly storage textures defined in the shader.  }
      num_readonly_storage_buffers: cuint32;    {*< The number of readonly storage buffers defined in the shader.  }
      num_readwrite_storage_textures: cuint32;  {*< The number of read-write storage textures defined in the shader.  }
      num_readwrite_storage_buffers: cuint32;   {*< The number of read-write storage buffers defined in the shader.  }
      num_uniform_buffers: cuint32;             {*< The number of uniform buffers defined in the shader.  }
      threadcount_x: cuint32;                   {*< The number of threads in the X dimension. This should match the value in the shader.  }
      threadcount_y: cuint32;                   {*< The number of threads in the Y dimension. This should match the value in the shader.  }
      threadcount_z: cuint32;                   {*< The number of threads in the Z dimension. This should match the value in the shader.  }

      props: TSDL_PropertiesID;                 {*< A properties ID for extensions. Should be 0 if no extensions are needed.  }
    end;

{*
 * A structure specifying the parameters of a color target used by a render
 * pass.
 *
 * The load_op field determines what is done with the texture at the beginning
 * of the render pass.
 *
 * - LOAD: Loads the data currently in the texture. Not recommended for
 *   multisample textures as it requires significant memory bandwidth.
 * - CLEAR: Clears the texture to a single color.
 * - DONT_CARE: The driver will do whatever it wants with the texture memory.
 *   This is a good option if you know that every single pixel will be touched
 *   in the render pass.
 *
 * The store_op field determines what is done with the color results of the
 * render pass.
 *
 * - STORE: Stores the results of the render pass in the texture. Not
 *   recommended for multisample textures as it requires significant memory
 *   bandwidth.
 * - DONT_CARE: The driver will do whatever it wants with the texture memory.
 *   This is often a good option for depth/stencil textures.
 * - RESOLVE: Resolves a multisample texture into resolve_texture, which must
 *   have a sample count of 1. Then the driver may discard the multisample
 *   texture memory. This is the most performant method of resolving a
 *   multisample target.
 * - RESOLVE_AND_STORE: Resolves a multisample texture into the
 *   resolve_texture, which must have a sample count of 1. Then the driver
 *   stores the multisample texture's contents. Not recommended as it requires
 *   significant memory bandwidth.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPURenderPass
 * \sa SDL_FColor
  }
type
  PPSDL_GPUColorTargetInfo = ^PSDL_GPUColorTargetInfo;
  PSDL_GPUColorTargetInfo = ^TSDL_GPUColorTargetInfo;
  TSDL_GPUColorTargetInfo = record
      texture: PSDL_GPUTexture;          {*< The texture that will be used as a color target by a render pass.  }
      mip_level: cuint32;                {*< The mip level to use as a color target.  }
      layer_or_depth_plane: cuint32;     {*< The layer index or depth plane to use as a color target. This value is treated as a layer index on 2D array and cube textures, and as a depth plane on 3D textures.  }
      clear_color: TSDL_FColor;          {*< The color to clear the color target to at the start of the render pass. Ignored if SDL_GPU_LOADOP_CLEAR is not used.  }
      load_op: TSDL_GPULoadOp;           {*< What is done with the contents of the color target at the beginning of the render pass.  }
      store_op: TSDL_GPUStoreOp;         {*< What is done with the results of the render pass.  }
      resolve_texture: PSDL_GPUTexture;  {*< The texture that will receive the results of a multisample resolve operation. Ignored if a RESOLVE* store_op is not used.  }
      resolve_mip_level: cuint32;        {*< The mip level of the resolve texture to use for the resolve operation. Ignored if a RESOLVE* store_op is not used.  }
      resolve_layer: cuint32;            {*< The layer index of the resolve texture to use for the resolve operation. Ignored if a RESOLVE* store_op is not used.  }
      cycle: Boolean;                    {*< true cycles the texture if the texture is bound and load_op is not LOAD  }
      cycle_resolve_texture: Boolean;    {*< true cycles the resolve texture if the resolve texture is bound. Ignored if a RESOLVE* store_op is not used.  }
      padding1: cuint8;
      padding2: cuint8;
    end;

{*
 * A structure specifying the parameters of a depth-stencil target used by a
 * render pass.
 *
 * The load_op field determines what is done with the depth contents of the
 * texture at the beginning of the render pass.
 *
 * - LOAD: Loads the depth values currently in the texture.
 * - CLEAR: Clears the texture to a single depth.
 * - DONT_CARE: The driver will do whatever it wants with the memory. This is
 *   a good option if you know that every single pixel will be touched in the
 *   render pass.
 *
 * The store_op field determines what is done with the depth results of the
 * render pass.
 *
 * - STORE: Stores the depth results in the texture.
 * - DONT_CARE: The driver will do whatever it wants with the depth results.
 *   This is often a good option for depth/stencil textures that don't need to
 *   be reused again.
 *
 * The stencil_load_op field determines what is done with the stencil contents
 * of the texture at the beginning of the render pass.
 *
 * - LOAD: Loads the stencil values currently in the texture.
 * - CLEAR: Clears the stencil values to a single value.
 * - DONT_CARE: The driver will do whatever it wants with the memory. This is
 *   a good option if you know that every single pixel will be touched in the
 *   render pass.
 *
 * The stencil_store_op field determines what is done with the stencil results
 * of the render pass.
 *
 * - STORE: Stores the stencil results in the texture.
 * - DONT_CARE: The driver will do whatever it wants with the stencil results.
 *   This is often a good option for depth/stencil textures that don't need to
 *   be reused again.
 *
 * Note that depth/stencil targets do not support multisample resolves.
 *
 * Due to ABI limitations, depth textures with more than 255 layers are not
 * supported.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPURenderPass
  }
type
  PPSDL_GPUDepthStencilTargetInfo = ^PSDL_GPUDepthStencilTargetInfo;
  PSDL_GPUDepthStencilTargetInfo = ^TSDL_GPUDepthStencilTargetInfo;
  TSDL_GPUDepthStencilTargetInfo = record
      texture: PSDL_GPUTexture;           {*< The texture that will be used as the depth stencil target by the render pass.  }
      clear_depth: cfloat;                {*< The value to clear the depth component to at the beginning of the render pass. Ignored if SDL_GPU_LOADOP_CLEAR is not used.  }
      load_op: TSDL_GPULoadOp;            {*< What is done with the depth contents at the beginning of the render pass.  }
      store_op: TSDL_GPUStoreOp;          {*< What is done with the depth results of the render pass.  }
      stencil_load_op: TSDL_GPULoadOp;    {*< What is done with the stencil contents at the beginning of the render pass.  }
      stencil_store_op: TSDL_GPUStoreOp;  {*< What is done with the stencil results of the render pass.  }
      cycle: Boolean;                     {*< true cycles the texture if the texture is bound and any load ops are not LOAD  }
      clear_stencil: cuint8;              {*< The value to clear the stencil component to at the beginning of the render pass. Ignored if SDL_GPU_LOADOP_CLEAR is not used.  }
      mip_level: cuint8;                  {   The mip level to use as the depth stencil target.  }
      layer: cuint8;                      {   The layer index to use as the depth stencil target.  }
    end;

{*
 * A structure containing parameters for a blit command.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BlitGPUTexture
  }
type
  PPSDL_GPUBlitInfo = ^PSDL_GPUBlitInfo;
  PSDL_GPUBlitInfo = ^TSDL_GPUBlitInfo;
  TSDL_GPUBlitInfo = record
      source: TSDL_GPUBlitRegion;       {*< The source region for the blit.  }
      destination: TSDL_GPUBlitRegion;  {*< The destination region for the blit.  }
      load_op: TSDL_GPULoadOp;          {*< What is done with the contents of the destination before the blit.  }
      clear_color: TSDL_FColor;         {*< The color to clear the destination region to before the blit. Ignored if load_op is not SDL_GPU_LOADOP_CLEAR.  }
      flip_mode: TSDL_FlipMode;         {*< The flip mode for the source region.  }
      filter: TSDL_GPUFilter;           {*< The filter mode used when blitting.  }
      cycle: Boolean;                   {*< true cycles the destination texture if it is already bound.  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
    end;

{ Binding structs  }

{*
 * A structure specifying parameters in a buffer binding call.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BindGPUVertexBuffers
 * \sa SDL_BindGPUIndexBuffer
  }
type
  PPSDL_GPUBufferBinding = ^PSDL_GPUBufferBinding;
  PSDL_GPUBufferBinding = ^TSDL_GPUBufferBinding;
  TSDL_GPUBufferBinding = record
      buffer: PSDL_GPUBuffer; {*< The buffer to bind. Must have been created with SDL_GPU_BUFFERUSAGE_VERTEX for SDL_BindGPUVertexBuffers, or SDL_GPU_BUFFERUSAGE_INDEX for SDL_BindGPUIndexBuffer.  }
      offset: cuint32;        {*< The starting byte of the data to bind in the buffer.  }
    end;

{*
 * A structure specifying parameters in a sampler binding call.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BindGPUVertexSamplers
 * \sa SDL_BindGPUFragmentSamplers
 * \sa SDL_GPUTexture
 * \sa SDL_GPUSampler
  }
type
  PPSDL_GPUTextureSamplerBinding = ^PSDL_GPUTextureSamplerBinding;
  PSDL_GPUTextureSamplerBinding = ^TSDL_GPUTextureSamplerBinding;
  TSDL_GPUTextureSamplerBinding = record
      texture: PSDL_GPUTexture; {*< The texture to bind. Must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.  }
      sampler: PSDL_GPUSampler; {*< The sampler to bind.  }
    end;

{*
 * A structure specifying parameters related to binding buffers in a compute
 * pass.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPUComputePass
  }
type
  PPSDL_GPUStorageBufferReadWriteBinding = ^PSDL_GPUStorageBufferReadWriteBinding;
  PSDL_GPUStorageBufferReadWriteBinding = ^TSDL_GPUStorageBufferReadWriteBinding;
  TSDL_GPUStorageBufferReadWriteBinding = record
      buffer: PSDL_GPUBuffer;  {*< The buffer to bind. Must have been created with SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE.  }
      cycle: Boolean;          {*< true cycles the buffer if it is already bound.  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
    end;

{*
 * A structure specifying parameters related to binding textures in a compute
 * pass.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_BeginGPUComputePass
  }
type
  PPSDL_GPUStorageTextureReadWriteBinding = ^PSDL_GPUStorageTextureReadWriteBinding;
  PSDL_GPUStorageTextureReadWriteBinding = ^TSDL_GPUStorageTextureReadWriteBinding;
  TSDL_GPUStorageTextureReadWriteBinding = record
      texture: PSDL_GPUTexture; {*< The texture to bind. Must have been created with SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE or SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE.  }
      mip_level: cuint32;       {*< The mip level index to bind.  }
      layer: cuint32;           {*< The layer index to bind.  }
      cycle: Boolean;           {*< true cycles the texture if it is already bound.  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
    end;

{ Functions  }

{ Device  }

{*
 * Checks for GPU runtime support.
 *
 * \param format_flags a bitflag indicating which shader formats the app is
 *                     able to provide.
 * \param name the preferred GPU driver, or nil to let SDL pick the optimal
 *             driver.
 * \returns true if supported, false otherwise.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUDevice
  }
function SDL_GPUSupportsShaderFormats(format_flags: TSDL_GPUShaderFormat; name: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GPUSupportsShaderFormats' {$ENDIF} {$ENDIF};

{*
 * Checks for GPU runtime support.
 *
 * \param props the properties to use.
 * \returns true if supported, false otherwise.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUDeviceWithProperties
  }
function SDL_GPUSupportsProperties(props: TSDL_PropertiesID): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GPUSupportsProperties' {$ENDIF} {$ENDIF};

{*
 * Creates a GPU context.
 *
 * The GPU driver name can be one of the following:
 *
 * - "vulkan": [Vulkan](CategoryGPU#vulkan)
 * - "direct3d12": [D3D12](CategoryGPU#d3d12)
 * - "metal": [Metal](CategoryGPU#metal)
 * - NULL: let SDL pick the optimal driver
 *
 * \param format_flags a bitflag indicating which shader formats the app is
 *                     able to provide.
 * \param debug_mode enable debug mode properties and validations.
 * \param name the preferred GPU driver, or nil to let SDL pick the optimal
 *             driver.
 * \returns a GPU context on success or nil on failure; call SDL_GetError()
 *          for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUDeviceWithProperties
 * \sa SDL_GetGPUShaderFormats
 * \sa SDL_GetGPUDeviceDriver
 * \sa SDL_DestroyGPUDevice
 * \sa SDL_GPUSupportsShaderFormats
  }
function SDL_CreateGPUDevice(format_flags: TSDL_GPUShaderFormat; debug_mode: Boolean; name: PAnsiChar): PSDL_GPUDevice; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUDevice' {$ENDIF} {$ENDIF};

{*
 * Creates a GPU context.
 *
 * These are the supported properties:
 *
 * - `SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN`: enable debug mode
 *   properties and validations, defaults to true.
 * - `SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN`: enable to prefer
 *   energy efficiency over maximum GPU performance, defaults to false.
 * - `SDL_PROP_GPU_DEVICE_CREATE_VERBOSE_BOOLEAN`: enable to automatically log
 *   useful debug information on device creation, defaults to true.
 * - `SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING`: the name of the GPU driver to
 *   use, if a specific one is desired.
 * - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_CLIP_DISTANCE_BOOLEAN`: Enable Vulkan
 *   device feature shaderClipDistance. If disabled, clip distances are not
 *   supported in shader code: gl_ClipDistance[] built-ins of GLSL,
 *   SV_ClipDistance0/1 semantics of HLSL and [[clip_distance]] attribute of
 *   Metal. Disabling optional features allows the application to run on some
 *   older Android devices. Defaults to true.
 * - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_DEPTH_CLAMPING_BOOLEAN`: Enable
 *   Vulkan device feature depthClamp. If disabled, there is no depth clamp
 *   support and enable_depth_clip in SDL_GPURasterizerState must always be
 *   set to true. Disabling optional features allows the application to run on
 *   some older Android devices. Defaults to true.
 * - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_INDIRECT_DRAW_FIRST_INSTANCE_BOOLEAN`:
 *   Enable Vulkan device feature drawIndirectFirstInstance. If disabled, the
 *   argument first_instance of SDL_GPUIndirectDrawCommand must be set to
 *   zero. Disabling optional features allows the application to run on some
 *   older Android devices. Defaults to true.
 * - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_ANISOTROPY_BOOLEAN`: Enable Vulkan
 *   device feature samplerAnisotropy. If disabled, enable_anisotropy of
 *   SDL_GPUSamplerCreateInfo must be set to false. Disabling optional
 *   features allows the application to run on some older Android devices.
 *   Defaults to true.
 *
 * These are the current shader format properties:
 *
 * - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN`: The app is able to
 *   provide shaders for an NDA platform.
 * - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN`: The app is able to
 *   provide SPIR-V shaders if applicable.
 * - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN`: The app is able to
 *   provide DXBC shaders if applicable
 * - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN`: The app is able to
 *   provide DXIL shaders if applicable.
 * - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN`: The app is able to
 *   provide MSL shaders if applicable.
 * - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN`: The app is able to
 *   provide Metal shader libraries if applicable.
 *
 * With the D3D12 backend:
 *
 * - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING`: the prefix to
 *   use for all vertex semantics, default is "TEXCOORD".
 * - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_ALLOW_FEWER_RESOURCE_SLOTS_BOOLEAN`: By
 *   default, Resourcing Binding Tier 2 is required for D3D12 support.
 *   However, an application can set this property to true to enable Tier 1
 *   support, if (and only if) the application uses 8 or fewer storage
 *   resources across all shader stages. As of writing, this property is
 *   useful for targeting Intel Haswell and Broadwell GPUs; other hardware
 *   either supports Tier 2 Resource Binding or does not support D3D12 in any
 *   capacity. Defaults to false.
 * - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_VERSION_NUMBER`: Certain
 *   feature checks are only possible on Windows 11 by default. By setting
 *   this alongside `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_PATH_STRING`
 *   and vendoring D3D12Core.dll from the D3D12 Agility SDK, you can make
 *   those feature checks possible on older platforms. The version you provide
 *   must match the one given in the DLL.
 * - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_PATH_STRING`: Certain
 *   feature checks are only possible on Windows 11 by default. By setting
 *   this alongside
 *   `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_VERSION_NUMBER` and
 *   vendoring D3D12Core.dll from the D3D12 Agility SDK, you can make those
 *   feature checks possible on older platforms. The path you provide must be
 *   relative to the executable path of your app. Be sure not to put the DLL
 *   in the same directory as the exe; Microsoft strongly advises against
 *   this!
 *
 * With the Vulkan backend:
 *
 * - `SDL_PROP_GPU_DEVICE_CREATE_VULKAN_REQUIRE_HARDWARE_ACCELERATION_BOOLEAN`:
 *   By default, Vulkan device enumeration includes drivers of all types,
 *   including software renderers (for example, the Lavapipe Mesa driver).
 *   This can be useful if your application _requires_ SDL_GPU, but if you can
 *   provide your own fallback renderer (for example, an OpenGL renderer) this
 *   property can be set to true. Defaults to false.
 * - `SDL_PROP_GPU_DEVICE_CREATE_VULKAN_OPTIONS_POINTER`: a pointer to an
 *   SDL_GPUVulkanOptions structure to be processed during device creation.
 *   This allows configuring a variety of Vulkan-specific options such as
 *   increasing the API version and opting into extensions aside from the
 *   minimal set SDL requires.
 *
 * With the Metal backend: -
 * `SDL_PROP_GPU_DEVICE_CREATE_METAL_ALLOW_MACFAMILY1_BOOLEAN`: By default,
 * macOS support requires what Apple calls "MTLGPUFamilyMac2" hardware or
 * newer. However, an application can set this property to true to enable
 * support for "MTLGPUFamilyMac1" hardware, if (and only if) the application
 * does not write to sRGB textures. (For history's sake: MacFamily1 also does
 * not support indirect command buffers, MSAA depth resolve, and stencil
 * resolve/feedback, but these are not exposed features in SDL_GPU.)
 *
 * \param props the properties to use.
 * \returns a GPU context on success or nil on failure; call SDL_GetError()
 *          for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGPUShaderFormats
 * \sa SDL_GetGPUDeviceDriver
 * \sa SDL_DestroyGPUDevice
 * \sa SDL_GPUSupportsProperties
  }
function SDL_CreateGPUDeviceWithProperties(props: TSDL_PropertiesID): PSDL_GPUDevice; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUDeviceWithProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN = 'SDL.gpu.device.create.debugmode';
  SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN = 'SDL.gpu.device.create.preferlowpower';
  SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING = 'SDL.gpu.device.create.name';
  SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN = 'SDL.gpu.device.create.shaders.private';
  SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN = 'SDL.gpu.device.create.shaders.spirv';
  SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN = 'SDL.gpu.device.create.shaders.dxbc';
  SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN = 'SDL.gpu.device.create.shaders.dxil';
  SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN = 'SDL.gpu.device.create.shaders.msl';
  SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN = 'SDL.gpu.device.create.shaders.metallib';
  SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING = 'SDL.gpu.device.create.d3d12.semantic';
  SDL_PROP_GPU_DEVICE_CREATE_D3D12_ALLOW_FEWER_RESOURCE_SLOTS_BOOLEAN = 'SDL.gpu.device.create.d3d12.allowtier1resourcebinding';
  SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_VERSION_NUMBER = 'SDL.gpu.device.create.d3d12.agility_sdk_version';
  SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_PATH_STRING = 'SDL.gpu.device.create.d3d12.agility_sdk_path';
  SDL_PROP_GPU_DEVICE_CREATE_VULKAN_REQUIRE_HARDWARE_ACCELERATION_BOOLEAN = 'SDL.gpu.device.create.vulkan.requirehardwareacceleration';
  SDL_PROP_GPU_DEVICE_CREATE_VULKAN_OPTIONS_POINTER = 'SDL.gpu.device.create.vulkan.options';
  SDL_PROP_GPU_DEVICE_CREATE_METAL_ALLOW_MACFAMILY1_BOOLEAN = 'SDL.gpu.device.create.metal.allowmacfamily1';

{*
 * A structure specifying additional options when using Vulkan.
 *
 * When no such structure is provided, SDL will use Vulkan API version 1.0 and
 * a minimal set of features. The requested API version influences how the
 * feature_list is processed by SDL. When requesting API version 1.0, the
 * feature_list is ignored. Only the vulkan_10_physical_device_features and
 * the extension lists are used. When requesting API version 1.1, the
 * feature_list is scanned for feature structures introduced in Vulkan 1.1.
 * When requesting Vulkan 1.2 or higher, the feature_list is additionally
 * scanned for compound feature structs such as
 * VkPhysicalDeviceVulkan11Features. The device and instance extension lists,
 * as well as vulkan_10_physical_device_features, are always processed.
 *
 * \since This struct is available since SDL 3.4.0.
  }
type
  PPSDL_GPUVulkanOptions = ^PSDL_GPUVulkanOptions;
  PSDL_GPUVulkanOptions = ^TSDL_GPUVulkanOptions;
  TSDL_GPUVulkanOptions = record
      vulkan_api_version: cuint32;                 {*< The Vulkan API version to request for the instance. Use Vulkan's VK_MAKE_VERSION or VK_MAKE_API_VERSION.  }
      feature_list: Pointer;                       {*< Pointer to the first element of a chain of Vulkan feature structs. (Requires API version 1.1 or higher.) }
      vulkan_10_physical_device_features: Pointer; {*< Pointer to a VkPhysicalDeviceFeatures struct to enable additional Vulkan 1.0 features.  }
      device_extension_count: cuint32;             {*< Number of additional device extensions to require.  }
      device_extension_names: PPAnsiChar;          {*< Pointer to a list of additional device extensions to require.  }
      instance_extension_count: cuint32;           {*< Number of additional instance extensions to require.  }
      instance_extension_names: PPAnsiChar;        {*< Pointer to a list of additional instance extensions to require.  }
    end;

{*
 * Destroys a GPU context previously returned by SDL_CreateGPUDevice.
 *
 * \param device a GPU Context to destroy.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUDevice
  }
procedure SDL_DestroyGPUDevice(device: PSDL_GPUDevice); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyGPUDevice' {$ENDIF} {$ENDIF};

{*
 * Get the number of GPU drivers compiled into SDL.
 *
 * \returns the number of built in GPU drivers.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGPUDriver
  }
function SDL_GetNumGPUDrivers: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumGPUDrivers' {$ENDIF} {$ENDIF};

{*
 * Get the name of a built in GPU driver.
 *
 * The GPU drivers are presented in the order in which they are normally
 * checked during initialization.
 *
 * The names of drivers are all simple, low-ASCII identifiers, like "vulkan",
 * "metal" or "direct3d12". These never have Unicode characters, and are not
 * meant to be proper names.
 *
 * \param index the index of a GPU driver.
 * \returns the name of the GPU driver with the given **index**.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumGPUDrivers
  }
function SDL_GetGPUDriver(index: cint): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGPUDriver' {$ENDIF} {$ENDIF};

{*
 * Returns the name of the backend used to create this GPU context.
 *
 * \param device a GPU context to query.
 * \returns the name of the device's driver, or nil on error.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGPUDeviceDriver(device: PSDL_GPUDevice): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGPUDeviceDriver' {$ENDIF} {$ENDIF};

{*
 * Returns the supported shader formats for this GPU context.
 *
 * \param device a GPU context to query.
 * \returns a bitflag indicating which shader formats the driver is able to
 *          consume.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGPUShaderFormats(device: PSDL_GPUDevice): TSDL_GPUShaderFormat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGPUShaderFormats' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with a GPU device.
 *
 * All properties are optional and may differ between GPU backends and SDL
 * versions.
 *
 * The following properties are provided by SDL:
 *
 * `SDL_PROP_GPU_DEVICE_NAME_STRING`: Contains the name of the underlying
 * device as reported by the system driver. This string has no standardized
 * format, is highly inconsistent between hardware devices and drivers, and is
 * able to change at any time. Do not attempt to parse this string as it is
 * bound to fail at some point in the future when system drivers are updated,
 * new hardware devices are introduced, or when SDL adds new GPU backends or
 * modifies existing ones.
 *
 * Strings that have been found in the wild include:
 *
 * - GTX 970
 * - GeForce GTX 970
 * - NVIDIA GeForce GTX 970
 * - Microsoft Direct3D12 (NVIDIA GeForce GTX 970)
 * - NVIDIA Graphics Device
 * - GeForce GPU
 * - P106-100
 * - AMD 15D8: C9
 * - AMD Custom GPU 0405
 * - AMD Radeon (TM) Graphics
 * - ASUS Radeon RX 470 Series
 * - Intel(R) Arc(tm) A380 Graphics (DG2)
 * - Virtio-GPU Venus (NVIDIA TITAN V)
 * - SwiftShader Device (LLVM 16.0.0)
 * - llvmpipe (LLVM 15.0.4, 256 bits)
 * - Microsoft Basic Render Driver
 * - unknown device
 *
 * The above list shows that the same device can have different formats, the
 * vendor name may or may not appear in the string, the included vendor name
 * may not be the vendor of the chipset on the device, some manufacturers
 * include pseudo-legal marks while others don't, some devices may not use a
 * marketing name in the string, the device string may be wrapped by the name
 * of a translation interface, the device may be emulated in software, or the
 * string may contain generic text that does not identify the device at all.
 *
 * `SDL_PROP_GPU_DEVICE_DRIVER_NAME_STRING`: Contains the self-reported name
 * of the underlying system driver.
 *
 * Strings that have been found in the wild include:
 *
 * - Intel Corporation
 * - Intel open-source Mesa driver
 * - Qualcomm Technologies Inc. Adreno Vulkan Driver
 * - MoltenVK
 * - Mali-G715
 * - venus
 *
 * `SDL_PROP_GPU_DEVICE_DRIVER_VERSION_STRING`: Contains the self-reported
 * version of the underlying system driver. This is a relatively short version
 * string in an unspecified format. If SDL_PROP_GPU_DEVICE_DRIVER_INFO_STRING
 * is available then that property should be preferred over this one as it may
 * contain additional information that is useful for identifying the exact
 * driver version used.
 *
 * Strings that have been found in the wild include:
 *
 * - 53.0.0
 * - 0.405.2463
 * - 32.0.15.6614
 *
 * `SDL_PROP_GPU_DEVICE_DRIVER_INFO_STRING`: Contains the detailed version
 * information of the underlying system driver as reported by the driver. This
 * is an arbitrary string with no standardized format and it may contain
 * newlines. This property should be preferred over
 * SDL_PROP_GPU_DEVICE_DRIVER_VERSION_STRING if it is available as it usually
 * contains the same information but in a format that is easier to read.
 *
 * Strings that have been found in the wild include:
 *
 * - 101.6559
 * - 1.2.11
 * - Mesa 21.2.2 (LLVM 12.0.1)
 * - Mesa 22.2.0-devel (git-f226222 2022-04-14 impish-oibaf-ppa)
 * - v1.r53p0-00eac0.824c4f31403fb1fbf8ee1042422c2129
 *
 * This string has also been observed to be a multiline string (which has a
 * trailing newline):
 *
 * ```
 * Driver Build: 85da404, I46ff5fc46f, 1606794520
 * Date: 11/30/20
 * Compiler Version: EV031.31.04.01
 * Driver Branch: promo490_3_Google
 * ```
 *
 * \param device a GPU context to query.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetGPUDeviceProperties(device: PSDL_GPUDevice): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGPUDeviceProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_DEVICE_NAME_STRING = 'SDL.gpu.device.name';
  SDL_PROP_GPU_DEVICE_DRIVER_NAME_STRING = 'SDL.gpu.device.driver_name';
  SDL_PROP_GPU_DEVICE_DRIVER_VERSION_STRING = 'SDL.gpu.device.driver_version';
  SDL_PROP_GPU_DEVICE_DRIVER_INFO_STRING = 'SDL.gpu.device.driver_info';

{ State Creation  }

{*
 * Creates a pipeline object to be used in a compute workflow.
 *
 * Shader resource bindings must be authored to follow a particular order
 * depending on the shader format.
 *
 * For SPIR-V shaders, use the following resource sets:
 *
 * - 0: Sampled textures, followed by read-only storage textures, followed by
 *   read-only storage buffers
 * - 1: Read-write storage textures, followed by read-write storage buffers
 * - 2: Uniform buffers
 *
 * For DXBC and DXIL shaders, use the following register order:
 *
 * - (t[n], space0): Sampled textures, followed by read-only storage textures,
 *   followed by read-only storage buffers
 * - (u[n], space1): Read-write storage textures, followed by read-write
 *   storage buffers
 * - (b[n], space2): Uniform buffers
 *
 * For MSL/metallib, use the following order:
 *
 * - [[buffer]]: Uniform buffers, followed by read-only storage buffers,
 *   followed by read-write storage buffers
 * - [[texture]]: Sampled textures, followed by read-only storage textures,
 *   followed by read-write storage textures
 *
 * There are optional properties that can be provided through `props`. These
 * are the supported properties:
 *
 * - `SDL_PROP_GPU_COMPUTEPIPELINE_CREATE_NAME_STRING`: a name that can be
 *   displayed in debugging tools.
 *
 * \param device a GPU Context.
 * \param createinfo a struct describing the state of the compute pipeline to
 *                   create.
 * \returns a compute pipeline object on success, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BindGPUComputePipeline
 * \sa SDL_ReleaseGPUComputePipeline
  }
function SDL_CreateGPUComputePipeline(device: PSDL_GPUDevice; createinfo: PSDL_GPUComputePipelineCreateInfo): PSDL_GPUComputePipeline; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUComputePipeline' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_COMPUTEPIPELINE_CREATE_NAME_STRING = 'SDL.gpu.computepipeline.create.name';

{*
 * Creates a pipeline object to be used in a graphics workflow.
 *
 * There are optional properties that can be provided through `props`. These
 * are the supported properties:
 *
 * - `SDL_PROP_GPU_GRAPHICSPIPELINE_CREATE_NAME_STRING`: a name that can be
 *   displayed in debugging tools.
 *
 * \param device a GPU Context.
 * \param createinfo a struct describing the state of the graphics pipeline to
 *                   create.
 * \returns a graphics pipeline object on success, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
 * \sa SDL_BindGPUGraphicsPipeline
 * \sa SDL_ReleaseGPUGraphicsPipeline
  }
function SDL_CreateGPUGraphicsPipeline(device: PSDL_GPUDevice; createinfo: PSDL_GPUGraphicsPipelineCreateInfo): PSDL_GPUGraphicsPipeline; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUGraphicsPipeline' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_GRAPHICSPIPELINE_CREATE_NAME_STRING = 'SDL.gpu.graphicspipeline.create.name';

{*
 * Creates a sampler object to be used when binding textures in a graphics
 * workflow.
 *
 * There are optional properties that can be provided through `props`. These
 * are the supported properties:
 *
 * - `SDL_PROP_GPU_SAMPLER_CREATE_NAME_STRING`: a name that can be displayed
 *   in debugging tools.
 *
 * \param device a GPU Context.
 * \param createinfo a struct describing the state of the sampler to create.
 * \returns a sampler object on success, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_BindGPUVertexSamplers
 * \sa SDL_BindGPUFragmentSamplers
 * \sa SDL_ReleaseGPUSampler
  }
function SDL_CreateGPUSampler(device: PSDL_GPUDevice; createinfo: PSDL_GPUSamplerCreateInfo): PSDL_GPUSampler; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUSampler' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_SAMPLER_CREATE_NAME_STRING = 'SDL.gpu.sampler.create.name';

{*
 * Creates a shader to be used when creating a graphics pipeline.
 *
 * Shader resource bindings must be authored to follow a particular order
 * depending on the shader format.
 *
 * For SPIR-V shaders, use the following resource sets:
 *
 * For vertex shaders:
 *
 * - 0: Sampled textures, followed by storage textures, followed by storage
 *   buffers
 * - 1: Uniform buffers
 *
 * For fragment shaders:
 *
 * - 2: Sampled textures, followed by storage textures, followed by storage
 *   buffers
 * - 3: Uniform buffers
 *
 * For DXBC and DXIL shaders, use the following register order:
 *
 * For vertex shaders:
 *
 * - (t[n], space0): Sampled textures, followed by storage textures, followed
 *   by storage buffers
 * - (s[n], space0): Samplers with indices corresponding to the sampled
 *   textures
 * - (b[n], space1): Uniform buffers
 *
 * For pixel shaders:
 *
 * - (t[n], space2): Sampled textures, followed by storage textures, followed
 *   by storage buffers
 * - (s[n], space2): Samplers with indices corresponding to the sampled
 *   textures
 * - (b[n], space3): Uniform buffers
 *
 * For MSL/metallib, use the following order:
 *
 * - [[texture]]: Sampled textures, followed by storage textures
 * - [[sampler]]: Samplers with indices corresponding to the sampled textures
 * - [[buffer]]: Uniform buffers, followed by storage buffers. Vertex buffer 0
 *   is bound at [[buffer(14)]], vertex buffer 1 at [[buffer(15)]], and so on.
 *   Rather than manually authoring vertex buffer indices, use the
 *   [[stage_in]] attribute which will automatically use the vertex input
 *   information from the SDL_GPUGraphicsPipeline.
 *
 * Shader semantics other than system-value semantics do not matter in D3D12
 * and for ease of use the SDL implementation assumes that non system-value
 * semantics will all be TEXCOORD. If you are using HLSL as the shader source
 * language, your vertex semantics should start at TEXCOORD0 and increment
 * like so: TEXCOORD1, TEXCOORD2, etc. If you wish to change the semantic
 * prefix to something other than TEXCOORD you can use
 * SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING with
 * SDL_CreateGPUDeviceWithProperties().
 *
 * There are optional properties that can be provided through `props`. These
 * are the supported properties:
 *
 * - `SDL_PROP_GPU_SHADER_CREATE_NAME_STRING`: a name that can be displayed in
 *   debugging tools.
 *
 * \param device a GPU Context.
 * \param createinfo a struct describing the state of the shader to create.
 * \returns a shader object on success, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUGraphicsPipeline
 * \sa SDL_ReleaseGPUShader
  }
function SDL_CreateGPUShader(device: PSDL_GPUDevice; createinfo: PSDL_GPUShaderCreateInfo): PSDL_GPUShader; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUShader' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_SHADER_CREATE_NAME_STRING = 'SDL.gpu.shader.create.name';

{*
 * Creates a texture object to be used in graphics or compute workflows.
 *
 * The contents of this texture are undefined until data is written to the
 * texture, either via SDL_UploadToGPUTexture or by performing a render or
 * compute pass with this texture as a target.
 *
 * Note that certain combinations of usage flags are invalid. For example, a
 * texture cannot have both the SAMPLER and GRAPHICS_STORAGE_READ flags.
 *
 * If you request a sample count higher than the hardware supports, the
 * implementation will automatically fall back to the highest available sample
 * count.
 *
 * There are optional properties that can be provided through
 * SDL_GPUTextureCreateInfo's `props`. These are the supported properties:
 *
 * - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_R_FLOAT`: (Direct3D 12 only) if
 *   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
 *   to a color with this red intensity. Defaults to zero.
 * - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_G_FLOAT`: (Direct3D 12 only) if
 *   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
 *   to a color with this green intensity. Defaults to zero.
 * - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_B_FLOAT`: (Direct3D 12 only) if
 *   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
 *   to a color with this blue intensity. Defaults to zero.
 * - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_A_FLOAT`: (Direct3D 12 only) if
 *   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
 *   to a color with this alpha intensity. Defaults to zero.
 * - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_DEPTH_FLOAT`: (Direct3D 12 only)
 *   if the texture usage is SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET, clear
 *   the texture to a depth of this value. Defaults to zero.
 * - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_STENCIL_NUMBER`: (Direct3D 12
 *   only) if the texture usage is SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET,
 *   clear the texture to a stencil of this Uint8 value. Defaults to zero.
 * - `SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING`: a name that can be displayed
 *   in debugging tools.
 *
 * \param device a GPU Context.
 * \param createinfo a struct describing the state of the texture to create.
 * \returns a texture object on success, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUTexture
 * \sa SDL_DownloadFromGPUTexture
 * \sa SDL_BeginGPURenderPass
 * \sa SDL_BeginGPUComputePass
 * \sa SDL_BindGPUVertexSamplers
 * \sa SDL_BindGPUVertexStorageTextures
 * \sa SDL_BindGPUFragmentSamplers
 * \sa SDL_BindGPUFragmentStorageTextures
 * \sa SDL_BindGPUComputeStorageTextures
 * \sa SDL_BlitGPUTexture
 * \sa SDL_ReleaseGPUTexture
 * \sa SDL_GPUTextureSupportsFormat
  }
function SDL_CreateGPUTexture(device: PSDL_GPUDevice; createinfo: PSDL_GPUTextureCreateInfo): PSDL_GPUTexture; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUTexture' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_R_FLOAT = 'SDL.gpu.texture.create.d3d12.clear.r';
  SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_G_FLOAT = 'SDL.gpu.texture.create.d3d12.clear.g';
  SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_B_FLOAT = 'SDL.gpu.texture.create.d3d12.clear.b';
  SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_A_FLOAT = 'SDL.gpu.texture.create.d3d12.clear.a';
  SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_DEPTH_FLOAT = 'SDL.gpu.texture.create.d3d12.clear.depth';
  SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_STENCIL_NUMBER = 'SDL.gpu.texture.create.d3d12.clear.stencil';
  SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING = 'SDL.gpu.texture.create.name';

{*
 * Creates a buffer object to be used in graphics or compute workflows.
 *
 * The contents of this buffer are undefined until data is written to the
 * buffer.
 *
 * Note that certain combinations of usage flags are invalid. For example, a
 * buffer cannot have both the VERTEX and INDEX flags.
 *
 * If you use a STORAGE flag, the data in the buffer must respect std140
 * layout conventions. In practical terms this means you must ensure that vec3
 * and vec4 fields are 16-byte aligned.
 *
 * For better understanding of underlying concepts and memory management with
 * SDL GPU API, you may refer
 * [this blog post](https://moonside.games/posts/sdl-gpu-concepts-cycling/)
 * .
 *
 * There are optional properties that can be provided through `props`. These
 * are the supported properties:
 *
 * - `SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING`: a name that can be displayed in
 *   debugging tools.
 *
 * \param device a GPU Context.
 * \param createinfo a struct describing the state of the buffer to create.
 * \returns a buffer object on success, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUBuffer
 * \sa SDL_DownloadFromGPUBuffer
 * \sa SDL_CopyGPUBufferToBuffer
 * \sa SDL_BindGPUVertexBuffers
 * \sa SDL_BindGPUIndexBuffer
 * \sa SDL_BindGPUVertexStorageBuffers
 * \sa SDL_BindGPUFragmentStorageBuffers
 * \sa SDL_DrawGPUPrimitivesIndirect
 * \sa SDL_DrawGPUIndexedPrimitivesIndirect
 * \sa SDL_BindGPUComputeStorageBuffers
 * \sa SDL_DispatchGPUComputeIndirect
 * \sa SDL_ReleaseGPUBuffer
  }
function SDL_CreateGPUBuffer(device: PSDL_GPUDevice; createinfo: PSDL_GPUBufferCreateInfo): PSDL_GPUBuffer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUBuffer' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING = 'SDL.gpu.buffer.create.name';

{*
 * Creates a transfer buffer to be used when uploading to or downloading from
 * graphics resources.
 *
 * Download buffers can be particularly expensive to create, so it is good
 * practice to reuse them if data will be downloaded regularly.
 *
 * There are optional properties that can be provided through `props`. These
 * are the supported properties:
 *
 * - `SDL_PROP_GPU_TRANSFERBUFFER_CREATE_NAME_STRING`: a name that can be
 *   displayed in debugging tools.
 *
 * \param device a GPU Context.
 * \param createinfo a struct describing the state of the transfer buffer to
 *                   create.
 * \returns a transfer buffer on success, or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUBuffer
 * \sa SDL_DownloadFromGPUBuffer
 * \sa SDL_UploadToGPUTexture
 * \sa SDL_DownloadFromGPUTexture
 * \sa SDL_ReleaseGPUTransferBuffer
  }
function SDL_CreateGPUTransferBuffer(device: PSDL_GPUDevice; createinfo: PSDL_GPUTransferBufferCreateInfo): PSDL_GPUTransferBuffer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateGPUTransferBuffer' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GPU_TRANSFERBUFFER_CREATE_NAME_STRING = 'SDL.gpu.transferbuffer.create.name';

{ Debug Naming  }

{*
 * Sets an arbitrary string constant to label a buffer.
 *
 * You should use SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING with
 * SDL_CreateGPUBuffer instead of this function to avoid thread safety issues.
 *
 * \param device a GPU Context.
 * \param buffer a buffer to attach the name to.
 * \param text a UTF-8 string constant to mark as the name of the buffer.
 *
 * \threadsafety This function is not thread safe, you must make sure the
 *               buffer is not simultaneously used by any other thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUBuffer
  }
procedure SDL_SetGPUBufferName(device: PSDL_GPUDevice; buffer: PSDL_GPUBuffer; text: PAnsiChar); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUBufferName' {$ENDIF} {$ENDIF};

{*
 * Sets an arbitrary string constant to label a texture.
 *
 * You should use SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING with
 * SDL_CreateGPUTexture instead of this function to avoid thread safety
 * issues.
 *
 * \param device a GPU Context.
 * \param texture a texture to attach the name to.
 * \param text a UTF-8 string constant to mark as the name of the texture.
 *
 * \threadsafety This function is not thread safe, you must make sure the
 *               texture is not simultaneously used by any other thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUTexture
  }
procedure SDL_SetGPUTextureName(device: PSDL_GPUDevice; texture: PSDL_GPUTexture; text: PAnsiChar); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUTextureName' {$ENDIF} {$ENDIF};

{*
 * Inserts an arbitrary string label into the command buffer callstream.
 *
 * Useful for debugging.
 *
 * On Direct3D 12, using SDL_InsertGPUDebugLabel requires
 * WinPixEventRuntime.dll to be in your PATH or in the same directory as your
 * executable. See
 * [here](https://devblogs.microsoft.com/pix/winpixeventruntime/)
 * for instructions on how to obtain it.
 *
 * \param command_buffer a command buffer.
 * \param text a UTF-8 string constant to insert as the label.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_InsertGPUDebugLabel(command_buffer: PSDL_GPUCommandBuffer; text: PAnsiChar); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_InsertGPUDebugLabel' {$ENDIF} {$ENDIF};

{*
 * Begins a debug group with an arbitrary name.
 *
 * Used for denoting groups of calls when viewing the command buffer
 * callstream in a graphics debugging tool.
 *
 * Each call to SDL_PushGPUDebugGroup must have a corresponding call to
 * SDL_PopGPUDebugGroup.
 *
 * On Direct3D 12, using SDL_PushGPUDebugGroup requires WinPixEventRuntime.dll
 * to be in your PATH or in the same directory as your executable. See
 * [here](https://devblogs.microsoft.com/pix/winpixeventruntime/)
 * for instructions on how to obtain it.
 *
 * On some backends (e.g. Metal), pushing a debug group during a
 * render/blit/compute pass will create a group that is scoped to the native
 * pass rather than the command buffer. For best results, if you push a debug
 * group during a pass, always pop it in the same pass.
 *
 * \param command_buffer a command buffer.
 * \param name a UTF-8 string constant that names the group.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PopGPUDebugGroup
  }
procedure SDL_PushGPUDebugGroup(command_buffer: PSDL_GPUCommandBuffer; name: PAnsiChar); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PushGPUDebugGroup' {$ENDIF} {$ENDIF};

{*
 * Ends the most-recently pushed debug group.
 *
 * On Direct3D 12, using SDL_PopGPUDebugGroup requires WinPixEventRuntime.dll
 * to be in your PATH or in the same directory as your executable. See
 * [here](https://devblogs.microsoft.com/pix/winpixeventruntime/)
 * for instructions on how to obtain it.
 *
 * \param command_buffer a command buffer.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PushGPUDebugGroup
  }
procedure SDL_PopGPUDebugGroup(command_buffer: PSDL_GPUCommandBuffer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PopGPUDebugGroup' {$ENDIF} {$ENDIF};

{ Disposal  }

{*
 * Frees the given texture as soon as it is safe to do so.
 *
 * You must not reference the texture after calling this function.
 *
 * \param device a GPU context.
 * \param texture a texture to be destroyed.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_ReleaseGPUTexture(device: PSDL_GPUDevice; texture: PSDL_GPUTexture); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUTexture' {$ENDIF} {$ENDIF};

{*
 * Frees the given sampler as soon as it is safe to do so.
 *
 * You must not reference the sampler after calling this function.
 *
 * \param device a GPU context.
 * \param sampler a sampler to be destroyed.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_ReleaseGPUSampler(device: PSDL_GPUDevice; sampler: PSDL_GPUSampler); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUSampler' {$ENDIF} {$ENDIF};

{*
 * Frees the given buffer as soon as it is safe to do so.
 *
 * You must not reference the buffer after calling this function.
 *
 * \param device a GPU context.
 * \param buffer a buffer to be destroyed.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_ReleaseGPUBuffer(device: PSDL_GPUDevice; buffer: PSDL_GPUBuffer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUBuffer' {$ENDIF} {$ENDIF};

{*
 * Frees the given transfer buffer as soon as it is safe to do so.
 *
 * You must not reference the transfer buffer after calling this function.
 *
 * \param device a GPU context.
 * \param transfer_buffer a transfer buffer to be destroyed.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_ReleaseGPUTransferBuffer(device: PSDL_GPUDevice; transfer_buffer: PSDL_GPUTransferBuffer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUTransferBuffer' {$ENDIF} {$ENDIF};

{*
 * Frees the given compute pipeline as soon as it is safe to do so.
 *
 * You must not reference the compute pipeline after calling this function.
 *
 * \param device a GPU context.
 * \param compute_pipeline a compute pipeline to be destroyed.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_ReleaseGPUComputePipeline(device: PSDL_GPUDevice; compute_pipeline: PSDL_GPUComputePipeline); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUComputePipeline' {$ENDIF} {$ENDIF};

{*
 * Frees the given shader as soon as it is safe to do so.
 *
 * You must not reference the shader after calling this function.
 *
 * \param device a GPU context.
 * \param shader a shader to be destroyed.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_ReleaseGPUShader(device: PSDL_GPUDevice; shader: PSDL_GPUShader); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUShader' {$ENDIF} {$ENDIF};

{*
 * Frees the given graphics pipeline as soon as it is safe to do so.
 *
 * You must not reference the graphics pipeline after calling this function.
 *
 * \param device a GPU context.
 * \param graphics_pipeline a graphics pipeline to be destroyed.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_ReleaseGPUGraphicsPipeline(device: PSDL_GPUDevice; graphics_pipeline: PSDL_GPUGraphicsPipeline); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUGraphicsPipeline' {$ENDIF} {$ENDIF};

{*
 * Acquire a command buffer.
 *
 * This command buffer is managed by the implementation and should not be
 * freed by the user. The command buffer may only be used on the thread it was
 * acquired on. The command buffer should be submitted on the thread it was
 * acquired on.
 *
 * It is valid to acquire multiple command buffers on the same thread at once.
 * In fact a common design pattern is to acquire two command buffers per frame
 * where one is dedicated to render and compute passes and the other is
 * dedicated to copy passes and other preparatory work such as generating
 * mipmaps. Interleaving commands between the two command buffers reduces the
 * total amount of passes overall which improves rendering performance.
 *
 * \param device a GPU context.
 * \returns a command buffer, or nil on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SubmitGPUCommandBuffer
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
  }
function SDL_AcquireGPUCommandBuffer(device: PSDL_GPUDevice): PSDL_GPUCommandBuffer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AcquireGPUCommandBuffer' {$ENDIF} {$ENDIF};

{ Uniform Data  }

{*
 * Pushes data to a vertex uniform slot on the command buffer.
 *
 * Subsequent draw calls in this command buffer will use this uniform data.
 *
 * The data being pushed must respect std140 layout conventions. In practical
 * terms this means you must ensure that vec3 and vec4 fields are 16-byte
 * aligned.
 *
 * For detailed information about accessing uniform data from a shader, please
 * refer to SDL_CreateGPUShader.
 *
 * \param command_buffer a command buffer.
 * \param slot_index the vertex uniform slot to push data to.
 * \param data client data to write.
 * \param length the length of the data to write.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_PushGPUVertexUniformData(command_buffer: PSDL_GPUCommandBuffer; slot_index: cuint32; data: Pointer; length: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PushGPUVertexUniformData' {$ENDIF} {$ENDIF};

{*
 * Pushes data to a fragment uniform slot on the command buffer.
 *
 * Subsequent draw calls in this command buffer will use this uniform data.
 *
 * The data being pushed must respect std140 layout conventions. In practical
 * terms this means you must ensure that vec3 and vec4 fields are 16-byte
 * aligned.
 *
 * \param command_buffer a command buffer.
 * \param slot_index the fragment uniform slot to push data to.
 * \param data client data to write.
 * \param length the length of the data to write.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_PushGPUFragmentUniformData(command_buffer: PSDL_GPUCommandBuffer; slot_index: cuint32; data: Pointer; length: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PushGPUFragmentUniformData' {$ENDIF} {$ENDIF};

{*
 * Pushes data to a uniform slot on the command buffer.
 *
 * Subsequent draw calls in this command buffer will use this uniform data.
 *
 * The data being pushed must respect std140 layout conventions. In practical
 * terms this means you must ensure that vec3 and vec4 fields are 16-byte
 * aligned.
 *
 * \param command_buffer a command buffer.
 * \param slot_index the uniform slot to push data to.
 * \param data client data to write.
 * \param length the length of the data to write.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_PushGPUComputeUniformData(command_buffer: PSDL_GPUCommandBuffer; slot_index: cuint32; data: Pointer; length: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PushGPUComputeUniformData' {$ENDIF} {$ENDIF};

{ Graphics State  }

{*
 * Begins a render pass on a command buffer.
 *
 * A render pass consists of a set of texture subresources (or depth slices in
 * the 3D texture case) which will be rendered to during the render pass,
 * along with corresponding clear values and load/store operations. All
 * operations related to graphics pipelines must take place inside of a render
 * pass. A default viewport and scissor state are automatically set when this
 * is called. You cannot begin another render pass, or begin a compute pass or
 * copy pass until you have ended the render pass.
 *
 * Using SDL_GPU_LOADOP_LOAD before any contents have been written to the
 * texture subresource will result in undefined behavior. SDL_GPU_LOADOP_CLEAR
 * will set the contents of the texture subresource to a single value before
 * any rendering is performed. It's fine to do an empty render pass using
 * SDL_GPU_STOREOP_STORE to clear a texture, but in general it's better to
 * think of clearing not as an independent operation but as something that's
 * done as the beginning of a render pass.
 *
 * \param command_buffer a command buffer.
 * \param color_target_infos an array of texture subresources with
 *                           corresponding clear values and load/store ops.
 * \param num_color_targets the number of color targets in the
 *                          color_target_infos array.
 * \param depth_stencil_target_info a texture subresource with corresponding
 *                                  clear value and load/store ops, may be
 *                                  nil.
 * \returns a render pass handle.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_EndGPURenderPass
  }
function SDL_BeginGPURenderPass(command_buffer: PSDL_GPUCommandBuffer; color_target_infos: PSDL_GPUColorTargetInfo; num_color_targets: cuint32; depth_stencil_target_info: PSDL_GPUDepthStencilTargetInfo): PSDL_GPURenderPass; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BeginGPURenderPass' {$ENDIF} {$ENDIF};

{*
 * Binds a graphics pipeline on a render pass to be used in rendering.
 *
 * A graphics pipeline must be bound before making any draw calls.
 *
 * \param render_pass a render pass handle.
 * \param graphics_pipeline the graphics pipeline to bind.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_BindGPUGraphicsPipeline(render_pass: PSDL_GPURenderPass; graphics_pipeline: PSDL_GPUGraphicsPipeline); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUGraphicsPipeline' {$ENDIF} {$ENDIF};

{*
 * Sets the current viewport state on a command buffer.
 *
 * \param render_pass a render pass handle.
 * \param viewport the viewport to set.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_SetGPUViewport(render_pass: PSDL_GPURenderPass; viewport: PSDL_GPUViewport); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUViewport' {$ENDIF} {$ENDIF};

{*
 * Sets the current scissor state on a command buffer.
 *
 * \param render_pass a render pass handle.
 * \param scissor the scissor area to set.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_SetGPUScissor(render_pass: PSDL_GPURenderPass; scissor: PSDL_Rect); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUScissor' {$ENDIF} {$ENDIF};

{*
 * Sets the current blend constants on a command buffer.
 *
 * \param render_pass a render pass handle.
 * \param blend_constants the blend constant color.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GPU_BLENDFACTOR_CONSTANT_COLOR
 * \sa SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR
  }
procedure SDL_SetGPUBlendConstants(render_pass: PSDL_GPURenderPass; blend_constants: TSDL_FColor); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUBlendConstants' {$ENDIF} {$ENDIF};

{*
 * Sets the current stencil reference value on a command buffer.
 *
 * \param render_pass a render pass handle.
 * \param reference the stencil reference value to set.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_SetGPUStencilReference(render_pass: PSDL_GPURenderPass; reference: cuint8); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUStencilReference' {$ENDIF} {$ENDIF};

{*
 * Binds vertex buffers on a command buffer for use with subsequent draw
 * calls.
 *
 * \param render_pass a render pass handle.
 * \param first_slot the vertex buffer slot to begin binding from.
 * \param bindings an array of SDL_GPUBufferBinding structs containing vertex
 *                 buffers and offset values.
 * \param num_bindings the number of bindings in the bindings array.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_BindGPUVertexBuffers(render_pass: PSDL_GPURenderPass; first_slot: cuint32; bindings: PSDL_GPUBufferBinding; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUVertexBuffers' {$ENDIF} {$ENDIF};

{*
 * Binds an index buffer on a command buffer for use with subsequent draw
 * calls.
 *
 * \param render_pass a render pass handle.
 * \param binding a Pointer to a struct containing an index buffer and offset.
 * \param index_element_size whether the index values in the buffer are 16- or
 *                           32-bit.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_BindGPUIndexBuffer(render_pass: PSDL_GPURenderPass; binding: PSDL_GPUBufferBinding; index_element_size: TSDL_GPUIndexElementSize); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUIndexBuffer' {$ENDIF} {$ENDIF};

{*
 * Binds texture-sampler pairs for use on the vertex shader.
 *
 * The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUShader().
 *
 * \param render_pass a render pass handle.
 * \param first_slot the vertex sampler slot to begin binding from.
 * \param texture_sampler_bindings an array of texture-sampler binding
 *                                 structs.
 * \param num_bindings the number of texture-sampler pairs to bind from the
 *                     array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
procedure SDL_BindGPUVertexSamplers(render_pass: PSDL_GPURenderPass; first_slot: cuint32; texture_sampler_bindings: PSDL_GPUTextureSamplerBinding; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUVertexSamplers' {$ENDIF} {$ENDIF};

{*
 * Binds storage textures for use on the vertex shader.
 *
 * These textures must have been created with
 * SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUShader().
 *
 * \param render_pass a render pass handle.
 * \param first_slot the vertex storage texture slot to begin binding from.
 * \param storage_textures an array of storage textures.
 * \param num_bindings the number of storage texture to bind from the array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
procedure SDL_BindGPUVertexStorageTextures(render_pass: PSDL_GPURenderPass; first_slot: cuint32; storage_textures: PPSDL_GPUTexture; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUVertexStorageTextures' {$ENDIF} {$ENDIF};

{*
 * Binds storage buffers for use on the vertex shader.
 *
 * These buffers must have been created with
 * SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUShader().
 *
 * \param render_pass a render pass handle.
 * \param first_slot the vertex storage buffer slot to begin binding from.
 * \param storage_buffers an array of buffers.
 * \param num_bindings the number of buffers to bind from the array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
procedure SDL_BindGPUVertexStorageBuffers(render_pass: PSDL_GPURenderPass; first_slot: cuint32; storage_buffers: PPSDL_GPUBuffer; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUVertexStorageBuffers' {$ENDIF} {$ENDIF};

{*
 * Binds texture-sampler pairs for use on the fragment shader.
 *
 * The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUShader().
 *
 * \param render_pass a render pass handle.
 * \param first_slot the fragment sampler slot to begin binding from.
 * \param texture_sampler_bindings an array of texture-sampler binding
 *                                 structs.
 * \param num_bindings the number of texture-sampler pairs to bind from the
 *                     array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
procedure SDL_BindGPUFragmentSamplers(render_pass: PSDL_GPURenderPass; first_slot: cuint32; texture_sampler_bindings: PSDL_GPUTextureSamplerBinding; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUFragmentSamplers' {$ENDIF} {$ENDIF};

{*
 * Binds storage textures for use on the fragment shader.
 *
 * These textures must have been created with
 * SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUShader().
 *
 * \param render_pass a render pass handle.
 * \param first_slot the fragment storage texture slot to begin binding from.
 * \param storage_textures an array of storage textures.
 * \param num_bindings the number of storage textures to bind from the array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
procedure SDL_BindGPUFragmentStorageTextures(render_pass: PSDL_GPURenderPass; first_slot: cuint32; storage_textures: PPSDL_GPUTexture; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUFragmentStorageTextures' {$ENDIF} {$ENDIF};

{*
 * Binds storage buffers for use on the fragment shader.
 *
 * These buffers must have been created with
 * SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUShader().
 *
 * \param render_pass a render pass handle.
 * \param first_slot the fragment storage buffer slot to begin binding from.
 * \param storage_buffers an array of storage buffers.
 * \param num_bindings the number of storage buffers to bind from the array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUShader
  }
procedure SDL_BindGPUFragmentStorageBuffers(render_pass: PSDL_GPURenderPass; first_slot: cuint32; storage_buffers: PPSDL_GPUBuffer; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUFragmentStorageBuffers' {$ENDIF} {$ENDIF};

{ Drawing  }

{*
 * Draws data using bound graphics state with an index buffer and instancing
 * enabled.
 *
 * You must not call this function before binding a graphics pipeline.
 *
 * Note that the `first_vertex` and `first_instance` parameters are NOT
 * compatible with built-in vertex/instance ID variables in shaders (for
 * example, SV_VertexID); GPU APIs and shader languages do not define these
 * built-in variables consistently, so if your shader depends on them, the
 * only way to keep behavior consistent and portable is to always pass 0 for
 * the correlating parameter in the draw calls.
 *
 * \param render_pass a render pass handle.
 * \param num_indices the number of indices to draw per instance.
 * \param num_instances the number of instances to draw.
 * \param first_index the starting index within the index buffer.
 * \param vertex_offset value added to vertex index before indexing into the
 *                      vertex buffer.
 * \param first_instance the ID of the first instance to draw.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DrawGPUIndexedPrimitives(render_pass: PSDL_GPURenderPass; num_indices: cuint32; num_instances: cuint32; first_index: cuint32; vertex_offset: cint32; first_instance: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DrawGPUIndexedPrimitives' {$ENDIF} {$ENDIF};

{*
 * Draws data using bound graphics state.
 *
 * You must not call this function before binding a graphics pipeline.
 *
 * Note that the `first_vertex` and `first_instance` parameters are NOT
 * compatible with built-in vertex/instance ID variables in shaders (for
 * example, SV_VertexID); GPU APIs and shader languages do not define these
 * built-in variables consistently, so if your shader depends on them, the
 * only way to keep behavior consistent and portable is to always pass 0 for
 * the correlating parameter in the draw calls.
 *
 * \param render_pass a render pass handle.
 * \param num_vertices the number of vertices to draw.
 * \param num_instances the number of instances that will be drawn.
 * \param first_vertex the index of the first vertex to draw.
 * \param first_instance the ID of the first instance to draw.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DrawGPUPrimitives(render_pass: PSDL_GPURenderPass; num_vertices: cuint32; num_instances: cuint32; first_vertex: cuint32; first_instance: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DrawGPUPrimitives' {$ENDIF} {$ENDIF};

{*
 * Draws data using bound graphics state and with draw parameters set from a
 * buffer.
 *
 * The buffer must consist of tightly-packed draw parameter sets that each
 * match the layout of SDL_GPUIndirectDrawCommand. You must not call this
 * function before binding a graphics pipeline.
 *
 * \param render_pass a render pass handle.
 * \param buffer a buffer containing draw parameters.
 * \param offset the offset to start reading from the draw buffer.
 * \param draw_count the number of draw parameter sets that should be read
 *                   from the draw buffer.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DrawGPUPrimitivesIndirect(render_pass: PSDL_GPURenderPass; buffer: PSDL_GPUBuffer; offset: cuint32; draw_count: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DrawGPUPrimitivesIndirect' {$ENDIF} {$ENDIF};

{*
 * Draws data using bound graphics state with an index buffer enabled and with
 * draw parameters set from a buffer.
 *
 * The buffer must consist of tightly-packed draw parameter sets that each
 * match the layout of SDL_GPUIndexedIndirectDrawCommand. You must not call
 * this function before binding a graphics pipeline.
 *
 * \param render_pass a render pass handle.
 * \param buffer a buffer containing draw parameters.
 * \param offset the offset to start reading from the draw buffer.
 * \param draw_count the number of draw parameter sets that should be read
 *                   from the draw buffer.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DrawGPUIndexedPrimitivesIndirect(render_pass: PSDL_GPURenderPass; buffer: PSDL_GPUBuffer; offset: cuint32; draw_count: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DrawGPUIndexedPrimitivesIndirect' {$ENDIF} {$ENDIF};

{*
 * Ends the given render pass.
 *
 * All bound graphics state on the render pass command buffer is unset. The
 * render pass handle is now invalid.
 *
 * \param render_pass a render pass handle.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_EndGPURenderPass(render_pass: PSDL_GPURenderPass); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EndGPURenderPass' {$ENDIF} {$ENDIF};

{ Compute Pass  }
{*
 * Begins a compute pass on a command buffer.
 *
 * A compute pass is defined by a set of texture subresources and buffers that
 * may be written to by compute pipelines. These textures and buffers must
 * have been created with the COMPUTE_STORAGE_WRITE bit or the
 * COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE bit. If you do not create a texture
 * with COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE, you must not read from the
 * texture in the compute pass. All operations related to compute pipelines
 * must take place inside of a compute pass. You must not begin another
 * compute pass, or a render pass or copy pass before ending the compute pass.
 *
 * A VERY IMPORTANT NOTE - Reads and writes in compute passes are NOT
 * implicitly synchronized. This means you may cause data races by both
 * reading and writing a resource region in a compute pass, or by writing
 * multiple times to a resource region. If your compute work depends on
 * reading the completed output from a previous dispatch, you MUST end the
 * current compute pass and begin a new one before you can safely access the
 * data. Otherwise you will receive unexpected results. Reading and writing a
 * texture in the same compute pass is only supported by specific texture
 * formats. Make sure you check the format support!
 *
 * \param command_buffer a command buffer.
 * \param storage_texture_bindings an array of writeable storage texture
 *                                 binding structs.
 * \param num_storage_texture_bindings the number of storage textures to bind
 *                                     from the array.
 * \param storage_buffer_bindings an array of writeable storage buffer binding
 *                                structs.
 * \param num_storage_buffer_bindings the number of storage buffers to bind
 *                                    from the array.
 * \returns a compute pass handle.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_EndGPUComputePass
  }
function SDL_BeginGPUComputePass(command_buffer: PSDL_GPUCommandBuffer; storage_texture_bindings: PSDL_GPUStorageTextureReadWriteBinding; num_storage_texture_bindings: cuint32; storage_buffer_bindings: PSDL_GPUStorageBufferReadWriteBinding; num_storage_buffer_bindings: cuint32): PSDL_GPUComputePass; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BeginGPUComputePass' {$ENDIF} {$ENDIF};

{*
 * Binds a compute pipeline on a command buffer for use in compute dispatch.
 *
 * \param compute_pass a compute pass handle.
 * \param compute_pipeline a compute pipeline to bind.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_BindGPUComputePipeline(compute_pass: PSDL_GPUComputePass; compute_pipeline: PSDL_GPUComputePipeline); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUComputePipeline' {$ENDIF} {$ENDIF};

{*
 * Binds texture-sampler pairs for use on the compute shader.
 *
 * The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUComputePipeline().
 *
 * \param compute_pass a compute pass handle.
 * \param first_slot the compute sampler slot to begin binding from.
 * \param texture_sampler_bindings an array of texture-sampler binding
 *                                 structs.
 * \param num_bindings the number of texture-sampler bindings to bind from the
 *                     array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUComputePipeline
  }
procedure SDL_BindGPUComputeSamplers(compute_pass: PSDL_GPUComputePass; first_slot: cuint32; texture_sampler_bindings: PSDL_GPUTextureSamplerBinding; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUComputeSamplers' {$ENDIF} {$ENDIF};

{*
 * Binds storage textures as readonly for use on the compute pipeline.
 *
 * These textures must have been created with
 * SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUComputePipeline().
 *
 * \param compute_pass a compute pass handle.
 * \param first_slot the compute storage texture slot to begin binding from.
 * \param storage_textures an array of storage textures.
 * \param num_bindings the number of storage textures to bind from the array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUComputePipeline
  }
procedure SDL_BindGPUComputeStorageTextures(compute_pass: PSDL_GPUComputePass; first_slot: cuint32; storage_textures: PPSDL_GPUTexture; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUComputeStorageTextures' {$ENDIF} {$ENDIF};

{*
 * Binds storage buffers as readonly for use on the compute pipeline.
 *
 * These buffers must have been created with
 * SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ.
 *
 * Be sure your shader is set up according to the requirements documented in
 * SDL_CreateGPUComputePipeline().
 *
 * \param compute_pass a compute pass handle.
 * \param first_slot the compute storage buffer slot to begin binding from.
 * \param storage_buffers an array of storage buffer binding structs.
 * \param num_bindings the number of storage buffers to bind from the array.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateGPUComputePipeline
  }
procedure SDL_BindGPUComputeStorageBuffers(compute_pass: PSDL_GPUComputePass; first_slot: cuint32; storage_buffers: PPSDL_GPUBuffer; num_bindings: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BindGPUComputeStorageBuffers' {$ENDIF} {$ENDIF};

{*
 * Dispatches compute work.
 *
 * You must not call this function before binding a compute pipeline.
 *
 * A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
 * the dispatches write to the same resource region as each other, there is no
 * guarantee of which order the writes will occur. If the write order matters,
 * you MUST end the compute pass and begin another one.
 *
 * \param compute_pass a compute pass handle.
 * \param groupcount_x number of local workgroups to dispatch in the X
 *                     dimension.
 * \param groupcount_y number of local workgroups to dispatch in the Y
 *                     dimension.
 * \param groupcount_z number of local workgroups to dispatch in the Z
 *                     dimension.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DispatchGPUCompute(compute_pass: PSDL_GPUComputePass; groupcount_x: cuint32; groupcount_y: cuint32; groupcount_z: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DispatchGPUCompute' {$ENDIF} {$ENDIF};

{*
 * Dispatches compute work with parameters set from a buffer.
 *
 * The buffer layout should match the layout of
 * SDL_GPUIndirectDispatchCommand. You must not call this function before
 * binding a compute pipeline.
 *
 * A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
 * the dispatches write to the same resource region as each other, there is no
 * guarantee of which order the writes will occur. If the write order matters,
 * you MUST end the compute pass and begin another one.
 *
 * \param compute_pass a compute pass handle.
 * \param buffer a buffer containing dispatch parameters.
 * \param offset the offset to start reading from the dispatch buffer.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DispatchGPUComputeIndirect(compute_pass: PSDL_GPUComputePass; buffer: PSDL_GPUBuffer; offset: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DispatchGPUComputeIndirect' {$ENDIF} {$ENDIF};

{*
 * Ends the current compute pass.
 *
 * All bound compute state on the command buffer is unset. The compute pass
 * handle is now invalid.
 *
 * \param compute_pass a compute pass handle.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_EndGPUComputePass(compute_pass: PSDL_GPUComputePass); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EndGPUComputePass' {$ENDIF} {$ENDIF};

{ TransferBuffer Data  }

{*
 * Maps a transfer buffer into application address space.
 *
 * You must unmap the transfer buffer before encoding upload commands. The
 * memory is owned by the graphics driver - do NOT call SDL_free() on the
 * returned pointer.
 *
 * \param device a GPU context.
 * \param transfer_buffer a transfer buffer.
 * \param cycle if true, cycles the transfer buffer if it is already bound.
 * \returns the address of the mapped transfer buffer memory, or nil on
 *          failure; call SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_MapGPUTransferBuffer(device: PSDL_GPUDevice; transfer_buffer: PSDL_GPUTransferBuffer; cycle: Boolean): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_MapGPUTransferBuffer' {$ENDIF} {$ENDIF};

{*
 * Unmaps a previously mapped transfer buffer.
 *
 * \param device a GPU context.
 * \param transfer_buffer a previously mapped transfer buffer.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_UnmapGPUTransferBuffer(device: PSDL_GPUDevice; transfer_buffer: PSDL_GPUTransferBuffer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UnmapGPUTransferBuffer' {$ENDIF} {$ENDIF};

{ Copy Pass  }

{*
 * Begins a copy pass on a command buffer.
 *
 * All operations related to copying to or from buffers or textures take place
 * inside a copy pass. You must not begin another copy pass, or a render pass
 * or compute pass before ending the copy pass.
 *
 * \param command_buffer a command buffer.
 * \returns a copy pass handle.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_EndGPUCopyPass
  }
function SDL_BeginGPUCopyPass(command_buffer: PSDL_GPUCommandBuffer): PSDL_GPUCopyPass; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BeginGPUCopyPass' {$ENDIF} {$ENDIF};

{*
 * Uploads data from a transfer buffer to a texture.
 *
 * The upload occurs on the GPU timeline. You may assume that the upload has
 * finished in subsequent commands.
 *
 * You must align the data in the transfer buffer to a multiple of the texel
 * size of the texture format.
 *
 * \param copy_pass a copy pass handle.
 * \param source the source transfer buffer with image layout information.
 * \param destination the destination texture region.
 * \param cycle if true, cycles the texture if the texture is bound, otherwise
 *              overwrites the data.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_UploadToGPUTexture(copy_pass: PSDL_GPUCopyPass; source: PSDL_GPUTextureTransferInfo; destination: PSDL_GPUTextureRegion; cycle: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UploadToGPUTexture' {$ENDIF} {$ENDIF};

{*
 * Uploads data from a transfer buffer to a buffer.
 *
 * The upload occurs on the GPU timeline. You may assume that the upload has
 * finished in subsequent commands.
 *
 * \param copy_pass a copy pass handle.
 * \param source the source transfer buffer with offset.
 * \param destination the destination buffer with offset and size.
 * \param cycle if true, cycles the buffer if it is already bound, otherwise
 *              overwrites the data.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_UploadToGPUBuffer(copy_pass: PSDL_GPUCopyPass; source: PSDL_GPUTransferBufferLocation; destination: PSDL_GPUBufferRegion; cycle: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UploadToGPUBuffer' {$ENDIF} {$ENDIF};

{*
 * Performs a texture-to-texture copy.
 *
 * This copy occurs on the GPU timeline. You may assume the copy has finished
 * in subsequent commands.
 *
 * This function does not support copying between depth and color textures.
 * For those, copy the texture to a buffer and then to the destination
 * texture.
 *
 * \param copy_pass a copy pass handle.
 * \param source a source texture region.
 * \param destination a destination texture region.
 * \param w the width of the region to copy.
 * \param h the height of the region to copy.
 * \param d the depth of the region to copy.
 * \param cycle if true, cycles the destination texture if the destination
 *              texture is bound, otherwise overwrites the data.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_CopyGPUTextureToTexture(copy_pass: PSDL_GPUCopyPass; source: PSDL_GPUTextureLocation; destination: PSDL_GPUTextureLocation; w: cuint32; h: cuint32; d: cuint32; cycle: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CopyGPUTextureToTexture' {$ENDIF} {$ENDIF};

{*
 * Performs a buffer-to-buffer copy.
 *
 * This copy occurs on the GPU timeline. You may assume the copy has finished
 * in subsequent commands.
 *
 * \param copy_pass a copy pass handle.
 * \param source the buffer and offset to copy from.
 * \param destination the buffer and offset to copy to.
 * \param size the length of the buffer to copy.
 * \param cycle if true, cycles the destination buffer if it is already bound,
 *              otherwise overwrites the data.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_CopyGPUBufferToBuffer(copy_pass: PSDL_GPUCopyPass; source: PSDL_GPUBufferLocation; destination: PSDL_GPUBufferLocation; size: cuint32; cycle: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CopyGPUBufferToBuffer' {$ENDIF} {$ENDIF};

{*
 * Copies data from a texture to a transfer buffer on the GPU timeline.
 *
 * This data is not guaranteed to be copied until the command buffer fence is
 * signaled.
 *
 * \param copy_pass a copy pass handle.
 * \param source the source texture region.
 * \param destination the destination transfer buffer with image layout
 *                    information.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DownloadFromGPUTexture(copy_pass: PSDL_GPUCopyPass; source: PSDL_GPUTextureRegion; destination: PSDL_GPUTextureTransferInfo); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DownloadFromGPUTexture' {$ENDIF} {$ENDIF};

{*
 * Copies data from a buffer to a transfer buffer on the GPU timeline.
 *
 * This data is not guaranteed to be copied until the command buffer fence is
 * signaled.
 *
 * \param copy_pass a copy pass handle.
 * \param source the source buffer with offset and size.
 * \param destination the destination transfer buffer with offset.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_DownloadFromGPUBuffer(copy_pass: PSDL_GPUCopyPass; source: PSDL_GPUBufferRegion; destination: PSDL_GPUTransferBufferLocation); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DownloadFromGPUBuffer' {$ENDIF} {$ENDIF};

{*
 * Ends the current copy pass.
 *
 * \param copy_pass a copy pass handle.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_EndGPUCopyPass(copy_pass: PSDL_GPUCopyPass); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EndGPUCopyPass' {$ENDIF} {$ENDIF};

{*
 * Generates mipmaps for the given texture.
 *
 * This function must not be called inside of any pass.
 *
 * \param command_buffer a command_buffer.
 * \param texture a texture with more than 1 mip level.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_GenerateMipmapsForGPUTexture(command_buffer: PSDL_GPUCommandBuffer; texture: PSDL_GPUTexture); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GenerateMipmapsForGPUTexture' {$ENDIF} {$ENDIF};

{*
 * Blits from a source texture region to a destination texture region.
 *
 * This function must not be called inside of any pass.
 *
 * \param command_buffer a command buffer.
 * \param info the blit info struct containing the blit parameters.
 *
 * \since This function is available since SDL 3.2.0.
  }

procedure SDL_BlitGPUTexture(command_buffer: PSDL_GPUCommandBuffer; info: PSDL_GPUBlitInfo); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_BlitGPUTexture' {$ENDIF} {$ENDIF};

{ Submission/Presentation  }

{*
 * Determines whether a swapchain composition is supported by the window.
 *
 * The window must be claimed before calling this function.
 *
 * \param device a GPU context.
 * \param window an SDL_Window.
 * \param swapchain_composition the swapchain composition to check.
 * \returns true if supported, false if unsupported.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ClaimWindowForGPUDevice
  }
function SDL_WindowSupportsGPUSwapchainComposition(device: PSDL_GPUDevice; window: PSDL_Window; swapchain_composition: TSDL_GPUSwapchainComposition): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WindowSupportsGPUSwapchainComposition' {$ENDIF} {$ENDIF};

{*
 * Determines whether a presentation mode is supported by the window.
 *
 * The window must be claimed before calling this function.
 *
 * \param device a GPU context.
 * \param window an SDL_Window.
 * \param present_mode the presentation mode to check.
 * \returns true if supported, false if unsupported.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ClaimWindowForGPUDevice
  }
function SDL_WindowSupportsGPUPresentMode(device: PSDL_GPUDevice; window: PSDL_Window; present_mode: TSDL_GPUPresentMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WindowSupportsGPUPresentMode' {$ENDIF} {$ENDIF};

{*
 * Claims a window, creating a swapchain structure for it.
 *
 * This must be called before SDL_AcquireGPUSwapchainTexture is called using
 * the window. You should only call this function from the thread that created
 * the window.
 *
 * The swapchain will be created with SDL_GPU_SWAPCHAINCOMPOSITION_SDR and
 * SDL_GPU_PRESENTMODE_VSYNC. If you want to have different swapchain
 * parameters, you must call SDL_SetGPUSwapchainParameters after claiming the
 * window.
 *
 * \param device a GPU context.
 * \param window an SDL_Window.
 * \returns true on success, or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called from the thread that
 *               created the window.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
 * \sa SDL_ReleaseWindowFromGPUDevice
 * \sa SDL_WindowSupportsGPUPresentMode
 * \sa SDL_WindowSupportsGPUSwapchainComposition
  }
function SDL_ClaimWindowForGPUDevice(device: PSDL_GPUDevice; window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ClaimWindowForGPUDevice' {$ENDIF} {$ENDIF};

{*
 * Unclaims a window, destroying its swapchain structure.
 *
 * \param device a GPU context.
 * \param window an SDL_Window that has been claimed.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ClaimWindowForGPUDevice
  }
procedure SDL_ReleaseWindowFromGPUDevice(device: PSDL_GPUDevice; window: PSDL_Window); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseWindowFromGPUDevice' {$ENDIF} {$ENDIF};

{*
 * Changes the swapchain parameters for the given claimed window.
 *
 * This function will fail if the requested present mode or swapchain
 * composition are unsupported by the device. Check if the parameters are
 * supported via SDL_WindowSupportsGPUPresentMode /
 * SDL_WindowSupportsGPUSwapchainComposition prior to calling this function.
 *
 * SDL_GPU_PRESENTMODE_VSYNC with SDL_GPU_SWAPCHAINCOMPOSITION_SDR is always
 * supported.
 *
 * \param device a GPU context.
 * \param window an SDL_Window that has been claimed.
 * \param swapchain_composition the desired composition of the swapchain.
 * \param present_mode the desired present mode for the swapchain.
 * \returns true if successful, false on error; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_WindowSupportsGPUPresentMode
 * \sa SDL_WindowSupportsGPUSwapchainComposition
  }
function SDL_SetGPUSwapchainParameters(device: PSDL_GPUDevice; window: PSDL_Window; swapchain_composition: TSDL_GPUSwapchainComposition; present_mode: TSDL_GPUPresentMode): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUSwapchainParameters' {$ENDIF} {$ENDIF};

{*
 * Configures the maximum allowed number of frames in flight.
 *
 * The default value when the device is created is 2. This means that after
 * you have submitted 2 frames for presentation, if the GPU has not finished
 * working on the first frame, SDL_AcquireGPUSwapchainTexture() will fill the
 * swapchain texture Pointer with nil, and
 * SDL_WaitAndAcquireGPUSwapchainTexture() will block.
 *
 * Higher values increase throughput at the expense of visual latency. Lower
 * values decrease visual latency at the expense of throughput.
 *
 * Note that calling this function will stall and flush the command queue to
 * prevent synchronization issues.
 *
 * The minimum value of allowed frames in flight is 1, and the maximum is 3.
 *
 * \param device a GPU context.
 * \param allowed_frames_in_flight the maximum number of frames that can be
 *                                 pending on the GPU.
 * \returns true if successful, false on error; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SetGPUAllowedFramesInFlight(device: PSDL_GPUDevice; allowed_frames_in_flight: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGPUAllowedFramesInFlight' {$ENDIF} {$ENDIF};

{*
 * Obtains the texture format of the swapchain for the given window.
 *
 * Note that this format can change if the swapchain parameters change.
 *
 * \param device a GPU context.
 * \param window an SDL_Window that has been claimed.
 * \returns the texture format of the swapchain.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGPUSwapchainTextureFormat(device: PSDL_GPUDevice; window: PSDL_Window): TSDL_GPUTextureFormat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGPUSwapchainTextureFormat' {$ENDIF} {$ENDIF};

{*
 * Acquire a texture to use in presentation.
 *
 * When a swapchain texture is acquired on a command buffer, it will
 * automatically be submitted for presentation when the command buffer is
 * submitted. The swapchain texture should only be referenced by the command
 * buffer used to acquire it.
 *
 * This function will fill the swapchain texture handle with nil if too many
 * frames are in flight. This is not an error. This NULL pointer should not be
 * passed back into SDL. Instead, it should be considered as an indication to
 * wait until the swapchain is available.
 *
 * If you use this function, it is possible to create a situation where many
 * command buffers are allocated while the rendering context waits for the GPU
 * to catch up, which will cause memory usage to grow. You should use
 * SDL_WaitAndAcquireGPUSwapchainTexture() unless you know what you are doing
 * with timing.
 *
 * The swapchain texture is managed by the implementation and must not be
 * freed by the user. You MUST NOT call this function from any thread other
 * than the one that created the window.
 *
 * \param command_buffer a command buffer.
 * \param window a window that has been claimed.
 * \param swapchain_texture a Pointer filled in with a swapchain texture
 *                          handle.
 * \param swapchain_texture_width a Pointer filled in with the swapchain
 *                                texture width, may be nil.
 * \param swapchain_texture_height a Pointer filled in with the swapchain
 *                                 texture height, may be nil.
 * \returns true on success, false on error; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called from the thread that
 *               created the window.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ClaimWindowForGPUDevice
 * \sa SDL_SubmitGPUCommandBuffer
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
 * \sa SDL_CancelGPUCommandBuffer
 * \sa SDL_GetWindowSizeInPixels
 * \sa SDL_WaitForGPUSwapchain
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
 * \sa SDL_SetGPUAllowedFramesInFlight
  }
function SDL_AcquireGPUSwapchainTexture(command_buffer: PSDL_GPUCommandBuffer; window: PSDL_Window; swapchain_texture: PPSDL_GPUTexture; swapchain_texture_width: pcuint32; swapchain_texture_height: pcuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AcquireGPUSwapchainTexture' {$ENDIF} {$ENDIF};

{*
 * Blocks the thread until a swapchain texture is available to be acquired.
 *
 * \param device a GPU context.
 * \param window a window that has been claimed.
 * \returns true on success, false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called from the thread that
 *               created the window.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AcquireGPUSwapchainTexture
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
 * \sa SDL_SetGPUAllowedFramesInFlight
  }
function SDL_WaitForGPUSwapchain(device: PSDL_GPUDevice; window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitForGPUSwapchain' {$ENDIF} {$ENDIF};

{*
 * Blocks the thread until a swapchain texture is available to be acquired,
 * and then acquires it.
 *
 * When a swapchain texture is acquired on a command buffer, it will
 * automatically be submitted for presentation when the command buffer is
 * submitted. The swapchain texture should only be referenced by the command
 * buffer used to acquire it. It is an error to call
 * SDL_CancelGPUCommandBuffer() after a swapchain texture is acquired.
 *
 * This function can fill the swapchain texture handle with nil in certain
 * cases, for example if the window is minimized. This is not an error. You
 * should always make sure to check whether the Pointer is nil before
 * actually using it.
 *
 * The swapchain texture is managed by the implementation and must not be
 * freed by the user. You MUST NOT call this function from any thread other
 * than the one that created the window.
 *
 * The swapchain texture is write-only and cannot be used as a sampler or for
 * another reading operation.
 *
 * \param command_buffer a command buffer.
 * \param window a window that has been claimed.
 * \param swapchain_texture a Pointer filled in with a swapchain texture
 *                          handle.
 * \param swapchain_texture_width a Pointer filled in with the swapchain
 *                                texture width, may be nil.
 * \param swapchain_texture_height a Pointer filled in with the swapchain
 *                                 texture height, may be nil.
 * \returns true on success, false on error; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called from the thread that
 *               created the window.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SubmitGPUCommandBuffer
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
 * \sa SDL_AcquireGPUSwapchainTexture
  }
function SDL_WaitAndAcquireGPUSwapchainTexture(command_buffer: PSDL_GPUCommandBuffer; window: PSDL_Window; swapchain_texture: PPSDL_GPUTexture; swapchain_texture_width: pcuint32; swapchain_texture_height: pcuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitAndAcquireGPUSwapchainTexture' {$ENDIF} {$ENDIF};

{*
 * Submits a command buffer so its commands can be processed on the GPU.
 *
 * It is invalid to use the command buffer after this is called.
 *
 * This must be called from the thread the command buffer was acquired on.
 *
 * All commands in the submission are guaranteed to begin executing before any
 * command in a subsequent submission begins executing.
 *
 * \param command_buffer a command buffer.
 * \returns true on success, false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AcquireGPUCommandBuffer
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
 * \sa SDL_AcquireGPUSwapchainTexture
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
  }
function SDL_SubmitGPUCommandBuffer(command_buffer: PSDL_GPUCommandBuffer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SubmitGPUCommandBuffer' {$ENDIF} {$ENDIF};

{*
 * Submits a command buffer so its commands can be processed on the GPU, and
 * acquires a fence associated with the command buffer.
 *
 * You must release this fence when it is no longer needed or it will cause a
 * leak. It is invalid to use the command buffer after this is called.
 *
 * This must be called from the thread the command buffer was acquired on.
 *
 * All commands in the submission are guaranteed to begin executing before any
 * command in a subsequent submission begins executing.
 *
 * \param command_buffer a command buffer.
 * \returns a fence associated with the command buffer, or nil on failure;
 *          call SDL_GetError() for more information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AcquireGPUCommandBuffer
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
 * \sa SDL_AcquireGPUSwapchainTexture
 * \sa SDL_SubmitGPUCommandBuffer
 * \sa SDL_ReleaseGPUFence
  }
function SDL_SubmitGPUCommandBufferAndAcquireFence(command_buffer: PSDL_GPUCommandBuffer): PSDL_GPUFence; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SubmitGPUCommandBufferAndAcquireFence' {$ENDIF} {$ENDIF};

{*
 * Cancels a command buffer.
 *
 * None of the enqueued commands are executed.
 *
 * It is an error to call this function after a swapchain texture has been
 * acquired.
 *
 * This must be called from the thread the command buffer was acquired on.
 *
 * You must not reference the command buffer after calling this function.
 *
 * \param command_buffer a command buffer.
 * \returns true on success, false on error; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_WaitAndAcquireGPUSwapchainTexture
 * \sa SDL_AcquireGPUCommandBuffer
 * \sa SDL_AcquireGPUSwapchainTexture
  }
function SDL_CancelGPUCommandBuffer(command_buffer: PSDL_GPUCommandBuffer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CancelGPUCommandBuffer' {$ENDIF} {$ENDIF};

{*
 * Blocks the thread until the GPU is completely idle.
 *
 * \param device a GPU context.
 * \returns true on success, false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_WaitForGPUFences
  }
function SDL_WaitForGPUIdle(device: PSDL_GPUDevice): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitForGPUIdle' {$ENDIF} {$ENDIF};

{*
 * Blocks the thread until the given fences are signaled.
 *
 * \param device a GPU context.
 * \param wait_all if 0, wait for any fence to be signaled, if 1, wait for all
 *                 fences to be signaled.
 * \param fences an array of fences to wait on.
 * \param num_fences the number of fences in the fences array.
 * \returns true on success, false on failure; call SDL_GetError() for more
 *          information.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
 * \sa SDL_WaitForGPUIdle
  }
function SDL_WaitForGPUFences(device: PSDL_GPUDevice; wait_all: Boolean; fences: PPSDL_GPUFence; num_fences: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitForGPUFences' {$ENDIF} {$ENDIF};

{*
 * Checks the status of a fence.
 *
 * \param device a GPU context.
 * \param fence a fence.
 * \returns true if the fence is signaled, false if it is not.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
  }
function SDL_QueryGPUFence(device: PSDL_GPUDevice; fence: PSDL_GPUFence): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_QueryGPUFence' {$ENDIF} {$ENDIF};

{*
 * Releases a fence obtained from SDL_SubmitGPUCommandBufferAndAcquireFence.
 *
 * You must not reference the fence after calling this function.
 *
 * \param device a GPU context.
 * \param fence a fence.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SubmitGPUCommandBufferAndAcquireFence
  }
procedure SDL_ReleaseGPUFence(device: PSDL_GPUDevice; fence: PSDL_GPUFence); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReleaseGPUFence' {$ENDIF} {$ENDIF};

{ Format Info  }

{*
 * Obtains the texel block size for a texture format.
 *
 * \param format the texture format you want to know the texel size of.
 * \returns the texel block size of the texture format.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UploadToGPUTexture
  }
function SDL_GPUTextureFormatTexelBlockSize(format: TSDL_GPUTextureFormat): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GPUTextureFormatTexelBlockSize' {$ENDIF} {$ENDIF};

{*
 * Determines whether a texture format is supported for a given type and
 * usage.
 *
 * \param device a GPU context.
 * \param format the texture format to check.
 * \param type the type of texture (2D, 3D, Cube).
 * \param usage a bitmask of all usage scenarios to check.
 * \returns whether the texture format is supported for this type and usage.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GPUTextureSupportsFormat(device: PSDL_GPUDevice; format: TSDL_GPUTextureFormat; type_: TSDL_GPUTextureType; usage: TSDL_GPUTextureUsageFlags): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GPUTextureSupportsFormat' {$ENDIF} {$ENDIF};

{*
 * Determines if a sample count for a texture format is supported.
 *
 * \param device a GPU context.
 * \param format the texture format to check.
 * \param sample_count the sample count to check.
 * \returns whether the sample count is supported for this texture format.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GPUTextureSupportsSampleCount(device: PSDL_GPUDevice; format: TSDL_GPUTextureFormat; sample_count: TSDL_GPUSampleCount): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GPUTextureSupportsSampleCount' {$ENDIF} {$ENDIF};

{*
 * Calculate the size in bytes of a texture format with dimensions.
 *
 * \param format a texture format.
 * \param width width in pixels.
 * \param height height in pixels.
 * \param depth_or_layer_count depth for 3D textures or layer count otherwise.
 * \returns the size of a texture with this format and dimensions.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_CalculateGPUTextureFormatSize(format: TSDL_GPUTextureFormat; width: cuint32; height: cuint32; depth_or_layer_count: cuint32): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CalculateGPUTextureFormatSize' {$ENDIF} {$ENDIF};

{*
 * Get the SDL pixel format corresponding to a GPU texture format.
 *
 * \param format a texture format.
 * \returns the corresponding pixel format, or SDL_PIXELFORMAT_UNKNOWN if
 *          there is no corresponding pixel format.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetPixelFormatFromGPUTextureFormat(format: TSDL_GPUTextureFormat): TSDL_PixelFormat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetPixelFormatFromGPUTextureFormat' {$ENDIF} {$ENDIF};

{*
 * Get the GPU texture format corresponding to an SDL pixel format.
 *
 * \param format a pixel format.
 * \returns the corresponding GPU texture format, or
 *          SDL_GPU_TEXTUREFORMAT_INVALID if there is no corresponding GPU
 *          texture format.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetGPUTextureFormatFromPixelFormat(format: TSDL_PixelFormat): TSDL_GPUTextureFormat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGPUTextureFormatFromPixelFormat' {$ENDIF} {$ENDIF};

{*
 * Call this to suspend GPU operation on Xbox when you receive the
 * SDL_EVENT_DID_ENTER_BACKGROUND event.
 *
 * Do NOT call any SDL_GPU functions after calling this function! This must
 * also be called before calling SDL_GDKSuspendComplete.
 *
 * \param device a GPU context.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddEventWatch
  }
procedure SDL_GDKSuspendGPU(device: PSDL_GPUDevice); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GDKSuspendGPU' {$ENDIF} {$ENDIF};

{*
 * Call this to resume GPU operation on Xbox when you receive the
 * SDL_EVENT_WILL_ENTER_FOREGROUND event.
 *
 * When resuming, this function MUST be called before calling any other
 * SDL_GPU functions.
 *
 * \param device a GPU context.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddEventWatch
  }
procedure SDL_GDKResumeGPU(device: PSDL_GPUDevice); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GDKResumeGPU' {$ENDIF} {$ENDIF};

