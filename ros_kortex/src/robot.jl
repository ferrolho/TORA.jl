struct Robot
    urdfpath::String
    mechanism::Mechanism
    state::MechanismState
    statecache::StateCache
    dynamicsresultcache::DynamicsResultCache
    mvis::MechanismVisualizer

    q_lo::Array{Float64}
    q_hi::Array{Float64}
    v_lo::Array{Float64}
    v_hi::Array{Float64}
    τ_lo::Array{Float64}
    τ_hi::Array{Float64}

    n_q::Int64  # Number of generalized coordinates
    n_v::Int64  # Number of generalized velocities
    n_τ::Int64  # Number of actuated joints

    frame_ee::CartesianFrame3D  # End-effector frame

    function Robot(urdfpath::String,
                   mechanism::Mechanism,
                   frame_ee::CartesianFrame3D,
                   mvis::MechanismVisualizer)
        state = MechanismState(mechanism)
        statecache = StateCache(mechanism)
        dynamicsresultcache = DynamicsResultCache(mechanism)

        q_lo = [lim for joint in joints(mechanism) for lim in map(x -> x.lower, position_bounds(joint))]
        q_hi = [lim for joint in joints(mechanism) for lim in map(x -> x.upper, position_bounds(joint))]
        v_lo = [lim for joint in joints(mechanism) for lim in map(x -> x.lower, velocity_bounds(joint))]
        v_hi = [lim for joint in joints(mechanism) for lim in map(x -> x.upper, velocity_bounds(joint))]
        τ_lo = [lim for joint in joints(mechanism) for lim in map(x -> x.lower,   effort_bounds(joint))]
        τ_hi = [lim for joint in joints(mechanism) for lim in map(x -> x.upper,   effort_bounds(joint))]

        new(
            urdfpath,
            mechanism,
            state,
            statecache,
            dynamicsresultcache,
            mvis,
            q_lo,
            q_hi,
            v_lo,
            v_hi,
            τ_lo,
            τ_hi,
            num_positions(mechanism),
            num_velocities(mechanism),
            num_velocities(mechanism),
            frame_ee
        )
    end
end

function create_robot_kuka_iiwa_14(vis::Visualizer)
    package_path = joinpath(@__DIR__, "..", "iiwa_stack")
    urdfpath = joinpath(@__DIR__, "..", "robots", "iiwa14.urdf")

    mechanism = parse_urdf(urdfpath, remove_fixed_tree_joints=false)
    frame_ee = default_frame(findbody(mechanism, "iiwa_link_pen_tip"))
    remove_fixed_tree_joints!(mechanism)

    urdfvisuals = URDFVisuals(urdfpath, package_path=[package_path])
    mvis = MechanismVisualizer(mechanism, urdfvisuals, vis["robot"])
    # setelement!(mvis, frame_ee)  # Visualise a triad at the end-effector

    Robot(urdfpath, mechanism, frame_ee, mvis)
end