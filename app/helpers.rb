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
      instance_variable_set(:"@#{variable}", Hashie::Mash.new(YAML.load_file(file)))
    end
  end

  def soft_hyphenate_content
    content = [@offerings, @people]
    content.each do |instance|
      instance.each { |key, value| recursively_modify_strings key, value }
    end
  end

  private
  def recursively_modify_strings(key, value)
    if   value.class == Hashie::Mash
      value.each do |key, value|
        recursively_modify_strings key, value
      end
    elsif value.class == String
      value = soft_hyphenate value
    end
  end

  def soft_hyphenate(string)
    hh = Text::Hyphen.new(:language => 'en_us', :left => 2, :right => 2)
    string.split(" ").map{ |word| hh.visualize(word, "&shy;") }.join(" ")
  end
end
