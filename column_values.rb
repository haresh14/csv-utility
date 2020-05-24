
class ColumnValues

  def initialize(vals)
    @values = vals
  end

  def unique
    uniqueVals = []

    @values.each do |val|
      if uniqueVals.index(val) == nil
        uniqueVals << val
      end
    end

    return uniqueVals
  end

  def sum
    total = 0

    @values.each do |val|
      total += (val.to_f)
    end

    return total
  end

  def count
    return @values.length
  end

  def count_unique
    uniqueVals = unique

    return uniqueVals.length
  end

  def average
    if @values.length == 0
      return 0
    end

    return sum / @values.length
  end
end