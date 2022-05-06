# LibHTS

require "./libhts/libhts"

# LibHTS2

module HTS
  module LibHTS2
    macro alias_method(new_name, old_name)
      def {{new_name.id}}(*args)
        LibHTS.{{old_name.id}}(*args)
      end
    end
  end
end

require "./libhts2/hfile"
require "./libhts2/bgzf"
require "./libhts2/sam"
require "./libhts2/vcf"
