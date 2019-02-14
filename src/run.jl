using ModernGL
using Makie

function run_experiment(escreen::PsychoScreen)
    #disable renderloop
    Makie.opengl_renderloop[] = (_screen)->nothing

    stop = false
    #sceen =  get the screen for the scene
    while !stop
        GLFW.PollEvents()
        Makie.render_frame(screen)
        GLFW.SwapBuffers(Makie.to_native(screen))
        glFinish()
    end
    Makie.opengl_renderloop[] = Makie.renderloop # restore previous loop
    Makie.destroy!(screen)
end
