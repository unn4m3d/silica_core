module SilicaCore
    abstract class Generator
        abstract def emit(line : String, no_sep = false, no_newline = false) : self
        abstract def block(header : String, separator : Bool = false, &) : self
        abstract def comment(line : String) : self
        abstract def separator : self

        abstract def doc(& : DocGenerator->) : self
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
        abstract def instance(type : String, name : String, args : Array(String) = [] of String) : self

        abstract def close

        abstract def escape_keywords(s : String) : String

        abstract def g_module(name : String, includes : Array(String) = [] of String, &) : self
        abstract def g_struct(name : String, ancestors : Array(String) = [] of String, &) : self
        abstract def g_enum(name : String, type : String, &) : self
        abstract def g_enum_member(name : String, value : String) : self
        abstract def g_enum_member(name : String) : self
        abstract def g_constant(type : String, name : String, value : String) : self
        abstract def g_alias(name : String, tgt : String) : self

        abstract def generic(type : String, args : Array(String)) : String
        abstract def generic(type : String, *args : String) : String
        abstract def path(parts : Array(String)) : String
        abstract def path(*parts : String) : String

    end
end