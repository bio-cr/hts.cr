require "./libhts/libhts"

module HTS
  module LibHTS2
    macro alias_method(new_name, old_name)
      def {{new_name.id}}(*args)
        LibHTS.{{old_name.id}}(*args)
      end
    end
  end
end

require "./libhts/sam"
require "./libhts/vcf"
