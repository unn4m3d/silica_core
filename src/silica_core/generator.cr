module SilicaCore
    abstract class Generator
        abstract def emit(line : String, no_sep = false, no_newline = false) : self
        abstract def block(header : String, separator : Bool = false, &) : self
        abstract def comment(line : String) : self
        abstract def separator : self

        abstract def doc(&) : self
        abstract def namespace(name : String, &) : self
        abstract def constant(type : String, name : String, value : String) : self

        def include_guard
            #do nothing by default

            self
        end

        abstract def require_file(name : String, local = false) : self
        abstract def require_support : self

        def generate(&)
            with self yield
        end

        abstract def escape(str : String) : String
        abstract def instance(type : String, name : String, args : Array(String)) : self
    end
end