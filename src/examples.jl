using PsychoJulia
using GLFW
using ModernGL
using AbstractPlotting, Makie
using GeometryTypes
using GLMakie
include(joinpath(@__DIR__, "visual.jl"))
"""

Sets up a basic fixation task where the fixation stays on until the subject has fixated for at least 500 ms, then disappears
"""
function basic_fixation()
    screen = Visual.get_screen((800,600), 54)
    Visual.draw_circle(screen, Point2f0(400,300), 40.0f0,"red")
    push!(screen.scene.plots[1][:visible], false)

    fstate = PsychoJulia.FixationState(Rectangle(-10,-10,20,20),
                                       PsychoJulia.ClockTimer(time(), 1.500, false),Point2f0(0.0, 0.0))

    estate = PsychoJulia.TrialEndState(PsychoJulia.ClockTimer(time(), 1.5, false))
    trans = PsychoJulia.StateTransitions([fstate, estate], [1,-1], [[1], [2]], [2 1;2 2], 1)
    done = false
    record = PsychoJulia.ExperimentRecord()
    ntrials = 0
    #basic experiment cycling through two correct trials
    #TODO: This should use screen instead
    display(screen.scene)
    glscreen = GLMakie.global_gl_screen()
    function close_screen()
        #reset the render loop
        GLMakie.opengl_renderloop[] = GLMakie.renderloop
        GLMakie.destroy!(GLMakie.to_native(glscreen))
    end
    GLMakie.opengl_renderloop[] = (screen)->nothing
    PsychoJulia.reset!(fstate.clock)
    while !done
        GLFW.PollEvents()
        #check for keys
        key_pressed = false
        if key_pressed
           done = true
        end
        state = trans.states[trans.current]
        aa = PsychoJulia.get_area(state)
        PsychoJulia.set_position!(state,Point2f0(aa.x + 1.0, aa.y+1.0))
        PsychoJulia.next!(trans, record, screen.scene)
        ntrials = 0
        for ee in record.event
            if occursin("-> 2", ee)
                ntrials += 1
            end
        end
        done = done | ntrials >= 10
        GLMakie.render_frame(glscreen)
        GLFW.SwapBuffers(GLMakie.to_native(glscreen))
        glFinish()
    end
    close_screen()

    #check that we get the correct timestamps to whitin 1ms precision
    record
end
