require 'sinatra'
require 'yaml'

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  # TODO make this HAML
  @title  = "hello"
  @beers = YAML.load_file('data/beer.yml')
  haml :index
end

get '/*' do
  redirect to('/')
end
__END__


# TODO put layout in its own file
@@ layout
%html
  %head
    %title
      = @title
    %style
      :sass
        /* TODO put styles in Sass-y stylesheet. */
        body
          background-color: #FAFAFA
          margin:           38px
        p
          padding:          0
          margin:           0
          font-family:      Helvetica, Arial, "Lucida Grande", sans-serif
        a
          color:            #33C
          text-decoration:  none
          &:visited
            color:          #339
  %body
    = yield

@@ index

-@beers.each do |beer|
  %h2= beer[1]["name"]
  %p=  beer[1]["description"]

%p below is the output of @beers["stout"]["description"]
= @beers["stout"]["description"]