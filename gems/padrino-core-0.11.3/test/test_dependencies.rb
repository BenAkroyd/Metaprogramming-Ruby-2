#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
require File.expand_path(File.dirname(__FILE__) + '/helper')

describe "Dependencies" do
  context 'when we require a dependency that have another dependency' do

    should 'raise an error without reloading it twice' do
      capture_io do
        assert_raises(RuntimeError) do
          Padrino.require_dependencies(
            Padrino.root("fixtures/dependencies/a.rb"),
            Padrino.root("fixtures/dependencies/b.rb"),
            Padrino.root("fixtures/dependencies/c.rb"),
            Padrino.root("fixtures/dependencies/d.rb")
          )
        end
      end
      assert_equal 1, D
    end

    should 'resolve dependency problems' do
      capture_io do
        Padrino.require_dependencies(
          Padrino.root("fixtures/dependencies/a.rb"),
          Padrino.root("fixtures/dependencies/b.rb"),
          Padrino.root("fixtures/dependencies/c.rb")
        )
      end
      assert_equal ["B", "C"], A_result
      assert_equal "C", B_result
    end

    should 'remove partially loaded constants' do
      capture_io do
        Padrino.require_dependencies(
          Padrino.root("fixtures/dependencies/circular/e.rb"),
          Padrino.root("fixtures/dependencies/circular/f.rb"),
          Padrino.root("fixtures/dependencies/circular/g.rb")
        )
      end

      assert_equal ["name"], F.fields
    end
  end
end
