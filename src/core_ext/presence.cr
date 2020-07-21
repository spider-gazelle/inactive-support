class Object
  # returns its receiver if it's not nil? or empty?
  def present?
    _self = self
    if _self.responds_to?(:empty?)
      _self if !_self.empty?
    else
      _self if !nil?
    end
  end
end

# a special case to return `nil` if a String only contains whitespace
class String
  def present?
    self if !blank?
  end
end
