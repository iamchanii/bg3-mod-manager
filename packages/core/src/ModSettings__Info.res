type t = {
  folder: string,
  md5: string,
  name: string,
  uuid: string,
  version: option<string>,
}

let schema = S.schema(s => {
  folder: s.matches(S.string),
  md5: s.matches(S.string),
  name: s.matches(S.string),
  uuid: s.matches(S.string),
  version: s.matches(S.option(S.string)),
})

let parse = S.parseWith(_, schema)

let make = (~folder, ~md5, ~name, ~uuid, ~version) => {
  {folder, md5, name, uuid, version}
}

let fromInfoFile = infoFile => {
  switch infoFile.ModSettings__InfoFile.mods {
  | [mod] =>
    Ok(
      make(
        ~folder=mod.folder,
        ~md5=infoFile.md5,
        ~name=mod.name,
        ~uuid=mod.uuid,
        ~version=mod.version,
      ),
    )
  | [] => Error("Invalid mod info. Expected at least one mod.")
  | _ => Error("Invalid mod info. Currently only supports single mod.")
  }
}

if Vitest.inSource {
  open Vitest

  test("make", _ => {
    let info = make(~folder="folder", ~md5="md5", ~name="name", ~uuid="uuid", ~version=None)

    expect(info.folder)->Expect.toEqual("folder")
    expect(info.md5)->Expect.toEqual("md5")
    expect(info.name)->Expect.toEqual("name")
    expect(info.uuid)->Expect.toEqual("uuid")
    expect(info.version)->Expect.toEqual(None)
  })

  describe("fromInfoFile", _ => {
    it("should return error if mods is empty", _ => {
      let result = ModSettings__InfoFile.makeWithMods(~mods=[], ~md5="md5")->fromInfoFile

      expect(result)->Expect.toEqual(Error("Invalid mod info. Expected at least one mod."))
    })

    it("should return error if mods has more than one mod", _ => {
      let result = ModSettings__InfoFile.makeWithMods(
        ~mods=[
          {
            author: "",
            name: "",
            folder: "",
            version: None,
            description: "",
            uuid: "",
            created: "",
            dependencies: [],
            group: "",
          },
          {
            author: "",
            name: "",
            folder: "",
            version: None,
            description: "",
            uuid: "",
            created: "",
            dependencies: [],
            group: "",
          },
        ],
        ~md5="md5",
      )->fromInfoFile

      expect(result)->Expect.toEqual(Error("Invalid mod info. Currently only supports single mod."))
    })

    it("should return ok with parsed info", _ => {
      let result =
        ModSettings__InfoFile.make(
          ~author="",
          ~name="AwesomeHair",
          ~folder="AwesomeHair",
          ~version=None,
          ~description="",
          ~uuid="looks-good-uuid-right",
          ~created="",
          ~dependencies=[],
          ~group="",
          ~md5="md5-hash-right-here",
        )->fromInfoFile

      expect(result)->Expect.toEqual(
        Ok(
          make(
            ~folder="AwesomeHair",
            ~md5="md5-hash-right-here",
            ~name="AwesomeHair",
            ~uuid="looks-good-uuid-right",
            ~version=None,
          ),
        ),
      )
    })
  })
}
