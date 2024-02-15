module Fields = struct
  module Field_dsl = struct
    module Aggregations = struct
      let any _t = 2

    end
  end

  include Field_dsl
end
