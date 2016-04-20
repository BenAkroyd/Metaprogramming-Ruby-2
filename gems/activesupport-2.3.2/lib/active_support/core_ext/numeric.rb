#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/numeric/bytes'
require 'active_support/core_ext/numeric/conversions'

class Numeric #:nodoc:
  include ActiveSupport::CoreExtensions::Numeric::Time 
  include ActiveSupport::CoreExtensions::Numeric::Bytes
  include ActiveSupport::CoreExtensions::Numeric::Conversions 
end
