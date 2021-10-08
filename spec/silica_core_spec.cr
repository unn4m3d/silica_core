require "./spec_helper"

describe SilicaCore do
  # TODO: Write tests

  it "works" do
    io = IO::Memory.new

    gen = SilicaCore::CppGenerator.new io

    gen.include_guard
    gen.require_support
    gen.separator

    gen.doc do |d|
      d.summary "Example namespace"
      d.separator
      d.summary "Generated with SilicaCore"
    end

    gen.namespace "foo" do
      constant "int", "bar", "0"
    end

    io.rewind
    io.gets_to_end.should eq("#pragma once\n#include <silica.hpp>\n\n/**\n * Example namespace\n *\n * Generated with SilicaCore\n */\nnamespace foo\n{\n  constexpr static int bar = 0;\n}\n")
  end

  it "escapes strings" do
    io = IO::Memory.new
    g = SilicaCore::CppGenerator.new io
    g.escape("foo\t\\bar\n\\baz").should eq %("foo\\t\\\\bar\\n\\\\baz")
  end
end

describe SilicaCore::DoxygenGenerator do
  it "works" do
    io = IO::Memory.new
    gen = SilicaCore::CppGenerator.new io

    doxygen = SilicaCore::DoxygenGenerator.new gen

    doxygen.doc_comment do
      brief "Example"
      separator
      summary "Example method"
      separator
      param ["foo", "Foo"]
      param ["bar", "Bar object"]
      returns "Baz"
    end

    io.rewind
    io.gets_to_end.should eq("/**\n * @brief Example\n *\n * Example method\n *\n * @param foo Foo\n * @param bar Bar object\n * @returns Baz\n */\n")
  end
end
