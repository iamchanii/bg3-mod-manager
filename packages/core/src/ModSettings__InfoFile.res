type mod = {
  @as("Author") author: string,
  @as("Name") name: string,
  @as("Folder") folder: string,
  @as("Version") version: option<string>,
  @as("Description") description: string,
  @as("UUID") uuid: string,
  @as("Created") created: string,
  @as("Dependencies") dependencies: array<string>,
  @as("Group") group: string,
}

type t = {@as("Mods") mods: array<mod>, @as("MD5") md5: string}

let schema = {
  let modSchema = S.schema(s => {
    author: s.matches(S.string),
    name: s.matches(S.string),
    folder: s.matches(S.string),
    version: s.matches(S.null(S.string)),
    description: s.matches(S.string),
    uuid: s.matches(S.string),
    created: s.matches(S.string),
    dependencies: s.matches(S.array(S.string)),
    group: s.matches(S.string),
  })

  S.schema(s => {
    mods: s.matches(S.array(modSchema)),
    md5: s.matches(S.string),
  })
}

let parse = S.parseWith(_, schema)

let make = (
  ~author,
  ~name,
  ~folder,
  ~version,
  ~description,
  ~uuid,
  ~created,
  ~dependencies,
  ~group,
  ~md5,
) => {
  let mod = {
    author,
    name,
    folder,
    version,
    description,
    uuid,
    created,
    dependencies,
    group,
  }

  let mods = [mod]

  {mods, md5}
}

let makeWithMods = (~mods, ~md5) => {mods, md5}
