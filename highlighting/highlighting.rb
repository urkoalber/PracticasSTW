require 'sinatra'
require 'syntaxi'

class String
  def formatted_body(opc)
    source = "[code lang= #{opc}]
                #{self}
              [/code]"
    html = Syntaxi.new(source).process
    %Q{
      <div class="syntax syntax_#{opc.delete("'")}">
        #{html}
      </div>
    }
  end
end

get '/' do
  erb :new
end

post '/' do
  @formatted_text = params[:body].formatted_body(params[:opc])
  erb :show
end

