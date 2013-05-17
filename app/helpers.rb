helpers do
  def find_template(views, name, engine, &block)
    # http://www.sinatrarb.com/intro#Looking%20Up%20Template%20Files
    _, folder = views.detect { |k,v| engine == Tilt[k] }
    folder ||= views[:default]
    super(folder, name, engine, &block)
  end

  def load_yaml_into_hashie_variables
    Dir.glob("data/*.yml").each do |file|
      variable = /data\/(.*).yml/.match(file)[1]
      yaml     = YAML.load_file file

      yaml.each_value { |value| modify_strings value }
      instance_variable_set(:"@#{variable}", Hashie::Mash.new(yaml))
    end
  end

  private
  def modify_strings(value)
    if    value.class == Hash   then value.each_value { |v| modify_strings v }
    elsif value.class == String then value.replace(soft_hyphenate value.to_s)
    end
  end

  def soft_hyphenate(string)
    if first_word(string).match(/\[.*\]/)
      string.split(" ")[1..-1].join(" ")
    else
      hh = Text::Hyphen.new(:language => 'en_us', :left => 2, :right => 2)
      string.split(" ").map{ |word| hh.visualize(word, "&shy;") }.join(" ")
    end
  end

  def first_word(string)
    string.split(" ")[0] ? string.split(" ")[0] : ""
  end
end
