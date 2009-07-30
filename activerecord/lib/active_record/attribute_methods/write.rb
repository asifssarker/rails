module ActiveRecord
  module AttributeMethods
    module Write
      extend ActiveSupport::Concern

      included do
        attribute_method_suffix "="
      end

      module ClassMethods
        protected
          def define_attribute_method=(attr_name)
            evaluate_attribute_method attr_name, "def #{attr_name}=(new_value); write_attribute('#{attr_name}', new_value); end", "#{attr_name}="
          end
      end

      # Updates the attribute identified by <tt>attr_name</tt> with the specified +value+. Empty strings for fixnum and float
      # columns are turned into +nil+.
      def write_attribute(attr_name, value)
        attr_name = attr_name.to_s
        @attributes_cache.delete(attr_name)
        if (column = column_for_attribute(attr_name)) && column.number?
          @attributes[attr_name] = convert_number_column_value(value)
        else
          @attributes[attr_name] = value
        end
      end

      # Sets the primary ID.
      def id=(value)
        write_attribute(self.class.primary_key, value)
      end

      private
        # Handle *= for method_missing.
        def attribute=(attribute_name, value)
          write_attribute(attribute_name, value)
        end
    end
  end
end
