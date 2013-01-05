require 'sinatra'

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  # TODO make this HAML
  @title = "hello"
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
%p
  Hello World!