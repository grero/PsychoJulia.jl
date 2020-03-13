module Visual
using GLFW
using Makie
using GeometryTypes

struct FakeMonitor
    distance::Float64
    resolution::Vec{2, Int64}
    widths::Vec{2, Float64}
end

get_physical_size(m::FakeMonitor) = m.widths
get_resolution(m::FakeMonitor) = m.resolution

get_physical_size(m::GLFW.Monitor) = GLFW.GetMonitorPhysicalSize(m)
get_resolution(m::GLFW.Monitor) = (vm = GLFW.GetVideoMode(m); Vec{2,Int64}([vm.width,vm.height]))

PsychoMonitor = Union{GLFW.Monitor, FakeMonitor}

struct PsychoScreen{T<:PsychoMonitor}
    scene
    monitor::T
    distance::Float64
end

PsychoSreen(scene, distance::Float64) = PsychoScreen(scene, GLFW.GetPrimaryMonitor(), distance)

get_widths(screen::PsychoScreen) = GLFW.GetMonitorPhysicalSize(screen.monitor)
get_resolution(screen::PsychoScreen) = GLFW.GetVideoMode(screen.monitor)

function mm2px(screen::PsychoScreen{T}, xy::Tuple{Float64, Float64}) where T <: PsychoMonitor
    widths = get_physical_size(screen.monitor)
    vm = get_resolution(screen.monitor)
    (xy[1]*vm[1]/widths[1], xy[2]*vm[2]/widths[2])
end

function deg2mm(screen::PsychoScreen{T}, deg::Vec{2,T2}; correctflat=false) where T2 <: Real where T <: PsychoMonitor
    d = screen.distance
    θ = deg2rad.(deg)
    if correctflat
        x = d*tan(θ[1])
        y = d*tan(θ[2])
        hy = sqrt(d*d + x*x)
        hx = sqrt(d*d + y*y)
        y = hy*tan(θ[2])
        x = hx*tan(θ[1])
        xy = Vec(x,y)
    else
        xy = θ.*d
        #xy = deg.*d*0.017453292519943295
    end
    xy
end

function deg2px(screen::PsychoScreen{T}, deg::Vec{2,T2};kvs...) where T2 <: Real where T <: PsychoMonitor
    x,y = deg2mm(screen,deg;kvs...)
    mm2px(screen, (x,y))
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
