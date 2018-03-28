__precompile__()
module JuliaSimulationServer
# import heavy libraries
using OrdinaryDiffEq
using Interpolations: interpolate, Gridded, Linear
using Calculus: derivative
using DataFrames
using CSV
using ConvectionBoxmodel
using ConvectionBoxmodel.ConvectionBoxmodelToolbox

function compute(x::Float64)
	@time x^2
end

function start()
	start(pwd())
end

function read_queue(path::String)
	f = open(path)
	lines = readlines(f)
	close(f)
	return lines
end

function clear_queue(path::String)
	f = open(path, "w")
	write(f, "")
	close(f)
end

function job_done(path::String)
	f = open(path, "w")
	write(f, "done")
	close(f)
end

function start(workspace::String)
	srv_queue_path = joinpath(workspace, "simulation_server_queue.jss")
	keywords = ["stop", "done"]
	touch(srv_queue_path)
	stop_server = false
	println("Simulation server up...")
	while ~stop_server
		watch_file(srv_queue_path)
		lines = read_queue(srv_queue_path)
		if length(lines) > 0
		   	stop_server = lines[1] == "stop"
		   	if ~(lines[1] in keywords)
		   		@time eval(parse(lines[1]))
		   		job_done(srv_queue_path)
		   	end
		end
	end
	sleep(1)
	clear_queue(srv_queue_path)
	println("Simulation server down")
end


end
