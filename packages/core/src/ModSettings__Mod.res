type t = {
  enabled: bool,
  modLocation: string,
  info: ModSettings__Info.t,
}

let schema = S.schema(s => {
  enabled: s.matches(S.bool),
  modLocation: s.matches(S.string),
  info: s.matches(ModSettings__Info.schema),
})

type action = Enabled | Disabled

let reducer = (state, action) => {
  switch (state, action) {
  | ({enabled: true}, Disabled) => {...state, enabled: false}
  | ({enabled: false}, Enabled) => {...state, enabled: true}
  | _ => state
  }
}

let make = (~enabled, ~modLocation, ~info) => {
  {enabled, modLocation, info}
}

if Vitest.inSource {
  open Vitest

  test("enabled", _ => {
    let state = {
      enabled: false,
      modLocation: "",
      info: ModSettings__Info.make(~folder="", ~md5="", ~name="", ~uuid="", ~version=None),
    }
    let result = reducer(state, Enabled)

    expect(result)->Expect.not->Expect.toBe(state)
    expect(result.enabled)->Expect.toBe(true)
  })

  test("disabled", _ => {
    let state = {
      enabled: true,
      modLocation: "",
      info: ModSettings__Info.make(~folder="", ~md5="", ~name="", ~uuid="", ~version=None),
    }
    let result = reducer(state, Disabled)

    expect(result)->Expect.not->Expect.toBe(state)
    expect(result.enabled)->Expect.toBe(false)
  })
}
