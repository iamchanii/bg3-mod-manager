import { Context, Effect, Layer } from 'effect';
import { homedir, platform } from 'node:os';
import { join } from 'node:path';
import { PathNotExistsError, UnsupportedOsError } from './Errors';
import { Fs } from './Fs';
import assert from 'node:assert';

export interface Paths {
  getBg3Path(): Effect.Effect<
    never,
    UnsupportedOsError | PathNotExistsError,
    string
  >;
  getModsPath(): Effect.Effect<
    never,
    UnsupportedOsError | PathNotExistsError,
    string
  >;
}

export const Paths = Context.Tag<Paths>();

export const PathsLive = Layer.effect(
  Paths,
  Effect.map(Fs, (fs) => {
    function ensureDirectoryExists(path: string) {
      return Effect.gen(function* (_) {
        try {
          assert(fs.statSync(path).isDirectory());
          return path;
        } catch (e) {
          console.log(e);
          return yield* _(Effect.fail(new PathNotExistsError({ path })));
        }
      });
    }

    return Paths.of({
      getBg3Path() {
        return Effect.gen(function* (_) {
          if (platform() !== 'darwin') {
            return yield* _(
              Effect.fail(new UnsupportedOsError({ currentOs: platform() }))
            );
          }

          const bg3Path = join(
            homedir(),
            `/Documents/Larian Studios/Baldur's Gate 3`
          );

          return yield* _(bg3Path, ensureDirectoryExists);
        });
      },

      getModsPath() {
        const that = this;

        return Effect.gen(function* (_) {
          const bg3Path = yield* _(that.getBg3Path());
          const modsPath = join(bg3Path, 'Mods');

          return yield* _(modsPath, ensureDirectoryExists);
        });
      },
    });
  })
);
