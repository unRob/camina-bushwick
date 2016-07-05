def chain(pool, set, direction)
  set = set.map(&:to_i)

  element = {
    head: set.first,
    tail: set.last,
  }[direction]

  next_set = pool.detect { |n| n.include? element }
  return set if next_set.nil?

  link_position = (next_set.index(element) + 1).to_f
  half = (next_set.count + 1).to_f / 2.0

  if (link_position < half)
    next_set = next_set.reverse if direction == :head
  elsif (link_position > half)
    next_set = next_set.reverse if direction == :tail
  else
    puts link_position, half
    raise 'WTF'
  end

  pool.delete(next_set)

  if direction == :head
    set.unshift(*next_set)
  elsif direction == :tail
    set.concat(next_set)
  end

  chain(pool, set.uniq, direction)
end