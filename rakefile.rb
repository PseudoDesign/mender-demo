PROJECT_NAME = "mender-demo"
ROOT_DIRECTORY = File.expand_path(File.dirname(__FILE__))

def mkdir_f(dir)
    mkdir dir unless File.directory?(dir)
end

desc "Build the Dockerfile as #{PROJECT_NAME}-build:latest"
task :docker do
    sh "docker build -t #{PROJECT_NAME}-build:latest #{ROOT_DIRECTORY}"
end

