Panda - Ruby Web Framework
==========================
Panda is a very simple ruby web framework consisting of only a router.

Example:
```ruby
# This is file app.rb
$app = Panda.new

$app.get('/first') do
	"First Page"
end

$app.get('/hello/{name}') do
	"Hello #{vars[name]}"
end

$app.get('/blog/{category}/{post_id}') do
	"Accessing Blog Post Id: #{vars[post_id]} In Category: #{vars[category]}"
end
```
```ruby
# This is file config.ru
require 'app'
run $app
```