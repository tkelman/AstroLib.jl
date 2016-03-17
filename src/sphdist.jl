# This file is a part of AstroLib.jl. License is MIT "Expat".
# Copyright (C) 2016 Mosè Giordano.

"""
    sphdist(long1, lat1, long2, lat2[, degrees=true]) -> Float64

### Purpose ###

Angular distance between points on a sphere.

### Arguments ###

* `long1`:  longitude of point 1
* `lat1`: latitude of point 1
* `long2`: longitude of point 2
* `lat2`: latitude of point 2
* `degrees` (optional boolean keyword): if `true`, all angles, including the
  output distance, are assumed to be in degrees, otherwise they are all in
  radians.  It defaults to `false`.

### Output ###

Angular distance on a sphere between points 1 and 2, as a `Float64`.  It is
expressed in radians unless `degrees` keyword is set to `true`.

### Notes ###

* `gcirc` function is similar to `sphdist`, but may be more suitable for
  astronomical applications.
* If `long1`, `lat1` are scalars, and `long2`, `lat2` are vectors, then the
 output is a vector giving the distance of each element of `long2`, `lat2` to
 `long1`, `lat1`.  Similarly, if `long1`,`de1` are vectors, and `long2`,` lat2`
 are scalars, then the output is a vector giving the distance of each element of
 `long1`, `lat1` to `long2`, `lat2`.  If both `long1`, `lat1` and `long2`,
 `lat2` are vectors then the output is a vector giving the distance of each
 element of `long1`, `lat1` to the corresponding element of `long2`, `lat2`.

Code of this function is based on IDL Astronomy User's Library.
"""
function sphdist(long1::Number, lat1::Number,
               long2::Number, lat2::Number; degrees::Bool=false)
    # Convert both points to rectangular coordinates.
    rxy, z1 = polrec(1.0, lat1,  degrees=degrees)
    x1, y1  = polrec(rxy, long1, degrees=degrees)
    rxy, z2 = polrec(1.0, lat2,  degrees=degrees)
    x2, y2  = polrec(rxy, long2, degrees=degrees)
    # Compute vector dot product for both points.
    cs = x1*x2 + y1*y2 + z1*z2
    # Compute the vector cross product for both points.
    xc = y1*z2 - z1*y2
    yc = z1*x2 - x1*z2
    zc = x1*y2 - y1*x2
    # Layman implementation of hypot(x,y,z).  Doesn't provide optimal
    # performance but it should be safer than "sqrt" in some cases.
    sn = hypot(xc, hypot(yc, zc))
    # Convert to polar coordinates.
    radius, angle = recpol(cs, sn)
    degrees ? (return rad2deg(angle)) : (return angle)
end

function sphdist{LO1<:Number, LA1<:Number}(long1::AbstractArray{LO1},
                                           lat1::AbstractArray{LA1},
                                           long2::Number,
                                           lat2::Number;
                                           degrees::Bool=false)
    @assert length(long1) == length(lat1)
    dist = similar(long1, Float64)
    for i in eachindex(long1)
        dist[i] = sphdist(long1[i], lat1[i], long2, lat2, degrees=degrees)
    end
    return dist
end

function sphdist{LO2<:Number, LA2<:Number}(long1::Number,
                                           lat1::Number,
                                           long2::AbstractArray{LO2},
                                           lat2::AbstractArray{LA2};
                                           degrees::Bool=false)
    @assert length(long2) == length(lat2)
    dist = similar(long2, Float64)
    for i in eachindex(long1)
        dist[i] = sphdist(long1, lat1, long2[i], lat2[i], degrees=degrees)
    end
    return dist
end

function sphdist{LO1<:Number, LA1<:Number, LO2<:Number, LA2<:Number}(long1::AbstractArray{LO1},
                                                                     lat1::AbstractArray{LA1},
                                                                     long2::AbstractArray{LO2},
                                                                     lat2::AbstractArray{LA2};
                                                                     degrees::Bool=false)
    @assert length(long1) == length(lat1) == length(long2) == length(lat2)
    dist = similar(long1, Float64)
    for i in eachindex(long1)
        dist[i] = sphdist(long1[i], lat1[i], long2[i], lat2[i], degrees=degrees)
    end
    return dist
end
