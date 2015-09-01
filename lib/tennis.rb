require "sneakers"

module Tennis
  module Worker
    autoload :Deferable, "tennis/worker/deferable"
    autoload :Generic,   "tennis/worker/generic"
  end

  module Serializer
    autoload :Generic, "tennis/serializer/generic"
  end
end
