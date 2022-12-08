#!/usr/bin/env ruby
=begin
```
data "external" "example" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./program.jsonnet"
    # or
    input = "{jsonnet: 'program'}"
  }
}

# => data.external.example.result.json
```
=end

require 'json'
require 'tempfile'

query = JSON.load($stdin)

Tempfile.open do |output|
  if path = query['path']
    exit $?.to_i unless system('jsonnet', path, out: output)
  else
    Tempfile.open do |input|
      input.write(query.fetch('input'))

      exit $?.to_i unless system('jsonnet', '-', in: input.tap(&:rewind), out: output)
    end
  end

  puts JSON.dump(json: output.tap(&:rewind).read)
end
