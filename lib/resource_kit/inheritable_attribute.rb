module ResourceKit
  module InheritableAttribute
    def inheritable_attr(name)
      instance_eval <<-RUBY
        def #{name}=(v)
          @#{name} = v
        end

        def #{name}
          @#{name} ||= InheritableAttribute.inherit(self, :#{name})
        end
      RUBY
    end

    def self.inherit(klass, name)
      return unless klass.superclass.respond_to?(name) and value = klass.superclass.send(name)
      value.clone
    end
  end
end
