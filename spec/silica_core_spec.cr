require "./spec_helper"

describe SilicaCore do
  # TODO: Write tests

  it "works" do
    io = IO::Memory.new

    gen = SilicaCore::CppGenerator.new io

    gen.doc do 
      emit "Example namespace"
      separator
      emit "Generated with SilicaCore"
    end

    gen.namespace "foo" do
      constant "int", "bar", "0"
    end

    io.rewind
    io.gets_to_end.should eq("/**\nExample namespace\n\nGenerated with SilicaCore\n*/\nnamespace foo\n{\n  constexpr static int bar = 0;\n}\n")
  end
end
