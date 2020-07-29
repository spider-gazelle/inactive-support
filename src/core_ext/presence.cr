class Object
  # returns its receiver if it's not nil? or empty?
  def presence
    _self = self
    if _self.responds_to?(:empty?)
      _self if !_self.empty?
    else
      _self
    end
  end
end
