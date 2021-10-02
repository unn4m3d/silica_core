module SilicaCore
    abstract class DocGenerator
        def generate(&)
            with self yield
        end

        abstract def doc_comment(&) : self
        abstract def directive(name, value : String) : self
        abstract def directive(name, value : Array(String)) : self
        abstract def separator : self
        abstract def summary(text) : self

        macro method_missing(call)
            {% if call.args.size == 1 %}
                directive {{call.name.stringify}}, {{call.args.first}}
            {% else %}
                directive {{call.name.stringify}}, {{call.args}}
            {% end %}
        end
    end
end