# attendee-gate - Ticketholder validation api

## Source

https://github.com/ruby-no-kai/rubykaigi-net-apps/tree/main/attendee-gate

## Usage

```ruby
require 'httpx'
require 'base64'
require 'openssl'

BASE_URL = ENV.fetch('BASE_URL')
HASH_KEY = ENV.fetch('HASH_KEY')
HASH_ALG = 'sha384'

def validate(email:, code:)
  HTTPX.post(
    "#{BASE_URL}/validate",
    form: {
      email_hashed: Base64.urlsafe_encode64(OpenSSL::HMAC.digest(HASH_ALG, HASH_KEY, email)),
      code:,
    },
  ).tap(&:raise_for_status).json
end


p validate(email: 'attendee@test.invalid', code: 'ABCD-1')
#=> {"meta"=>{"db"=>{"epoch"=>1, "finger"=>"...", "created_at"=>1741285189}}, "result"=>"ok",
#    "ticket"=>{"release"=>"Attendee"}}

p validate(email: 'unexist@test.invalid', code: 'TEST-1')
#=> {"meta"=>{"db"=>{"epoch"=>1, "finger"=>"...", "created_at"=>1741285189}}, "result"=>"not_found"}
p validate(email: 'partial@test.invalid', code: 'TEST-1')
#=> {"meta"=>{"db"=>{"epoch"=>1, "finger"=>"...", "created_at"=>1741285189}}, "result"=>"code_mismatch"}
p validate(email: 'unexist@test.invalid', code: 'ABCD-1')
#=> {"meta"=>{"db"=>{"epoch"=>1, "finger"=>"...", "created_at"=>1741285189}}, "result"=>"email_mismatch"}
```
