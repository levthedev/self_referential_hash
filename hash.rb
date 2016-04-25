class SelfHash < Hash
  def refer(tracker, tracked)
    self[tracker] = lambda { self[tracked] }            # => #<Proc:0x007facfb833970@/Users/levkravinsky/man.rb:3 (lambda)>
    instance_variable_set("@#{tracker}", :referential)  # => :referential
  end

  def [](key)
    clone = Hash[self.keys.zip(self.values)]                            # => {:a=>#<Proc:0x007facfb833970@/Users/levkravinsky/man.rb:3 (lambda)>, :b=>"baz", :z=>#<Proc:0x007facfb833c18@/Users/levkravinsky/man.rb:17>}, {:a=>#<Proc:0x007facfb833970@/Users/levkravinsky/man.rb:3 (lambda)>, :b=>"baz", :z=>#<Proc:0x007facfb833c18@/Users/levkravinsky/man.rb:17>}, {:a=>"x", :b=>"baz", :z=>#<Proc:0x007facfb833c18@/Users/levkravinsky/man.rb:17>}, {:a=>"x", :b=>"baz", :z=>#<Proc:0x007facfb833c18@/Users/levkravinsky/man.rb:17>}, {:a=>"x", :b=>"baz", :z=>#<Proc:0x007facfb833c18@/Users/levkravinsky/man.rb:17>}
    key_var = instance_variable_get("@#{key}")                          # => :referential, nil, :referential, nil, nil
    clone[key].class == Proc && key_var ? clone[key].call : clone[key]  # => "baz", "baz", "x", "baz", #<Proc:0x007facfb833c18@/Users/levkravinsky/man.rb:17>
  end
end

h = SelfHash.new     # => {}
h[:a] = "foo"        # => "foo"
h[:b] = "bar"        # => "bar"
h.refer :a, :b       # => :referential
h[:b] = "baz"        # => "baz"
h[:a]                # => "baz"
