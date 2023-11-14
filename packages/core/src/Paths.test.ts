import { Effect, Layer, pipe } from 'effect';
import * as memfs from 'memfs';
import { homedir, platform } from 'node:os';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { PathNotExistsError, UnsupportedOsError } from './Errors';
import { Fs } from './Fs';
import { Paths, PathsLive } from './Paths';

vi.mock('node:os');

let fakeVol: InstanceType<typeof memfs.Volume>;
let fakeFs: memfs.IFs;
let layer: Layer.Layer<never, never, Paths>;

const HOMEDIR = '/Users/Darwin';
const BG3_PATH = `${HOMEDIR}/Documents/Larian Studios/Baldur's Gate 3`;
const MODS_PATH = `${BG3_PATH}/Mods`;

beforeEach(() => {
  fakeVol = new memfs.Volume();
  fakeFs = memfs.createFsFromVolume(fakeVol);

  layer = pipe(Layer.succeed(Fs, fakeFs), Layer.provide(PathsLive));
});

describe('getBg3Path', () => {
  const program = Effect.gen(function* (_) {
    const paths = yield* _(Paths);
    return yield* _(paths.getBg3Path());
  });

  beforeEach(() => {
    vi.mocked(platform).mockReturnValue('darwin' as never);
    vi.mocked(homedir).mockReturnValue(HOMEDIR);
  });

  it('should return UnsupportedOsError when os is not supported', async () => {
    vi.mocked(platform).mockReturnValue('linux');

    const result = pipe(
      program,
      Effect.catchAll(Effect.succeed),
      Effect.provide(layer),
      Effect.runSync
    );

    expect(result).toBeInstanceOf(UnsupportedOsError);
    expect((result as UnsupportedOsError).currentOs).toEqual('linux');
  });

  it('should return PathNotExistsError when path does not exist', () => {
    const result = pipe(
      program,
      Effect.catchAll(Effect.succeed),
      Effect.provide(layer),
      Effect.runSync
    );

    expect(result).toBeInstanceOf(PathNotExistsError);
  });

  it('should return path when path exists', () => {
    vi.mocked(platform).mockReturnValue('darwin' as never);
    fakeFs.mkdirSync(BG3_PATH, { recursive: true });

    const layer = pipe(
      Layer.succeed(Fs, Fs.of(fakeFs)),
      Layer.provide(PathsLive)
    );

    const result = pipe(program, Effect.provide(layer), Effect.runSync);

    expect(result).toEqual(
      `/Users/Darwin/Documents/Larian Studios/Baldur's Gate 3`
    );
  });
});

describe('getModsPath', () => {
  const program = Effect.gen(function* (_) {
    const paths = yield* _(Paths);
    return yield* _(paths.getModsPath());
  });

  beforeEach(() => {
    vi.mocked(platform).mockReturnValue('darwin' as never);
    vi.mocked(homedir).mockReturnValue(HOMEDIR);
  });

  it('should return UnsupportedOsError when os is not supported', async () => {
    vi.mocked(platform).mockReturnValue('linux');

    const result = pipe(
      program,
      Effect.catchAll(Effect.succeed),
      Effect.provide(layer),
      Effect.runSync
    );

    expect(result).toBeInstanceOf(UnsupportedOsError);
  });

  it('should return PathNotExistsError when path does not exist', () => {
    const program = Effect.gen(function* (_) {
      const paths = yield* _(Paths);
      return yield* _(paths.getModsPath());
    });

    const result = pipe(
      program,
      Effect.catchAll(Effect.succeed),
      Effect.provide(layer),
      Effect.runSync
    );

    expect(result).toBeInstanceOf(PathNotExistsError);
  });

  it('should return path when path exists', () => {
    vi.mocked(platform).mockReturnValue('darwin' as never);
    fakeFs.mkdirSync(MODS_PATH, { recursive: true });

    const layer = pipe(
      Layer.succeed(Fs, Fs.of(fakeFs)),
      Layer.provide(PathsLive)
    );

    const result = pipe(program, Effect.provide(layer), Effect.runSync);

    expect(result).toEqual(
      `/Users/Darwin/Documents/Larian Studios/Baldur's Gate 3/Mods`
    );
  });
});
