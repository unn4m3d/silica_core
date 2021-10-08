module SilicaCore
  class DoxygenGenerator < DocGenerator
    def initialize(@gen : Generator)
    end

    private def emit_line(str)
      @gen.emit str, no_sep: true
      self
    end

    def doc_comment(&) : self
      emit_line "/**"
      begin
        with self yield
      ensure
        emit_line " */"
      end
      self
    end

    def separator : self
      emit_line " *"
    end

    def directive(name, value : String) : self
      emit_line " * @#{name} #{value}"
    end

    def directive(name, values : Array(String)) : self
      emit_line " * @#{name} #{values.join(' ')}"
    end

    def summary(text) : self
      text.split(/\r?\n\s*/).each do |line|
        emit_line " * #{line}"
      end
      self
    end
  end
end
