# Introducing app-routes gem 0.1.17

    require 'app-routes'

    class Fun
      include AppRoutes

      def initialize()
        super()
        params = {}
        routes(@params)
      end

      def routes(params) 

        get '/sugar' do 
          'ffff'
        end

        get '/sour' do 
          'gggg'
        end

        get '/hello/:name' do
          'zzzz ... hello ' + params[:name]
        end

        get %r{/hello2/([\w]+)} do
          'ready ' + params[:captures].first
        end

        get '/addresses' do
          'inside addresses 2'
        end

        post '/addresses' do
          'inside addresses'
        end

      end


    end

    fun = Fun.new

    fun.run_route '/sour'
    #=>  "gggg"

    fun.run_route '/hello/James'
    #=> "zzzz ... hello James"

    fun.add_route '/hello3/:name' do |name|
      'welcome ' + name
    end

    fun.run_route '/hello3/James'
    #=> "welcome James"

    fun.run_route '/addresses', 'POST'
    #=> "inside addresses" 

    fun.run_route '/addresses'
    #=> "inside addresses 2"


## Resources

* [jrobertson/app-routes](https://github.com/jrobertson/app-routes)

gem approutes route routes
