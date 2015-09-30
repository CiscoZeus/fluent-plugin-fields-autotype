class String
  def is_i?
    /\A[-+]?\d+\z/ === self
  end 
  def nan?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
  end    
end

module Fluent
  class OutputFieldsAutotype < Fluent::Output
    Fluent::Plugin.register_output('fields_autotype', self)

    config_param :remove_tag_prefix,  :string, :default => nil
    config_param :add_tag_prefix,     :string, :default => nil
    config_param :parse_key,          :string, :default => 'message'
    config_param :fields_key,         :string, :default => nil
    config_param :pattern,            :string,
                 :default => %{(\S+)=(\S+)}


    def compiled_pattern
      @compiled_pattern ||= Regexp.new(pattern)
    end

    def emit(tag, es, chain)
      tag = update_tag(tag)
      es.each { |time, record|
        Engine.emit(tag, time, parse_fields(record))
      }
      chain.next
    end

    def update_tag(tag)
      if remove_tag_prefix
        if remove_tag_prefix == tag
          tag = ''
        elsif tag.to_s.start_with?(remove_tag_prefix+'.')
          tag = tag[remove_tag_prefix.length+1 .. -1]
        end
      end
      if add_tag_prefix
        tag = tag && tag.length > 0 ? "#{add_tag_prefix}.#{tag}" : add_tag_prefix
      end
      return tag
    end

    def parse_fields(record)
      source = record[parse_key].to_s
      target = fields_key ? (record[fields_key] ||= {}) : record

      reduced_source = source.dup
      until reduced_source.length == 0 do
        match1 = reduced_source.match pattern
        key = match1[1].to_s
        val = match1[2].to_s
        if val.is_i?
          target[key] = val.to_i
        elsif val.nan?
          target[key] = val
        else
          target[key] = val.to_f
        end
        reduced_source = reduced_source[match1.offset(2)[1]..-1]
      end
      return record
    end
  end
end

