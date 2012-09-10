require "rack"

class Panda
	attr_accessor :req, :res

	def initialize
		@req = nil
		@res = nil
	end

	def match(pattern)
		Route.new(pattern)
	end

	def call(env)
		@req = Rack::Request.new(env)
		@res = Rack::Response.new()

		routes = Route.get_routes(@req.request_method)
		unless routes
			@res.status = 404
			@res.write "Not Found"
			return @res.finish
		end

		path = @req.path_info
		vars = nil
		response = nil
		routes.each do |route|
			vars = route.match(path)
			if vars
				response = route.execute
				break
			end
		end

		unless vars
			@res.status = 404
			@res.write "Not Found"
			return @res.finish
		end

		@res.write response
		return @res.finish
	end
end

class Route
	@@routes = {}

	def initialize(pattern)
		@path_regex = compile_pattern(pattern)
		@callbacks = {}
	end

	def get(callback)		route 'GET', callback		end
	def post(callback)		route 'POST', callback		end
	def put(callback)		route 'PUT', callback		end
	def delete(callback)	route 'DELETE', callback	end
	def head(callback)		route 'HEAD', callback		end
	def options(callback)	route 'OPTIONS', callback	end
	def patch(callback)		route 'PATCH', callback		end

	def before(callback)	@before = callback			end
	def after(callback)		@after = callback			end

	def route(method, callback)
		@callbacks[method] = callback
		(@@routes[method] ||= []) << self
	end

	def compile_pattern(pattern)
		regex = /
			([^{]*)						# Match Everything Before Opening Brace
			\{([a-zA-Z0-9_]+)\}			# Match The Identifier Name
			([^{]*)						# Match Everything After Closing Brace, Till The Next Opening Brace
		/x

		path_regex = pattern.gsub(regex) do
			left = Regexp.escape($1)
			middle = $2
			right = Regexp.escape($3)
			"#{left}(?<#{middle}>[^/]*)#{right}"
		end

		Regexp.compile('^' + path_regex + '$')
	end

	def match(path)
		if path =~ @path_regex
			vars = {}
			@path_regex.names.each do |key|
				vars[key] = $~[key]
			end
			return vars
		else
			return nil
		end
	end

	def self.get_routes(method)
		@@routes[method]
	end
end