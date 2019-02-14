module Visual
using GLFW
using Makie
using GeometryTypes

struct PsychoScreen
    scene
    monitor::GLFW.Monitor
    distance::Float64
end

PsychoSreen(scene, distance::Float64) = PsychoScreen(scene, GLFW.GetPrimaryMonitor(), distance)

function px2deg(screen::PsychoScreen, px)
    widths = GLFW.GetMonitorPhysicalSize(screen.monitor)
    r = sqrt(widths[1]^2 + widths[2]^2)
    dg = r/screen.distance
    vm = GLFW.GetVideoMode(screen.monitor)
    dpx = sqrt(vm.height^2 + vm.width^2)
    px*dg/dpx
end

function get_screen(resolution, distance, monitor=GLFW.GetPrimaryMonitor())
    scene = Scene(resolution=resolution,raw=true, show_axis=false)
    campixel!(scene)
    PsychoScreen(scene, monitor, distance)
end

function draw_circle(screen::PsychoScreen, pos::Point2f0, radius::Float32, color="black")
    points = decompose(Point2f0, Sphere(pos,radius))
    draw_poly(screen, points, color)
    nothing
end

function draw_square(screen::PsychoScreen, pos::Point2f0, width::Float32, color="black")
    points = [pos, pos + Point2f0(width, 0.0), pos + Point2f0(width, width), pos + Point2f0(0.0, width), pos]
    draw_poly(screen, points, color)
    nothing
end

function draw_poly(screen, points::AbstractVector{Point2f0}, color)
    poly!(screen.scene, points, show_axis=false, raw=true, color=color)
end

#Makie.opengl_renderloop[] = (screen)-> begin
#    GLFW.PollEvents()
#    Makie.render_frame(screen)
#    GLFW.SwapBuffers(Makie.to_native(screen))
#    glFinish()
#end

end# module
