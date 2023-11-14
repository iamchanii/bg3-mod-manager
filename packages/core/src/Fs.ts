import { Context, Layer } from 'effect';
import * as fs from 'node:fs';

export interface Fs {
  statSync(path: string): fs.Stats;
}

export const Fs = Context.Tag<Fs>('Fs');

export const FsLive = Layer.succeed(Fs, Fs.of({ statSync: fs.statSync }));
