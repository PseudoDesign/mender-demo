PROJECT_NAME = "mender-demo"
ROOT_DIRECTORY = File.expand_path(File.dirname(__FILE__))
DOCKER_USER = "oe-user"
DOCKER_WORKDIR = "/app/oe"

def mkdir_f(dir)
    mkdir dir unless File.directory?(dir)
end

def docker_volume_string()
    # Returns a string with the docker volume arguments
    # host directory => container directory
    volumes = {
        # Map the current user's SSH keys to the client user's
        "~/.ssh" => "/home/#{DOCKER_USER}/.ssh",
        ROOT_DIRECTORY => DOCKER_WORKDIR
    }
    retval = ""
    volumes.each do |host, container|
        retval += "-v #{host}:#{container} "
    end
    return retval
end

def docker_run_command(command)
    # Execute the provided comlmand in the docker image, with appropriate mounting, secrets, etc
    run_string = "docker run --rm #{docker_volume_string} -it #{PROJECT_NAME}-build:latest /bin/bash -c \" export BITBAKEDIR=sources/poky/bitbake;  #{command} \""
    sh run_string
end

def source_command(build_name)
    # Generate the "source" command to initialize bitbake for the provided project
    "source sources/poky/oe-init-build-env #{build_name}-build"
end

def init_build(build_name)
    # Initialize a build in the "build_name" directory via the 'source' poky command
    docker_run_command(source_command(build_name))
end

def do_build(build_name, machine_name, bitbake_command)
    # Use a secondary "priv-local" file for variables not checked in to the repo
    priv_local_file = "#{build_name}-build/conf/priv-local.conf"
    `touch "#{priv_local_file}"`
    docker_run_command("#{source_command(build_name)}; MACHINE=#{machine_name} bitbake --postread='/app/oe/#{priv_local_file}' #{bitbake_command}")
end

desc "Build the Dockerfile as #{PROJECT_NAME}-build:latest"
task :docker do
    sh "docker build -t #{PROJECT_NAME}-build:latest #{ROOT_DIRECTORY}/docker"
end

desc "Run a shell in the Docker container at #{PROJECT_NAME}-build:latest with the appropriate project volumes mounted"
task :run_docker_shell => [:docker] do
    docker_run_command("/bin/bash")
end

namespace :debug do
    DEBUG = "debug"
    QEMU_MACHINE = "qemux86-64"

    desc "Initialize the #{DEBUG}-build directory (if it doesn't already exist)"
    task :init => [:docker] do
        init_build(DEBUG)
    end

    desc "Build the #{QEMU_MACHINE} debug image"
    task :build_qemu => [:docker] do
        do_build(DEBUG, "#{QEMU_MACHINE}", "core-image-minimal")
    end

    desc "Run the #{QEMU_MACHINE} debug image"
    task :run_qemu => [:docker] do
        docker_run_command("#{source_command("debug")}; MACHINE=#{QEMU_MACHINE} ../sources/meta-mender/meta-mender-qemu/scripts/mender-qemu core-image-minimal")
    end

    desc "Run bitbake 'bitbake_command' targeting 'machine'"
    task :bitbake, [:cmd, :machine] => [:docker] do |t, args|
        do_build(DEBUG, args[:machine], args[:cmd])
    end
end

namespace :rpi do
    RPI = "rpi"
    RPI4_MACHINE = "raspberrypi4-64"
    RPI_DEV_IMAGE = "pseudodesign-dev-image"

    desc "Initialize the #{RPI}-build directory (if it doesn't already exist)"
    task :init => [:docker] do
        init_build(RPI)
    end

    desc "Build the #{RPI4_MACHINE} debug image: #{RPI_DEV_IMAGE}"
    task :build_rpi4_dev => [:docker] do
        mender_artifact_name = ENV.fetch('MENDER_ARTIFACT_NAME',`echo "pseudodesign-dev-$(uname -n)-$(date +'%Y%m%d-%H%M%S')"`.strip)
        do_build(RPI, "#{RPI4_MACHINE}", "MENDER_ARTIFACT_NAME='#{mender_artifact_name}' #{RPI_DEV_IMAGE}")
    end

    desc "Cleans the #{RPI4_MACHINE} debug image: #{RPI_DEV_IMAGE}"
    task :clean_rpi4_dev => [:docker] do
        do_build(RPI, "#{RPI4_MACHINE}", "-c cleanall #{RPI_DEV_IMAGE}")
    end
end