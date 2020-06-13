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

def source_build(build_name)
    # Initialize a build in the "build_name" directory via the 'source' poky command
    run_string = "docker run --rm " + docker_volume_string + "-it #{PROJECT_NAME}-build:latest /bin/bash -c \" export BITBAKEDIR=sources/poky/bitbake; source sources/poky/oe-init-build-env #{build_name}-build\""
    sh run_string
end

desc "Build the Dockerfile as #{PROJECT_NAME}-build:latest"
task :docker do
    sh "docker build -t #{PROJECT_NAME}-build:latest #{ROOT_DIRECTORY}"
end


namespace :qemux86_64 do
    desc "Initialize the qemu86-64-build directory (if it doesn't already exist)"
    task :init, [:docker] do
        source_build("qemu86-64")
    end
end