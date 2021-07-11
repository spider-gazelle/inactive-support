class Hash(K, V)
  def self.with_default(initial_capacity : Int32? = nil, &block : -> V) : Hash(K, V)
    Hash(K, V).new(initial_capacity: initial_capacity) do |hash, key|
      hash[key] = block.call
    end
  end

  def self.with_default(default : V, initial_capacity : Int32? = nil) : Hash(K, V)
    with_default(initial_capacity: initial_capacity) { default }
  end
end
