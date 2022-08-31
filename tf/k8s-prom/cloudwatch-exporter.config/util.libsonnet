{
  map(a, f):: std.map(f, a),
  flatMap(a, f):: std.map(f, a),

  product2(xy, ys)::
    std.flatMap(function(x) std.map(function(y) x + y, ys), xy),

  product(xss)::
    std.foldl($.product2, xss, [{}]),
}
