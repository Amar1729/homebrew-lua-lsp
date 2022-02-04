class LuaLsp < Formula
  desc "Lua language server"
  homepage "https://github.com/Alloyed/lua-lsp"
  url "https://github.com/Alloyed/lua-lsp/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a1f34e9828e8dbfb3f4c9d80f9bc4ca3d9784e006c066c5bf629e2c67eed1429"
  license "MIT"

  depends_on "luarocks" => :build
  depends_on "lua@5.1"

  resource "dkjson" do
    url "http://dkolf.de/src/dkjson-lua.fsl/tarball/dkjson-2.5.tar.gz?uuid=release_2_5"
    sha256 "552bde07d6eb95dc32423cc4c6f6fa40699611ef6ba96ba990fcd0e055b38a93"
  end

  # lua-lsp requires ~> 3.1
  # but the tags for inspect.lua don't match up with the VERSION numbers?
  resource "inspect" do
    url "https://github.com/kikito/inspect.lua/archive/refs/tags/v3.1.2.tar.gz"
    sha256 "6b5856d04bc9ab12a5849dd529bb5f6a986a8cb7447f8824479aedbaca259622"
  end

  resource "lpeglabel" do
    url "https://github.com/sqmedeiros/lpeglabel/archive/v1.6.0-1.tar.gz"
    sha256 "9bf132b6e55ecd4c3909bb0689cbc43408f8028ccd78872a7e3e0221bba602c4"
  end

  def install
    luaversion = Formula["lua@5.1"].version.major_minor
    luapath = libexec/"vendor"
    ENV["LUA_PATH"] = "?.lua;" \
                      "#{luapath}/share/lua/#{luaversion}/?.lua;" \
                      "#{luapath}/share/lua/#{luaversion}/?/init.lua"
    ENV["LUA_CPATH"] = "#{luapath}/lib/lua/#{luaversion}/?.so"

    resources.each do |r|
      r.stage do
        system "luarocks", "--lua-dir=#{Formula["lua@5.1"].opt_prefix}", "make", "--tree=#{luapath}"
      end
    end

    system "luarocks", "--lua-dir=#{Formula["lua@5.1"].prefix}", \
      "install", "--tree=#{luapath}", "lua-lsp-scm-1.rockspec"

    cp_r "lua-lsp/", "#{luapath}/share/lua/#{luaversion}/"

    env = {
      LUA_PATH:  "#{ENV["LUA_PATH"]};;",
      LUA_CPATH: "#{ENV["LUA_CPATH"]};;",
    }

    (bin/"lua-lsp").write_env_script libexec/"vendor/bin/lua-lsp", env
  end

  test do
    true
  end
end
