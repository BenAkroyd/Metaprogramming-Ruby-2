#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
class Pry
  class Command::Cat
    class ExceptionFormatter < AbstractFormatter
      attr_accessor :ex
      attr_accessor :opts
      attr_accessor :_pry_

      def initialize(exception, _pry_, opts)
        @ex = exception
        @opts = opts
        @_pry_ = _pry_
      end

      def format
        check_for_errors
        set_file_and_dir_locals(backtrace_file, _pry_, _pry_.current_context)
        code = decorate(Pry::Code.from_file(backtrace_file).
                                    between(*start_and_end_line_for_code_window).
                                    with_marker(backtrace_line)).to_s
        "#{header}#{code}"
      end

      private

      def code_window_size
        Pry.config.default_window_size || 5
      end

      def backtrace_level
        return @backtrace_level if @backtrace_level

        bl =  if opts[:ex].nil?
                ex.bt_index
              else
                ex.bt_index = absolute_index_number(opts[:ex], ex.backtrace.size)
              end

        increment_backtrace_level
        @backtrace_level = bl
      end

      def increment_backtrace_level
        ex.inc_bt_index
      end

      def backtrace_file
        file = Array(ex.bt_source_location_for(backtrace_level)).first
        (file && RbxPath.is_core_path?(file)) ? RbxPath.convert_path_to_full(file) : file
      end

      def backtrace_line
        Array(ex.bt_source_location_for(backtrace_level)).last
      end

      def check_for_errors
        raise CommandError, "No exception found." unless ex
        raise CommandError, "The given backtrace level is out of bounds." unless backtrace_file
      end

      def start_and_end_line_for_code_window
        start_line = backtrace_line - code_window_size
        start_line = 1 if start_line < 1

        [start_line, backtrace_line + code_window_size]
      end

      def header
        unindent %{
        #{Helpers::Text.bold 'Exception:'} #{ex.class}: #{ex.message}
        --
        #{Helpers::Text.bold('From:')} #{backtrace_file} @ line #{backtrace_line} @ #{Helpers::Text.bold("level: #{backtrace_level}")} of backtrace (of #{ex.backtrace.size - 1}).

      }
      end

    end
  end
end
