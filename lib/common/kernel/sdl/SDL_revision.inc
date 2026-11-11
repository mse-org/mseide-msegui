{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{
 * SDL_revision.h contains the SDL revision, which might be defined on the
 * compiler command line, or generated right into the header itself by the
 * build system.
  }

{*
 * This macro is a string describing the source at a particular point in
 * development.
 *
 * This string is often generated from revision control's state at build time.
 *
 * This string can be quite complex and does not follow any standard. For
 * example, it might be something like "SDL-prerelease-3.1.1-47-gf687e0732".
 * It might also be user-defined at build time, so it's best to treat it as a
 * clue in debugging forensics and not something the app will parse in any
 * way.
 *
 * SDL_revision.h must be included in your program explicitly if you want
 * access to the SDL_REVISION constant.
 *
 * \since This macro is available since SDL 3.2.0.
  }
const
  SDL_REVISION = 'Some arbitrary string decided at SDL build time';

