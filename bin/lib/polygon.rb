class Polygon
  def initialize points
    @points = points
  end

  def contains_point?(lat, lng)
    contains_point = false
    i = -1
    j = @points.size - 1
    while (i += 1) < @points.size
      starts = @points[i]
      ends = @points[j]
      if inside_ys?(starts, ends, lat) && crosses_segment?(starts, ends, lng, lat)
        contains_point = !contains_point
      end
      j = i
    end
    contains_point
  end

  private

  def inside_ys?(starts, ends, lat)
    (starts[0] <= lat && lat < ends[0]) ||
    (ends[0] <= lat && lat < starts[0])
  end

  def crosses_segment?(starts, ends, lon, lat)
    (lon < (ends[1] - starts[1]) * (lat - starts[0]) /
    (ends[0] - starts[0]) + starts[1])
  end
end