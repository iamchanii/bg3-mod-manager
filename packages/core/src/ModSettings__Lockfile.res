type t = {mods: array<ModSettings__Mod.t>}

let schema = S.schema(s => {
  mods: s.matches(S.array(ModSettings__Mod.schema)),
})

type action = Append(ModSettings__Mod.t) | Remove(string) | Update(ModSettings__Mod.t)

let reducer = (state, action) => {
  switch (state, action) {
  | ({mods}, Append(mod)) => {mods: Array.concat(mods, [mod])}
  | ({mods}, Remove(uuid)) => {mods: mods->Array.filter(mod => mod.info.uuid !== uuid)}
  | ({mods}, Update(mod)) => {
      mods: mods->Array.map(m => m.info.uuid === mod.info.uuid ? mod : m),
    }
  }
}

let parse = S.parseWith(_, schema)

if Vitest.inSource {
  open Vitest

  test("append", _ => {
    let state = {mods: []}
    let mod = ModSettings__Mod.make(
      ~enabled=true,
      ~modLocation="",
      ~info=ModSettings__Info.make(
        ~folder="folder",
        ~md5="md5",
        ~name="mod name",
        ~uuid="my-uuid",
        ~version=None,
      ),
    )
    let action = Append(mod)
    let result = reducer(state, action)

    expect(result)->Expect.toEqual({mods: [mod]})
  })

  test("remove", _ => {
    let state = {
      mods: [
        ModSettings__Mod.make(
          ~enabled=true,
          ~modLocation="",
          ~info=ModSettings__Info.make(
            ~folder="folder",
            ~md5="md5",
            ~name="mod name",
            ~uuid="my-uuid",
            ~version=None,
          ),
        ),
        ModSettings__Mod.make(
          ~enabled=true,
          ~modLocation="",
          ~info=ModSettings__Info.make(
            ~folder="folder",
            ~md5="md5",
            ~name="mod name",
            ~uuid="my-uuid-2",
            ~version=None,
          ),
        ),
      ],
    }
    let action = Remove("my-uuid")
    let result = reducer(state, action)

    expect(result)->Expect.toEqual({
      mods: [
        ModSettings__Mod.make(
          ~enabled=true,
          ~modLocation="",
          ~info=ModSettings__Info.make(
            ~folder="folder",
            ~md5="md5",
            ~name="mod name",
            ~uuid="my-uuid-2",
            ~version=None,
          ),
        ),
      ],
    })
  })

  test("update", _ => {
    let state = {
      mods: [
        ModSettings__Mod.make(
          ~enabled=true,
          ~modLocation="",
          ~info=ModSettings__Info.make(
            ~folder="folder",
            ~md5="md5",
            ~name="mod name",
            ~uuid="my-uuid",
            ~version=None,
          ),
        ),
        ModSettings__Mod.make(
          ~enabled=true,
          ~modLocation="",
          ~info=ModSettings__Info.make(
            ~folder="folder",
            ~md5="md5",
            ~name="mod name",
            ~uuid="my-uuid-2",
            ~version=None,
          ),
        ),
      ],
    }
    let action = Update(
      ModSettings__Mod.make(
        ~enabled=false,
        ~modLocation="",
        ~info=ModSettings__Info.make(
          ~folder="folder",
          ~md5="md5",
          ~name="mod name - 2",
          ~uuid="my-uuid",
          ~version=Some("1234"),
        ),
      ),
    )
    let result = reducer(state, action)

    expect(result)->Expect.toEqual({
      mods: [
        ModSettings__Mod.make(
          ~enabled=false,
          ~modLocation="",
          ~info=ModSettings__Info.make(
            ~folder="folder",
            ~md5="md5",
            ~name="mod name - 2",
            ~uuid="my-uuid",
            ~version=Some("1234"),
          ),
        ),
        ModSettings__Mod.make(
          ~enabled=true,
          ~modLocation="",
          ~info=ModSettings__Info.make(
            ~folder="folder",
            ~md5="md5",
            ~name="mod name",
            ~uuid="my-uuid-2",
            ~version=None,
          ),
        ),
      ],
    })
  })
}
