require "./generator"

module SilicaCore
  class CppGenerator < Generator
    LINE_SEPARATOR = ';'

    def initialize(@io : IO, @tab : String = "  ", @newline : String = "\n")
      @depth = 0u64
    end

    getter io

    def emit(line, no_sep = false, no_newline = false, no_indent = false) : Generator
      if !no_sep && !(line =~ /#{LINE_SEPARATOR}\n?$/)
        line += LINE_SEPARATOR
      end

      @io << @tab * @depth unless no_indent
      @io << line << ((line.ends_with?(@newline) || no_newline) ? "" : @newline)
      self
    end

    def comment(line) : Generator
      if line =~ /\n/
        emit "/*", true
        begin
          line.split(/\r?\n/).each do |l|
            emit "* #{l}", true
          end
        ensure
          emit "*/", true
        end
      else
        emit "// #{line}", true
      end
      self
    end

    def block(header : String, separator : Bool = false, &) : Generator
      emit header, true
      emit "{", true
      old_depth = @depth
      @depth += 1
      begin
        with self yield
      ensure
        @depth = old_depth
        emit "}", !separator
      end
      self
    end

    def separator : Generator
      emit "", no_sep: true
      self
    end

    def doc(& : DocGenerator ->) : Generator
      doxygen = DoxygenGenerator.new self
      doxygen.doc_comment do
        with self yield doxygen
      end
      self
    end

    def constant(type : String, name : String, value : String) : Generator
      emit "constexpr static #{type} #{name} = #{value}"
    end

    def namespace(name : String, &) : Generator
      block "namespace #{name}" do
        with self yield
      end
    end

    def include_guard : Generator
      emit "#pragma once", true
    end

    def require_file(name, local = false) : Generator
      opening = local ? '"' : '<'
      ending = local ? '"' : '>'

      emit "#include #{opening}#{name}#{ending}", true
    end

    def require_support : Generator
      require_file "silica.hpp"
    end

    def escape(str : String) : String
      String.build str.size do |s|
        s << %(")
        str.each_char do |char|
          case char
          when '\t'
            s << "\\t"
          when '\r'
            s << "\\r"
          when '\n'
            s << "\\n"
          when '\e'
            s << "\\e"
          when '\\'
            s << "\\\\"
          when '"'
            s << "\\\""
          else
            s << char
          end
        end
        s << %(")
      end
    end

    KEYWORDS = %w(
      alignas alignof and and_eq asm atomic_cancel atomic_commit atomic_noexcept
      auto bitand bitor bool break case catch char char8_t char16_t char32_t
      class compl concept const consteval constexpr constinit const_cast
      continue co_await co_return co_yield decltype default delete do double
      dynamic_cast else enum explicit export extern false float for friend goto
      if inline int long mutable namespace new noexcept not not_eq nullptr
      operator or or_eq private protected public reflexpr register
      reinterpret_cast requires return short signed sizeof static static_assert
      static_cast struct switch synchronized template this thread_local throw
      true try typedef typeid typename union unsigned using virtual void volatile
      wchar_t while xor xor_eq
    )

    def escape_keywords(str : String) : String
      if KEYWORDS.includes? str
        "_#{str}"
      else
        str
      end
    end

    def instance(type : String, name : String, args : Array(String) = [] of String) : Generator
      name = escape_keywords name
      if args.empty?
        emit "#{type} #{name}"
      else
        emit "#{type} #{name}(#{args.join(", ")})"
      end
    end

    def close
      @io.close
    end

    def g_module(name : String, includes : Array(String) = [] of String, &) : self
      header = if includes.size == 0
                 "struct #{name}"
               elsif includes.size == 1
                 "struct #{name} : #{includes.first}"
               else
                 "struct #{name} : virtual #{includes.join(", ")}"
               end

      block header, separator: true do
        with self yield
      end
    end

    def g_struct(name : String, ancestors : Array(String) = [] of String, &) : self
      g_module name, ancestors do
        with self yield
      end
    end

    @enum_member_first = true

    def g_enum(name : String, type : String, &) : self
      block "enum class #{name} : #{type}", separator: true do
        begin
          @enum_member_first = true
          with self yield
        ensure
          emit "", no_sep: true
        end
      end
    end

    def g_enum(name : String, &) : self
      block "enum class #{name}", separator: true do
        begin
          @enum_member_first = true
          with self yield
        ensure
          emit "", no_sep: true
        end
      end
    end

    def g_enum_member(name : String, value : String, &) : self
      unless @enum_member_first
        emit ",", no_sep: true, no_indent: true
      end

      with self yield

      @enum_member_first = false
      emit "#{name} = #{value}", no_sep: true, no_newline: true
    end

    def g_enum_member(name : String, &) : self
      unless @enum_member_first
        emit ",", no_sep: true, no_indent: true
      end

      with self yield

      @enum_member_first = false
      emit name, no_sep: true, no_newline: true
    end

    def g_enum_member(name : String, value : String) : self
      g_enum_member(name, value) { }
    end

    def g_enum_member(name : String) : self
      g_enum_member(name) { }
    end

    def g_constant(type : String, name : String, value : String) : self
      emit "constexpr const static #{type} #{name} = #{value}"
    end

    def g_alias(name : String, tgt : String) : self
      emit "using #{name} = #{tgt}"
    end

    def generic(type : String, args : Array(String)) : String
      "#{type}<#{args.join(", ")} >"
    end

    def generic(type : String, *args : String) : String
      generic type, args.to_a
    end

    def path(parts : Array(String)) : String
      parts.join("::")
    end

    def path(*parts : String) : String
      path parts.to_a
    end
  end
end
