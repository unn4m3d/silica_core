require "./generator"

module SilicaCore
    class CppGenerator < Generator
        LINE_SEPARATOR = ';'

        def initialize(@io : IO, @tab : String = "  ", @newline : String = "\n")
            @depth = 0u64
            @doc_mode = false
        end

        def emit(line, no_sep = false, no_newline = false) : Generator
            if !no_sep && !(line =~ /#{LINE_SEPARATOR}\n?$/) && !@doc_mode
                line += LINE_SEPARATOR
            end

            @io << @tab * @depth
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

        def block(header : String, &) : Generator
            emit header, true
            emit "{", true
            old_depth = @depth
            @depth += 1
            begin
                with self yield
            ensure
                @depth = old_depth
                emit "}", true
            end
            self
        end

        def separator : Generator
            emit "", no_sep: true
            self
        end

        def doc(&) : Generator
            old_doc_mode = @doc_mode
            @doc_mode = true
            emit "/**"
            begin
                with self yield
            ensure
                emit "*/"
                @doc_mode = old_doc_mode
            end
            self
        end

        def constant(type : String, name : String, value : String) : Generator
            emit "constexpr static #{type} #{name} = #{value}"
        end

        def namespace(name : String, & ) : Generator
            block "namespace #{name}" do
                with self yield
            end
        end

        def include_guard : Generator
            emit "#pragma once", true
        end

        def require_file(name, local = false)  : Generator
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
    end
end