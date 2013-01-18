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
end