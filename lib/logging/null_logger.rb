module Logging
  class NullLogger
    [:error, :warn, :debug, :info, :fatal].each do |meth| 
      define_method meth do |message| 
        # NO OP
      end
    end
  end
end
