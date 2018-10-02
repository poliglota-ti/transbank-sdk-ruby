require 'json'

module Transbank
  module Onepay
    module Utils
      module JSONifier
        def self.included(mod)
          unless mod.respond_to? :to_h
            mod.send(:define_method, :to_h) do
              JSON.parse(self.jsonify)
            end
          end
        end

        def jsonify
          # Get all instance variables of an instance of a class,
          # then for all of these variables,
          # if the instance of the class' respond_to? returns true,
          # #send the variable name (so, you'll get the value of the instance variable's
          # getter), then save that to a Hash where [key] is the instance variable's name
          # and [value] is its value
          #
          # Finally, generate a JSON string from this hash
          instance_vars = instance_variables.map! { |var| var.to_s.gsub!(/^@/, '') }
          instance_as_hash =
              instance_vars.reduce({}) do |resulting_hash, instance_variable|
                if respond_to? instance_variable
                  value = send(instance_variable)

                  value = value.to_h if value.respond_to? :to_h unless value.is_a? Array
                  value = value.to_a if value.respond_to? :to_a unless value.is_a? Hash
                  if value.is_a? Array
                    value.map! {|x| x.respond_to?(:jsonify) ? JSON.parse(x.jsonify) : x }
                  end
                  value = value.jsonify if value.respond_to? :jsonify
                  resulting_hash[instance_variable] = value
                end
                resulting_hash
              end
          JSON.generate instance_as_hash
        end
      end
    end
  end
end

