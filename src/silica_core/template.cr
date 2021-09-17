require "ecr"

module SilicaCore
    abstract class Template
        abstract def to_s(io : IO, &)
        
        def to_s(&block) : String
            String.build do |f|
                to_s f, &block
            end
        end
    end

    macro ecr_template(name, file, &)
        class {{name.id}} < ::SilicaCore::Template
            {{yield}}
        
            def to_s(io : IO, &)
                ECR.embed {{file}}
            end
        end
    end
end