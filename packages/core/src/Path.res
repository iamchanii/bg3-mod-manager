let getBg3Path = async (~platform, ~homedir) => {
  switch platform() {
  | "darwin" => Ok(NodeJs.Path.join([homedir(), `/Documents/Larian Studios/Baldur's Gate 3`]))
  | platform => Error(`${platform} is not supported`)
  }
}

let getModsPath = async (~platform, ~homedir) => {
  switch await getBg3Path(~platform, ~homedir) {
  | Ok(bg3Path) => Ok(NodeJs.Path.join([bg3Path, "Mods"]))
  | error => error
  }
}

let getTempPath = async (~mkdtemp) => {
  switch await mkdtemp("bg3-mod-manager-") {
  | tempPath => Ok(tempPath)
  | exception _ => Error("Failed to create temp directory")
  }
}

let getModSettingsPath = async (~platform, ~homedir) => {
  switch await getBg3Path(~platform, ~homedir) {
  | Ok(bg3Path) => Ok(NodeJs.Path.join([bg3Path, "PlayerProfiles", "Public", "modsettings.lsx"]))
  | error => error
  }
}

let getConfigPath = async (~platform, ~homedir) => {
  switch platform() {
  | "darwin" => Ok(NodeJs.Path.join([homedir(), "Library", "Preferences", "BG3ModManager"]))
  | platform => Error(`${platform} is not supported`)
  }
}

let makeConfigPath = async (~platform, ~homedir, ~mkdirRecursively) => {
  switch await getConfigPath(~platform, ~homedir) {
  | Ok(configPath) =>
    switch await mkdirRecursively(configPath) {
    | _ => Ok()
    | exception _ => Error("Failed to create config directory")
    }
  | Error(error) => Error(error)
  }
}

if Vitest.inSource {
  open Vitest

  describe("getBg3Path", _ => {
    testAsync("should return error if not unsupported platform", async _ => {
      let result = await getBg3Path(~platform=() => "linux", ~homedir=() => "/Users/Player")
      expect(result)->Expect.toEqual(Error("linux is not supported"))
    })

    testAsync("should return bg3 directory", async _ => {
      let result = await getBg3Path(~platform=() => "darwin", ~homedir=() => "/Users/Player")
      expect(result)->Expect.toEqual(Ok(`/Users/Player/Documents/Larian Studios/Baldur's Gate 3`))
    })
  })

  describe("getModsPath", _ => {
    testAsync("should return error if not unsupported platform", async _ => {
      let result = await getModsPath(~platform=() => "linux", ~homedir=() => "/Users/Player")
      expect(result)->Expect.toEqual(Error("linux is not supported"))
    })

    testAsync("should return bg3 mod directory", async _ => {
      let result = await getModsPath(~platform=() => "darwin", ~homedir=() => "/Users/Player")
      expect(result)->Expect.toEqual(
        Ok(`/Users/Player/Documents/Larian Studios/Baldur's Gate 3/Mods`),
      )
    })
  })

  describe("getTempPath", _ => {
    testAsync("should return created temp directory path", async _ => {
      let result = await getTempPath(~mkdtemp=async _ => "/tmp/bg3-mod-manager-1234")
      expect(result)->Expect.toEqual(Ok("/tmp/bg3-mod-manager-1234"))
    })

    testAsync("should return error if failed to create temp directory", async _ => {
      let result = await getTempPath(~mkdtemp=async _ => Exn.raiseError("Error"))
      expect(result)->Expect.toEqual(Error("Failed to create temp directory"))
    })
  })

  describe("getModSettingsPath", _ => {
    testAsync("should return error if not unsupported platform", async _ => {
      let result = await getModsPath(~platform=() => "linux", ~homedir=() => "/Users/Player")
      expect(result)->Expect.toEqual(Error("linux is not supported"))
    })

    testAsync("should return modsettings.lsx file path", async _ => {
      let result = await getModSettingsPath(
        ~platform=() => "darwin",
        ~homedir=() => "/Users/Player",
      )
      expect(result)->Expect.toEqual(
        Ok(`/Users/Player/Documents/Larian Studios/Baldur's Gate 3/PlayerProfiles/Public/modsettings.lsx`),
      )
    })
  })

  describe("getConfigPath", _ => {
    testAsync("should return error if not unsupported platform", async _ => {
      let result = await getConfigPath(~platform=() => "linux", ~homedir=() => "/Users/Player")
      expect(result)->Expect.toEqual(Error("linux is not supported"))
    })

    testAsync("should return config directory path", async _ => {
      let result = await getConfigPath(~platform=() => "darwin", ~homedir=() => "/Users/Player")
      expect(result)->Expect.toEqual(Ok(`/Users/Player/Library/Preferences/BG3ModManager`))
    })
  })

  describe("makeConfigPath", _ => {
    testAsync("should return error if not unsupported platform", async _ => {
      let result = await makeConfigPath(
        ~platform=() => "linux",
        ~homedir=() => "/Users/Player",
        ~mkdirRecursively=async _ => (),
      )
      expect(result)->Expect.toEqual(Error("linux is not supported"))
    })

    testAsync("should return error if failed to create config directory", async _ => {
      let result = await makeConfigPath(
        ~platform=() => "darwin",
        ~homedir=() => "/Users/Player",
        ~mkdirRecursively=async _ => Exn.raiseError("Error"),
      )
      expect(result)->Expect.toEqual(Error("Failed to create config directory"))
    })

    testAsync("should return unit if config directory already exists", async _ => {
      let result = await makeConfigPath(
        ~platform=() => "darwin",
        ~homedir=() => "/Users/Player",
        ~mkdirRecursively=async _ => (),
      )
      expect(result)->Expect.toEqual(Ok())
    })
  })
}
