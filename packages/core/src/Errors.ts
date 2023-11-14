import { Data } from 'effect';

export class UnsupportedOsError extends Data.TaggedError('UnsupportedOsError')<{
  currentOs: string;
}> {}

export class PathNotExistsError extends Data.TaggedError('PathNotExistsError')<{
  path: string;
}> {}
