abstract type AbstractClock end

mutable struct Clock <: AbstractClock
    t0::Float64
end

mutable struct ClockTimer <: AbstractClock
    t0::Float64
    t1::Float64
    done::Bool
end

ClockTimer() = Clock(time(), Inf, false)
Clock() = Clock(time())

get_time(c::AbstractClock) = time() - c.t0
set_time!(c::AbstractClock, t0) = (c.t0 = t0)
reset!(c::AbstractClock) = set_time!(c, time())
set_endtime!(c::ClockTimer, t1) = (c.t1 = t1)

function get_time!(c::ClockTimer)
    t1 = time() - c.t0
    if t1 >= c.t1
        c.done = true
    end
    t1
end

function reset!(c::ClockTimer)
    c.t0 = time()
    c.done = false
end

function is_done!(c::ClockTimer)
    get_time!(c)
    c.done
end
