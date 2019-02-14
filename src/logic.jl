using GeometryTypes

abstract type TrialState end

mutable struct FixationState <: TrialState
    area::Rectangle
    clock::ClockTimer
    current_pos::Point2f0
end

mutable struct TargetState <: TrialState
    area::Rectangle
    clock::ClockTimer
    current_pos::Point2f0
end

mutable struct ResponseState <: TrialState
    area::Rectangle
    clock::ClockTimer
    current_pos::Point2f0
end

mutable struct TrialEndState <: TrialState
    clock::ClockTimer
end

mutable struct StateTransitions
    states::Vector{TrialState}
    edges::Matrix{Int64}
    current::Int64
end

mutable struct ExperimentRecord
    clock::Clock
    timestamp::Vector{Float64}
    event::Vector{String}
end

ExperimentRecord() = ExperimentRecord(Clock(), Float64[], String[])

function next!(tt::StateTransitions,engaged::Bool, record::ExperimentRecord)
    nn = tt.current 
    if engaged
        nn = tt.edges[1,tt.current]
    else
        nn = tt.edges[2, tt.current]
    end
    #log this event
    t1 = get_time(record.clock)
    push!(record.timestamp, t1)
    push!(record.event, "$(tt.current) -> $(nn)")
    #make sure we reset the clock
    reset!(tt.states[nn].clock)
    tt.current = nn
    tt.current
end

check_state(state::TrialState) = error("Not implemented")
next(state::TrialState, engaged::Bool) = error("Not implemented")
get_position(state::TrialState) = state.current_pos
get_area(state::TrialState) = state.area
get_area(state::TrialEndState) = Rectangle(-Inf32, -Inf32, Inf32, Inf32)

function set_position!(state::TrialState, pos::Point2f0)
    state.current_pos = pos
    nothing
end
set_position!(state::TrialEndState,pos::Point2f0) = nothing

function next!(transitions::StateTransitions, record::ExperimentRecord)
    state = transitions.states[transitions.current]
    b = check_state(state)
    #check if we are transitioning and if so to which state
    if b == 1
        next!(transitions, true, record)
    elseif b == 2
        next!(transitions, false, record)
    end
    nothing
end

"""
Check whether we should transition out of `state`. Returns 0 if we should stay in the same state, 1 if we should transition to the next valid state and 2 if we should transition to the next invalid state.
"""
function check_state(state::Union{FixationState,ResponseState})
    b = 0
    if is_inside(state)
        if is_done!(state.clock)
            b = 1 
        end
    else
        b = 2
    end
    b
end

function check_state(state::TrialEndState)
    b = 0
    if is_done!(state.clock)
        b = 1
    end
    b
end

function is_inside(state::TrialState)
    pos = get_position(state)
    is_inside(state, pos)
end

function is_inside(state::TrialState, pos::Point2f0)
    area = get_area(state)
    b = (area.x <= pos[1] <= area.x + area.w)
    b &= (area.y <= pos[2] <= area.y + area.h)
    return b
end
