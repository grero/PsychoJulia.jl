using PsychoJulia
using GeometryTypes
using Random
using Test

@testset "States" begin
    fstate = PsychoJulia.FixationState(Rectangle(-10,-10,20,20),
                                       PsychoJulia.ClockTimer(time(), 5.0, false),Point2f0(0.0, 0.0))
    b =  PsychoJulia.is_inside(fstate, Point2f0(0.0, 0.0))
    @test b

    rstate = PsychoJulia.ResponseState(Rectangle(50.0,50.0, 20.0, 20.0),
                                       PsychoJulia.ClockTimer(time(), 5.0, false), Point2f0(0.0, 0.0))
    b = PsychoJulia.is_inside(rstate, Point2f0(51.0, 51.0))
    @test b

    estate = PsychoJulia.TrialEndState(PsychoJulia.ClockTimer(time(), 5.0, false))
    trans = PsychoJulia.StateTransitions([fstate, rstate, estate], [2 3 1;3 3 3], 1)
    done = false
    record = PsychoJulia.ExperimentRecord()
    ntrials = 0
    #basic experiment cycling through two correct trials
    PsychoJulia.reset!(fstate.clock)
    while !done
        state = trans.states[trans.current]
        aa = PsychoJulia.get_area(state)
        PsychoJulia.set_position!(state,Point2f0(aa.x + 1.0, aa.y+1.0))
        PsychoJulia.next!(trans, record)
        ntrials = 0
        for ee in record.event
            if occursin("-> 3", ee)
                ntrials += 1
            end
        end
        done = ntrials >= 2
    end
    @test record.event == ["1 -> 2", "2 -> 3", "3 -> 1", "1 -> 2", "2 -> 3"]

    dd = diff(record.timestamp)
    #check that we get the correct timestamps to whitin 1ms precision
    @test dd ≈ [5.0, 5.0, 5.0, 5.0] atol=0.001
end
