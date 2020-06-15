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
    docker_run_command("#{source_command(build_name)}; MACHINE=#{machine_name} bitbake #{bitbake_command}")
end

desc "Build the Dockerfile as #{PROJECT_NAME}-build:latest"
task :docker do
    sh "docker build -t #{PROJECT_NAME}-build:latest #{ROOT_DIRECTORY}"
end

namespace :debug do
    DEBUG = "debug"
    desc "Initialize the #{DEBUG}-build directory (if it doesn't already exist)"
    task :init => [:docker] do
        init_build(DEBUG)
    end

    desc "Build the qemux86-64 debug image"
    task :build_qemu => [:docker] do
        do_build(DEBUG, "qemux86-64", "core-image-minimal")
    end

    desc "Run bitbake 'bitbake_command' targeting 'machine'"
    task :bitbake, [:cmd, :machine] => [:docker] do |t, args|
        do_build(DEBUG, args[:machine], args[:cmd])
    end
end

namespace :release do
    RELEASE = "release"
    desc "Initialize the #{RELEASE}-build directory (if it doesn't already exist)"
    task :init, [:docker] do
        init_build(RELEASE)
    end
end